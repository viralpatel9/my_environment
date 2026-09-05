#!/usr/bin/env bash
# ==============================================================================
#  my_environment — portable Linux dev environment installer
#  Bash + Neovim (C/C++ IntelliSense) + Nerd Fonts + history autosuggestions
#
#  Usage:
#     ./install.sh                 # full install
#     ./install.sh --minimal       # no fonts, no debugger, no extras
#     ./install.sh --dry-run       # print what would happen
#     ./install.sh --help
# ==============================================================================
set -Eeuo pipefail

# ------------------------------------------------------------------ constants
readonly ENV_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly STATE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/my_environment"
readonly BACKUP_DIR="$STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)"
readonly LOCAL_BIN="$HOME/.local/bin"
readonly FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
readonly NVIM_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

NERD_FONT_VERSION="${NERD_FONT_VERSION:-v3.4.0}"
NERD_FONTS="${NERD_FONTS:-JetBrainsMono FiraCode}"
NVIM_VERSION="${NVIM_VERSION:-stable}"
NVIM_MIN_MAJOR=0
NVIM_MIN_MINOR=11

# ------------------------------------------------------------------- switches
DO_FONTS=1
DO_NVIM=1
DO_BLE=1
DO_PLUGINS=1
DO_EXTRAS=1
DO_CLAUDE=1
DRY_RUN=0
ASSUME_YES=0

# --------------------------------------------------------------------- output
if [[ -t 1 ]] && [[ "${TERM:-dumb}" != "dumb" ]]; then
  C_RST=$'\033[0m'; C_R=$'\033[31m'; C_G=$'\033[32m'; C_Y=$'\033[33m'
  C_B=$'\033[34m'; C_M=$'\033[35m'; C_C=$'\033[36m'; C_D=$'\033[2m'; C_BD=$'\033[1m'
else
  C_RST=''; C_R=''; C_G=''; C_Y=''; C_B=''; C_M=''; C_C=''; C_D=''; C_BD=''
fi

step()  { printf '\n%s==>%s %s%s%s\n' "$C_B$C_BD" "$C_RST" "$C_BD" "$*" "$C_RST"; }
info()  { printf '    %s·%s %s\n' "$C_D" "$C_RST" "$*"; }
ok()    { printf '    %s✓%s %s\n' "$C_G" "$C_RST" "$*"; }
warn()  { printf '    %s!%s %s\n' "$C_Y" "$C_RST" "$*" >&2; }
die()   { printf '\n%s✗ %s%s\n' "$C_R$C_BD" "$*" "$C_RST" >&2; exit 1; }

run() {
  if (( DRY_RUN )); then printf '    %s$ %s%s\n' "$C_D" "$*" "$C_RST"; return 0; fi
  "$@"
}

trap 'die "failed at line $LINENO: ${BASH_COMMAND}"' ERR

usage() {
  sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  cat <<'EOF'

Options:
  --minimal      Skip fonts, extra CLI tools and the DAP debugger
  --no-fonts     Do not download/install Nerd Fonts
  --no-nvim      Do not install/upgrade the Neovim binary (config is still linked)
  --no-ble       Do not install ble.sh (fish-like history autosuggestions)
  --no-plugins   Do not bootstrap Neovim plugins headlessly
  --no-claude    Do not install the Claude Code CLI
  --dry-run      Show the commands without executing them
  -y, --yes      Never prompt
  -h, --help     This help

Environment overrides:
  NERD_FONTS="JetBrainsMono FiraCode"   Fonts to install
  NVIM_VERSION="stable"                  Neovim release tag (e.g. v0.11.3)
EOF
}

while (( $# )); do
  case "$1" in
    --minimal)    DO_FONTS=0; DO_EXTRAS=0 ;;
    --no-fonts)   DO_FONTS=0 ;;
    --no-nvim)    DO_NVIM=0 ;;
    --no-ble)     DO_BLE=0 ;;
    --no-plugins) DO_PLUGINS=0 ;;
    --no-claude)  DO_CLAUDE=0 ;;
    --dry-run)    DRY_RUN=1 ;;
    -y|--yes)     ASSUME_YES=1 ;;
    -h|--help)    usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

