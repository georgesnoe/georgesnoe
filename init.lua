if vim.g.neovide then
	vim.o.guifont = "CaskaydiaCove_NF:h10:b:#e-subpixelantialias:#h-none"
	vim.g.neovide_scale_factor = 1.0
	vim.g.neovide_floating_shadow = false
	vim.g.neovide_floating_z_height = 0
	vim.g.neovide_light_angle_degrees = 45
	vim.g.neovide_light_radius = 5
	vim.g.neovide_floating_corner_radius = 0.0
	vim.g.neovide_opacity = 1.0
	vim.g.neovide_normal_opacity = 1.0
	vim.g.neovide_refresh_rate = 60
	vim.g.neovide_no_idle = true
	vim.g.neovide_cursor_antialiasing = false
	vim.g.neovide_cursor_animate_in_insert_mode = true
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
