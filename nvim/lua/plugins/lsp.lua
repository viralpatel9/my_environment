-- ----------------------------------------------------------------- lsp.lua --
-- C/C++ IntelliSense via clangd, plus Lua/CMake/Python for good measure.
--
-- clangd gets its knowledge of your build from `compile_commands.json`.
-- Generate one with the shell helper `cc-db`, or:
--     cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
--     bear -- make            # for plain Makefiles
-- For loose single files, a `compile_flags.txt` (see `cc-flags`) is enough.

return {
  -- =================================== install servers/formatters/DAP ====
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    keys = { { "<leader>cM", "<cmd>Mason<CR>", desc = "Mason (LSP installer)" } },
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
    },
    config = function()
      -- ------------------------------------------------------ capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink then capabilities = blink.get_lsp_capabilities(capabilities) end
      -- clangd streams huge completion lists; let it know we can take them.
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.offsetEncoding = { "utf-16" }

      -- --------------------------------------------------------- on_attach
      local function on_attach(client, bufnr)
        local function m(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = "LSP: " .. desc })
        end

        m("n", "K", vim.lsp.buf.hover, "Hover documentation")
        m("n", "gd", vim.lsp.buf.definition, "Go to definition")
        m("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        m("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        m("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
        m("n", "gr", vim.lsp.buf.references, "References")
        m("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
        m("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        m({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        m("n", "<leader>cl", vim.lsp.codelens.run, "Run code lens")

        -- Inlay hints: parameter names and deduced types, inline.
        if client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          m("n", "<leader>ci", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
          end, "Toggle inlay hints")
        end

        -- Breadcrumbs in the statusline.
        if client:supports_method("textDocument/documentSymbol") then
          local ok_navic, navic = pcall(require, "nvim-navic")
          if ok_navic then navic.attach(client, bufnr) end
        end

        -- Highlight the symbol under the cursor after a short pause.
        if client:supports_method("textDocument/documentHighlight") then
          local g = vim.api.nvim_create_augroup("my_env_lsp_hl_" .. bufnr, { clear = true })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = g, buffer = bufnr, callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = g, buffer = bufnr, callback = vim.lsp.buf.clear_references,
          })
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("my_env_lsp_attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client then on_attach(client, ev.buf) end
        end,
      })

      -- ------------------------------------------------------ server config
      -- Neovim 0.11+ API: vim.lsp.config() layers on top of the defaults that
      -- nvim-lspconfig ships, then vim.lsp.enable() turns the server on.
      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",              -- index the project in the background
          "--clang-tidy",                    -- lint as you type
          "--completion-style=detailed",
          "--header-insertion=iwyu",         -- add #includes automatically
          "--header-insertion-decorators",
          "--function-arg-placeholders",     -- fill argument names on completion
          "--fallback-style=llvm",
          "--all-scopes-completion",
          "--pch-storage=memory",            -- faster, at the cost of RAM
          "-j=4",
          "--offset-encoding=utf-16",        -- must match capabilities above
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
        -- Look upward for a build description so clangd finds the right root.
        root_markers = {
          ".clangd", ".clang-tidy", ".clang-format",
          "compile_commands.json", "compile_flags.txt",
          "CMakeLists.txt", "Makefile", "meson.build", "build/compile_commands.json",
          "configure.ac", ".git",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      })

      vim.lsp.config("neocmake", {})

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
            hint = { enable = true },
          },
        },
      })

      vim.lsp.config("basedpyright", {
        settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
      })

      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "lua_ls", "neocmake" },
        automatic_enable = true,
      })

      -- If clangd came from the distro rather than Mason, enable it anyway.
      if vim.fn.executable("clangd") == 1 then vim.lsp.enable("clangd") end
      vim.lsp.enable("lua_ls")
    end,
  },

  -- ==================================================== extra clangd UX ===
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    keys = {
      { "<leader>cs", "<cmd>ClangdSymbolInfo<CR>", desc = "Symbol info (clangd)" },
      { "<leader>ct", "<cmd>ClangdTypeHierarchy<CR>", desc = "Type hierarchy" },
      { "<leader>cA", "<cmd>ClangdAST<CR>", desc = "Show AST" },
    },
    -- AST role/kind icons stay at the plugin's defaults.
    opts = { inlay_hints = { inline = false } },
  },

  -- ========================================================= formatting ===
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
      {
        "<leader>cF",
        function() vim.g.my_env_autoformat = not vim.g.my_env_autoformat end,
        desc = "Toggle format-on-save",
      },
    },
    init = function()
      vim.g.my_env_autoformat = true
    end,
    opts = {
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        cuda = { "clang_format" },
        lua = { "stylua" },
        python = { "ruff_format" },
        sh = { "shfmt" },
        json = { "jq" },
        cmake = { "cmake_format" },
      },
      -- Only reformats when a config exists, so it never fights a project style.
      formatters = {
        clang_format = {
          prepend_args = function(_, ctx)
            local found = vim.fs.find({ ".clang-format", "_clang-format" }, {
              upward = true, path = ctx.dirname, type = "file",
            })
            if #found > 0 then return {} end
            return { "--style={BasedOnStyle: LLVM, IndentWidth: 4, ColumnLimit: 100}" }
          end,
        },
        shfmt = { prepend_args = { "-i", "4", "-ci" } },
      },
      format_on_save = function(bufnr)
        if not vim.g.my_env_autoformat then return end
        -- Never reformat someone else's tree wholesale.
        if vim.bo[bufnr].filetype == "" then return end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
    },
  },

  -- ====================================================== diagnostics UI ==
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { focus = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (project)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Diagnostics (buffer)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<CR>", desc = "Symbol outline" },
      { "<leader>xl", "<cmd>Trouble lsp toggle win.position=right<CR>", desc = "LSP references/defs" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list" },
      { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "TODO list" },
    },
  },

  -- ============================================ TODO / FIXME highlighting =
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
  },
}
