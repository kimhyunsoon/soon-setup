#!/usr/bin/env python3
"""현재 워크스페이스의 모든 창을 같은 모니터의 이전/다음 워크스페이스 창들과 통째로 교환 (dwindle 배치 유지)

사용: workspace-swap.py l|r [--stay] [--target N] [--dry-run]
  l / r      : 왼쪽(이전) / 오른쪽(다음) 워크스페이스와 교환 (모니터 내에서 순환)
  --stay     : 교환 후 현재 워크스페이스에 남음 (기본은 창을 따라 이동)
  --target N : 대상 워크스페이스를 직접 지정
  --dry-run  : 계산된 분할 트리만 출력

원리: Hyprland는 창을 옮길 때 타일 트리를 함께 옮기지 못하므로,
창 좌표에서 dwindle 분할 트리를 역산한 뒤 대상 워크스페이스에서
focus + preselect + settiled 순서로 같은 트리를 다시 쌓고 분할 비율을 맞춘다.
"""
import json
import subprocess
import sys

TOL = 2  # 좌표 비교 허용 오차(px)


def hc(*args):
    return subprocess.run(["hyprctl", *args], capture_output=True, text=True).stdout


def hj(*args):
    return json.loads(hc("-j", *args))


def batch(cmds):
    if cmds:
        hc("--batch", "; ".join(cmds))


def rect(c):
    return (c["at"][0], c["at"][1], c["size"][0], c["size"][1])


def build(wins):
    """창 목록을 (axis, left, right) 이진 트리로 분할. axis 0=좌우, 1=상하. 리프는 address 문자열."""
    if len(wins) == 1:
        return wins[0]["address"]
    for axis in (0, 1):
        cuts = sorted({rect(c)[axis] + rect(c)[axis + 2] for c in wins})
        for cut in cuts:
            left = [c for c in wins if rect(c)[axis] + rect(c)[axis + 2] <= cut + TOL]
            right = [c for c in wins if rect(c)[axis] >= cut - TOL]
            if left and right and len(left) + len(right) == len(wins):
                lt, rt = build(left), build(right)
                if lt and rt:
                    return (axis, lt, rt)
    return None


def rep(node):
    return node if isinstance(node, str) else rep(node[1])


def extent(node, rects, axis):
    """서브트리가 차지하는 폭(axis 0) 또는 높이(axis 1)"""
    if isinstance(node, str):
        return rects[node][axis + 2]
    _, l, r = node
    if node[0] == axis:
        return extent(l, rects, axis) + extent(r, rects, axis)
    return max(extent(l, rects, axis), extent(r, rects, axis))


def size_of(addr, axis):
    for c in hj("clients"):
        if c["address"] == addr:
            return c["size"][axis]
    return None


def fix_size(addr, axis, want):
    """addr 창의 폭/높이를 want로 맞춤 (resize 방향이 반대로 적용되면 보정)"""
    for _ in range(2):
        cur = size_of(addr, axis)
        if cur is None or abs(want - cur) <= TOL:
            return
        d = want - cur
        vec = f"{d} 0" if axis == 0 else f"0 {d}"
        hc("dispatch", "resizewindowpixel", f"{vec},address:{addr}")
        cur2 = size_of(addr, axis)
        if cur2 is not None and abs(want - cur2) > abs(d):  # 반대로 움직였으면 뒤집어서 재적용
            vec = f"{-2 * d} 0" if axis == 0 else f"0 {-2 * d}"
            hc("dispatch", "resizewindowpixel", f"{vec},address:{addr}")


def place(node, rects):
    if isinstance(node, str):
        return
    axis, l, r = node
    rl, rr = rep(l), rep(r)
    batch([
        f"dispatch focuswindow address:{rl}",
        f"dispatch layoutmsg preselect {'r' if axis == 0 else 'd'}",
        f"dispatch settiled address:{rr}",
    ])
    fix_size(rl, axis, extent(l, rects, axis))
    place(l, rects)
    place(r, rects)


def rebuild(tree, rects):
    hc("dispatch", "settiled", f"address:{rep(tree)}")
    place(tree, rects)


