-- ---------------------------------------------------------------- icons.lua --
-- Every Nerd Font glyph used by this config, written as \u{XXXX} escapes.
--
-- Pasted glyph literals get mangled by editors, terminals and copy-paste; the
-- escapes always survive. Codepoints below are Powerline (e0a0-e0b3), Font
-- Awesome (f000-f2ff) and codicons (ea60-ec1e) — the three ranges every Nerd
-- Font build includes.
--
-- If you see boxes (tofu) instead of icons, your *terminal* font is not a
-- Nerd Font yet. Set MY_ENV_ASCII=1 in the shell for a plain-text prompt, and
-- pick "JetBrainsMono Nerd Font Mono" in your terminal preferences.

return {
  -- diagnostics (codicons)
  diagnostics = {
    error = "\u{ea87}", --
    warn  = "\u{ea6c}", --
    info  = "\u{ea74}", --
    hint  = "\u{ea61}", --  lightbulb
  },

  -- powerline
  sep = {
    right_solid = "\u{e0b0}", --
    left_solid  = "\u{e0b2}", --
    branch      = "\u{e0a0}", --
  },

  -- font awesome
  fa = {
    search   = "\u{f002}",
    folder   = "\u{f07b}",
    file     = "\u{f15b}",
    history  = "\u{f1da}",
    gear     = "\u{f013}",
    wrench   = "\u{f0ad}",
    question = "\u{f059}",
    power    = "\u{f011}",
    rocket   = "\u{f135}",
    lock     = "\u{f023}",
    terminal = "\u{f120}",
    bug      = "\u{f188}",
  },

  -- git signs: plain Unicode, so they render without a Nerd Font too
  git = {
    add    = "▎",
    change = "▎",
    delete = "▁",
    top    = "▔",
  },

  fold = { open = "▾", closed = "▸" },
}
