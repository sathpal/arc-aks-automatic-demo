# shared by every script: load .env, basic checks, helpers
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$ROOT/.env" ] || { echo "no .env: cp .env.example .env and edit it"; exit 1; }
set -a; . "$ROOT/.env"; set +a
export GITHUB_CONFIG_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}"
OUT="$ROOT/out"; mkdir -p "$OUT"
bold() { printf '\n\033[1m%s\033[0m\n' "$*"; }
need() { command -v "$1" >/dev/null || { echo "missing: $1 (run: make tools)"; exit 1; }; }
