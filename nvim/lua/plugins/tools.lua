-- --------------------------------------------------------------- tools.lua --
-- Terminal, debugger, project runner, and the which-key legend.

return {
  -- ============================================================ terminal ===
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { [[<C-\>]], desc = "Toggle terminal" },
      { "<leader>tf", desc = "Floating terminal" },
      { "<leader>th", desc = "Horizontal terminal" },
      { "<leader>tv", desc = "Vertical terminal" },
      { "<leader>tg", desc = "LazyGit" },
      { "<leader>tp", desc = "Python REPL" },
    },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
      float_opts = { border = "rounded", winblend = 0 },
      shade_terminals = false,
      start_in_insert = true,
      persist_size = true,
      size = function(term)
        if term.direction == "horizontal" then return 15 end
        if term.direction == "vertical" then return vim.o.columns * 0.4 end
        return 20
      end,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      local Terminal = require("toggleterm.terminal").Terminal

      local function factory(cmd, direction)
        local t = Terminal:new({ cmd = cmd, direction = direction or "float", hidden = true,
                                 float_opts = { border = "rounded" } })
        return function() t:toggle() end
      end

      local map = vim.keymap.set
      map("n", "<leader>tf", factory(nil, "float"), { desc = "Floating terminal" })
      map("n", "<leader>th", factory(nil, "horizontal"), { desc = "Horizontal terminal" })
      map("n", "<leader>tv", factory(nil, "vertical"), { desc = "Vertical terminal" })
      if vim.fn.executable("lazygit") == 1 then
        map("n", "<leader>tg", factory("lazygit"), { desc = "LazyGit" })
      end
      if vim.fn.executable("python3") == 1 then
        map("n", "<leader>tp", factory("python3"), { desc = "Python REPL" })
      end
    end,
  },

  -- ============================================================ debugger ===
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
      "mason-org/mason.nvim",
      { "jay-babu/mason-nvim-dap.nvim", opts = { ensure_installed = { "codelldb" }, automatic_installation = true } },
    },
    keys = {
      { "<F5>",  function() require("dap").continue() end, desc = "Debug: start/continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
        desc = "Conditional breakpoint",
      },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last debug session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
      {
        "<leader>de",
        function() require("dapui").eval(nil, { enter = true }) end,
        mode = { "n", "v" },
        desc = "Evaluate expression",
      },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.35 },
              { id = "breakpoints", size = 0.15 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 44,
            position = "left",
          },
          { elements = { { id = "repl", size = 0.5 }, { id = "console", size = 0.5 } },
            size = 12, position = "bottom" },
        },
        floating = { border = "rounded" },
      })

      require("nvim-dap-virtual-text").setup({ commented = true })

      -- Open/close the UI with the session.
      dap.listeners.before.attach.dapui_config = dapui.open
      dap.listeners.before.launch.dapui_config = dapui.open
      dap.listeners.before.event_terminated.dapui_config = dapui.close
      dap.listeners.before.event_exited.dapui_config = dapui.close

      -- Nicer breakpoint signs.
      vim.fn.sign_define("DapBreakpoint",
        { text = "●", texthl = "DiagnosticError", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition",
        { text = "◆", texthl = "DiagnosticWarn", numhl = "" })
      vim.fn.sign_define("DapStopped",
        { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual", numhl = "" })

      -- ---------------------------------------------------- C/C++ adapter
      -- mason installs codelldb; this points dap at it wherever it landed.
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
      if vim.fn.executable(mason_bin) == 1 or vim.fn.executable("codelldb") == 1 then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = vim.fn.executable(mason_bin) == 1 and mason_bin or "codelldb",
            args = { "--port", "${port}" },
          },
        }
      end

      local cpp_config = {
        {
          name = "Launch (prompt for binary)",
          type = "codelldb",
          request = "launch",
          program = function()
            -- Default to a build/ directory, which is where cc-db puts things.
            local default = vim.fn.getcwd() .. "/build/"
            return vim.fn.input("Path to executable: ", default, "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = function()
            local input = vim.fn.input("Arguments: ")
            return vim.split(input, " ", { trimempty = true })
          end,
          runInTerminal = false,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }

      dap.configurations.cpp = cpp_config
      dap.configurations.c = cpp_config
      dap.configurations.rust = cpp_config
    end,
  },

  -- ========================================================== which-key ===
  -- The discoverable half of the cheatsheet: press <Space> and wait.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 350,
      icons = { mappings = true, rules = false },
      spec = {
        { "<leader>a", group = "claude" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code / C++" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>o", group = "options / toggles" },
        { "<leader>s", group = "split / substitute" },
        { "<leader>t", group = "terminal" },
        { "<leader>x", group = "diagnostics" },
        { "<leader><Tab>", group = "tabs" },
        { "<leader>?", desc = "Cheatsheet" },
        { "[", group = "previous …" },
        { "]", group = "next …" },
        { "g", group = "goto" },
        { "z", group = "fold / view" },
      },
    },
    keys = {
      {
        "<leader>K",
        function() require("which-key").show({ global = true }) end,
        desc = "All keymaps (which-key)",
      },
    },
  },

  -- ==================================================== session restore ===
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>Ss", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>Sl", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>Sd", function() require("persistence").stop() end, desc = "Don't save this session" },
    },
  },

  -- ================================================= project-wide search ==
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = { headerMaxWidth = 80 },
    keys = {
      {
        "<leader>sR",
        function()
          require("grug-far").open({ transient = true, prefills = { paths = vim.fn.expand("%") } })
        end,
        mode = { "n", "v" },
        desc = "Search & replace (project)",
      },
    },
  },
}
