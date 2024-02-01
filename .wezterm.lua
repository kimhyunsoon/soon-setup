local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font(
  'D2CodingLigature Nerd Font Mono', { weight = 'Medium'}
)
config.font_size = 13
config.cell_width = 0.8
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.8
config.window_padding = {
  left = 2,
  right = 2,
  top = 2,
  bottom = 2,
}
config.color_scheme = 'Adventuretime'
config.win32_system_backdrop = 'Acrylic'
config.macos_window_background_blur = 50
config.keys = {
  {
    key = '|',
    mods = 'CMD',
    action = wezterm.action.SplitVertical,
  },
  {
    key = '|',
    mods = 'CTRL',
    action = wezterm.action.SplitVertical,
  },
   {
    key = ']',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = ']',
    mods = 'CTRL',
    action = wezterm.action.ActivatePaneDirection 'Down',
  }, {
    key = '[',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = '[',
    mods = 'CTRL',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
}
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.4,
}
return config
