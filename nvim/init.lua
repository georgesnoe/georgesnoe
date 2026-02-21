if vim.g.neovide then
  vim.g.neovide_refresh_rate = 30
  vim.g.neovide_refresh_rate_idle = 5
  vim.g.neovide_no_idle = true
  vim.g.neovide_confirm_quit = true
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_profiler = false
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_cursor_smooth_blink = false
  vim.g.neovide_cursor_vfx_mode = "railgun"

  ---@param scale_factor number
  ---@return number
  local function clamp_scale_factor(scale_factor)
    return math.max(math.min(scale_factor, vim.g.neovide_max_scale_factor), vim.g.neovide_min_scale_factor)
  end

  ---@param scale_factor number
  ---@param clamp? boolean
  local function set_scale_factor(scale_factor, clamp)
    vim.g.neovide_scale_factor = clamp and clamp_scale_factor(scale_factor) or scale_factor
  end

  local function reset_scale_factor()
    vim.g.neovide_scale_factor = vim.g.neovide_initial_scale_factor
  end

  ---@param increment number
  ---@param clamp? boolean
  local function change_scale_factor(increment, clamp)
    set_scale_factor(vim.g.neovide_scale_factor + increment, clamp)
  end

  vim.g.neovide_increment_scale_factor = vim.g.neovide_increment_scale_factor or 0.1
  vim.g.neovide_min_scale_factor = vim.g.neovide_min_scale_factor or 0.7
  vim.g.neovide_max_scale_factor = vim.g.neovide_max_scale_factor or 2.0
  vim.g.neovide_initial_scale_factor = vim.g.neovide_scale_factor or 1
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor or 1

  vim.api.nvim_create_user_command("NeovideSetScaleFactor", function(event)
    local scale_factor, option = tonumber(event.fargs[1]), event.fargs[2]

    if not scale_factor then
      vim.notify(
        "Error: scale factor argument is nil or not a valid number.",
        vim.log.levels.ERROR,
        { title = "Recipe: neovide" }
      )
      return
    end

    set_scale_factor(scale_factor, option ~= "force")
  end, { nargs = "+" })

  vim.api.nvim_create_user_command(
    "NeovideResetScaleFactor",
    reset_scale_factor,
    { desc = "Reset Neovide scale factor" }
  )

  vim.api.nvim_create_user_command("NeovideIncreaseScaleFactor", function()
    change_scale_factor(vim.g.neovide_increment_scale_factor * vim.v.count1, true)
  end, { desc = "Increase Neovide scale factor" })

  vim.api.nvim_create_user_command("NeovideDecreaseScaleFactor", function()
    change_scale_factor(-vim.g.neovide_increment_scale_factor * vim.v.count1, true)
  end, { desc = "Decrease Neovide scale factor" })

  vim.api.nvim_create_user_command(
    "NeovideResetScaleFactor",
    reset_scale_factor,
    { desc = "Reset Neovide scale factor" }
  )

  vim.keymap.set("n", "<C-=>", function()
    change_scale_factor(vim.g.neovide_increment_scale_factor * vim.v.count1, true)
  end, { desc = "Increase Neovide scale factor" })

  vim.keymap.set("n", "<C-->", function()
    change_scale_factor(-vim.g.neovide_increment_scale_factor * vim.v.count1, true)
  end, { desc = "Decrease Neovide scale factor" })

  vim.keymap.set("n", "<C-0>", reset_scale_factor, { desc = "Reset Neovide scale factor" })
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.cmd("colorscheme tokyonight-day")

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.arb",
  command = "setfiletype json",
})

require("blink-cmp").setup({
  sources = {
    per_filetype = {
      codecompanion = { "codecompanion" },
    },
  },
  signature = {
    enabled = true,
  },
  fuzzy = { implementation = "rust" },
  term = {
    completion = {
      ghost_text = {
        enabled = function()
          return true
        end,
      },
    },
  },
})