def main():
    args = sys.argv[1:]
    direction, stay, dry, forced = "r", False, False, None
    i = 0
    while i < len(args):
        a = args[i]
        if a in ("l", "left", "prev"):
            direction = "l"
        elif a in ("r", "right", "next"):
            direction = "r"
        elif a == "--stay":
            stay = True
        elif a == "--dry-run":
            dry = True
        elif a == "--target":
            i += 1
            forced = int(args[i])
        i += 1

    ws = hj("activeworkspace")
    cur, mon = ws["id"], ws["monitor"]
    if cur < 0:  # special 워크스페이스에서는 동작 안 함
        return
    if forced is not None:
        target = forced
    else:
        # 같은 모니터의 워크스페이스 목록: 규칙(workspace = N, monitor:X) 기준, 없으면 현재 존재하는 것 기준
        ids = sorted(int(r["workspaceString"]) for r in hj("workspacerules")
                     if r.get("monitor") == mon and r["workspaceString"].isdigit())
        if cur not in ids:
            ids = sorted(w["id"] for w in hj("workspaces") if w["monitor"] == mon and w["id"] > 0)
        if len(ids) < 2:
            return
        k = ids.index(cur)
        target = ids[(k - 1) % len(ids)] if direction == "l" else ids[(k + 1) % len(ids)]
    if target == cur:
        return

    active = hj("activewindow").get("address")

    def clients():
        return [c for c in hj("clients")
                if c["mapped"] and not c["pinned"] and c["workspace"]["id"] in (cur, target)]

    cl = clients()
    # 전체화면은 타일 좌표를 읽을 수 없으므로 잠시 해제했다가 마지막에 복원
    fs = [(c["address"], c["fullscreen"], c["fullscreenClient"]) for c in cl if c["fullscreen"] or c["fullscreenClient"]]
    if fs and not dry:
        batch([f"dispatch focuswindow address:{a}; dispatch fullscreenstate 0 0" for a, _, _ in fs])
        cl = clients()

    def split(wsid):
        tiled = [c for c in cl if c["workspace"]["id"] == wsid and not c["floating"] and not c["hidden"]]
        others = [c for c in cl if c["workspace"]["id"] == wsid and (c["floating"] or c["hidden"])]
        return tiled, others

    a_t, a_o = split(cur)
    b_t, b_o = split(target)
    rects = {c["address"]: rect(c) for c in cl}
    tree_a = build(a_t) if a_t else None
    tree_b = build(b_t) if b_t else None

    if dry:
        print(f"cur={cur} target={target} monitor={mon}")
        print("A:", tree_a, [c["class"] for c in a_t])
        print("B:", tree_b, [c["class"] for c in b_t])
        return

    cmds = []
    # 트리를 역산할 수 있는 쪽은 전부 floating으로 바꿔 옮긴 뒤 순서대로 다시 타일링
    for c in (a_t if tree_a else []) + (b_t if tree_b else []):
        cmds.append(f"dispatch setfloating address:{c['address']}")
    for c in a_t + a_o:
        cmds.append(f"dispatch movetoworkspacesilent {target},address:{c['address']}")
    for c in b_t + b_o:
        cmds.append(f"dispatch movetoworkspacesilent {cur},address:{c['address']}")
    batch(cmds)

    order = [(cur, tree_b), (target, tree_a)]
    final = target
    if stay:
        order.reverse()
        final = cur
    for wsid, tree in order:
        if hj("activeworkspace")["id"] != wsid:
            hc("dispatch", "workspace", str(wsid))
        if tree:
            rebuild(tree, rects)

    cmds = [f"dispatch focuswindow address:{a}; dispatch fullscreenstate {f} {fc}" for a, f, fc in fs]
    cmds.append(f"dispatch workspace {final}")
    if active:
        cmds.append(f"dispatch focuswindow address:{active}")
    batch(cmds)


if __name__ == "__main__":
    import datetime
    import fcntl
    import traceback
    # 동시 실행 방지 (키 이벤트가 중복 전달되거나 연타해도 한 번만 수행)
    lock = open("/tmp/workspace-swap.lock", "w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        sys.exit(0)
    with open("/tmp/workspace-swap.log", "a") as log:
        log.write(f"{datetime.datetime.now():%H:%M:%S} args={sys.argv[1:]}\n")
        try:
            main()
        except Exception:
            log.write(traceback.format_exc())
            raise
