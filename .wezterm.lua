local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

local function get_last_dir_name(path)
  return path:match("[/\\]([^/\\]*)$")
end

wezterm.on(
  'format-tab-title',
  function(tab)
    local pane = tab.active_pane
    local title = pane.title
    local current_working_dir = pane.current_working_dir
    local process = get_last_dir_name(pane.foreground_process_name)
    if current_working_dir ~= nil and (process == 'nvim' or title == 'pnpm')then
      title = get_last_dir_name(current_working_dir.path)
    end
    return title
  end
)

config.show_tab_index_in_tab_bar = false
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
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = '[',
    mods = 'ALT',
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