require("codecompanion").setup({
  interactions = {
    inline = {
      keymaps = {
        accept_change = {
          modes = { n = "a" },
          description = "Accept the suggested change",
        },
        reject_change = {
          modes = { n = "r" },
          opts = { nowait = true },
          description = "Reject the suggested change",
        },
      },
      adapter = {
        name = "githubmodels",
        model = "DeepSeek-R1",
      },
    },
    chat = {
      adapter = "gemini_cli",
      -- adapter = {
      --   name = "githubmodels",
      --   model = "DeepSeek-R1",
      -- },
    },
    cmd = {
      adapter = {
        name = "githubmodels",
        model = "DeepSeek-R1",
      },
    },
    backgrounds = {
      adapter = {
        name = "githubmodels",
        model = "DeepSeek-R1",
      },
    },
  },
  display = {
    inline = {
      layout = "vertical",
    },
  },
  memory = {
    opts = {
      chat = {
        enabled = true,
      },
    },
  },
  adapters = {
    acp = {
      gemini_cli = function()
        return require("codecompanion.adapters").extend("gemini_cli", {
          commands = {
            default = {
              "gemini",
              "--experimental-acp",
            },
          },
          defaults = {
            auth_method = "oauth-personal",
            timeout = 600000, -- 10 minutes
          },
        })
      end,
    },
  },
  extensions = {
    mcphub = {
      callback = "mcphub.extensions.codecompanion",
      opts = {
        make_tools = true,
        show_server_tools_in_chat = true,
        add_mcp_prefix_to_tool_names = false,
        show_result_in_chat = true,
        format_tool = nil,
        make_vars = true,
        make_slash_commands = true,
      },
    },
  },
})

require("mcphub").setup({
  auto_approve = function(params)
    if vim.g.codecompanion_auto_tool_mode == true then
      return true
    end

    if params.server_name == "github" and params.tool_name == "get_issue" then
      return true
    end

    if params.arguments.repo == "private" then
      return "You can't access my private repo"
    end

    if params.tool_name == "read_file" then
      local path = params.arguments.path or ""
      if path:match("^" .. vim.fn.getcwd()) then
        return true
      end
    end

    if params.is_auto_approved_in_server then
      return true
    end

    return false
  end,
})

require("neo-tree").setup({
  sources = {
    "filesystem",
    "buffers",
    "git_status",
    "document_symbols",
  },
  filesystem = {
    group_empty_dirs = false,
    filtered_items = {
      hide_dotfiles = false,
      hide_hidden = false,
      hide_gitignored = false,
      hide_ignored = false,
      visible = true,
    },
  },
  source_selector = {
    winbar = true,
    statusline = true,
    sources = {
      { source = "filesystem" },
      { source = "buffers" },
      { source = "git_status" },
      { source = "document_symbols" },
    },
    truncation_character = "…",
  },
  window = {
    mappings = {
      ["P"] = {
        "toggle_preview",
        config = {
          use_float = true,
          use_image_nvim = true,
        },
      },
    },
  },
})

