#!/bin/bash
# hyprctl 호환 함수 (source 해서 사용)
# Hyprland 0.57부터 hyprlang 설정과 `hyprctl keyword`, 기존 dispatch 문법이 없어지고 Lua로 바뀜
# 실행 중인 Hyprland 버전에 맞는 명령을 보냄

if [[ -z "$HYPR_LUA" ]]; then
  HYPR_LUA=0
  ver=$(hyprctl version -j 2>/dev/null | jq -r '.version // empty' 2>/dev/null)
  [[ -n "$ver" && "$(printf '%s\n' 0.57.0 "$ver" | sort -V | head -1)" == 0.57.0 ]] && HYPR_LUA=1
  unset ver
fi

# Lua 디스패처 실행 (예: hypr_lua_dispatch 'hl.dsp.focus({ workspace = "1" })')
hypr_lua_dispatch() {
  hyprctl dispatch "$1" > /dev/null
}

# 모니터 끄기: hypr_monitor_disable eDP-1
hypr_monitor_disable() {
  if ((HYPR_LUA)); then
    hyprctl eval "hl.monitor({ output = \"$1\", disabled = true })" > /dev/null
  else
    hyprctl keyword monitor "$1,disable" > /dev/null
  fi
}

# 모니터 설정: hypr_monitor_set 이름 모드 위치 배율 [회전]
hypr_monitor_set() {
  local name=$1 mode=$2 pos=$3 scale=$4 transform=${5:-0}
  if ((HYPR_LUA)); then
    hyprctl eval "hl.monitor({ output = \"$name\", disabled = false, mirror = \"\", mode = \"$mode\", position = \"$pos\", scale = $scale, transform = $transform })" > /dev/null
  else
    hyprctl keyword monitor "$name,$mode,$pos,$scale,transform,$transform" > /dev/null
  fi
}

# 미러링: hypr_monitor_mirror 이름 원본모니터
hypr_monitor_mirror() {
  if ((HYPR_LUA)); then
    hyprctl eval "hl.monitor({ output = \"$1\", disabled = false, mode = \"preferred\", position = \"auto\", scale = 1, transform = 0, mirror = \"$2\" })" > /dev/null
  else
    hyprctl keyword monitor "$1,preferred,auto,1,mirror,$2" > /dev/null
  fi
}

# 화면 켜기/끄기: hypr_dpms on|off [모니터]
hypr_dpms_raw() {
  if ((HYPR_LUA)); then
    local action=disable monitor=""
    [[ "$1" == on ]] && action=enable
    [[ -n "$2" ]] && monitor=", monitor = \"$2\""
    hypr_lua_dispatch "hl.dsp.dpms({ action = \"$action\"$monitor })"
  else
    hyprctl dispatch dpms "$@" > /dev/null
  fi
}

# 워크스페이스로 이동: hypr_workspace 3
hypr_workspace() {
  if ((HYPR_LUA)); then
    hypr_lua_dispatch "hl.dsp.focus({ workspace = \"$1\" })"
  else
    hyprctl dispatch workspace "$1" > /dev/null
  fi
}

# 모니터로 포커스: hypr_focus_monitor DP-1
hypr_focus_monitor() {
  if ((HYPR_LUA)); then
    hypr_lua_dispatch "hl.dsp.focus({ monitor = \"$1\" })"
  else
    hyprctl dispatch focusmonitor "$1" > /dev/null
  fi
}

# 워크스페이스를 모니터로 옮김: hypr_move_workspace 7 HDMI-A-1
hypr_move_workspace() {
  if ((HYPR_LUA)); then
    hypr_lua_dispatch "hl.dsp.workspace.move({ workspace = \"$1\", monitor = \"$2\" })"
  else
    hyprctl dispatch moveworkspacetomonitor "$1" "$2" > /dev/null
  fi
}

# 워크스페이스 규칙의 모니터 변경: hypr_workspace_rule 7 HDMI-A-1
hypr_workspace_rule() {
  if ((HYPR_LUA)); then
    hyprctl eval "hl.workspace_rule({ workspace = \"$1\", monitor = \"$2\" })" > /dev/null
  else
    hyprctl keyword workspace "$1,monitor:$2" > /dev/null
  fi
}
