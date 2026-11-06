-- Hyprland 설정 (0.57부터 Lua 설정만 지원, 이전 버전은 hyprland.conf 사용)
-- 문서: https://wiki.hypr.land/configuring/

local scripts = "~/.config/hypr/scripts/"

------------------
---- 환경변수 ----
------------------
hl.env("GTK_IM_MODULE", "kime")
hl.env("QT_IM_MODULE", "kime")
hl.env("QT4_IM_MODULE", "kime")
hl.env("XMODIFIERS", "@im=kime")
hl.env("XCURSOR_SIZE", "32")
-- firefox용
hl.env("MOZ_ENABLE_WAYLAND", "1")
-- t14s용 (amd gpu)
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
hl.env("VDPAU_DRIVER", "radeonsi")
hl.env("AMD_VULKAN_ICD", "RADV")

------------------
---- 디스플레이 ----
------------------
-- 내장
hl.monitor({ output = "eDP-1", mode = "2880x1800@60", position = "960x333", scale = 1 })
-- 외장1
hl.monitor({ output = "DP-1", mode = "3840x2160@60", position = "3840x333", scale = 1 })
-- 외장2 (기본: 세로 확장)
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "7680x0", scale = 1, transform = 1 })

-- 클램쉘 (덮개 닫힘 + 외장 없음이면 5분 유예 후 절전)
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(scripts .. "lid.sh close"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(scripts .. "lid.sh open"), { locked = true })

-- 모니터별 워크스페이스 할당 (동적, 우선순위는 monitor-manager.sh)
-- 1-3: eDP-1 > DP-1 > HDMI-A-1
-- 4-6: DP-1 > eDP-1 > HDMI-A-1
-- 7-9: HDMI-A-1 > eDP-1 > DP-1
for ws = 1, 9 do
  local monitor = ws <= 3 and "eDP-1" or ws <= 6 and "DP-1" or "HDMI-A-1"
  hl.workspace_rule({ workspace = tostring(ws), monitor = monitor, default = (ws % 3 == 1) })
end

------------------
---- 창 규칙 ----
------------------
-- Spotify 창 관리
hl.window_rule({
  name = "spotify",
  match = { class = "^([Ss]potify)$" },
  no_anim = true,
  tile = true,
  suppress_event = "fullscreen maximize",
})

-- Thunderbird 창 관리
hl.window_rule({
  name = "thunderbird",
  match = { class = "^(org.mozilla.Thunderbird)$" },
  no_anim = true,
  tile = true,
  suppress_event = "fullscreen maximize",
})

-- Bottles/Wine 앱 (카카오톡 등) 창 관리
hl.window_rule({
  name = "steam-proton",
  match = { class = "^(steam_proton)$", title = "^(.+)$" },
  float = true,
  size = { 1000, 1200 },
  move = { 100, 100 },
  suppress_event = "fullscreen maximize",
})

-- Playwright test 창 관리
hl.window_rule({
  name = "chromium",
  match = { class = "Chromium-browser" },
  no_max_size = true,
  tile = true,
})

-- xfreerdp 창 관리
hl.window_rule({
  name = "xfreerdp",
  match = { class = "^(xfreerdp)$" },
  suppress_event = "maximize fullscreen",
  no_max_size = true,
  tile = true,
})

-- rofi 애니메이션 제외
hl.layer_rule({
  name = "rofi-no-anim",
  match = { namespace = "rofi" },
  no_anim = true,
})

------------------
---- 기본 설정 ----
------------------
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },

  -- 모니터 변경 시 Firefox 크래시 방지 (color management 프로토콜 버그)
  render = {
    cm_enabled = false,
  },

  decoration = {
    rounding = 0,
    active_opacity = 1.0,
    inactive_opacity = 0.7,
    blur = { enabled = false },
    shadow = { enabled = false },
  },

  cursor = {
    no_hardware_cursors = false,
    enable_hyprcursor = true,
  },

  general = {
    border_size = 2,
    col = {
      active_border = "rgba(000000ff)",
      inactive_border = "rgba(000000ff)",
    },
    -- 창 간격
    gaps_in = 0,
    gaps_out = 0,
    -- 창 크기조절 (마우스)
    resize_on_border = true,
    extend_border_grab_area = 15,
    allow_tearing = false,
  },

  input = {
    follow_mouse = 0,
    touchpad = {
      -- 터치로 클릭 안함
      tap_to_click = false,
      -- 1점: 클릭, 2점: 우클릭
      clickfinger_behavior = true,
    },
  },

  misc = {
    disable_splash_rendering = true,
    disable_hyprland_logo = true,
    vrr = 1,
    disable_autoreload = true,
    always_follow_on_dnd = true,
    animate_manual_resizes = false,
    enable_swallow = false,
    focus_on_activate = true,
    -- 화면은 power.sh가 켬 (마우스/키 입력으로 켜지지 않게)
    mouse_move_enables_dpms = false,
    key_press_enables_dpms = false,
  },

  layers = {
    layers_hog_keyboard_focus = false,
  },

  debug = {
    vfr = true,
  },

  animations = {
    enabled = true,
  },
})

