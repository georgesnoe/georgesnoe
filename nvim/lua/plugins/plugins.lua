return {
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = { "dart" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = true,
  },

  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "bundled_build.lua",
    config = function()
      require("mcphub").setup({
        use_bundled_binary = true,
      })
    end,
  },

  {
    "olimorris/codecompanion.nvim",
    opts = {
      extensions = {
        spinner = {},
        history = {
          enabled = true,
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

  {
    "mgierada/lazydocker.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      require("lazydocker").setup({
        border = "single",
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

  {
    "georgesnoe/lazygithub.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      require("lazygithub").setup({
        border = "single",
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

  {
    "georgesnoe/lazykube.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      require("lazykube").setup({
        border = "single",
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

  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_general_viewer = "atril"
      vim.g.vimtex_imaps_enabled = 0
      vim.g.vimtex_complete_enabled = 0
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
  },

  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
   ____                                                    
  / __,\  __,  _   __   ,_    __,  _   ,   _  _    __   _  
 | /  | |/  | |/  /  \_/  |  /  | |/  / \_/ |/ |  /  \_|/  
 | \_/|/ \_/|/|__/\__/    |_/\_/|/|__/ \/   |  |_/\__/ |__/
  \____/   /|                  /|                          
           \|                  \|                          ]],
        },
      },
    },
  },
}
