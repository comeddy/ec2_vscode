#!/bin/bash

# OpenAI Codex CLI bashrc 환경변수 설정 스크립트

BASHRC_FILE="$HOME/.bashrc"

echo "=== OpenAI Codex CLI 환경변수 설정 ==="
echo

# OPENAI_API_KEY 값 입력받기
read -p "OPENAI_API_KEY 값을 입력하세요: " OPENAI_KEY

if [ -z "$OPENAI_KEY" ]; then
    echo "오류: OPENAI_API_KEY 값이 비어있습니다."
    exit 1
fi

# 모델 선택
echo
echo "기본 모델을 선택하세요:"
echo "  1) o4-mini     (빠르고 경제적, 기본값)"
echo "  2) o3          (고성능 추론)"
echo "  3) gpt-4.1     (범용 고성능)"
echo "  4) gpt-4.1-mini (범용 경제적)"
echo
read -p "선택 (1-4, 기본값: 1): " MODEL_CHOICE

case "$MODEL_CHOICE" in
    2) SELECTED_MODEL="o3" ;;
    3) SELECTED_MODEL="gpt-4.1" ;;
    4) SELECTED_MODEL="gpt-4.1-mini" ;;
    *) SELECTED_MODEL="o4-mini" ;;
esac
echo "선택된 모델: $SELECTED_MODEL"

# 승인 모드 선택
echo
echo "Codex 승인 모드를 선택하세요:"
echo "  1) suggest    - 모든 작업에 대해 승인 요청 (기본값, 가장 안전)"
echo "  2) auto-edit  - 파일 편집은 자동, 명령어 실행은 승인 요청"
echo "  3) full-auto  - 모든 작업 자동 실행 (주의 필요)"
echo
read -p "선택 (1-3, 기본값: 1): " APPROVAL_CHOICE

case "$APPROVAL_CHOICE" in
    2) SELECTED_APPROVAL="auto-edit" ;;
    3) SELECTED_APPROVAL="full-auto" ;;
    *) SELECTED_APPROVAL="suggest" ;;
esac
echo "선택된 승인 모드: $SELECTED_APPROVAL"

# 기존 설정 확인
if grep -q "# OpenAI Codex CLI 설정" "$BASHRC_FILE" 2>/dev/null; then
    echo
    echo "기존 Codex CLI 설정이 발견되었습니다."
    read -p "기존 설정을 덮어쓰시겠습니까? (y/n): " OVERWRITE
    if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
        sed -i '/# OpenAI Codex CLI 설정/,/^$/d' "$BASHRC_FILE"
        echo "기존 설정을 제거했습니다."
    else
        echo "설정을 취소합니다."
        exit 0
    fi
fi

# bashrc에 설정 추가
cat >> "$BASHRC_FILE" << EOF

# OpenAI Codex CLI 설정
export OPENAI_API_KEY="${OPENAI_KEY}"
export CODEX_DEFAULT_MODEL="${SELECTED_MODEL}"
export CODEX_APPROVAL_MODE="${SELECTED_APPROVAL}"

EOF

echo
echo "bashrc에 설정이 추가되었습니다."
echo
echo "설정된 환경변수:"
echo "  OPENAI_API_KEY       = ${OPENAI_KEY:0:10}...${OPENAI_KEY: -4}"
echo "  CODEX_DEFAULT_MODEL  = $SELECTED_MODEL"
echo "  CODEX_APPROVAL_MODE  = $SELECTED_APPROVAL"
echo
echo "설정을 적용하려면 다음 명령어를 실행하세요:"
echo "  source ~/.bashrc"