# ================================================================ 0. platform
have() { command -v "$1" >/dev/null 2>&1; }

detect_platform() {
  step "Detecting platform"
  OS="$(uname -s)"
  [[ "$OS" == "Linux" ]] || die "this installer targets Linux (found: $OS)"

  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64|amd64)  NVIM_ARCH="linux-x86_64" ;;
    aarch64|arm64) NVIM_ARCH="linux-arm64" ;;
    *) warn "unrecognised arch '$ARCH'; Neovim binary install will be skipped"; DO_NVIM=0; NVIM_ARCH="" ;;
  esac

  DISTRO_ID="unknown"; DISTRO_NAME="unknown"
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"; DISTRO_NAME="${PRETTY_NAME:-$DISTRO_ID}"
  fi

  for mgr in apt-get dnf pacman zypper apk; do
    if have "$mgr"; then PKG_MGR="$mgr"; break; fi
  done
  PKG_MGR="${PKG_MGR:-none}"

  SUDO=""
  if [[ $EUID -ne 0 ]]; then
    if have sudo; then SUDO="sudo"; else warn "no sudo and not root — system packages will be skipped"; PKG_MGR="none"; fi
  fi

  ok "$DISTRO_NAME ($ARCH), package manager: $PKG_MGR"
}

# ======================================================== 1. system packages
# Canonical name -> per-distro package name. Empty value = not packaged there.
pkg_for() {
  local want="$1"
  case "$PKG_MGR:$want" in
    apt-get:build)      echo "build-essential" ;;
    dnf:build)          echo "gcc gcc-c++ make" ;;
    pacman:build)       echo "base-devel" ;;
    zypper:build)       echo "gcc gcc-c++ make" ;;
    apk:build)          echo "build-base" ;;

    apt-get:fd)         echo "fd-find" ;;
    dnf:fd)             echo "fd-find" ;;
    *:fd)               echo "fd" ;;

    apt-get:bat)        echo "bat" ;;
    *:bat)              echo "bat" ;;

    apt-get:clangd)     echo "clangd clang-format clang-tidy" ;;
    dnf:clangd)         echo "clang-tools-extra" ;;
    pacman:clangd)      echo "clang" ;;
    zypper:clangd)      echo "clang-tools" ;;
    apk:clangd)         echo "clang-extra-tools" ;;

    apt-get:python)     echo "python3 python3-venv python3-pip" ;;
    *:python)           echo "python3 python-pip" ;;

    *:*)                echo "$want" ;;
  esac
}

pkg_install() {
  local pkgs=("$@")
  (( ${#pkgs[@]} )) || return 0
  case "$PKG_MGR" in
    apt-get) run $SUDO apt-get install -y --no-install-recommends "${pkgs[@]}" ;;
    dnf)     run $SUDO dnf install -y "${pkgs[@]}" ;;
    pacman)  run $SUDO pacman -S --needed --noconfirm "${pkgs[@]}" ;;
    zypper)  run $SUDO zypper install -y "${pkgs[@]}" ;;
    apk)     run $SUDO apk add --no-cache "${pkgs[@]}" ;;
    none)    warn "skipping packages: ${pkgs[*]}" ;;
  esac
}

install_system_packages() {
  step "Installing system packages"
  [[ "$PKG_MGR" == "none" ]] && { warn "no package manager available — install deps manually (see README)"; return 0; }

  [[ "$PKG_MGR" == "apt-get" ]] && run $SUDO apt-get update -qq

  local core=(git curl wget unzip tar ca-certificates)
  local dev=(cmake gdb make pkg-config)
  local cli=(ripgrep fzf tree jq htop)

  local wanted=("${core[@]}" "${dev[@]}")
  (( DO_EXTRAS )) && wanted+=("${cli[@]}")

  local resolved=()
  local w
  for w in build clangd python "${wanted[@]}"; do
    # shellcheck disable=SC2206
    local expanded=( $(pkg_for "$w") )
    resolved+=("${expanded[@]}")
  done
  (( DO_EXTRAS )) && { local x; for x in fd bat; do local e; e="$(pkg_for "$x")"; resolved+=("$e"); done; }

  info "packages: ${resolved[*]}"
  # Install one at a time so a single unavailable package cannot abort the run.
  local p
  for p in "${resolved[@]}"; do
    if (( DRY_RUN )); then
      pkg_install "$p"
    else
      pkg_install "$p" >/dev/null 2>&1 || warn "could not install '$p' (skipped)"
    fi
  done
  ok "system packages done"
}

