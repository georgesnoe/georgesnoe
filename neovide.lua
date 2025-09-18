if not vim.g.neovide then
  return {}
end

--vim.o.guifont = "CaskaydiaCove NF:h10:b:#e-antialias:#h-none"
vim.g.neovide_scale_factor = 1.1
vim.g.neovide_floating_shadow = false
vim.g.neovide_floating_z_height = 0
vim.g.neovide_light_angle_degrees = 0
vim.g.neovide_light_radius = 0
vim.g.neovide_floating_corner_radius = 0
vim.g.neovide_opacity = 1.0
vim.g.neovide_normal_opacity = 1.0
vim.g.neovide_refresh_rate = 30
vim.g.neovide_refresh_rate_idle = 1
vim.g.neovide_no_idle = true
vim.g.neovide_cursor_trail_size = 1
vim.g.neovide_cursor_smooth_blink = true
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_animate_in_insert_mode = true
vim.g.neovide_cursor_animate_command_line = true
vim.g.neovide_text_gamma = 1
vim.g.neovide_text_contrast = 1
vim.g.neovide_position_animation_length = 0.05
vim.g.neovide_scroll_animation_length = 0.05
vim.g.neovide_scroll_animation_far_lines = 9999
vim.g.neovide_hide_mouse_when_typing = true

---@param scale_factor number
---@return number
local function clamp_scale_factor(scale_factor)
  return math.max(
    math.min(scale_factor, vim.g.neovide_max_scale_factor),
    vim.g.neovide_min_scale_factor
  )
end

---@param scale_factor number
---@param clamp? boolean
local function set_scale_factor(scale_factor, clamp)
  vim.g.neovide_scale_factor = clamp and clamp_scale_factor(scale_factor)
    or scale_factor
end

local function reset_scale_factor()
  vim.g.neovide_scale_factor = vim.g.neovide_initial_scale_factor
end

---@param increment number
---@param clamp? boolean
local function change_scale_factor(increment, clamp)
  set_scale_factor(vim.g.neovide_scale_factor + increment, clamp)
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      g = {
        neovide_increment_scale_factor = vim.g.neovide_increment_scale_factor
          or 0.1,
        neovide_min_scale_factor = vim.g.neovide_min_scale_factor or 0.7,
        neovide_max_scale_factor = vim.g.neovide_max_scale_factor or 2.0,
        neovide_initial_scale_factor = vim.g.neovide_scale_factor or 1,
        neovide_scale_factor = vim.g.neovide_scale_factor or 1,
      },
    },
    commands = {
      NeovideSetScaleFactor = {
        function(event)
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
        end,
        nargs = "+",
        desc = "Set Neovide scale factor",
      },
      NeovideResetScaleFactor = {
        reset_scale_factor,
        desc = "Reset Neovide scale factor",
      },
    },
    mappings = {
      n = {
        ["<C-=>"] = {
          function()
            change_scale_factor(
              vim.g.neovide_increment_scale_factor * vim.v.count1,
              true
            )
          end,
          desc = "Increase Neovide scale factor",
        },
        ["<C-->"] = {
          function()
            change_scale_factor(
              -vim.g.neovide_increment_scale_factor * vim.v.count1,
              true
            )
          end,
          desc = "Decrease Neovide scale factor",
        },
        ["<C-0>"] = { reset_scale_factor, desc = "Reset Neovide scale factor" },
      },
    },
  },
}
