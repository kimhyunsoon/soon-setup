#!/bin/bash
# 절전 메뉴 (Super+Ctrl+L)
#   menu              rofi 메뉴 (절전 / 화면만 끄기)
#   suspend           절전
#   screenoff         바로 화면만 끄기 (작업 유지, 입력 시 복귀)
#   cancel            진행 중인 세션 취소 (덮개 열림 등)
# 절전 후 깨어났을 때 (덮개 닫힘):
#   블루투스 키보드로 깨움 → 바로 화면 켜기
#   그 외(원치 않는 깨어남) → 화면을 꺼둔 채 5분간 키보드 입력이 없으면 다시 절전
# POWER_DRY_RUN=1 이면 실제 절전/dpms 대신 로그만 남김

source "$(dirname "$0")/power-lib.sh"

PIDFILE="$STATE/power.pid"
# 깨어난 뒤 입력 대기 시간
GUARD_SEC=${POWER_GUARD_SEC:-300}

menu() {
  case "$(printf "절전\n화면만 끄기" | rofi -dmenu -i -no-custom -p 절전)" in
    절전) start suspend ;;
    화면*) start screenoff ;;
  esac
}

# 기존 세션을 끝내고 새 세션을 백그라운드로 시작
start() {
  kill_pidfile "$PIDFILE"
  setsid "$0" _run "$@" > /dev/null 2>&1 < /dev/null &
}

# 절전 후 깨어날 때까지 대기 (벽시계 점프로 감지). 60초 안에 절전이 안 되면 실패
wait_resume() {
  if [[ -n "$POWER_DRY_RUN" ]]; then
    return 0
  fi
  local prev now i
  prev=$(date +%s)
  for ((i = 0; i < 60; i++)); do
    sleep 1
    now=$(date +%s)
    ((now - prev > 5)) && return 0
    prev=$now
  done
  return 1
}

do_suspend() {
  if [[ -n "$POWER_DRY_RUN" ]]; then
    log "DRY_RUN: systemctl suspend"
  else
    systemctl suspend || return 1
  fi
}

# EC(gpe07)를 제외한 ACPI GPE 발생 횟수 합 (USB/BT 컨트롤러 등 장치에 의한 깨어남 판별)
non_ec_gpe() {
  local g n=0
  for g in /sys/firmware/acpi/interrupts/gpe[0-9A-F][0-9A-F]; do
    [[ "$g" == */gpe07 ]] && continue
    n=$((n + $(awk '{print $1}' "$g")))
  done
  echo "$n"
}

# 블루투스 키보드 목록 (재연결되면 새 inputN으로 생김, 마우스 제외)
bt_inputs() {
  local e
  for e in /sys/class/input/input*; do
    [[ "$(readlink -f "$e")" == */uhid/* ]] || continue
    udevadm info -q property -p "$e" | grep -qx 'ID_INPUT_KEYBOARD=1' && basename "$e"
  done | sort
}

# 블루투스 키보드로 깨운 것인지: 장치 GPE로 깨어났고 5초 안에 BT 키보드가 새로 연결됨
# (깨운 키 입력 자체는 연결 전이라 전달되지 않으므로 입력을 기다리지 않고 바로 판단)
woke_by_bt_input() {
  local gpe_before=$1 bt_before=$2 i
  (($(non_ec_gpe) > gpe_before)) || return 1
  for ((i = 0; i < 10; i++)); do
    [[ -n "$(comm -13 <(echo "$bt_before") <(bt_inputs))" ]] && return 0
    sleep 0.5
  done
  return 1
}

# 화면을 끈 채 입력을 기다림. 입력이 있으면 0, 시간 초과면 1
# 메뉴 선택 직후의 입력으로 바로 취소되지 않도록 2초 뒤부터 감지
# 모니터가 다시 연결되며 켜질 수 있으므로 처음 30초는 2초마다 다시 끔
wait_input_dark() {
  local i
  dpms_off
  sleep 2
  "$SCRIPTS/input-wait.py" "$1" & INPUT_PID=$!
  for ((i = 0; i < 15; i++)); do
    kill -0 $INPUT_PID 2>/dev/null || break
    hypr_dpms off
    sleep 2
  done
  wait $INPUT_PID
}

run_suspend() {
  # 메뉴 선택 키 입력이 끝나도록 잠시 대기
  sleep 1
  while :; do
    log "절전"
    dpms_off
    local gpe_before bt_before
    gpe_before=$(non_ec_gpe)
    bt_before=$(bt_inputs)
    do_suspend || { log "suspend 실패"; dpms_on; return; }
    wait_resume || { log "절전되지 않음"; dpms_on; return; }
    log "깨어남 (lid: $(lid_closed && echo closed || echo open))"
    # 덮개를 열어서 깨운 경우는 lid.sh open이 처리
    lid_closed || return
    if woke_by_bt_input "$gpe_before" "$bt_before"; then
      log "블루투스 키보드로 깨어남 → 복귀"
      dpms_on
      return
    fi
    if wait_input_dark "$GUARD_SEC"; then
      log "입력 감지 → 복귀"
      dpms_on
      return
    fi
    log "${GUARD_SEC}초간 입력 없음 → 다시 절전"
    [[ -n "$POWER_DRY_RUN" ]] && return
  done
}

run_screenoff() {
  echo screenoff > "$STATE/mode"
  log "화면만 끄기"
  wait_input_dark 999999
  log "입력 감지 → 화면 켜기"
  dpms_on
}

cleanup() {
  kill $INPUT_PID 2>/dev/null
  rm -f "$STATE/mode"
  # 어떤 경로로 끝나든 화면을 꺼둔 채로 남기지 않음 (key_press_enables_dpms=false라 키로 못 켬)
  [[ -f "$STATE/dpms-off" ]] && dpms_on
  [[ "$(cat "$PIDFILE" 2>/dev/null)" == $$ ]] && rm -f "$PIDFILE"
}

case "$1" in
  menu) menu ;;
  suspend) start suspend ;;
  screenoff) start screenoff ;;
  cancel) kill_pidfile "$PIDFILE" ;;
  _run)
    echo $$ > "$PIDFILE"
    trap cleanup EXIT
    trap exit TERM
    case "$2" in
      suspend) run_suspend ;;
      screenoff) run_screenoff ;;
    esac
    ;;
  *) echo "usage: $0 menu|suspend|screenoff|cancel" >&2; exit 1 ;;
esac
