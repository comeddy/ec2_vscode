#!/bin/bash
###############################################################################
# OpenAI Codex CLI 설치 스크립트
#
# Node.js / npm 확인 후 @openai/codex를 글로벌 설치합니다.
###############################################################################

set -euo pipefail

# ANSI 색상 코드
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
fail()  { echo -e "${RED}[FAIL]${NC} $*"; exit 1; }

echo "====================================="
echo " OpenAI Codex CLI 설치 스크립트"
echo "====================================="
echo ""

###############################################################################
# 1. 사전 요구사항 확인
###############################################################################
info "=== 사전 요구사항 확인 ==="

# Node.js 확인
if command -v node >/dev/null 2>&1; then
    NODE_VER=$(node --version)
    # Node.js 22+ 필요
    NODE_MAJOR=$(echo "$NODE_VER" | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 22 ]; then
        ok "Node.js: $NODE_VER"
    else
        warn "Node.js: $NODE_VER (22+ 권장, 현재 ${NODE_MAJOR})"
        echo ""
        echo -e "${YELLOW}Node.js 22+가 권장됩니다. 계속하시겠습니까?${NC}"
        read -p "계속 (y/n, 기본값: y): " CONTINUE
        if [ "$CONTINUE" = "n" ] || [ "$CONTINUE" = "N" ]; then
            echo "설치를 취소합니다."
            exit 0
        fi
    fi
else
    fail "Node.js가 설치되어 있지 않습니다. 설치: sudo dnf install -y nodejs"
fi

# npm 확인
if command -v npm >/dev/null 2>&1; then
    ok "npm: $(npm --version)"
else
    fail "npm이 설치되어 있지 않습니다."
fi

# OPENAI_API_KEY 확인
if [ -n "${OPENAI_API_KEY:-}" ]; then
    ok "OPENAI_API_KEY: 설정됨 (${OPENAI_API_KEY:0:10}...)"
else
    warn "OPENAI_API_KEY가 설정되지 않았습니다."
    echo -e "${YELLOW}먼저 01-setup-openai-env.sh를 실행하세요.${NC}"
fi

echo ""

###############################################################################
# 2. 기존 설치 확인
###############################################################################
info "=== Codex CLI 설치 상태 확인 ==="

if command -v codex >/dev/null 2>&1; then
    CURRENT_VER=$(codex --version 2>&1 || echo "unknown")
    warn "Codex CLI가 이미 설치되어 있습니다: $CURRENT_VER"
    read -p "재설치(업데이트) 하시겠습니까? (y/n, 기본값: y): " REINSTALL
    if [ "$REINSTALL" = "n" ] || [ "$REINSTALL" = "N" ]; then
        echo "설치를 취소합니다."
        exit 0
    fi
else
    info "Codex CLI가 설치되어 있지 않습니다. 새로 설치합니다."
fi

echo ""

###############################################################################
# 3. Codex CLI 설치
###############################################################################
info "=== Codex CLI 설치 ==="

info "@openai/codex 글로벌 설치 중..."
if sudo npm install -g @openai/codex 2>&1; then
    ok "@openai/codex 설치 완료"
else
    fail "@openai/codex 설치 실패"
fi

echo ""

###############################################################################
# 4. 설치 검증
###############################################################################
info "=== 설치 검증 ==="

if command -v codex >/dev/null 2>&1; then
    INSTALLED_VER=$(codex --version 2>&1 || echo "unknown")
    ok "Codex CLI: $INSTALLED_VER"
    CODEX_PATH=$(which codex)
    ok "설치 경로: $CODEX_PATH"
else
    fail "codex 명령어를 찾을 수 없습니다. PATH를 확인하세요."
fi

echo ""

###############################################################################
# 5. 결과 요약
###############################################################################
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN} Codex CLI 설치가 완료되었습니다!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo "사용법:"
echo "  codex \"질문 또는 작업 설명\"          대화형 모드"
echo "  codex -q \"질문\"                      조용한 모드 (quiet)"
echo "  codex --model o3 \"질문\"              모델 지정"
echo "  codex --approval-mode full-auto \"질문\" 전체 자동 모드"
echo ""
echo "예시:"
echo "  codex \"현재 디렉토리의 파일 구조를 설명해줘\""
echo "  codex \"이 프로젝트에 대한 README.md를 작성해줘\""
echo ""
if [ -z "${OPENAI_API_KEY:-}" ]; then
    echo -e "${YELLOW}주의: OPENAI_API_KEY가 설정되지 않았습니다.${NC}"
    echo "  bash 01-setup-openai-env.sh 를 먼저 실행하세요."
fi