# =============================================================== 2. local bin
ensure_local_bin() {
  step "Preparing ~/.local/bin"
  run mkdir -p "$LOCAL_BIN" "$STATE_DIR"
  # Debian renames these binaries; create the conventional names.
  if have fdfind && ! have fd; then run ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"; ok "shim: fd -> fdfind"; fi
  if have batcat && ! have bat; then run ln -sf "$(command -v batcat)" "$LOCAL_BIN/bat"; ok "shim: bat -> batcat"; fi
  ok "$LOCAL_BIN ready"
}

# ================================================================ 3. neovim
nvim_version_ok() {
  have nvim || return 1
  local v major minor
  v="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)" || return 1
  major="${v%%.*}"; minor="${v#*.}"; minor="${minor%%.*}"
  (( major > NVIM_MIN_MAJOR )) && return 0
  (( major == NVIM_MIN_MAJOR && minor >= NVIM_MIN_MINOR ))
}

install_neovim() {
  step "Installing Neovim ($NVIM_VERSION)"
  if (( ! DO_NVIM )); then info "skipped (--no-nvim)"; return 0; fi

  if nvim_version_ok && [[ "${FORCE_NVIM:-0}" != "1" ]]; then
    ok "Neovim $(nvim --version | head -1 | awk '{print $2}') already satisfies >= 0.$NVIM_MIN_MINOR"
    return 0
  fi

  local prefix="$STATE_DIR/neovim"
  local tmp; tmp="$(mktemp -d)"
  local base="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION"

  local tarball="nvim-$NVIM_ARCH.tar.gz"
  info "downloading $tarball"
  if ! run curl -fsSL --retry 3 -o "$tmp/nvim.tar.gz" "$base/$tarball"; then
    # Releases before v0.10.4 used the old naming scheme.
    warn "falling back to legacy asset name"
    run curl -fsSL --retry 3 -o "$tmp/nvim.tar.gz" "$base/nvim-linux64.tar.gz" \
      || { rm -rf "$tmp"; warn "download failed — keeping existing Neovim"; return 0; }
  fi

  run rm -rf "$prefix"
  run mkdir -p "$prefix"
  run tar -xzf "$tmp/nvim.tar.gz" -C "$prefix" --strip-components=1
  run rm -rf "$tmp"
  run ln -sf "$prefix/bin/nvim" "$LOCAL_BIN/nvim"
  ok "Neovim installed to $prefix (linked into $LOCAL_BIN)"
}

# ============================================================== 4. nerd fonts
install_fonts() {
  step "Installing Nerd Fonts"
  if (( ! DO_FONTS )); then info "skipped"; return 0; fi

  run mkdir -p "$FONT_DIR"
  local font tmp changed=0
  for font in $NERD_FONTS; do
    if compgen -G "$FONT_DIR/${font}NerdFont*" >/dev/null 2>&1; then
      ok "$font Nerd Font already present"
      continue
    fi
    tmp="$(mktemp -d)"
    info "downloading $font ($NERD_FONT_VERSION)"
    if run curl -fsSL --retry 3 -o "$tmp/$font.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONT_VERSION/$font.zip"; then
      run unzip -qo "$tmp/$font.zip" -d "$FONT_DIR" -x 'LICENSE*' 'README*' '*.md' || true
      changed=1
      ok "$font installed"
    else
      warn "could not download $font"
    fi
    run rm -rf "$tmp"
  done

  if (( changed )) && have fc-cache; then
    run fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true
    ok "font cache rebuilt"
  fi
  info "Set your terminal font to e.g. 'JetBrainsMono Nerd Font Mono'"
}

