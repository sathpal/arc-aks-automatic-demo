#!/usr/bin/env bash
# Preflight: tools, logins, .env values. Run this before anything else.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; ok=0; fail() { echo "  ✗ $*"; ok=1; }; pass() { echo "  ✓ $*"; }
echo "tools"
for t in az kubectl helm gh kubelogin envsubst; do command -v $t >/dev/null && pass "$t" || fail "$t missing (make tools)"; done
v=$(az version --query '"azure-cli"' -o tsv 2>/dev/null); [ "$(printf '%s\n2.80.0\n' "$v" | sort -V | head -1)" = "2.80.0" ] && pass "azure-cli $v" || fail "azure-cli $v is older than 2.80 (make tools)"
az extension show -n aks-preview >/dev/null 2>&1 && fail "aks-preview extension installed: az extension remove -n aks-preview" || pass "no aks-preview extension"
echo "logins"
az account show --query name -o tsv >/dev/null 2>&1 && pass "azure: $(az account show --query name -o tsv)" || fail "not logged in to Azure (az login)"
gh auth status >/dev/null 2>&1 && pass "github: $(gh api user -q .login)" || fail "not logged in to GitHub (gh auth login)"
echo ".env"
if [ -f "$ROOT/.env" ]; then set -a; . "$ROOT/.env"; set +a
  [ "${GITHUB_OWNER:-}" != "your-github-user" ] && [ -n "${GITHUB_OWNER:-}" ] && pass "GITHUB_OWNER=$GITHUB_OWNER" || fail "set GITHUB_OWNER in .env to your GitHub user"
  gh api "repos/${GITHUB_OWNER:-x}/${GITHUB_REPO:-x}/actions/workflows/arc-automatic-validation.yml" >/dev/null 2>&1 && pass "workflow found in $GITHUB_OWNER/$GITHUB_REPO" || fail "workflow not found in $GITHUB_OWNER/$GITHUB_REPO: fork this repo, or push .github/workflows/arc-automatic-validation.yml to that repo"
  pass "LOCATION=$LOCATION RG=$RG CLUSTER=$CLUSTER"
else fail "no .env (cp .env.example .env, then edit GITHUB_OWNER)"; fi
[ -n "${GITHUB_TOKEN:-}" ] && pass "GITHUB_TOKEN is set" || echo "  · GITHUB_TOKEN not set yet; needed for make runners:  export GITHUB_TOKEN=\$(gh auth token)"
[ $ok = 0 ] && echo "ready: make quota" || echo "fix the ✗ lines, then run make check again"
exit $ok
