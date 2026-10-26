import sys
import csv
import math
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

# 위치/가능성 표시 단계 (1~SCALE)
SCALE = 5

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
    # target을 감싸는 구간 찾기: 이전 시작일(base)과 바로 다음 시작일(next_start)
    base = None
    next_start = None
    for r in records:
        if r.start <= target:
            base = r.start
        elif next_start is None:
            next_start = r.start
    if base is None:
        # 모든 기록이 target 이후 → 첫 기록 기준 역산
        days_diff = (records[0].start - target).days
        return (-days_diff) % avg_cycle + 1
    days_since = (target - base).days
    # 다음 실제 기록이 존재하면 base~next 구간은 실측 주기 → 모듈로 없이 그대로 일차 계산
    if next_start is not None:
        return days_since + 1
    # 마지막 기록 이후 → 데이터 없음, 평균 주기로 추측
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


# 정점 이후 다음 시작까지의 고정 지연(일)과 그 자체의 변동(σ)
PEAK_LAG = 13
LAG_SIGMA = 1.0


def _gap_stats(records: list[Record]) -> tuple[float, float]:
    # 관측 간격 + 기본 28일(가상 관측 1개)의 평균과 표본 표준편차. 극단 이상치는 없다고 가정.
    # 간격 변동은 대부분 정점 이전 구간에서 생기므로 정점일 σ ≈ 간격 σ, 여기에 고정 지연 변동을 합산.
    # 간격 σ 하한 1.0은 규칙적 주기에서도 존재하는 자연 변동, 상한 4.0은 과도한 평탄화 방지
    gaps = [(records[i + 1].start - records[i].start).days for i in range(len(records) - 1)]
    vals = [float(g) for g in gaps] + [float(DEFAULT_CYCLE)]
    mu = sum(vals) / len(vals)
    var = sum((v - mu) ** 2 for v in vals) / max(len(vals) - 1, 1)
    gap_sigma = min(max(math.sqrt(var), 1.0), 4.0)
    return mu, math.sqrt(gap_sigma**2 + LAG_SIGMA**2)


def _normal_dist(center: float, sigma: float) -> list[tuple[int, float]]:
    # 정점일(주기일차) 정규분포를 ±2.5σ 범위에서 이산화해 정규화
    lo = max(1, math.floor(center - 2.5 * sigma))
    hi = math.ceil(center + 2.5 * sigma)
    raw = [(pk, math.exp(-((pk - center) ** 2) / (2 * sigma**2))) for pk in range(lo, hi + 1)]
    total = sum(w for _, w in raw)
    return [(pk, w / total) for pk, w in raw]


def peak_distribution(records: list[Record], target: date) -> list[tuple[int, float]]:
    # target이 속한 구간의 다음 시작이 이미 기록돼 있으면 실측 간격 기준(지연 변동만 남음),
    # 아니면 평균 간격 기준 예측 분포
    base = next_start = None
    for r in records:
        if r.start <= target:
            base = r.start
        elif next_start is None:
            next_start = r.start
    if base is not None and next_start is not None:
        return _normal_dist((next_start - base).days - PEAK_LAG, LAG_SIGMA)
    mu, sigma = _gap_stats(records)
    return _normal_dist(mu - PEAK_LAG, sigma)


# 정점일 기준(diff = 주기일차 - 정점일) 일별 확률. 관측 연구 기반 값으로 정점 당일까지 이어지고
# 정점 다음 날부터는 사실상 0
_LEVEL_TABLE = {-5: 0.10, -4: 0.16, -3: 0.14, -2: 0.27, -1: 0.31, 0: 0.33}

# 정점일 기준 상대 높이(0~1). 정점 일주일 전부터 점진 상승, 정점 전후 최고, 이후 이틀 내 급강하
_POSITION_TABLE = {
    -7: 0.10, -6: 0.20, -5: 0.30, -4: 0.45, -3: 0.60, -2: 0.80, -1: 1.00,
    0: 1.00, 1: 0.60, 2: 0.30, 3: 0.10,
}


# 정점일 분포 하에서의 기댓값 (정점일 불확실성을 확률 가중으로 반영)
def _expected(cycle_day: int, dist: list[tuple[int, float]], table: dict[int, float]) -> float:
    return sum(w * table.get(cycle_day - pk, 0.0) for pk, w in dist)


def _scaled(cycle_day: int, dist: list[tuple[int, float]], table: dict[int, float]) -> int:
    # 해당 분포에서 도달 가능한 최고 기댓값을 SCALE, 0을 1로 두는 상대 단계
    horizon = dist[-1][0] + 4
    top = max(_expected(cd, dist, table) for cd in range(1, horizon + 1))
    if top <= 0:
        return 1
    return 1 + round((SCALE - 1) * _expected(cycle_day, dist, table) / top)


def eval_level(cycle_day: int, dist: list[tuple[int, float]]) -> int:
    return _scaled(cycle_day, dist, _LEVEL_TABLE)


def eval_position(cycle_day: int, dist: list[tuple[int, float]]) -> int:
    return _scaled(cycle_day, dist, _POSITION_TABLE)


def color_position(v: int) -> str:
    if v <= SCALE * 0.4:
        return f"{C_RED}{v}{C_RESET}"
    if v >= SCALE * 0.8:
        return f"{C_GREEN}{v}{C_RESET}"
    return str(v)


def color_level(v: int) -> str:
    if v <= SCALE * 0.4:
        return f"{C_GREEN}{v}{C_RESET}"
    if v >= SCALE * 0.8:
        return f"{C_RED}{v}{C_RESET}"
    return str(v)


def cmd_show(extra_days: int = 0) -> None:
    records = load_records()
    if not records:
        print("데이터가 없습니다. 'check add'로 추가해주세요.")
        return

    today = date.today()

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
        dist = peak_distribution(records, d)
        lv = eval_level(cd, dist)
        ps = eval_position(cd, dist)

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


def cmd_list() -> None:
    records = load_records()
    if not records:
        print("데이터가 없습니다.")
        return

    avg_cycle = calc_avg_cycle(records)
    for i, r in enumerate(records, 1):
        # 직전 기록과의 간격 표시
        if i < len(records):
            gap = (records[i].start - r.start).days
            print(f"  {i}. {format_date(r.start)} ~ {format_date(r.end)}  (+{gap}일)")
        else:
            print(f"  {i}. {format_date(r.start)} ~ {format_date(r.end)}")
    print()
    print(f"총 {len(records)}건, 평균 주기 {avg_cycle}일")


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
    print("  -l, --list          추가한 기록 목록 표시")
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
    elif opt in ("-l", "--list"):
        cmd_list()
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