# ============================================== 5. ble.sh (autosuggestions)
install_blesh() {
  step "Installing ble.sh (history autosuggestions)"
  if (( ! DO_BLE )); then info "skipped (--no-ble)"; return 0; fi

  local dest="${XDG_DATA_HOME:-$HOME/.local/share}/blesh"
  if [[ -r "$dest/ble.sh" ]] && [[ "${FORCE_BLE:-0}" != "1" ]]; then
    ok "ble.sh already installed"
    return 0
  fi
  have git make || { warn "git/make missing — skipping ble.sh"; return 0; }

  local tmp; tmp="$(mktemp -d)"
  if run git clone --recursive --depth 1 --shallow-submodules \
        https://github.com/akinomyoga/ble.sh.git "$tmp/ble.sh" >/dev/null 2>&1; then
    run make -C "$tmp/ble.sh" install PREFIX="$HOME/.local" >/dev/null 2>&1 \
      && ok "ble.sh installed to $dest" \
      || warn "ble.sh build failed (bash fallback autosuggestions will be used)"
  else
    warn "could not clone ble.sh (bash fallback autosuggestions will be used)"
  fi
  run rm -rf "$tmp"
}

# ============================================== 6. optional extra CLI tools
install_extras() {
  step "Installing extra CLI tools"
  if (( ! DO_EXTRAS )); then info "skipped (--minimal)"; return 0; fi

  if ! have zoxide; then
    info "zoxide (smarter cd)"
    run bash -c 'curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- --bin-dir "$HOME/.local/bin"' \
      >/dev/null 2>&1 && ok "zoxide installed" || warn "zoxide install skipped"
  else ok "zoxide present"; fi

  if ! have fzf; then
    info "fzf (fuzzy finder)"
    if run git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" >/dev/null 2>&1; then
      run "$HOME/.fzf/install" --bin >/dev/null 2>&1 && run ln -sf "$HOME/.fzf/bin/fzf" "$LOCAL_BIN/fzf"
      ok "fzf installed"
    else warn "fzf install skipped"; fi
  else ok "fzf present"; fi
}

# ============================================== 6b. Claude Code CLI ========
install_claude_code() {
  step "Installing the Claude Code CLI"
  if (( ! DO_CLAUDE )); then info "skipped (--no-claude)"; return 0; fi

  if have claude && [[ "${FORCE_CLAUDE:-0}" != "1" ]]; then
    ok "Claude Code already installed ($(claude --version 2>/dev/null || echo "version unknown"))"
    return 0
  fi
  have curl || { warn "curl is required to install Claude Code — skipped"; return 0; }

  # Native installer: no Node/npm dependency, self-updating, lands at
  # ~/.local/bin/claude — already on PATH via bash/env.sh. This is also what
  # the Neovim integration (plugins/claude.lua) expects to find.
  info "downloading the native installer (claude.ai/install.sh)"
  if run bash -c 'curl -fsSL https://claude.ai/install.sh | bash'; then
    ok "Claude Code installed"
  else
    warn "Claude Code install failed — install manually later: https://claude.ai/install.sh"
  fi
}

