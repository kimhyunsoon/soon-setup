#!/usr/bin/env python3
"""키보드 입력을 기다림. 입력이 있으면 exit 0, 시간 초과면 exit 1.

사용법: input-wait.py <초>
/dev/input/event* 를 직접 읽음 (input 그룹 필요). 블루투스 재연결 등 핫플러그 장치도 2초마다 다시 스캔.
"""
import os
import select
import struct
import sys
import time

# 키보드가 아닌 장치 (ACPI 버튼, 오디오 잭, 헤드셋 AVRCP, 마우스 버튼을 키로 바꿔 보내는 logid 등)
EXCLUDE = ("Power Button", "Sleep Button", "Lid Switch", "Video Bus", "ThinkPad Extra Buttons", "HD-Audio", "AVRCP", "LogiOps")
EV_KEY = 1
# 마우스/터치패드 버튼 (BTN_MISC ~ BTN_GEAR_UP). 마우스로는 화면을 켜지 않음
BTN_RANGE = range(0x100, 0x160)
# 절전 해제 시 커널이 보내는 키, 마우스 측면 버튼(logid → keyd를 거쳐 키보드 키로 들어옴)
IGNORED_KEYS = {116, 142, 143, 158, 159}  # KEY_POWER, KEY_SLEEP, KEY_WAKEUP, KEY_BACK, KEY_FORWARD
# 수식키 (Ctrl/Shift/Alt/Meta). 단독 또는 조합 입력은 무시 (마우스 제스처 버튼이 Meta+A 등으로 들어옴)
MODIFIERS = {29, 97, 42, 54, 56, 100, 125, 126}
EVENT = struct.Struct("llHHi")


def device_name(ev):
    try:
        with open(f"/sys/class/input/{ev}/device/name") as f:
            return f.read().strip()
    except OSError:
        return ""


def scan(fds):
    for ev in os.listdir("/dev/input"):
        if not ev.startswith("event") or ev in fds.values():
            continue
        if any(x in device_name(ev) for x in EXCLUDE):
            continue
        try:
            fds[os.open(f"/dev/input/{ev}", os.O_RDONLY | os.O_NONBLOCK)] = ev
        except OSError:
            pass


def main():
    deadline = time.monotonic() + float(sys.argv[1])
    fds = {}
    held = set()
    while (remain := deadline - time.monotonic()) > 0:
        scan(fds)
        ready, _, _ = select.select(list(fds), [], [], min(2, remain))
        for fd in ready:
            try:
                data = os.read(fd, EVENT.size * 64)
            except OSError:
                os.close(fd)
                del fds[fd]
                continue
            for i in range(0, len(data) - EVENT.size + 1, EVENT.size):
                _, _, typ, code, value = EVENT.unpack_from(data, i)
                if typ != EV_KEY:
                    continue
                if code in MODIFIERS:
                    if value == 1:
                        held.add(code)
                    elif value == 0:
                        held.discard(code)
                    continue
                if value == 1 and not held and code not in IGNORED_KEYS and code not in BTN_RANGE:
                    sys.exit(0)
    sys.exit(1)


if __name__ == "__main__":
    main()
