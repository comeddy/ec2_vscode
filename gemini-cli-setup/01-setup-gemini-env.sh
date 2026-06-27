#!/bin/bash

# Gemini CLI bashrc 환경변수 설정 스크립트

BASHRC_FILE="$HOME/.bashrc"

echo "=== Gemini CLI 환경변수 설정 ==="
echo

# 인증 방식 선택
echo "인증 방식을 선택하세요:"
echo "  1) Google AI Studio  - GEMINI_API_KEY 사용 (간편, 기본값)"
echo "  2) Vertex AI         - Google Cloud 프로젝트 + ADC 인증"
echo
read -p "선택 (1 또는 2, 기본값: 1): " AUTH_CHOICE

case "$AUTH_CHOICE" in
    2)
        AUTH_MODE="vertex"
        echo "선택: Vertex AI"
        ;;
    *)
        AUTH_MODE="aistudio"
        echo "선택: Google AI Studio"
        ;;
esac

echo

if [ "$AUTH_MODE" = "aistudio" ]; then
    # Google AI Studio 모드
    read -p "GEMINI_API_KEY 값을 입력하세요: " GEMINI_KEY

    if [ -z "$GEMINI_KEY" ]; then
        echo "오류: GEMINI_API_KEY 값이 비어있습니다."
        exit 1
    fi
else
    # Vertex AI 모드
    read -p "Google Cloud Project ID를 입력하세요: " GCP_PROJECT

    if [ -z "$GCP_PROJECT" ]; then
        echo "오류: Project ID가 비어있습니다."
        exit 1
    fi

    echo
    echo "Region을 선택하세요:"
    echo "  1) us-central1  (기본값)"
    echo "  2) us-east4"
    echo "  3) europe-west1"
    echo "  4) asia-northeast1 (도쿄)"
    echo
    read -p "선택 (1-4, 기본값: 1): " REGION_CHOICE

    case "$REGION_CHOICE" in
        2) SELECTED_REGION="us-east4" ;;
        3) SELECTED_REGION="europe-west1" ;;
        4) SELECTED_REGION="asia-northeast1" ;;
        *) SELECTED_REGION="us-central1" ;;
    esac
    echo "선택된 리전: $SELECTED_REGION"
fi

# 모델 선택
echo
echo "기본 모델을 선택하세요:"
echo "  1) gemini-2.5-pro    (고성능, 기본값)"
echo "  2) gemini-2.5-flash  (빠르고 경제적)"
echo
read -p "선택 (1 또는 2, 기본값: 1): " MODEL_CHOICE

case "$MODEL_CHOICE" in
    2) SELECTED_MODEL="gemini-2.5-flash" ;;
    *) SELECTED_MODEL="gemini-2.5-pro" ;;
esac
echo "선택된 모델: $SELECTED_MODEL"

# 기존 설정 확인
if grep -q "# Gemini CLI 설정" "$BASHRC_FILE" 2>/dev/null; then
    echo
    echo "기존 Gemini CLI 설정이 발견되었습니다."
    read -p "기존 설정을 덮어쓰시겠습니까? (y/n): " OVERWRITE
    if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
        sed -i '/# Gemini CLI 설정/,/^$/d' "$BASHRC_FILE"
        echo "기존 설정을 제거했습니다."
    else
        echo "설정을 취소합니다."
        exit 0
    fi
fi

# bashrc에 설정 추가
if [ "$AUTH_MODE" = "aistudio" ]; then
    cat >> "$BASHRC_FILE" << EOF

# Gemini CLI 설정
export GEMINI_API_KEY="${GEMINI_KEY}"
export GEMINI_MODEL="${SELECTED_MODEL}"

EOF

    echo
    echo "bashrc에 설정이 추가되었습니다."
    echo
    echo "설정된 환경변수:"
    echo "  GEMINI_API_KEY = ${GEMINI_KEY:0:10}...${GEMINI_KEY: -4}"
    echo "  GEMINI_MODEL   = $SELECTED_MODEL"
else
    cat >> "$BASHRC_FILE" << EOF

# Gemini CLI 설정
export GOOGLE_CLOUD_PROJECT="${GCP_PROJECT}"
export GOOGLE_CLOUD_LOCATION="${SELECTED_REGION}"
export GEMINI_MODEL="${SELECTED_MODEL}"

EOF

    echo
    echo "bashrc에 설정이 추가되었습니다."
    echo
    echo "설정된 환경변수:"
    echo "  GOOGLE_CLOUD_PROJECT  = $GCP_PROJECT"
    echo "  GOOGLE_CLOUD_LOCATION = $SELECTED_REGION"
    echo "  GEMINI_MODEL          = $SELECTED_MODEL"
    echo
    echo "Vertex AI 사용 시 ADC(Application Default Credentials) 설정이 필요합니다:"
    echo "  gcloud auth application-default login"
fi

echo
echo "설정을 적용하려면 다음 명령어를 실행하세요:"
echo "  source ~/.bashrc"
