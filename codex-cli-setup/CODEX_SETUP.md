# Codex CLI Setup Scripts

VSCode Server 내에서 OpenAI Codex CLI 환경을 구성하는 스크립트 모음입니다.

## 사전 요구사항

| 항목 | 설치 확인 | 설치 방법 |
|------|----------|-----------|
| Codex CLI | `codex --version` | `npm install -g @openai/codex` (03번 스크립트) |
| Node.js / npm | `node --version` | `sudo dnf install -y nodejs` |
| uv / uvx | `uvx --version` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| AWS CLI | `aws --version` | UserData에서 자동 설치됨 |
| jq | `jq --version` | `sudo dnf install -y jq` |

## 스크립트 실행 순서

```
03-update-codex.sh             Codex CLI 설치 (최초 1회)
        |
        v
01-setup-env.sh                환경변수 설정 (API 키, 모델)
        |
        v
   source ~/.bashrc             환경변수 적용
        |
        v
02-setup-mcp-servers.sh        MCP 서버 설정 (~/.codex/mcp.json)
        |
        v
   codex                        Codex CLI 실행
```

---

## 01-setup-env.sh

Codex CLI 실행에 필요한 환경변수를 `~/.bashrc`에 설정합니다.

**실행:**
```bash
bash codex-cli-setup/01-setup-env.sh
source ~/.bashrc
```

**대화형 입력 항목:**
- API Provider 선택 (OpenAI / Amazon Bedrock / 커스텀)
- API 키 (필수, 입력 내용 숨김) - 선택한 Provider에서 발급한 키를 `OPENAI_API_KEY` 환경변수에 저장합니다. Bedrock 선택 시 Amazon Bedrock API 키를 입력하며, OpenAI Platform API 키를 입력하지 않습니다.
- `OPENAI_BASE_URL` - Base URL (Bedrock/커스텀 선택 시)
- 모델 선택 (o4-mini / o3 / gpt-4.1 / codex-mini / 직접 입력)

**설정되는 환경변수:**
```bash
OPENAI_API_KEY          # API 인증 키
OPENAI_BASE_URL         # (Bedrock/커스텀 시) API Base URL
CODEX_DEFAULT_MODEL     # 선택한 모델
```

---

## 02-setup-mcp-servers.sh

`~/.codex/mcp.json`에 AWS MCP 서버를 등록합니다.

**실행:**
```bash
bash codex-cli-setup/02-setup-mcp-servers.sh
```

**등록되는 MCP 서버:**

| 서버 | 패키지 | 기능 |
|------|--------|------|
| awslabs-terraform-mcp-server | `awslabs.terraform-mcp-server` | Terraform/Terragrunt AWS 인프라 개발 |
| awslabs-core-mcp-server | `awslabs.core-mcp-server` | AWS API, Cost Explorer, 다이어그램, 가격 분석 |
| bedrock-agentcore-mcp-server | `awslabs.amazon-bedrock-agentcore-mcp-server` | Bedrock AgentCore Gateway, Memory, Runtime |

**설정 파일:**
```
~/.codex/mcp.json
```

---

## 03-update-codex.sh

Codex CLI를 설치하거나 최신 버전으로 업데이트합니다.

**실행:**
```bash
bash codex-cli-setup/03-update-codex.sh
```

**동작:**
1. Node.js 설치 확인
2. 현재 버전 출력 (이미 설치된 경우)
3. `npm install -g @openai/codex` 실행
4. 설치/업데이트 후 버전 출력

---

## 빠른 시작

```bash
# 1. Codex CLI 설치
bash codex-cli-setup/03-update-codex.sh

# 2. 환경변수 설정
bash codex-cli-setup/01-setup-env.sh
source ~/.bashrc

# 3. MCP 서버 설정
bash codex-cli-setup/02-setup-mcp-servers.sh

# 4. Codex CLI 실행
codex
```
