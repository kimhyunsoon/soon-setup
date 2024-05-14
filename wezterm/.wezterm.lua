local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

local function get_last_dir_name(path)
  return path:match("[/\\]([^/\\]*)$")
end

local function auto_format_title()
  wezterm.on(
  'format-tab-title',
  function(tab)
    local pane = tab.active_pane
    local title = pane.title
    local current_working_dir = pane.current_working_dir
    local process = get_last_dir_name(pane.foreground_process_name)
    if current_working_dir ~= nil and (process == 'nvim' or title == 'pnpm' or process == 'NVIM') then
      title = get_last_dir_name(current_working_dir.path)
    end
    return title
  end
  )
end

if package.config:sub(1,1) == "\\" then
  config.default_domain = "WSL:Ubuntu"
else
  auto_format_title()
end

config.show_tab_index_in_tab_bar = false
config.font = wezterm.font_with_fallback {
  {
    family = 'Hack Nerd Font Mono',
    weight = 'Medium'
  },

}
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.font_size = 10.5
config.cell_width = 0.8
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.83
config.window_padding = {
  left = 0,
  right = 0,
  top = 4,
  bottom = 0,
}
config.win32_system_backdrop = 'Acrylic'
config.macos_window_background_blur = 52
config.keys = {
  {
    key = '\\',
    mods = 'ALT',
    action = act.SplitVertical,
  },
  {
    key = 'v',
    mods = 'CTRL',
    action = act.PasteFrom 'Clipboard',
  },
  {
    key = ']',
    mods = 'CTRL',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = '[',
    mods = 'CTRL',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = ']',
    mods = 'CMD',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = '[',
    mods = 'CMD',
    action = act.ActivatePaneDirection 'Up',
  },
  { key = '{', mods = 'SHIFT|ALT', action = act.MoveTabRelative(-1) },
  { key = '}', mods = 'SHIFT|ALT', action = act.MoveTabRelative(1) },
  {
    key = '{',
    mods = 'CTRL|SHIFT',
    action = act.ActivateTabRelative(-1),
  },
  {
    key = '}',
    mods = 'CTRL|SHIFT',
    action = act.ActivateTabRelative(1),
  },
  {
    key = 't',
    mods = 'CMD',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 't',
    mods = 'CTRL',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },
  {
    key = 'w',
    mods = 'CTRL',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },
  {
    key = 'e',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
}

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
