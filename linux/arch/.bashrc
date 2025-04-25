# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# 명령어 시작 시간을 저장할 변수
TIMER_START=0

# 명령어 실행 전 타이머 시작
trap 'TIMER_START=$(date +%s%N)' DEBUG

# Git 브랜치 함수
parse_git_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null | sed 's/.*/ \0/'
}

# 프롬프트 표시 전에 실행 시간 계산
PROMPT_COMMAND=__prompt_command

function __prompt_command() {
  local EXIT="$?"
  # 실행 시간 계산
  if [ $TIMER_START -ne 0 ]; then
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
}

# PS1 설정 (개행 포함)
PS1='
\[\033[38;5;252m\]$PWD\[\033[0m\]\[\033[33m\]$(parse_git_branch)\[\033[0m\] \[\033[38;5;244m\]${TIMER_SHOW}\[\033[0m\]
$ '


# ble.sh start
[[ $- == *i* ]] && source $HOME/ble.sh/out/ble.sh

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# fzf to dir
fcd() {
  local dir
  dir=$(find ~ -type d 2> /dev/null | \
    fzf --preview 'ls -la --color=always {} | head -100' \
      --preview-window=right:50% \
      --height=80% \
      --layout=reverse \
      --border=rounded \
      --query="$1" \
      --color='hl:yellow,hl+:yellow' \
      --prompt=' ')
  
  if [[ -n "$dir" ]]; then
    cd "$dir"
  fi
}

# fzf to file
ff() {
  local file
  file=$(find ~ -type f 2> /dev/null | \
    fzf --height=80% \
      --layout=reverse \
      --border=rounded \
      --query="$1" \
      --prompt=' ')
  if [[ -n "$file" ]]; then
    cd "$(dirname "$file")"
  fi
}

# fzf to nvim
fnvim() {
  local dir
  dir=$(find ~ -type d 2> /dev/null | \
    fzf --preview 'ls -la --color=always {} | head -100' \
      --preview-window=right:50% \
      --height=80% \
      --layout=reverse \
      --border=rounded \
      --query="$1" \
      --color='hl:yellow,hl+:yellow' \
      --prompt=' ')

  if [[ -n "$dir" ]]; then
    # CDPATH 설정
    export CDPATH="$dir"
    # 디렉토리 변경
    cd "$dir"
    # PWD 업데이트
    export PWD="$dir"
    # nvim 실행
    nvim .
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

# wezterm detect cwd
if [[ -n "$WEZTERM_PANE" ]]; then
  update_cwd() {
    printf "\033]7;file://%s%s\033\\" "${HOSTNAME}" "$PWD"
  }
  if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND="update_cwd"
  else
    PROMPT_COMMAND="$PROMPT_COMMAND;update_cwd"
  fi
fi

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
  /opt/cursor-bin/cursor-bin.AppImage "$@" > /dev/null 2>&1 &
}

# thunar
open() {
  thunar "$@" > /dev/null 2>&1 &
}

export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$JAVA_HOME/bin:$PATH

export ANDROID_SDK_ROOT=$HOME/android-sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools
