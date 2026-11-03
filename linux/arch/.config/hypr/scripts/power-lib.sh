#!/bin/bash
# power.sh / lid.sh 공용 함수

STATE="${XDG_RUNTIME_DIR:-/run/user/$UID}/power"
LOG="/tmp/power-manager.log"
SCRIPTS="$HOME/.config/hypr/scripts"
mkdir -p "$STATE"

log() {
  echo "[$(date '+%m-%d %H:%M:%S')] [$(basename "$0")] $1" >> "$LOG"
}

ac_online() {
  [[ "${POWER_AC:-$(cat /sys/class/power_supply/AC/online 2>/dev/null)}" == 1 ]]
}

battery_low() {
  (( $(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100) <= 10 ))
}

lid_closed() {
  grep -q closed /proc/acpi/button/lid/LID/state 2>/dev/null
}

# 물리적으로 연결된 외장 모니터 수
external_count() {
  local n=0 s
  for s in /sys/class/drm/card*-{DP,HDMI-A}-*/status; do
    [[ "$(cat "$s" 2>/dev/null)" == connected ]] && ((n++))
  done
  echo "$n"
}

hypr_dpms() {
  if [[ -n "$POWER_DRY_RUN" ]]; then
    log "DRY_RUN: dpms $*"
  else
    hyprctl dispatch dpms "$@" > /dev/null
  fi
}

dpms_off() {
  touch "$STATE/dpms-off"
  # 열린 rofi가 꺼진 화면에 남아 입력을 가로채지 않도록 닫음
  pkill -x rofi
  hypr_dpms off
}

dpms_on() {
  rm -f "$STATE/dpms-off"
  # 덮개 닫힘 + 외장 없음이면 내장 화면을 켜지 않음
  if lid_closed && (( $(external_count) == 0 )); then
    return
  fi
  pkill -x rofi
  hypr_dpms on
  # 깨어나며 연결이 흔들린 모니터(특히 HDMI)를 몇 초 뒤 다시 설정
  if [[ -z "$POWER_DRY_RUN" ]]; then
    (sleep 4; "$SCRIPTS/monitor-manager.sh" --refresh) > /dev/null 2>&1 &
  fi
}

# pidfile의 프로세스 종료
kill_pidfile() {
  local pid
  pid=$(cat "$1" 2>/dev/null) || return 0
  kill "$pid" 2>/dev/null
  rm -f "$1"
}