-- 터치패드 3점 스와이프로 작업공간 전환
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- MX Vertical 감도 조절
hl.device({ name = "logitech-mx-vertical-advanced-ergonomic-mouse", sensitivity = 0.3 })
-- t14s 터치패드 감도 조절
hl.device({ name = "elan0676:00-04f3:3195-touchpad", sensitivity = 0.3 })

------------------
---- 애니메이션 ----
------------------
hl.curve("fade", { type = "bezier", points = { { 0.3, 0.0 }, { 0.3, 1.0 } } })
hl.curve("quart", { type = "bezier", points = { { 0.25, 0.46 }, { 0.45, 0.94 } } })

-- 창 열고 닫기
hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "quart" })
-- 창 등장
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "quart", style = "popin 60%" })
-- 창 닫기
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "quart", style = "popin 100%" })
-- 창 이동
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "quart" })
-- 워크스페이스
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "quart", style = "slidefade 30%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "quart", style = "fade" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "fade" })

------------------
---- 시작 앱 ----
------------------
hl.on("hyprland.start", function()
  -- 배경화면
  hl.exec_cmd("hyprpaper")
  -- 시스템 알림
  hl.exec_cmd("swaync")
  -- 블루투스 미디어 컨트롤
  hl.exec_cmd("mpris-proxy")
  -- 네트워크 매니저
  hl.exec_cmd("nm-applet --indicator")
  -- 클립보드 히스토리
  hl.exec_cmd("rm -f ~/.cache/cliphist/db && wl-paste --type text --watch " .. scripts .. "cliphist-store.sh & wl-paste --type image --watch " .. scripts .. "cliphist-store.sh")
  -- 앱 별 키 바인딩
  hl.exec_cmd("keyd-application-mapper -d")
  -- 트레이 watcher (waybar 재시작해도 트레이 아이콘 유지, waybar보다 먼저 실행)
  hl.exec_cmd(scripts .. "sni-watcher.py")
  -- 덮개 처리를 lid.sh가 맡도록 logind의 덮개 절전 억제 (Hyprland 종료 시 해제되어 logind가 다시 처리)
  hl.exec_cmd(scripts .. "lid.sh inhibit")
end)

-- 시작 + reload마다 실행
-- (config.reloaded는 첫 실행 때 Wayland 소켓이 준비되기 전에도 오므로, 그때는 hyprland.start에서 실행)
local function on_start_and_reload(fn)
  hl.on("hyprland.start", fn)
  hl.on("config.reloaded", function()
    if os.getenv("WAYLAND_DISPLAY") then
      fn()
    end
  end)
end

on_start_and_reload(function()
  -- 모니터/워크스페이스/waybar 데몬 재시작
  hl.exec_cmd(scripts .. "monitor-manager.sh --daemon")
  -- 한글 입력기 (재)시작
  hl.exec_cmd("pkill -x kime; sleep 0.3; kime")
end)

------------------
---- 단축키 헬퍼 ----
------------------
-- 1~9 안에서 이전/다음 (끝에서는 순환하지 않고 멈춤, 범위 밖이면 nil)
local function step_ws(id, delta)
  local target = id + delta
  if id < 1 or id > 9 or target < 1 or target > 9 then return nil end
  return target
end

local function focus_ws(delta)
  local ws = hl.get_active_workspace()
  if not ws then return end
  local target = step_ws(ws.id, delta)
  if not target then return end
  hl.dispatch(hl.dsp.focus({ workspace = tostring(target) }))
end

local function move_window_ws(delta)
  local win = hl.get_active_window()
  if not win or not win.workspace then return end
  local target = step_ws(win.workspace.id, delta)
  if not target then return end
  hl.dispatch(hl.dsp.window.move({ workspace = tostring(target) }))
end

local function find_window(class_pattern)
  for _, w in ipairs(hl.get_windows()) do
    if w.class and w.class:lower():match(class_pattern) then
      return w
    end
  end
end

-- special 워크스페이스에 숨긴 앱을 현재 워크스페이스로 가져오거나 다시 숨김. 실행 중이 아니면 start 실행
local function toggle_hidden_app(class_pattern, special, start)
  local w = find_window(class_pattern)
  if not w then
    hl.exec_cmd(start)
    return
  end
  local selector = "address:" .. w.address
  if w.workspace and w.workspace.name == "special:" .. special then
    local cur = hl.get_active_workspace()
    hl.dispatch(hl.dsp.window.move({ window = selector, workspace = tostring(cur.id) }))
    hl.dispatch(hl.dsp.focus({ window = selector }))
  else
    hl.dispatch(hl.dsp.window.move({ window = selector, workspace = "special:" .. special, follow = false }))
  end
end

