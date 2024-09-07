-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = "Gruvbox Dark (Gogh)"

-- This is the default font and is embedded in wezterm but specify it anyway
config.font = wezterm.font("JetBrains Mono", {})

config.font_size = 12.0

-- I don't use the terminal emulator's tabs I use tmux both local and remote, so save some screen
-- real estate and hide the tab bar.
config.hide_tab_bar_if_only_one_tab = true

-- This seems to be the default but I always use tmux for scrolling so I definitely don't want wezterm messing
-- that up.
config.enable_scroll_bar = false

-- AJN: Support cycling between windows and sessions in tmux
config.keys = {
	{
		key = "Tab",
		mods = "CTRL",
		action = wezterm.action.SendString("\x1b[1;5I"),
	},
	{
		key = "Tab",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SendString("\x1b[1;6I"),
	},
	-- Disable Cmd-W to prevent accidentally closing Wezterm
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.DisableDefaultAssignment,
	},
	-- Support Neovim completions with Ctrl-Enter
	{
		key = "Enter",
		mods = "CTRL",
		action = wezterm.action.SendString("\x1b[13;5u"),
	},
}

-- Static gradient background inspired by Gruvbox Dark
config.background = {
	{
		source = {
			Gradient = {
				orientation = "Vertical",
				colors = {
					"#282828", -- Gruvbox Dark bg
					"#3c3836", -- Gruvbox Dark bg1
					"#504945", -- Gruvbox Dark bg2
				},
			},
		},
		width = "100%",
		height = "100%",
	},
}

-- and finally, return the configuration to wezterm
return config
