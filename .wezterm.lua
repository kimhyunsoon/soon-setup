local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font_with_fallback {
   {
    family = 'Hack Nerd Font Mono',
    weight = 'Medium'
  },
  {
    family = 'D2CodingLigature Nerd Font Mono',
    weight = 'Medium'
  },
}
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.font_size = 12.4
config.cell_width = 0.8
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.83
config.window_padding = {
  left = 0,
  right = 0,
  top = 4,
  bottom = 0,
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
for i = 1, 8 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CMD|ALT',
    action = wezterm.action.MoveTab(i - 1),
  })
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CTRL|ALT',
    action = wezterm.action.MoveTab(i - 1),
  })
end

config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.4,
}
config.foreground_text_hsb = {
  hue = 1,
  saturation = 1,
  brightness = 1.2,
}

return config
