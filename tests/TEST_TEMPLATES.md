# Test Templates for Devcontainer Init

## Overview
This document defines test script templates and execution rules for generated devcontainer setups.

Goals:
- predictable pass/fail behavior
- bounded readiness waits with clear reasons
- deployment-mode aware connectivity validation
- machine-readable final report for CI-style runs
- self-contained, rerunnable scripts

---

## Required Script Set

Generate these scripts under `tests/`:

- `00-preflight-tools.sh`
- `01-container-health.sh`
- `02-runtime-language.sh`
- `03-service-readiness.sh`
- `04-connectivity-local.sh` (local dev mode)
- `05-connectivity-image.sh` (docker-image mode)
- `06-connectivity-semi-dev.sh` (semi-dev mode)
- `07-extension-policy.sh`
- `08-env-safety.sh`
- `run-all-tests.sh`

Optional component-specific tests can still be generated (`postgres`, `mongo`, `redis`, `geoserver`, etc.), but the core set above is mandatory.

---

## Global Conventions (All Scripts)

Use this shell contract in every generated script:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Behavior rules:
- no unbounded loops
- explicit timeout and retry limit
- clear failure messages
- exit non-zero on real failures
- print actionable hint when possible

Shared retry helper template:

```bash
retry_until() {
  local name="$1"
  local max_attempts="$2"
  local sleep_seconds="$3"
  local cmd="$4"

  local attempt=1
  while true; do
    if eval "$cmd" >/dev/null 2>&1; then
      echo "PASS: $name"
      return 0
    fi

    if [ "$attempt" -ge "$max_attempts" ]; then
      echo "FAIL: $name (attempts=$max_attempts)"
      echo "Reason: readiness timeout"
      return 1
    fi

    echo "WAIT: $name attempt $attempt/$max_attempts"
    attempt=$((attempt + 1))
    sleep "$sleep_seconds"
  done
}
```

---

## 00-preflight-tools.sh

Purpose:
- verify required tools before service tests run
- fail early with per-OS install hints

Required checks:
- docker
- docker compose or docker-compose
- curl
- language/test CLIs used by generated tests (example: psql, mongosh, redis-cli)

Template:

```bash
#!/usr/bin/env bash
set -euo pipefail

missing=0

check_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "PASS: tool $cmd"
  else
    echo "FAIL: missing tool $cmd"
    missing=1
  fi
}

check_cmd docker
if docker compose version >/dev/null 2>&1; then
  echo "PASS: tool docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  echo "PASS: tool docker-compose"
else
  echo "FAIL: missing docker compose"
  missing=1
fi

check_cmd curl

# Add conditional checks only for selected components
# check_cmd psql
# check_cmd mongosh
# check_cmd redis-cli

if [ "$missing" -ne 0 ]; then
  echo "Install hints:"
  echo "- Linux: use distro package manager for docker, compose plugin, curl"
  echo "- macOS: install Docker Desktop and curl via brew"
  echo "- Windows: install Docker Desktop and ensure curl is available"
  exit 1
fi
```

---

## 01-container-health.sh

Purpose:
- validate base container startup and workspace mounting

Template:

```bash
#!/usr/bin/env bash
set -euo pipefail

[ -d /workspace ] && echo "PASS: workspace mounted" || { echo "FAIL: workspace missing"; exit 1; }

docker ps >/dev/null 2>&1 || { echo "FAIL: docker daemon unreachable"; exit 1; }
echo "PASS: docker daemon reachable"
```

---

## 02-runtime-language.sh

Purpose:
- validate selected language runtimes and essential CLI availability

Examples:

```bash
# Python
python --version >/dev/null 2>&1 || { echo "FAIL: python unavailable"; exit 1; }

# Node.js
node --version >/dev/null 2>&1 || { echo "FAIL: node unavailable"; exit 1; }

# Go
go version >/dev/null 2>&1 || { echo "FAIL: go unavailable"; exit 1; }

# Java
java -version >/dev/null 2>&1 || { echo "FAIL: java unavailable"; exit 1; }
```

---

## 03-service-readiness.sh

Purpose:
- wait for each selected service to become ready
- bounded retries only

