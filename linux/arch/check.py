import sys
import csv
from datetime import date, timedelta
from pathlib import Path
from typing import NamedTuple

DATA_DIR = Path.home() / ".local" / "share" / "check"
DATA_FILE = DATA_DIR / "data.csv"

WEEKDAYS = ["월", "화", "수", "목", "금", "토", "일"]

# 진행 일수 (시작일 포함). 종료일은 시작일 + (DURATION - 1)일로 자동 계산
DURATION = 6

# 기본 주기 (기록이 없거나 적을 때의 기준값)
DEFAULT_CYCLE = 28

# ANSI colors
C_RESET = "\033[0m"
C_RED = "\033[31m"
C_GREEN = "\033[32m"
C_YELLOW = "\033[33m"
C_BLUE = "\033[34m"


class Record(NamedTuple):
    start: date
    end: date


def parse_date(s: str) -> date:
    s = s.strip()
    if len(s) != 6 or not s.isdigit():
        raise ValueError
    return date(2000 + int(s[:2]), int(s[2:4]), int(s[4:6]))


def format_date(d: date, color_weekend: bool = False) -> str:
    wd = WEEKDAYS[d.weekday()]
    text = f"{d.year - 2000}-{d.month:02d}-{d.day:02d} ({wd})"
    if color_weekend and d.weekday() >= 5:
        return f"{C_BLUE}{text}{C_RESET}"
    return text


