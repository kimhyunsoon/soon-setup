#!/usr/bin/env python3
"""화면을 다시 켤 키(Super+[ 또는 Super+])를 기다림. 입력이 있으면 exit 0, 시간 초과면 exit 1.

사용법: input-wait.py <초>
/dev/input/event* 를 직접 읽음 (input 그룹 필요). 블루투스 재연결 등 핫플러그 장치도 2초마다 다시 스캔.
마우스(logid가 버튼을 Meta+A, KEY_BACK 등으로 보냄)는 이 조합을 보내지 않으므로 화면을 켜지 않음.
"""
import os
import select
import struct
import sys
import time

# 키 입력을 보내지만 키보드가 아닌 장치 (ACPI 버튼, 오디오 잭, 헤드셋 AVRCP, logid)
EXCLUDE = ("Power Button", "Sleep Button", "Lid Switch", "Video Bus", "ThinkPad Extra Buttons", "HD-Audio", "AVRCP", "LogiOps")
EV_KEY = 1
META = {125, 126}  # KEY_LEFTMETA, KEY_RIGHTMETA
WAKE_KEYS = {26, 27}  # KEY_LEFTBRACE, KEY_RIGHTBRACE (워크스페이스 이동 키)
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
                if code in META:
                    if value == 1:
                        held.add(code)
                    elif value == 0:
                        held.discard(code)
                elif value == 1 and code in WAKE_KEYS and held:
                    print(f"{fds[fd]} {device_name(fds[fd])} key={code}")
                    sys.exit(0)
    sys.exit(1)


if __name__ == "__main__":
    main()
