if vim.g.neovide then
  vim.g.neovide_floating_corner_radius = 1.0
  vim.g.neovide_refresh_rate = 40
  vim.g.neovide_no_idle = true
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_cursor_vfx_mode = "torpedo"
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