------------------
---- 시스템 단축키 ----
------------------
-- 절전 메뉴 (절전 / 화면만 끄기)
hl.bind("SUPER + CONTROL + L", hl.dsp.exec_cmd(scripts .. "power.sh menu"))
-- HDMI 확장/미러링 토글
hl.bind("SUPER + CONTROL + P", hl.dsp.exec_cmd(scripts .. "hdmi-toggle-mirror.sh"))
-- hyprland 새로고침
hl.bind("SUPER + CONTROL + R", hl.dsp.exec_cmd("hyprctl reload"))
-- HDMI 모니터 수동 복구
hl.bind("SUPER + CONTROL + M", hl.dsp.exec_cmd(scripts .. "hdmi-reset.sh"))
-- 스크린샷 (다시 누르면 취소, OCR 진행 중이면 무시)
hl.bind("SUPER + A", hl.dsp.exec_cmd(scripts .. "capture.sh"))
-- ocr (다시 누르면 선택 취소)
hl.bind("SUPER + S", hl.dsp.exec_cmd("~/.local/bin/ocr"))
-- 컬러피커 (다시 누르면 취소)
hl.bind("SUPER + D", hl.dsp.exec_cmd("pkill -x hyprpicker || hyprpicker -a -n"))
-- 클립보드 히스토리
hl.bind("CONTROL + SHIFT + V", hl.dsp.exec_cmd(scripts .. "cliphist.sh"))
-- 앱 종료 (Spotify, Thunderbird는 숨김)
hl.bind("CONTROL + SHIFT + Q", function()
  local w = hl.get_active_window()
  if not w then return end
  local special = (w.class:lower() == "spotify" and "spotify") or (w.class == "org.mozilla.Thunderbird" and "thunderbird")
  if special then
    hl.dispatch(hl.dsp.window.move({ window = "address:" .. w.address, workspace = "special:" .. special, follow = false }))
  else
    hl.dispatch(hl.dsp.window.close())
  end
end)

------------------
---- 앱 단축키 ----
------------------
-- 앱 런처
hl.bind("CONTROL + SPACE", hl.dsp.exec_cmd('rofi -modi "launcher:~/.config/rofi/rofi.sh" -show launcher -show-icons -no-lazy-grab'))
-- 파일 관리자
hl.bind("ALT + F", hl.dsp.exec_cmd("thunar"))
-- ghostty
hl.bind("ALT + T", hl.dsp.exec_cmd("ghostty"))
-- firefox
hl.bind("ALT + W", hl.dsp.exec_cmd("firefox"))
-- slack (wayland 네이티브 실행 — 플래그 없이 실행하면 창이 매핑되지 않는 문제 있음)
hl.bind("ALT + S", hl.dsp.exec_cmd("env -u DISPLAY slack --ozone-platform=wayland --enable-wayland-ime --wayland-text-input-version=3 --enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer --disable-features=WaylandFractionalScaleV1"))
-- thunderbird 토글
hl.bind("ALT + E", function()
  toggle_hidden_app("^org%.mozilla%.thunderbird$", "thunderbird", "thunderbird")
end)
-- dbgate (IME 플래그는 ~/.config/dbgate-flags.conf에서 적용됨)
hl.bind("ALT + B", hl.dsp.exec_cmd("env -u DISPLAY dbgate"))
-- spotify 토글
hl.bind("ALT + M", function()
  toggle_hidden_app("^spotify$", "spotify", "pkill -x spotify; sleep 1; env -u DISPLAY spotify --ozone-platform=wayland --enable-features=UseOzonePlatform")
end)

------------------
---- 창 단축키 ----
------------------
-- 플로팅-타일링 토글
hl.bind("CONTROL + backslash", hl.dsp.window.float({ action = "toggle" }))
-- ALT+드래그로 창 이동
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
-- 워크스페이스 이동
hl.bind("SUPER + bracketleft", function() focus_ws(-1) end)
hl.bind("SUPER + bracketright", function() focus_ws(1) end)

-- 창 focus 이동
hl.bind("CONTROL + left", hl.dsp.focus({ direction = "left" }))
hl.bind("CONTROL + right", hl.dsp.focus({ direction = "right" }))
hl.bind("CONTROL + up", hl.dsp.focus({ direction = "up" }))
hl.bind("CONTROL + down", hl.dsp.focus({ direction = "down" }))
-- 창 이동
hl.bind("SUPER + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.window.move({ direction = "down" }))
-- 워크스페이스 간 창 이동
hl.bind("SUPER + CONTROL + bracketleft", function() move_window_ws(-1) end)
hl.bind("SUPER + CONTROL + bracketright", function() move_window_ws(1) end)
-- 워크스페이스 통째로 교환 (현재 워크스페이스의 모든 창 <-> 이전/다음 워크스페이스 창, 모니터 무관)
hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.exec_cmd(scripts .. "workspace-swap.py l"))
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.exec_cmd(scripts .. "workspace-swap.py r"))

------------------
---- 노트북 기능키 ----
------------------
-- 음량 조절
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"))
-- F키 음량 조절
hl.bind("F12", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("F11", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind("F10", hl.dsp.exec_cmd("playerctl play-pause"))
-- 밝기 조절
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
-- 미디어 컨트롤
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("SUPER + SHIFT + period", hl.dsp.exec_cmd("playerctl next"))
hl.bind("SUPER + SHIFT + comma", hl.dsp.exec_cmd("playerctl previous"))
