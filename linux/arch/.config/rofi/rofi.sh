#!/bin/bash

# rofi script 모드로 앱 + 계산기 통합

CACHE_FILE="$HOME/.cache/rofi-apps.cache"

# 캐시 생성 함수
generate_cache() {
    {
        find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read desktop; do
            name=$(grep -m 1 "^Name=" "$desktop" | cut -d'=' -f2)
            icon=$(grep -m 1 "^Icon=" "$desktop" | cut -d'=' -f2)
            echo -en "$name\0icon\x1f$icon\n"
        done
    } > "$CACHE_FILE"
}

if [ -z "$@" ]; then
    # .desktop 파일 중 가장 최근 것 찾기
    newest_desktop=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" -printf '%T@\n' 2>/dev/null | sort -n | tail -1 | cut -d. -f1)
    cache_time=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)

    # 캐시가 없거나 새 .desktop 파일이 있으면 재생성
    if [ ! -f "$CACHE_FILE" ] || [ "$newest_desktop" -gt "$cache_time" ]; then
        generate_cache
    fi
    cat "$CACHE_FILE"
else
    input="$@"

    # 계산 결과를 선택한 경우 (= 포함)
    if echo "$input" | grep -q "="; then
        # " = " 뒤에 있는 문자열만 잘라내기 (##*= )
        result="${input##*= }"
        wl-copy "$result"
        exit 0
    fi

    # 계산식인지 확인 (숫자나 연산자 포함 시 계산 시도)
    if echo "$input" | grep -qE '[0-9]+.*[\+\-\*/\^\%\(\)]'; then
        result=$(qalc -t "$input" 2>/dev/null | tail -n1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [ -n "$result" ]; then
            # 결과를 목록에 표시
            echo -en "$input = $result\0info\x1fcalc\n"
            exit 0
        fi
    fi

    # 앱 실행
    desktop=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read d; do
        name=$(grep -m 1 "^Name=" "$d" | cut -d'=' -f2)
        if [ "$name" = "$input" ]; then
            echo "$d"
            break
        fi
    done)

    if [ -n "$desktop" ]; then
        exec=$(grep -m 1 "^Exec=" "$desktop" | cut -d'=' -f2 | sed 's/%.//')
        nohup $exec >/dev/null 2>&1 &
    fi
fi
