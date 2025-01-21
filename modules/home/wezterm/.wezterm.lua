-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.front_end = "WebGpu"
config.cursor_blink_rate = 3000
config.enable_scroll_bar = false
config.enable_tab_bar = false
config.window_padding = {
  left = 48,
  right = 48,
  top = 48,
  bottom = 48
}
config.color_scheme = 'rose-pine'
config.colors = { background = '#080808' }
config.font = wezterm.font_with_fallback {
  'Tamzen',
  'Material Icons'
}
config.allow_square_glyphs_to_overflow_width = "Never"


-- and finally, return the configuration to wezterm
return config