Rules:
- each service gets a readiness check
- include reason on failure (dns/auth/timeout/network)

Examples:

```bash
# PostgreSQL
retry_until "postgres-ready" 30 2 "pg_isready -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER}"

# Redis
retry_until "redis-ready" 30 2 "redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} -a ${REDIS_PASSWORD} ping | grep -q PONG"

# GeoServer
retry_until "geoserver-ready" 20 3 "curl -fsS -u ${GEO_ADMIN_USER}:${GEO_ADMIN_PASSWORD} http://${GEO_SERVER_HOST}:${GEO_SERVER_PORT}/geoserver/web/"
```

---

## Deployment-Mode Connectivity Tests

Use exactly one of the following according to deployment mode.

### 04-connectivity-local.sh (Local Dev)

Required checks:
- host-to-service (published host ports)
- service-to-service (internal DNS names)

Examples:

```bash
# Host to service
curl -fsS "http://localhost:${BACKEND_PORT}/health" >/dev/null || { echo "FAIL: host-to-backend"; exit 1; }

# Service to service (run inside app container or using service DNS)
curl -fsS "http://geoserver:${GEO_SERVER_PORT}/geoserver/web/" >/dev/null || { echo "FAIL: backend-to-geoserver"; exit 1; }
```

### 05-connectivity-image.sh (Docker Image Workflow)

Required checks:
- docker build succeeds
- docker run succeeds
- smoke endpoint responds

Examples:

```bash
docker build -t app-smoke:test .
docker run --rm -d --name app-smoke -p 18080:8080 app-smoke:test
retry_until "image-smoke" 20 2 "curl -fsS http://localhost:18080/health"
docker rm -f app-smoke >/dev/null 2>&1 || true
```

### 06-connectivity-semi-dev.sh (Semi-Dev Remote DB)

Required checks:
- remote host reachability
- db probe with env-supplied endpoint
- TLS options validation

Examples:

```bash
# Reachability probe
retry_until "remote-db-port" 15 2 "nc -z ${REMOTE_DB_HOST} ${REMOTE_DB_PORT}"

# PostgreSQL with TLS option example
psql "host=${REMOTE_DB_HOST} port=${REMOTE_DB_PORT} user=${REMOTE_DB_USER} dbname=${REMOTE_DB_NAME} sslmode=${REMOTE_DB_SSLMODE:-require}" -c "SELECT 1;" >/dev/null \
  || { echo "FAIL: remote-db probe (check credentials/network/TLS)"; exit 1; }
```

---

## 07-extension-policy.sh

Purpose:
- enforce minimal extension policy

Policy:
- always `github.copilot`
- one lint extension per selected language
- one docs/intellisense extension per selected language
- flag unexpected extras

Template:

```bash
#!/usr/bin/env bash
set -euo pipefail

DC_FILE=".devcontainer/devcontainer.json"
[ -f "$DC_FILE" ] || { echo "FAIL: missing $DC_FILE"; exit 1; }

# Example approach: parse with jq when available
if command -v jq >/dev/null 2>&1; then
  jq -e '.customizations.vscode.extensions' "$DC_FILE" >/dev/null || { echo "FAIL: no extensions list"; exit 1; }
fi

echo "PASS: extension list present"
# Generator should append explicit allow-list comparison logic per selected stack.
```

---

## 08-env-safety.sh

Purpose:
- verify no unsafe defaults and no obvious real secrets in tracked env templates

Checks:
- `.env.template` contains placeholders instead of production credentials
- flag unsafe values: `password`, `admin`, `changeme`, `devpass`

Template:

```bash
#!/usr/bin/env bash
set -euo pipefail

TARGET=".env.template"
[ -f "$TARGET" ] || { echo "FAIL: missing $TARGET"; exit 1; }

if grep -Eqi '=(password|admin|changeme|devpass)(\s|$)' "$TARGET"; then
  echo "FAIL: unsafe default values detected in $TARGET"
  exit 1
fi

echo "PASS: env safety scan"
```

---

## Master Runner with JSON Report

File: `tests/run-all-tests.sh`

