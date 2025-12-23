# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# 명령어 시간 측정 변수
TIMER_START=0
TIMER_SHOW=""
TIMER_READY=1

# Git 브랜치 함수
parse_git_branch() {
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # 브랜치 이름을 해시하여 0-6 사이의 숫자로 변환
    local hash=0
    for (( i=0; i<${#branch}; i++ )); do
      local char="${branch:$i:1}"
      local ascii=$(LC_CTYPE=C printf '%d' "'$char")
      hash=$(( (hash + ascii) % 7 ))
    done
    # 해시값에 따라 색상 코드 선택 (31-37)
    local color=$((hash + 31))
    # 색상이 적용된 브랜치 이름 반환
    printf "\033[%sm %s\033[0m" "$color" "$branch"
  fi
}

# 명령어 실행 전 타이머 시작 (ble.sh용)
preexec() {
  TIMER_START=$(date +%s%N)
  TIMER_READY=0
}

# 프롬프트 표시 전에 실행 시간 계산
precmd() {
  local EXIT="$?"
  # 실행 시간 계산
  if [[ $TIMER_READY == 0 && $TIMER_START -ne 0 ]]; then
    local TIMER_END=$(date +%s%N)
    local TIMER_DIFF=$((TIMER_END - TIMER_START))
    # 나노초를 밀리초로 변환
    local MS=$((TIMER_DIFF / 1000000))
    # 시간 형식 결정
    if [ $MS -lt 1000 ]; then
      TIMER_SHOW="${MS}ms"
    elif [ $MS -lt 60000 ]; then
      local SEC=$((MS / 1000))
      local MSEC=$((MS % 1000))
      TIMER_SHOW="${SEC}s ${MSEC}ms"
    else
      local MIN=$((MS / 60000))
      local SEC=$(((MS % 60000) / 1000))
      TIMER_SHOW="${MIN}m ${SEC}s"
    fi
  fi
  TIMER_START=0
  TIMER_READY=1
}

# ble.sh 호환 설정
if [[ ${BLE_VERSION-} ]]; then
  blehook PRECMD+=precmd
  blehook PREEXEC+=preexec
else
  # ble.sh가 없는 경우 기본 bash 설정
  trap '[[ $TIMER_READY == 1 ]] && TIMER_START=$(date +%s%N) && TIMER_READY=0' DEBUG
  PROMPT_COMMAND=precmd
fi

# PS1 설정 (개행 포함)
PS1='
\[\033[38;5;252m\]$PWD\[\033[0m\]\[$(parse_git_branch)\] \[\033[38;5;244m\]${TIMER_SHOW}\[\033[0m\]
$ '

# bash-completion
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion 2>/dev/null

# ble.sh
[[ $- == *i* ]] && source $HOME/ble.sh/out/ble.sh 2>/dev/null

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# fzf to dir
fcd() {
  local dir
  dir=$(fd --type d --hidden . ~ 2> /dev/null | \
    fzf --preview 'ls -la --color=always {} | head -100' \
      --preview-window=right:50% \
      --height=80% \
      --layout=reverse \
      --border=rounded \
      --query="$1" \
      --color='hl:yellow,hl+:yellow' \
      --prompt=' ')
  [[ -n "$dir" ]] && cd "$dir"
}

# fzf to file
ff() {
  local file
  file=$(fd --type f --hidden . ~ 2> /dev/null | \
    fzf --height=80% \
      --layout=reverse \
      --border=rounded \
      --query="$1" \
      --prompt=' ')
  if [[ -n "$file" ]]; then
    cd "$(dirname "$file")"
  fi
}

# ocr
ocr() {
  SCREENSHOT_DIR="$HOME/ocr_screenshot"
  rm -rf "$SCREENSHOT_DIR" 2>/dev/null && mkdir -p "$SCREENSHOT_DIR"
  hyprshot -m region -o "$SCREENSHOT_DIR" --silent

  for i in {1..3}; do
    SCREENSHOT_FILE=$(ls $SCREENSHOT_DIR/* 2>/dev/null | head -n 1)
    [ -f "$SCREENSHOT_FILE" ] && break
    [ $i -eq 3 ] && { notify-send "OCR 실패" "스크린샷 생성 실패"; rm -rf "$SCREENSHOT_DIR"; exit 1; }
    sleep 1
  done

  TEXT=$(tesseract "$SCREENSHOT_FILE" stdout -l eng+kor)
  if [ -n "$TEXT" ]; then
    printf '%s' "$TEXT" | wl-copy && notify-send "OCR 완료" "$TEXT"
  else
    notify-send "OCR 실패" "텍스트 추출 실패"
  fi

  rm -rf "$SCREENSHOT_DIR"
}

# pnpm
export PNPM_HOME="/home/soon/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Created by `pipx` on 2025-01-24 00:34:55
export PATH="$PATH:/home/soon/.local/bin"

# code (cursor)
code() {
  nohup /usr/bin/cursor "$@" > /dev/null 2>&1 &
  disown
}

# studio-3t
3t() {
  GDK_SCALE=1 GDK_DPI_SCALE=1.4 /usr/bin/studio-3t "$@" > ~/studio3t.log 2>&1 &
  disown
}

# thunar
open() {
  thunar "$@" > /dev/null 2>&1 &
}

export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$JAVA_HOME/bin:$PATH

export ANDROID_SDK_ROOT=$HOME/android-sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools

export TERMINAL=ghostty

# sudo 다음 명령어에도 alias 적용
alias sudo='sudo '

# 강제 재부팅 (--force --force: 즉시 재부팅, 프로그램 대기 없음)
alias reboot='systemctl reboot --force --force'
