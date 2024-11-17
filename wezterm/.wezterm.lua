
local wezterm = require 'wezterm'
local is_windows = string.find(wezterm.target_triple, 'windows')
local is_mac = string.find(wezterm.target_triple, 'apple')

-- Config Builder
local config = {}
if wezterm.config_builder then config = wezterm.config_builder() end

-- Title Auto Formatting (Apply non-Windows)
local function get_last_dir_name(path) return path:match("[/\\]([^/\\]*)$") end
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

-- Set Windows
if is_windows then
  config.wsl_domains = {
    {
      name = 'WSL:Ubuntu',
      distribution = 'Ubuntu',
      default_cwd = '~',
    },
  }
  config.default_prog = { 'wsl.exe', '~' }

-- Set Others
else
  auto_format_title()
end

-- Set Config
config.window_close_confirmation = 'NeverPrompt'
config.show_tab_index_in_tab_bar = false
config.font = wezterm.font_with_fallback {
  {
    family = 'Hack Nerd Font Mono',
    weight = 'Regular',
  },
  {
    family = 'D2CodingLigature Nerd Font Mono',
    weight = 'Regular',
  },
}
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.font_size = 10.5
config.cell_width = 0.8
config.window_decorations = 'RESIZE'
config.window_padding = {
  left = 0,
  right = 0,
  top = 4,
  bottom = 0,
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

-- Set Keybindings
local act = wezterm.action
local CTRL = is_mac and 'CMD' or 'CTRL'

config.keys = {

  -- Vertical Split Pane
  {
    key = '[',
    mods = 'ALT',
    action = act.SplitVertical,
  },

  -- Horizontal Split Pane
  {
    key = ']',
    mods = 'ALT',
    action = act.SplitHorizontal,
  },

  {
    key = '[',
    mods = 'ALT',
    action = act.SplitVertical,
  },

  -- Paste
  {
    key = 'v',
    mods = 'CTRL',
    action = act.PasteFrom 'Clipboard',
  },

  -- Direction Pane
  { key = 'RightArrow', mods = 'SHIFT', action = act.ActivatePaneDirection 'Right' },
  { key = 'DownArrow', mods = 'SHIFT', action = act.ActivatePaneDirection 'Down' },
  { key = 'LeftArrow', mods = 'SHIFT', action = act.ActivatePaneDirection 'Left' },
  { key = 'UpArrow', mods = 'SHIFT', action = act.ActivatePaneDirection 'Up' },

  -- Move Tab
  { key = '{', mods = 'SHIFT|ALT', action = act.MoveTabRelative(-1) },
  { key = '}', mods = 'SHIFT|ALT', action = act.MoveTabRelative(1) },

  -- Direction Tab
  {
    key = '{',
    mods = CTRL .. '|SHIFT',
    action = act.ActivateTabRelative(-1),
  },
  {
    key = '}',
    mods = CTRL .. '|SHIFT',
    action = act.ActivateTabRelative(1),
  },

  -- Spawn Tab
  {
    key = 't',
    mods = CTRL,
    action = act.SpawnTab 'CurrentPaneDomain',
  },

  -- Close Tab
  {
    key = 'w',
    mods = CTRL,
    action = wezterm.action.CloseCurrentTab { confirm = false },
  },

  -- Edit Tab Title
  {
    key = 'e',
    mods = CTRL .. '|SHIFT',
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

return config