Requirements:
- execute only tests relevant to selected deployment mode
- collect pass/fail details
- write `reports/devcontainer-init-report.json`
- print human summary

Template:

```bash
#!/usr/bin/env bash
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TESTS_DIR/.." && pwd)"
REPORT_DIR="$ROOT_DIR/reports"
REPORT_FILE="$REPORT_DIR/devcontainer-init-report.json"
MODE="${DEVCONTAINER_MODE:-interactive}"
DEPLOYMENT_MODE="${DEPLOYMENT_MODE:-local-dev}"

mkdir -p "$REPORT_DIR"

PASSED=0
FAILED=0
TEST_ROWS=""

run_test() {
  local name="$1"
  local script="$2"

  if [ ! -f "$script" ]; then
    return 0
  fi

  echo "Running: $name"
  if bash "$script"; then
    PASSED=$((PASSED + 1))
    TEST_ROWS="$TEST_ROWS\n{\"name\":\"$name\",\"status\":\"pass\",\"details\":\"ok\"},"
  else
    FAILED=$((FAILED + 1))
    TEST_ROWS="$TEST_ROWS\n{\"name\":\"$name\",\"status\":\"fail\",\"details\":\"see logs\"},"
  fi
}

run_test "preflight-tools" "$TESTS_DIR/00-preflight-tools.sh"
run_test "container-health" "$TESTS_DIR/01-container-health.sh"
run_test "runtime-language" "$TESTS_DIR/02-runtime-language.sh"
run_test "service-readiness" "$TESTS_DIR/03-service-readiness.sh"

case "$DEPLOYMENT_MODE" in
  local-dev)
    run_test "connectivity-local" "$TESTS_DIR/04-connectivity-local.sh"
    ;;
  docker-image)
    run_test "connectivity-image" "$TESTS_DIR/05-connectivity-image.sh"
    ;;
  semi-dev)
    run_test "connectivity-semi-dev" "$TESTS_DIR/06-connectivity-semi-dev.sh"
    ;;
  *)
    echo "FAIL: unknown DEPLOYMENT_MODE=$DEPLOYMENT_MODE"
    FAILED=$((FAILED + 1))
    ;;
esac

run_test "extension-policy" "$TESTS_DIR/07-extension-policy.sh"
run_test "env-safety" "$TESTS_DIR/08-env-safety.sh"

# Trim trailing comma for JSON array
TEST_ROWS_JSON="$(echo "$TEST_ROWS" | sed 's/^\n//' | sed '$ s/,$//')"

cat > "$REPORT_FILE" <<JSON
{
  "mode": "$MODE",
  "deploymentMode": "$DEPLOYMENT_MODE",
  "files": {
    "created": [],
    "updated": []
  },
  "defaultsInferred": [],
  "ports": {
    "requested": {},
    "remapped": {}
  },
  "tests": [
$TEST_ROWS_JSON
  ],
  "fixesApplied": [],
  "remainingManualSteps": []
}
JSON

echo "========================================"
echo "DEVCONTAINER TEST SUMMARY"
echo "========================================"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Report: $REPORT_FILE"

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi
```

---

## Non-Interactive Predictability

When run in non-interactive mode:
- use safe defaults when inputs are missing
- include inferred defaults in report `defaultsInferred`
- include any port remaps in report `ports.remapped`
- keep output deterministic for CI logs

---

## Idempotency Requirements for Test Generation

Re-running init must:
- update scripts in place without duplicating blocks
- preserve user custom sections delimited by markers
- avoid duplicate test registration in `run-all-tests.sh`

Recommended custom section markers:

```text
# BEGIN USER CUSTOM
# END USER CUSTOM
```

---

## Partial Failure Cleanup and Recovery

On partial failure, print cleanup commands and recovery path.

Cleanup template:

```bash
docker compose down -v || true
docker rm -f $(docker ps -aq --filter "name=<project>") 2>/dev/null || true
docker volume prune -f || true
```

Recovery path:
1. Fix the reported issue (missing tool, credentials, network, TLS, port conflict)
2. Re-run `/devcontainer init` (idempotent merge)
3. Re-run `bash tests/run-all-tests.sh`

All scripts must remain self-contained and safe to rerun.