require("render-markdown").setup({
  enabled = true,
  render_modes = { "n", "c", "t" },
  max_file_size = 10.0,
  debounce = 100,
  preset = "none",
  log_level = "off",
  log_runtime = false,
  file_types = { "markdown", "codecompanion" },
  ignore = function()
    return false
  end,
  nested = true,
  change_events = {},
  restart_highlighter = false,
  injections = {
    gitcommit = {
      enabled = true,
      query = [[
                ((message) @injection.content
                    (#set! injection.combined)
                    (#set! injection.include-children)
                    (#set! injection.language "markdown"))
            ]],
    },
  },
  patterns = {
    markdown = {
      disable = true,
      directives = {
        { id = 17, name = "conceal_lines" },
        { id = 18, name = "conceal_lines" },
      },
    },
  },
  anti_conceal = {
    enabled = true,
    disabled_modes = false,
    above = 0,
    below = 0,
    ignore = {
      bullet = true,
      callout = true,
      check_icon = true,
      check_scope = true,
      code_background = true,
      code_border = true,
      code_language = true,
      dash = true,
      head_background = true,
      head_border = true,
      head_icon = true,
      indent = true,
      link = true,
      quote = true,
      sign = true,
      table_border = true,
      virtual_lines = true,
    },
  },
  padding = {
    highlight = "Normal",
  },
  latex = {
    enabled = true,
    render_modes = false,
    converter = { "utftex", "latex2text" },
    highlight = "RenderMarkdownMath",
    position = "center",
    top_pad = 0,
    bottom_pad = 0,
  },
  on = {
    attach = function() end,
    initial = function() end,
    render = function() end,
    clear = function() end,
  },
  completions = {
    blink = { enabled = true },
    coq = { enabled = false },
    lsp = { enabled = true },
    filter = {
      callout = function()
        return true
      end,
      checkbox = function()
        return true
      end,
    },
  },
  heading = {
    enabled = true,
    render_modes = false,
    atx = true,
    setext = true,
    sign = true,
    icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    position = "overlay",
    signs = { "󰫎 " },
    width = "full",
    left_margin = 0,
    left_pad = 0,
    right_pad = 0,
    min_width = 0,
    border = false,
    border_virtual = false,
    border_prefix = false,
    above = "▄",
    below = "▀",
    backgrounds = {
      "RenderMarkdownH1Bg",
      "RenderMarkdownH2Bg",
      "RenderMarkdownH3Bg",
      "RenderMarkdownH4Bg",
      "RenderMarkdownH5Bg",
      "RenderMarkdownH6Bg",
    },
    foregrounds = {
      "RenderMarkdownH1",
      "RenderMarkdownH2",
      "RenderMarkdownH3",
      "RenderMarkdownH4",
      "RenderMarkdownH5",
      "RenderMarkdownH6",
    },
    custom = {},
  },
  paragraph = {
    enabled = true,
    render_modes = false,
    left_margin = 0,
    indent = 0,
    min_width = 0,
  },
  code = {
    enabled = true,
    render_modes = false,
    sign = true,
    conceal_delimiters = true,
    language = true,
    position = "right",
    language_icon = true,
    language_name = true,
    language_info = true,
    language_pad = 0,
    disable_background = { "diff" },
    width = "full",
    left_margin = 0,
    left_pad = 0,
    right_pad = 0,
    min_width = 0,
    border = "thick",
    language_border = "█",
    language_left = "",
    language_right = "",
    above = "▄",
    below = "▀",
    inline = true,
    inline_left = "",
    inline_right = "",
    inline_pad = 0,
    highlight = "RenderMarkdownCode",
    highlight_info = "RenderMarkdownCodeInfo",
    highlight_language = nil,
    highlight_border = "RenderMarkdownCodeBorder",
    highlight_fallback = "RenderMarkdownCodeFallback",
    highlight_inline = "RenderMarkdownCodeInline",
    style = "full",
  },
  dash = {
    enabled = true,
    render_modes = false,
    icon = "─",
    width = "full",
    left_margin = 0,
    highlight = "RenderMarkdownDash",
  },
  document = {
    enabled = true,
    render_modes = false,
    conceal = {
      char_patterns = {},
      line_patterns = {},
    },
  },
  bullet = {
    enabled = true,
    render_modes = false,
    icons = { "●", "○", "◆", "◇" },
    ordered_icons = function(ctx)
      local value = vim.trim(ctx.value)
      local index = tonumber(value:sub(1, #value - 1))
      return ("%d."):format(index > 1 and index or ctx.index)
    end,
    left_pad = 0,
    right_pad = 0,
    highlight = "RenderMarkdownBullet",
    scope_highlight = {},
    scope_priority = nil,
  },
  checkbox = {
    enabled = true,
    render_modes = false,
    bullet = false,
    left_pad = 0,
    right_pad = 1,
    unchecked = {
      icon = "󰄱 ",
      highlight = "RenderMarkdownUnchecked",
      scope_highlight = nil,
    },
    checked = {
      icon = "󰱒 ",
      highlight = "RenderMarkdownChecked",
      scope_highlight = nil,
    },
    custom = {
      todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo", scope_highlight = nil },
    },
    scope_priority = nil,
  },
  quote = {
    enabled = true,
    render_modes = false,
    icon = "▋",
    repeat_linebreak = false,
    highlight = {
      "RenderMarkdownQuote1",
      "RenderMarkdownQuote2",
      "RenderMarkdownQuote3",
      "RenderMarkdownQuote4",
      "RenderMarkdownQuote5",
      "RenderMarkdownQuote6",
    },
  },
  pipe_table = {
    enabled = true,
    render_modes = false,
    preset = "none",
    cell = "padded",
    cell_offset = function()
      return 0
    end,
    padding = 1,
    min_width = 0,
    border = {
      "┌",
      "┬",
      "┐",
      "├",
      "┼",
      "┤",
      "└",
      "┴",
      "┘",
      "│",
      "─",
    },
    border_enabled = true,
    border_virtual = false,
    alignment_indicator = "━",
    head = "RenderMarkdownTableHead",
    row = "RenderMarkdownTableRow",
    filler = "RenderMarkdownTableFill",
    style = "full",
  },
  callout = {
    note = {
      raw = "[!NOTE]",
      rendered = "󰋽 Note",
      highlight = "RenderMarkdownInfo",
      category = "github",
    },
    tip = {
      raw = "[!TIP]",
      rendered = "󰌶 Tip",
      highlight = "RenderMarkdownSuccess",
      category = "github",
    },
    important = {
      raw = "[!IMPORTANT]",
      rendered = "󰅾 Important",
      highlight = "RenderMarkdownHint",
      category = "github",
    },
    warning = {
      raw = "[!WARNING]",
      rendered = "󰀪 Warning",
      highlight = "RenderMarkdownWarn",
      category = "github",
    },
    caution = {
      raw = "[!CAUTION]",
      rendered = "󰳦 Caution",
      highlight = "RenderMarkdownError",
      category = "github",
    },
    abstract = {
      raw = "[!ABSTRACT]",
      rendered = "󰨸 Abstract",
      highlight = "RenderMarkdownInfo",
      category = "obsidian",
    },
    summary = {
      raw = "[!SUMMARY]",
      rendered = "󰨸 Summary",
      highlight = "RenderMarkdownInfo",
      category = "obsidian",
    },
    tldr = {
      raw = "[!TLDR]",
      rendered = "󰨸 Tldr",
      highlight = "RenderMarkdownInfo",
      category = "obsidian",
    },
    info = {
      raw = "[!INFO]",
      rendered = "󰋽 Info",
      highlight = "RenderMarkdownInfo",
      category = "obsidian",
    },
    todo = {
      raw = "[!TODO]",
      rendered = "󰗡 Todo",
      highlight = "RenderMarkdownInfo",
      category = "obsidian",
    },
    hint = {
      raw = "[!HINT]",
      rendered = "󰌶 Hint",
      highlight = "RenderMarkdownSuccess",
      category = "obsidian",
    },
    success = {
      raw = "[!SUCCESS]",
      rendered = "󰄬 Success",
      highlight = "RenderMarkdownSuccess",
      category = "obsidian",
    },
    check = {
      raw = "[!CHECK]",
      rendered = "󰄬 Check",
      highlight = "RenderMarkdownSuccess",
      category = "obsidian",
    },
    done = {
      raw = "[!DONE]",
      rendered = "󰄬 Done",
      highlight = "RenderMarkdownSuccess",
      category = "obsidian",
    },
    question = {
      raw = "[!QUESTION]",
      rendered = "󰘥 Question",
      highlight = "RenderMarkdownWarn",
      category = "obsidian",
    },
    help = {
      raw = "[!HELP]",
      rendered = "󰘥 Help",
      highlight = "RenderMarkdownWarn",
      category = "obsidian",
    },
    faq = {
      raw = "[!FAQ]",
      rendered = "󰘥 Faq",
      highlight = "RenderMarkdownWarn",
      category = "obsidian",
    },
    attention = {
      raw = "[!ATTENTION]",
      rendered = "󰀪 Attention",
      highlight = "RenderMarkdownWarn",
      category = "obsidian",
    },
    failure = {
      raw = "[!FAILURE]",
      rendered = "󰅖 Failure",
      highlight = "RenderMarkdownError",
      category = "obsidian",
    },
    fail = {
      raw = "[!FAIL]",
      rendered = "󰅖 Fail",
      highlight = "RenderMarkdownError",
      category = "obsidian",
    },
    missing = {
      raw = "[!MISSING]",
      rendered = "󰅖 Missing",
      highlight = "RenderMarkdownError",
      category = "obsidian",
    },
    danger = {
      raw = "[!DANGER]",
      rendered = "󱐌 Danger",
      highlight = "RenderMarkdownError",
      category = "obsidian",
    },
    error = {
      raw = "[!ERROR]",
      rendered = "󱐌 Error",
      highlight = "RenderMarkdownError",
      category = "obsidian",
    },
    bug = {
      raw = "[!BUG]",
      rendered = "󰨰 Bug",
      highlight = "RenderMarkdownError",
      category = "obsidian",
    },
    example = {
      raw = "[!EXAMPLE]",
      rendered = "󰉹 Example",
      highlight = "RenderMarkdownHint",
      category = "obsidian",
    },
    quote = {
      raw = "[!QUOTE]",
      rendered = "󱆨 Quote",
      highlight = "RenderMarkdownQuote",
      category = "obsidian",
    },
    cite = {
      raw = "[!CITE]",
      rendered = "󱆨 Cite",
      highlight = "RenderMarkdownQuote",
      category = "obsidian",
    },
  },
  link = {
    enabled = true,
    render_modes = false,
    footnote = {
      enabled = true,
      icon = "󰯔 ",
      superscript = true,
      prefix = "",
      suffix = "",
    },
    image = "󰥶 ",
    email = "󰀓 ",
    hyperlink = "󰌹 ",
    highlight = "RenderMarkdownLink",
    wiki = {
      icon = "󱗖 ",
      body = function()
        return nil
      end,
      highlight = "RenderMarkdownWikiLink",
      scope_highlight = nil,
    },
    custom = {
      web = { pattern = "^http", icon = "󰖟 " },
      discord = { pattern = "discord%.com", icon = "󰙯 " },
      github = { pattern = "github%.com", icon = "󰊤 " },
      gitlab = { pattern = "gitlab%.com", icon = "󰮠 " },
      google = { pattern = "google%.com", icon = "󰊭 " },
      neovim = { pattern = "neovim%.io", icon = " " },
      reddit = { pattern = "reddit%.com", icon = "󰑍 " },
      stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
      wikipedia = { pattern = "wikipedia%.org", icon = "󰖬 " },
      youtube = { pattern = "youtube%.com", icon = "󰗃 " },
    },
  },
  sign = {
    enabled = true,
    highlight = "RenderMarkdownSign",
  },
  inline_highlight = {
    enabled = true,
    render_modes = false,
    highlight = "RenderMarkdownInlineHighlight",
  },
  indent = {
    enabled = false,
    render_modes = false,
    per_level = 2,
    skip_level = 1,
    skip_heading = false,
    icon = "▎",
    priority = 0,
    highlight = "RenderMarkdownIndent",
  },
  html = {
    enabled = true,
    render_modes = false,
    comment = {
      conceal = true,
      text = nil,
      highlight = "RenderMarkdownHtmlComment",
    },
    tag = {},
  },
  win_options = {
    conceallevel = {
      default = vim.o.conceallevel,
      rendered = 3,
    },
    concealcursor = {
      default = vim.o.concealcursor,
      rendered = "",
    },
  },
  overrides = {
    buflisted = {},
    buftype = {
      nofile = {
        render_modes = true,
        padding = { highlight = "NormalFloat" },
        sign = { enabled = false },
      },
    },
    filetype = {},
  },
  custom_handlers = {},
  yaml = {
    enabled = true,
    render_modes = false,
  },
})

local highlight = {
  "RainbowRed",
  "RainbowYellow",
  "RainbowBlue",
  "RainbowOrange",
  "RainbowGreen",
  "RainbowViolet",
  "RainbowCyan",
}

local hooks = require("ibl.hooks")

hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
  vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
  vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
  vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
  vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
  vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
  vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
end)

vim.g.rainbow_delimiters = { highlight = highlight }
require("ibl").setup({
  indent = { highlight = highlight },
  whitespace = {
    highlight = {
      "NonText",
      "Whitespace",
      "CursorColumn",
    },
    remove_blankline_trail = true,
  },
  scope = { enabled = true },
})
hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