# ================================================================ 7. linking
backup_and_link() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    [[ "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]] && { ok "$dst already linked"; return 0; }
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    run mkdir -p "$BACKUP_DIR"
    run mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
    info "backed up $dst -> $BACKUP_DIR/"
  fi
  run mkdir -p "$(dirname "$dst")"
  run ln -sfn "$src" "$dst"
  ok "linked $dst"
}

link_configs() {
  step "Linking configuration"

  backup_and_link "$ENV_ROOT/nvim" "$NVIM_CFG"
  backup_and_link "$ENV_ROOT/config/inputrc" "$HOME/.inputrc"

  run mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/clangd"
  backup_and_link "$ENV_ROOT/config/clangd.yaml" "${XDG_CONFIG_HOME:-$HOME/.config}/clangd/config.yaml"

  # Global clang-format only if the user has no project-level one already.
  [[ -e "$HOME/.clang-format" ]] || run ln -sfn "$ENV_ROOT/config/clang-format" "$HOME/.clang-format"

  # ~/.bashrc keeps whatever it had; we append a single guarded source line.
  local marker="# >>> my_environment >>>"
  local rc="$HOME/.bashrc"
  run touch "$rc"
  if grep -qF "$marker" "$rc" 2>/dev/null; then
    ok "~/.bashrc hook already present"
  else
    if (( DRY_RUN )); then
      info "would append my_environment hook to $rc"
    else
      mkdir -p "$BACKUP_DIR"
      cp "$rc" "$BACKUP_DIR/bashrc" 2>/dev/null || true
      {
        printf '\n%s\n' "$marker"
        printf '# Managed by my_environment (%s). Remove this block to uninstall.\n' "$ENV_ROOT"
        printf 'export MY_ENV_ROOT="%s"\n' "$ENV_ROOT"
        printf '[ -f "$MY_ENV_ROOT/bash/bashrc" ] && . "$MY_ENV_ROOT/bash/bashrc"\n'
        printf '# <<< my_environment <<<\n'
      } >> "$rc"
      ok "hooked into ~/.bashrc"
    fi
  fi
}

# ====================================================== 8. neovim bootstrap
bootstrap_plugins() {
  step "Bootstrapping Neovim plugins"
  if (( ! DO_PLUGINS )); then info "skipped (--no-plugins)"; return 0; fi
  if (( DRY_RUN )); then info "would run: nvim --headless '+Lazy! sync' +qa"; return 0; fi

  local nvim_bin="$LOCAL_BIN/nvim"
  [[ -x "$nvim_bin" ]] || nvim_bin="$(command -v nvim || true)"
  [[ -x "$nvim_bin" ]] || { warn "no nvim binary found — run ':Lazy sync' manually"; return 0; }

  info "this downloads plugins and can take a minute…"
  if "$nvim_bin" --headless "+Lazy! sync" +qa 2>&1 | tail -5; then
    ok "plugins installed"
  else
    warn "plugin sync reported errors — open nvim and run :Lazy"
  fi

  info "installing treesitter parsers for C/C++"
  "$nvim_bin" --headless "+TSUpdateSync c cpp lua vim vimdoc query bash markdown" +qa >/dev/null 2>&1 \
    || warn "treesitter sync deferred to first launch"
}

# ==================================================================== 9. done
summary() {
  step "Done"
  cat <<EOF

  ${C_G}${C_BD}my_environment is installed.${C_RST}

  ${C_BD}Next steps${C_RST}
    1. ${C_C}exec bash${C_RST}                     reload your shell
    2. Set your terminal font to ${C_C}JetBrainsMono Nerd Font Mono${C_RST}
    3. ${C_C}claude${C_RST}                        log in (opens a browser once)
    4. ${C_C}nvim${C_RST}                          first launch finishes LSP setup
    5. ${C_C}envhelp${C_RST}                       shell cheatsheet
       ${C_C}<Space>?${C_RST} inside nvim         keybinding cheatsheet
       ${C_C}<Space>ac${C_RST} inside nvim        Claude Code in a right-hand split

  ${C_BD}C/C++ IntelliSense${C_RST}
    clangd needs a ${C_C}compile_commands.json${C_RST}. Generate one with:
      cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && ln -sf build/compile_commands.json .
      # or, for Makefile projects:  bear -- make
    A fallback ${C_C}.clangd${C_RST} config is applied so single files still work.

  ${C_BD}Backups${C_RST}   $BACKUP_DIR
  ${C_BD}Uninstall${C_RST} $ENV_ROOT/uninstall.sh

EOF
}

# ======================================================================= main
main() {
  printf '%s\n' "$C_M$C_BD"
  cat <<'BANNER'
   __  __         ______
  |  \/  |_   _  |  ____|_ ____   __
  | |\/| | | | | | |__  | '_ \ \ / /
  | |  | | |_| | |  __| | | | \ V /
  |_|  |_|\__, | |_|    |_| |_|\_/
          |___/   bash · neovim · C/C++
BANNER
  printf '%s\n' "$C_RST"

  (( DRY_RUN )) && warn "DRY RUN — nothing will be modified"

  detect_platform
  install_system_packages
  ensure_local_bin
  install_neovim
  install_fonts
  install_blesh
  install_extras
  install_claude_code
  link_configs
  bootstrap_plugins
  summary
}

main "$@"
