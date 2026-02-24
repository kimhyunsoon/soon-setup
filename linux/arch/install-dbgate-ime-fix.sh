#!/bin/bash
# DbGate kime IME fix 설치 스크립트
# 설치: ./install-dbgate-ime-fix.sh install
# 제거: ./install-dbgate-ime-fix.sh uninstall
set -e

# app.asar 또는 이미 설치된 상태(app-original.asar)에서 기본 경로 반환
find_dbgate_dir() {
    for dir in "/usr/lib/dbgate" "/opt/dbgate-bin/resources" "/opt/dbgate/resources" "/usr/share/dbgate/resources"; do
        if [ -f "$dir/app.asar" ] || [ -f "$dir/app-original.asar" ]; then
            echo "$dir"
            return 0
        fi
    done
    return 1
}

install() {
    echo "=== DbGate kime IME fix 설치 ==="

    DIR="${1:-$(find_dbgate_dir)}" || {
        echo "ERROR: DbGate를 찾을 수 없음. 경로 직접 지정: $0 install /path/to/dbgate/dir"
        exit 1
    }

    ASAR="$DIR/app.asar"
    ORIGINAL="$DIR/app-original.asar"

    # 이미 설치 확인
    if [ -f "$ORIGINAL" ]; then
        echo "이미 설치됨. 재설치: '$0 uninstall' 먼저 실행"
        exit 0
    fi

    [ ! -f "$ASAR" ] && { echo "ERROR: $ASAR 없음"; exit 1; }
    echo "app.asar: $ASAR"

    # @electron/asar 설치 확인
    NPM_GLOBAL="$(npm root -g)"
    if [ ! -d "$NPM_GLOBAL/@electron/asar" ]; then
        echo "@electron/asar 설치 중..."
        npm install -g @electron/asar
        NPM_GLOBAL="$(npm root -g)"
    fi
    export NODE_PATH="$NPM_GLOBAL"

    TMPDIR=$(mktemp -d)
    trap "rm -rf $TMPDIR" EXIT

    # 원래 main entry 확인
    ORIGINAL_MAIN=$(node -e "
      const asar = require('@electron/asar');
      const pkg = JSON.parse(asar.extractFile('$ASAR', 'package.json'));
      console.log(pkg.main || 'index.js');
    ")
    echo "원래 main: $ORIGINAL_MAIN"

    # wrapper 생성
    mkdir -p "$TMPDIR/wrapper"

    cat > "$TMPDIR/wrapper/loader.js" << LOADEREOF
/* dbgate-ime-fix */
const { app } = require('electron');
const path = require('path');

const _imeFix = \`
(function() {
  let dk = false;
  document.addEventListener('keydown', e => {
    if (e.key === 'Backspace' || e.key === 'Delete') dk = true;
  }, true);
  document.addEventListener('keyup', e => {
    if (e.key === 'Backspace' || e.key === 'Delete') dk = false;
  }, true);
  document.addEventListener('beforeinput', e => {
    const t = e.target;
    if ((e.inputType === 'deleteContentBackward' || e.inputType === 'deleteContentForward') && !dk) {
      if (t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA')) {
        const s = { v: t.value, ss: t.selectionStart, se: t.selectionEnd };
        setTimeout(() => {
          const set = Object.getOwnPropertyDescriptor(
            t.tagName === 'INPUT' ? HTMLInputElement.prototype : HTMLTextAreaElement.prototype, 'value'
          )?.set;
          if (set) set.call(t, s.v); else t.value = s.v;
          t.selectionStart = s.ss;
          t.selectionEnd = s.se;
          t.dispatchEvent(new Event('input', { bubbles: true }));
        }, 0);
      }
    }
  }, true);
})();
\`;

app.on('browser-window-created', (_, win) => {
  win.webContents.on('did-finish-load', () => {
    win.webContents.executeJavaScript(_imeFix).catch(() => {});
  });
});

// 원래 앱 로드
require(path.join(__dirname, '..', 'app-original.asar', '$ORIGINAL_MAIN'));
LOADEREOF

    node -e "
      const asar = require('@electron/asar');
      const pkg = JSON.parse(asar.extractFile('$ASAR', 'package.json'));
      pkg.main = 'loader.js';
      require('fs').writeFileSync('$TMPDIR/wrapper/package.json', JSON.stringify(pkg, null, 2));
    "

    echo "wrapper asar 생성 중..."
    npx asar pack "$TMPDIR/wrapper" "$TMPDIR/app.asar"

    echo "적용 중..."
    sudo mv "$ASAR" "$ORIGINAL"
    sudo cp "$TMPDIR/app.asar" "$ASAR"
    sudo chmod a+r "$ASAR"

    echo ""
    echo "=== 완료! DbGate 재시작 필요 ==="
    echo "제거: $0 uninstall"
}

uninstall() {
    echo "=== DbGate kime IME fix 제거 ==="

    DIR="${1:-$(find_dbgate_dir)}" || { echo "ERROR: DbGate를 찾을 수 없음"; exit 1; }
    ASAR="$DIR/app.asar"
    ORIGINAL="$DIR/app-original.asar"

    if [ -f "$ORIGINAL" ]; then
        sudo mv "$ORIGINAL" "$ASAR"
        echo "app.asar 복원됨"
    else
        echo "원본 파일 없음 (이미 제거됨?)"
    fi

    echo ""
    echo "=== 제거 완료! DbGate 재시작 필요 ==="
}

status() {
    DIR="$(find_dbgate_dir 2>/dev/null)" || { echo "상태: DbGate를 찾을 수 없음"; return; }

    if [ -f "$DIR/app-original.asar" ]; then
        echo "상태: ✅ 설치됨"
        echo "경로: $DIR"
    else
        echo "상태: ❌ 미설치"
    fi
}

case "${1:-install}" in
    install)   install "$2" ;;
    uninstall) uninstall "$2" ;;
    status)    status ;;
    *)         echo "사용법: $0 {install|uninstall|status} [dbgate 디렉토리]"; exit 1 ;;
esac
