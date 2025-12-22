return {
  -- Flutter tools
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = { "dart" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = true,
  },

  -- Roslyn
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    dependencies = {
      {
        -- By loading as a dependencies, we ensure that we are available to set
        -- the handlers for Roslyn.
        "tris203/rzls.nvim",
        config = true,
      },
    },
    config = function()
      -- Use one of the methods in the Integration section to compose the command.
      local mason_registry = require("mason-registry")

      local rzls_path = vim.fn.expand("$MASON/packages/rzls/libexec")
      local cmd = {
        "roslyn",
        "--stdio",
        "--logLevel=Information",
        "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
        "--razorSourceGenerator=" .. vim.fs.joinpath(rzls_path, "Microsoft.CodeAnalysis.Razor.Compiler.dll"),
        "--razorDesignTimePath=" .. vim.fs.joinpath(rzls_path, "Targets", "Microsoft.NET.Sdk.Razor.DesignTime.targets"),
        "--extension",
        vim.fs.joinpath(rzls_path, "RazorExtension", "Microsoft.VisualStudioCode.RazorExtension.dll"),
      }

      vim.lsp.config("roslyn", {
        cmd = cmd,
        handlers = require("rzls.roslyn_handlers"),
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,

            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          },
        },
      })
      vim.lsp.enable("roslyn")
    end,
    init = function()
      -- We add the Razor file types before the plugin loads.
      vim.filetype.add({
        extension = {
          razor = "razor",
          cshtml = "razor",
        },
      })
    end,
  },

  -- Mcphub
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "bundled_build.lua", -- Bundles `mcp-hub` binary along with the neovim plugin
    config = function()
      require("mcphub").setup({
        use_bundled_binary = true, -- Use local `mcp-hub` binary
      })
    end,
  },

  -- Code companion
  {
    "olimorris/codecompanion.nvim",
    -- tag = "v17.33.0", -- pin to a specific version
    opts = {
      extensions = {
        spinner = {},
        history = {
          enabled = true, -- defaults to true
          opts = {
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion_chats.json",
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "franco-ruggeri/codecompanion-spinner.nvim",
      "ravitemer/codecompanion-history.nvim",
    },
    keys = {
      { "cc", "<cmd>CodeCompanionChat Toggle<CR>", desc = "Toggle CodeCompanion" },
      { "ca", "<cmd>CodeCompanionActions<CR>", desc = "CodeCompanion Actions" },
    },
  },

  -- lazydocker.nvim
  {
    "mgierada/lazydocker.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      require("lazydocker").setup({
        border = "single", -- valid options are "single" | "double" | "shadow" | "curved"
      })
    end,
    event = "VeryLazy",
    keys = {
      {
        "<leader>ld",
        function()
          require("lazydocker").open()
        end,
        desc = "Open Lazydocker floating window",
      },
    },
  },

  -- Image
  -- {
  --   "3rd/image.nvim",
  --   build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
  --   opts = {
  --     processor = "magick_cli",
  --   },
  -- },

  -- Imgclip
  {
    "HakonHarnes/img-clip.nvim",
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    },
  },

  -- Lazygithub.nvim
  {
    "georgesnoe/lazygithub.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      require("lazygithub").setup({
        border = "single", -- valid options are "single" | "double" | "shadow" | "curved"
      })
    end,
    event = "VeryLazy",
    keys = {
      {
        "<leader>lg",
        function()
          require("lazygithub").open()
        end,
        desc = "Open Lazygithub",
      },
    },
  },

  -- Lazykube.nvim
  {
    "georgesnoe/lazykube.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      require("lazykube").setup({
        border = "single", -- valid options are "single" | "double" | "shadow" | "curved"
      })
    end,
    event = "VeryLazy",
    keys = {
      {
        "<leader>lk",
        function()
          require("lazykube").open()
        end,
        desc = "Open Lazykube",
      },
    },
  },

  -- Vimtex
  {
    "lervag/vimtex",
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = "zathura"
    end,
  },

  -- Catppuccin
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, event = "VeryLazy" },
}
