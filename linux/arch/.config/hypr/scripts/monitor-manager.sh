#!/bin/bash
# 모니터/워크스페이스/waybar 통합 관리

LOG="/tmp/monitor-manager.log"

EDP="eDP-1,2880x1800@60,960x333,1"
HDMI_EXTENDED="HDMI-A-1,3840x2160@60,7680x0,1,transform,1"
HDMI_MIRROR="HDMI-A-1,preferred,auto,1,mirror,eDP-1"
HDMI_STATE_FILE="/tmp/hdmi-mirror-state"
STATE_FILE="/tmp/monitor-manager-state"
TRAILING_FILE="/tmp/monitor-manager-trailing"
POWER_DPMS_OFF="$XDG_RUNTIME_DIR/power/dpms-off"

log() {
  echo "[$(date '+%H:%M:%S')] $1" >> "$LOG"
}

log "Script started ($1)"

# 클램쉘 상태 확인 및 eDP-1 설정
apply_clamshell() {
  local lid_state=$(cat /proc/acpi/button/lid/LID/state 2>/dev/null | awk '{print $2}')

  local retry=0
  local monitor_count=0
  while [[ $retry -lt 5 ]]; do
    monitor_count=$(hyprctl monitors -j 2>/dev/null | jq 'length' 2>/dev/null)
    if [[ $monitor_count -gt 0 ]]; then
      break
    fi
    sleep 0.3
    ((retry++))
  done

  log "Lid: $lid_state, Monitors: $monitor_count"

  if [[ "$lid_state" == "closed" ]] && [[ $monitor_count -gt 1 ]]; then
    hyprctl keyword monitor "eDP-1,disable"
    log "eDP-1 disabled"
  else
    hyprctl keyword monitor "$EDP"
    log "eDP-1 enabled"
  fi
}

# 워크스페이스를 올바른 모니터로 이동
fix_workspaces() {
  sleep 0.3
  local monitors=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null)
  local workspaces=$(hyprctl workspaces -j 2>/dev/null)
  local active_ws=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id' 2>/dev/null)
  log "Monitors: $(echo $monitors | tr '\n' ' '), WS: $active_ws"

  for ws in {1..9}; do
    local priority
    if [[ $ws -le 3 ]]; then
      priority="eDP-1 DP-1 HDMI-A-1"
    elif [[ $ws -le 6 ]]; then
      priority="DP-1 eDP-1 HDMI-A-1"
    else
      priority="HDMI-A-1 eDP-1 DP-1"
    fi

    for monitor in $priority; do
      if echo "$monitors" | grep -q "^$monitor$"; then
        local current=$(echo "$workspaces" | jq -r ".[] | select(.id == $ws) | .monitor" 2>/dev/null)
        if [[ -n "$current" && "$current" != "$monitor" ]]; then
          hyprctl dispatch moveworkspacetomonitor "$ws" "$monitor"
          log "WS $ws: $current -> $monitor"
        fi
        hyprctl keyword workspace "$ws,monitor:$monitor"
        break
      fi
    done
  done

  if [[ -n "$active_ws" ]] && echo "$workspaces" | jq -e ".[] | select(.id == $active_ws)" >/dev/null 2>&1; then
    hyprctl dispatch workspace "$active_ws"
  else
    hyprctl dispatch workspace 1
  fi
}

# waybar 재시작 (flock으로 동시 실행 방지)
_restart_waybar() {
  (
    flock -n 200 || { log "waybar restart skipped (locked)"; return; }

    log "waybar restart executing"

    local monitors
    monitors=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null)

    local primary
    for mon in eDP-1 DP-1 HDMI-A-1; do
      if echo "$monitors" | grep -q "^$mon$"; then
        primary="$mon"
        break
      fi
    done

    if [[ -z "$primary" ]]; then
      log "No primary monitor found"
      return
    fi

    local config_dir="$HOME/.config/waybar"
    local temp_config="/tmp/waybar-config.json"
    jq --arg output "$primary" '.output = [$output]' "$config_dir/config" > "$temp_config"

    pkill -x waybar 2>/dev/null
    sleep 0.5
    waybar -c "$temp_config" -s "$config_dir/style.css" 200>&- &
    disown
    log "waybar started on $primary"
  ) 200>/tmp/waybar-restart.lock
}

# HDMI 상태 복원 (미러링/확장)
restore_hdmi() {
  if ! grep -q "^connected" /sys/class/drm/card*-HDMI-A-1/status 2>/dev/null; then
    return
  fi
  local hdmi_state=$(cat "$HDMI_STATE_FILE" 2>/dev/null || echo "extended")
  if [[ "$hdmi_state" == "mirror" ]]; then
    hyprctl keyword monitor "$HDMI_MIRROR"
    log "HDMI-A-1 restored: mirror"
  fi
}

# 즉시 실행 모드
run_once() {
  log "=== RUN_ONCE ==="
  apply_clamshell
  restore_hdmi
  sleep 0.8
  fix_workspaces
  _restart_waybar &
  disown
  log "=== DONE ==="
}

