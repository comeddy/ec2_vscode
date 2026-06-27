#!/bin/bash
###############################################################################
# Gemini CLI 설치 스크립트
#
# Node.js / npm 확인 후 @google/gemini-cli를 글로벌 설치합니다.
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
echo " Gemini CLI 설치 스크립트"
echo "====================================="
echo ""

###############################################################################
# 1. 사전 요구사항 확인
###############################################################################
info "=== 사전 요구사항 확인 ==="

# Node.js 확인
if command -v node >/dev/null 2>&1; then
    NODE_VER=$(node --version)
    NODE_MAJOR=$(echo "$NODE_VER" | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 20 ]; then
        ok "Node.js: $NODE_VER"
    else
        warn "Node.js: $NODE_VER (20+ 필요, 현재 ${NODE_MAJOR})"
        read -p "계속 하시겠습니까? (y/n, 기본값: y): " CONTINUE
        if [ "$CONTINUE" = "n" ] || [ "$CONTINUE" = "N" ]; then
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

# GEMINI_API_KEY 확인
if [ -n "${GEMINI_API_KEY:-}" ]; then
    ok "GEMINI_API_KEY: 설정됨 (${GEMINI_API_KEY:0:10}...)"
elif [ -n "${GOOGLE_CLOUD_PROJECT:-}" ]; then
    ok "GOOGLE_CLOUD_PROJECT: ${GOOGLE_CLOUD_PROJECT} (Vertex AI 모드)"
else
    warn "GEMINI_API_KEY 또는 GOOGLE_CLOUD_PROJECT가 설정되지 않았습니다."
    echo -e "${YELLOW}  먼저 01-setup-gemini-env.sh를 실행하세요.${NC}"
fi

echo ""

###############################################################################
# 2. 기존 설치 확인
###############################################################################
info "=== Gemini CLI 설치 상태 확인 ==="

if command -v gemini >/dev/null 2>&1; then
    CURRENT_VER=$(gemini --version 2>&1 | tail -1 || echo "unknown")
    warn "Gemini CLI가 이미 설치되어 있습니다: v$CURRENT_VER"
    read -p "재설치(업데이트) 하시겠습니까? (y/n, 기본값: y): " REINSTALL
    if [ "$REINSTALL" = "n" ] || [ "$REINSTALL" = "N" ]; then
        echo "설치를 취소합니다."
        exit 0
    fi
else
    info "Gemini CLI가 설치되어 있지 않습니다. 새로 설치합니다."
fi

echo ""

###############################################################################
# 3. Gemini CLI 설치
###############################################################################
info "=== Gemini CLI 설치 ==="

info "@google/gemini-cli 글로벌 설치 중..."
if sudo npm install -g @google/gemini-cli 2>&1; then
    ok "@google/gemini-cli 설치 완료"
else
    fail "@google/gemini-cli 설치 실패"
fi

# ~/.gemini 디렉토리 생성 (초기 오류 방지)
mkdir -p "$HOME/.gemini"

echo ""

###############################################################################
# 4. 설치 검증
###############################################################################
info "=== 설치 검증 ==="

if command -v gemini >/dev/null 2>&1; then
    INSTALLED_VER=$(gemini --version 2>&1 | tail -1 || echo "unknown")
    ok "Gemini CLI: v$INSTALLED_VER"
    GEMINI_PATH=$(which gemini)
    ok "설치 경로: $GEMINI_PATH"
else
    fail "gemini 명령어를 찾을 수 없습니다. PATH를 확인하세요."
fi

echo ""

###############################################################################
# 5. 결과 요약
###############################################################################
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN} Gemini CLI 설치가 완료되었습니다!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo "사용법:"
echo "  gemini                                대화형 모드 시작"
echo "  gemini -p \"질문\"                      단일 프롬프트 실행"
echo "  gemini -m gemini-2.5-flash \"질문\"     모델 지정"
echo "  echo \"질문\" | gemini                  파이프 입력"
echo ""
echo "예시:"
echo "  gemini                                # 대화형 세션 시작"
echo "  gemini -p \"이 프로젝트의 구조를 설명해줘\""
echo ""
if [ -z "${GEMINI_API_KEY:-}" ] && [ -z "${GOOGLE_CLOUD_PROJECT:-}" ]; then
    echo -e "${YELLOW}주의: 인증 정보가 설정되지 않았습니다.${NC}"
    echo "  bash 01-setup-gemini-env.sh 를 먼저 실행하세요."
fi
