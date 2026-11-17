# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias hyprland='start-hyprland'

# 명령어 시간 측정 (시작 시각 걸린 시간)
CMD_START=""
TIMER_SHOW=""

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

# 걸린 시간을 읽기 쉬운 단위로 (320ms · 2.9s · 1m 05s · 1h 02m 03s)
_fmt_duration() {
  local ms=$1
  if (( ms < 1000 )); then
    printf '%dms' "$ms"
  elif (( ms < 60000 )); then
    printf '%d.%ds' $((ms / 1000)) $((ms % 1000 / 100))
  elif (( ms < 3600000 )); then
    printf '%dm %02ds' $((ms / 60000)) $((ms % 60000 / 1000))
  else
    printf '%dh %02dm %02ds' $((ms / 3600000)) $((ms % 3600000 / 60000)) $((ms % 60000 / 1000))
  fi
}

# 명령어 실행 직전: 시작 시각 기록 (마이크로초, fork 없음)
preexec() {
  CMD_START=${EPOCHREALTIME//[!0-9]/}
}

# 프롬프트 표시 직전: 시작 시각 걸린 시간
precmd() {
  TIMER_SHOW=""
  [[ -n $CMD_START ]] || return 0   # 빈 Enter 면 표시하지 않음 (이전 값 남기지 않음)
  local end=${EPOCHREALTIME//[!0-9]/}
  local ms=$(( (end - CMD_START) / 1000 ))
  printf -v TIMER_SHOW '%(%H:%M:%S)T %s' $(( CMD_START / 1000000 )) "$(_fmt_duration "$ms")"
  CMD_START=""
}

# PS1 설정 (개행 포함)
PS1='
\[\033[38;5;252m\]$PWD\[\033[0m\]\[$(parse_git_branch)\] \[\033[38;5;244m\]${TIMER_SHOW}\[\033[0m\]
$ '

# bash-completion
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion 2>/dev/null

# 패키지 매니저 completion 비활성화
_minimal_complete() { return 0; }
complete -F _minimal_complete paru yay pacman

# ble.sh
[[ $- == *i* ]] && source $HOME/ble.sh/out/ble.sh 2>/dev/null

# 시간 측정 훅 (ble.sh 를 불러온 뒤에 걸어야 BLE_VERSION 이 보인다)
if [[ ${BLE_VERSION-} ]]; then
  blehook PRECMD+=precmd
  blehook PREEXEC+=preexec
else
  trap '[[ -z $CMD_START && $BASH_COMMAND != precmd ]] && preexec' DEBUG
  PROMPT_COMMAND=precmd
fi

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


# timer (스톱워치 / 카운트다운)
timer() {
  local total=0
  if [[ -n "$1" ]]; then
    local arg="$1"
    if [[ "$arg" =~ ^([0-9]+)h$ ]]; then
      total=$(( ${BASH_REMATCH[1]} * 3600 ))
    elif [[ "$arg" =~ ^([0-9]+)m$ ]]; then
      total=$(( ${BASH_REMATCH[1]} * 60 ))
    elif [[ "$arg" =~ ^([0-9]+)s$ ]]; then
      total=${BASH_REMATCH[1]}
    elif [[ "$arg" =~ ^([0-9]+)$ ]]; then
      total=$arg
    else
      echo "사용법: timer [시간]  예: timer 5m, timer 1h, timer 90s"
      return 1
    fi
  fi

  if [[ $total -gt 0 ]]; then
    local remain=$total
    while [[ $remain -ge 0 ]]; do
      local h=$(( remain / 3600 ))
      local m=$(( (remain % 3600) / 60 ))
      local s=$(( remain % 60 ))
      printf "\r%02d:%02d:%02d" $h $m $s
      [[ $remain -eq 0 ]] && break
      sleep 1
      (( remain-- ))
    done
    printf "\n"
    notify-send "타이머 종료" "$(printf '%02d:%02d:%02d' $((total/3600)) $(((total%3600)/60)) $((total%60))) 경과" 2>/dev/null
  else
    local elapsed=0
    while true; do
      local h=$(( elapsed / 3600 ))
      local m=$(( (elapsed % 3600) / 60 ))
      local s=$(( elapsed % 60 ))
      printf "\r%02d:%02d:%02d" $h $m $s
      sleep 1
      (( elapsed++ ))
    done
  fi
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

# thunar
open() {
  thunar "$@" > /dev/null 2>&1 &
}

export PATH="$HOME/.bun/bin:$PATH"

export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$JAVA_HOME/bin:$PATH

export ANDROID_SDK_ROOT=$HOME/android-sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools

export TERMINAL=ghostty

# sudo 다음 명령어에도 alias 적용
alias sudo='sudo '

# 강제 재부팅 (--force --force: 즉시 재부팅, 프로그램 대기 없음)
alias reboot='systemctl reboot --force --force'

check() { python3 ~/workspace/soon-setup/linux/arch/check.py "$@"; }

# 타자연습
alias typo='~/workspace/soon-setup/common/typo/typo'

export PATH=$PATH:/home/soon/.spicetify