# 모니터 상태 요약: 물리 연결된 외장 출력 | Hyprland가 인식한 모니터
monitor_state() {
  local f
  for f in /sys/class/drm/card*-{DP,HDMI-A}-*/status; do
    [[ "$(cat "$f" 2>/dev/null)" == connected ]] && basename "$(dirname "$f")"
  done | paste -sd' '
  echo "|$(hyprctl monitors -j 2>/dev/null | jq -r '[.[].name] | sort | join(" ")')"
}

# HDMI 상태(미러링/확장)에 맞는 설정 적용
apply_hdmi() {
  grep -q "^connected" /sys/class/drm/card*-HDMI-A-1/status 2>/dev/null || return 1
  local hdmi_state=$(cat "$HDMI_STATE_FILE" 2>/dev/null || echo "extended")
  if [[ "$hdmi_state" == "mirror" ]]; then
    hyprctl keyword monitor "$HDMI_MIRROR"
  else
    hyprctl keyword monitor "$HDMI_EXTENDED"
  fi
  log "HDMI-A-1 applied: $hdmi_state"
}

# 모니터 연결 변화 처리
handle_change() {
  apply_hdmi && sleep 0.5
  apply_clamshell
  sleep 0.5
  fix_workspaces
  _restart_waybar &
  # power.sh가 화면을 꺼둔 상태면 다시 연결된 모니터도 끔
  if [[ -f "$POWER_DPMS_OFF" ]]; then
    hyprctl dispatch dpms off
    log "dpms off 유지"
  fi
  monitor_state > "$STATE_FILE"
}

# 화면을 다시 켠 뒤 호출 (power.sh): 깨어나며 신호를 못 잡은 HDMI를 다시 설정
run_refresh() {
  log "=== REFRESH ==="
  handle_change
  # 그 사이 power.sh가 다시 화면을 껐으면 켜지 않음
  [[ -f "$POWER_DPMS_OFF" ]] || hyprctl dispatch dpms on
}

# 데몬 모드 (이벤트 감지)
run_daemon() {
  # 기존 데몬 모두 종료 (자기 자신 제외)
  local old_pids
  old_pids=$(pgrep -f "monitor-manager.sh --daemon" | grep -v "^$$\$")
  if [[ -n "$old_pids" ]]; then
    echo "$old_pids" | xargs kill 2>/dev/null
    sleep 0.5
  else
    # 첫 실행 시 모니터 준비 대기
    sleep 3
  fi

  local watchdog_pid
  trap 'kill $watchdog_pid 2>/dev/null' EXIT

  # 초기 실행
  rm -f "$TRAILING_FILE"
  run_once
  monitor_state > "$STATE_FILE"

  # 초기 실행 직후 디바운스 설정 (reload 시 발생하는 모니터 이벤트 무시)
  local debounce_file="/tmp/monitor-manager-debounce"
  local suppress_file="/tmp/monitor-manager-suppress"
  echo "$(date +%s)" > "$debounce_file"

  # waybar watchdog (5초마다 체크, 죽었으면 재시작)
  (while true; do
    sleep 5
    if ! pgrep -x waybar > /dev/null; then
      log "waybar watchdog: not running, restarting"
      _restart_waybar
    fi
  done) &
  watchdog_pid=$!

  # 이벤트 감지 (디바운스 5초)
  socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    case "${line%%>>*}" in
      monitoradded|monitorremoved)
        # suppress 파일이 있으면 무시 (hdmi-reset.sh 실행 중)
        if [[ -f "$suppress_file" ]]; then
          log "Suppressed: $line"
          continue
        fi
        # 덮개 닫힘 상태에서 외장 연결/해제 → 절전 유예 재평가 (디바운스와 무관하게 매번)
        ~/.config/hypr/scripts/lid.sh check &
        # power.sh가 화면을 꺼둔 상태면 디바운스로 무시되는 이벤트에서도 다시 끔
        [[ -f "$POWER_DPMS_OFF" ]] && (sleep 2; hyprctl dispatch dpms off > /dev/null) &
        local now=$(date +%s)
        local last=$(cat "$debounce_file" 2>/dev/null || echo 0)
        if (( now - last < 5 )); then
          log "Debounced: $line"
          # 모니터가 깨어나며 연결이 여러 번 끊겼다 붙으면 마지막 상태가 버려지므로,
          # 디바운스가 끝난 뒤 물리 연결 상태가 마지막 처리 때와 다르면 한 번 더 처리
          if [[ ! -f "$TRAILING_FILE" ]]; then
            touch "$TRAILING_FILE"
            (
              sleep 6
              rm -f "$TRAILING_FILE"
              if [[ "$(monitor_state)" != "$(cat "$STATE_FILE" 2>/dev/null)" ]]; then
                log "Trailing: $(monitor_state | paste -sd' ')"
                echo "$(date +%s)" > "$debounce_file"
                handle_change
              fi
            ) &
          fi
          continue
        fi
        echo "$now" > "$debounce_file"
        sleep 1
        handle_change
        ;;
    esac
  done
}

case "$1" in
  --daemon) run_daemon ;;
  --refresh) run_refresh ;;
  *) run_once ;;
esac
