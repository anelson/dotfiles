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

-- Set up the background gradient in terms of the color scheme
local scheme = wezterm.get_builtin_color_schemes()[config.color_scheme]
config.background = {
	{
		-- File = "/Users/rupert/.wallpaper/rusty-tile.png",
		source = {
			Gradient = {
				-- Can be "Vertical" or "Horizontal".  Specifies the direction
				-- in which the color gradient varies.  The default is "Horizontal",
				-- with the gradient going from left-to-right.
				-- Linear and Radial gradients are also supported; see the other
				-- examples below
				orientation = "Vertical",

				-- Specifies the set of colors that are interpolated in the gradient.
				-- Accepts CSS style color specs, from named colors, through rgb
				-- strings and more
				--
				-- Colors drawn from background colors in https://github.com/morhetz/gruvbox?tab=readme-ov-file#dark-mode-1
				colors = {
					-- bg0
					"#282828",

					-- bg1
					"#3c3836",

					-- bg0
					"#282828",
				},

				-- Instead of specifying `colors`, you can use one of a number of
				-- predefined, preset gradients.
				-- A list of presets is shown in a section below.
				-- preset = "Warm",

				-- Specifies the interpolation style to be used.
				-- "Linear", "Basis" and "CatmullRom" as supported.
				-- The default is "Linear".
				interpolation = "Linear",

				-- How the colors are blended in the gradient.
				-- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
				-- The default is "Rgb".
				blend = "Rgb",

				-- To avoid vertical color banding for horizontal gradients, the
				-- gradient position is randomly shifted by up to the `noise` value
				-- for each pixel.
				-- Smaller values, or 0, will make bands more prominent.
				-- The default value is 64 which gives decent looking results
				-- on a retina macbook pro display.
				-- noise = 64,

				-- By default, the gradient smoothly transitions between the colors.
				-- You can adjust the sharpness by specifying the segment_size and
				-- segment_smoothness parameters.
				-- segment_size configures how many segments are present.
				-- segment_smoothness is how hard the edge is; 0.0 is a hard edge,
				-- 1.0 is a soft edge.

				-- segment_size = 11,
				-- segment_smoothness = 0.0,
			},
		},
		width = "100%",
		height = "100%",
	},
}

-- Tweak the padding slightly.  By default it's 1cell on each side and 0.5 cell top and bottom.
-- But remember that terminal cells are taller than they are wide, so this still works out to some
-- extra space on the bottom
config.window_padding = {
	left = "1cell",
	right = "1cell",
	top = "0cell",
	bottom = "0.22cell",
}

-- Make the terminal contents (including background colors) slightly translucent so that we can see the cool background image.
-- As we all know, ricing one's terminal is far more important than actually getting work done.
config.text_background_opacity = 0.90

-- and finally, return the configuration to wezterm
return config