def load_records() -> list[Record]:
    if not DATA_FILE.exists():
        return []
    records: list[Record] = []
    with open(DATA_FILE, newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            start = parse_date(row["start"])
            records.append(Record(start, start + timedelta(days=DURATION - 1)))
    records.sort(key=lambda r: r.start)
    return records


def save_records(records: list[Record]) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    records.sort(key=lambda r: r.start)
    with open(DATA_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["start"])
        writer.writeheader()
        for r in records:
            writer.writerow({"start": r.start.strftime("%y%m%d")})


def calc_avg_cycle(records: list[Record]) -> int:
    if len(records) < 2:
        return DEFAULT_CYCLE
    gaps = [(records[i + 1].start - records[i].start).days for i in range(len(records) - 1)]
    # 기본 28일을 가상의 1개 관측으로 두고 실제 기록으로 보정 (기록이 많을수록 관측값에 수렴)
    est = (DEFAULT_CYCLE + sum(gaps)) / (len(gaps) + 1)
    return max(round(est), 1)


def get_cycle_day(records: list[Record], target: date) -> int:
    avg_cycle = calc_avg_cycle(records)
    # target 이하의 가장 최근 시작일을 기준으로 주기일차 계산
    base = None
    for r in records:
        if r.start <= target:
            base = r.start
    if base is None:
        # 모든 기록이 target 이후 → 첫 기록 기준 역산
        days_diff = (records[0].start - target).days
        return (-days_diff) % avg_cycle + 1
    days_since = (target - base).days
    return days_since % avg_cycle + 1


def predict_current_start(records: list[Record], target: date) -> date:
    avg_cycle = calc_avg_cycle(records)
    last_start = records[-1].start
    if target >= last_start:
        days_since = (target - last_start).days
        cycles_passed = days_since // avg_cycle
        return last_start + timedelta(days=cycles_passed * avg_cycle)
    return last_start


def predict_next_start(records: list[Record], target: date) -> date:
    avg_cycle = calc_avg_cycle(records)
    current_start = predict_current_start(records, target)
    return current_start + timedelta(days=avg_cycle)


def eval_status(cycle_day: int, avg_duration: int) -> str:
    return "TRUE" if cycle_day <= avg_duration else "FALSE"


def _peak_day(avg_cycle: int) -> int:
    # 배란일 = 다음 시작 14일 전. 시작일이 1일차이므로 주기일차로는 avg_cycle - 13
    return avg_cycle - 13


def eval_level(cycle_day: int, avg_cycle: int) -> int:
    peak = _peak_day(avg_cycle)
    diff = cycle_day - peak  # 음수: 배란 전, 양수: 배란 후
    # 가임기는 배란 5일 전부터 열려(정자 생존) 배란 당일 정점, 배란 후 급감(난자 수명)
    if diff <= -6:
        return 1
    if diff == -5:
        return 2
    if diff == -4:
        return 3
    if diff == -3:
        return 4
    if diff <= 0:  # -2, -1, 0: 정점
        return 5
    if diff == 1:
        return 2
    return 1


def eval_position(cycle_day: int, avg_cycle: int) -> int:
    peak = _peak_day(avg_cycle)
    menses = round(avg_cycle * 0.18)
    if cycle_day <= menses:
        return 2
    if cycle_day <= peak:
        dist = peak - cycle_day
        if dist <= 1:
            return 5
        if dist <= 3:
            return 4
        if dist <= 5:
            return 3
        return 2
    dist = cycle_day - peak
    if dist <= 2:
        return 4
    if dist <= 5:
        return 3
    if dist <= 8:
        return 2
    return 1


def color_position(v: int) -> str:
    if v <= 2:
        return f"{C_RED}{v}{C_RESET}"
    if v >= 4:
        return f"{C_GREEN}{v}{C_RESET}"
    return str(v)


def color_level(v: int) -> str:
    if v <= 2:
        return f"{C_GREEN}{v}{C_RESET}"
    if v >= 4:
        return f"{C_RED}{v}{C_RESET}"
    return str(v)


def cmd_show(extra_days: int = 0) -> None:
    records = load_records()
    if not records:
        print("데이터가 없습니다. 'check add'로 추가해주세요.")
        return

    today = date.today()
    avg_cycle = calc_avg_cycle(records)

    # 이전 (현재 사이클)
    prev_start = predict_current_start(records, today)
    prev_end = prev_start + timedelta(days=DURATION - 1)

    # 다음 사이클
    next_start = predict_next_start(records, today)
    next_end = next_start + timedelta(days=DURATION - 1)

    print(f"이전: {format_date(prev_start)} ~ {format_date(prev_end)}")
    print(f"다음: {format_date(next_start)} ~ {format_date(next_end)}")
    print()

    wd = today.weekday()
    start_offset = -((wd + 2) % 7)
    end_offset = (6 - wd) % 7
    if end_offset == 0:
        end_offset = 7
    if end_offset - start_offset < 7:
        end_offset += 7

    end_offset += extra_days

    for i in range(start_offset, end_offset + 1):
        d = today + timedelta(days=i)
        cd = get_cycle_day(records, d)
        st = eval_status(cd, DURATION)
        lv = eval_level(cd, avg_cycle)
        ps = eval_position(cd, avg_cycle)

        label = format_date(d, color_weekend=True)
        if d == today:
            label = f"{C_YELLOW}{format_date(d)}{C_RESET}"

        if st == "TRUE":
            print(f"{C_RED}{format_date(d)}{C_RESET}")
        else:
            print(f"{label}  위치: {color_position(ps)}  가능성: {color_level(lv)}")


def cmd_add() -> None:
    try:
        raw_start = input("시작일을 입력해주세요. (YYMMDD): ")
        start = parse_date(raw_start)
    except (ValueError, EOFError):
        print("올바른 날짜 형식이 아닙니다.")
        return

    if start > date.today():
        print("시작일은 오늘 이전이어야 합니다.")
        return

    # 종료일은 시작일 + (DURATION - 1)일로 자동 계산
    end = start + timedelta(days=DURATION - 1)

    records = load_records()
    # 겹치는 레코드 제거
    records = [r for r in records if not (start <= r.end and end >= r.start)]
    records.append(Record(start, end))
    save_records(records)
    print("저장되었습니다.")


def cmd_delete() -> None:
    records = load_records()
    if not records:
        print("데이터가 없습니다.")
        return

    for i, r in enumerate(records, 1):
        print(f"  {i}. {format_date(r.start)} ~ {format_date(r.end)}")
    print(f"  0. 전체 삭제")

    try:
        raw = input("삭제할 번호 (쉼표로 복수 선택): ")
    except (EOFError, KeyboardInterrupt):
        print()
        return

    nums: set[int] = set()
    for part in raw.split(","):
        part = part.strip()
        if part.isdigit():
            nums.add(int(part))

    if not nums:
        print("취소되었습니다.")
        return

    if 0 in nums:
        if DATA_FILE.exists():
            DATA_FILE.unlink()
        print("전체 삭제되었습니다.")
        return

    remaining = [r for i, r in enumerate(records, 1) if i not in nums]
    removed = len(records) - len(remaining)
    if removed == 0:
        print("해당 번호가 없습니다.")
        return

    if remaining:
        save_records(remaining)
    elif DATA_FILE.exists():
        DATA_FILE.unlink()
    print(f"{removed}건 삭제되었습니다.")


def print_help() -> None:
    print("사용법: check [옵션]")
    print()
    print("옵션:")
    print("  (없음)              현재 주기 정보 표시")
    print("  -e, --extend <N>    기본 표시 범위 이후 N일 추가 표시 (1~100)")
    print("  -a, --add           새 기록 추가")
    print("  -d, --delete        기록 삭제")
    print("  -h, --help          도움말 표시")


def main() -> None:
    args = sys.argv[1:]
    if not args:
        cmd_show()
        return

    opt = args[0]
    if opt in ("-h", "--help"):
        print_help()
    elif opt in ("-a", "--add"):
        cmd_add()
    elif opt in ("-d", "--delete"):
        cmd_delete()
    elif opt in ("-e", "--extend"):
        if len(args) >= 2 and args[1].isdigit() and 1 <= int(args[1]) <= 100:
            cmd_show(extra_days=int(args[1]))
        else:
            cmd_show()
    else:
        print_help()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
