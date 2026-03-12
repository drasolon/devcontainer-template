# Test Templates for Devcontainer Components

## Overview
After Copilot generates devcontainer configs, these test scripts validate that all components are working correctly.

Generate appropriate test scripts based on selected components.

---

## Basic Container Health Tests

### Test 1: Container Starts Successfully
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 Test 1: Container is running..."
docker ps --filter "status=running" | grep -q "(devcontainer\|dev)" && echo "✅ Container running" || (echo "❌ Container not running" && exit 1)
```

### Test 2: Workspace Directory Accessible
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 Test 2: Workspace directory accessible..."
test -d /workspace && echo "✅ Workspace accessible" || (echo "❌ Workspace not found" && exit 1)
```

---

## Language Runtime Tests

### Python Runtime Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 Python Runtime Test"
PYTHON_VERSION=$(python --version)
echo "Python installed: $PYTHON_VERSION"
python -c "import sys; print('✅ Python working')" || (echo "❌ Python failed" && exit 1)
```

### Node.js Runtime Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 Node.js Runtime Test"
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
echo "Node.js: $NODE_VERSION, npm: $NPM_VERSION"
node -e "console.log('✅ Node.js working')" || (echo "❌ Node.js failed" && exit 1)
```

### Go Runtime Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 Go Runtime Test"
GO_VERSION=$(go version)
echo "Go: $GO_VERSION"
go version | grep -q "go" && echo "✅ Go working" || (echo "❌ Go failed" && exit 1)
```

---

## Database Connection Tests

### PostgreSQL Connection Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 PostgreSQL Connection Test"

TIMEOUT=30
ELAPSED=0

# Wait for PostgreSQL to be ready
while ! pg_isready -h ${DB_HOST:-postgres} -p ${DB_PORT:-5432} -U ${DB_USER} > /dev/null 2>&1; do
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "❌ PostgreSQL not ready after ${TIMEOUT}s"
    exit 1
  fi
  echo "  Waiting for PostgreSQL... ($ELAPSED/$TIMEOUT)"
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

echo "✅ PostgreSQL is accessible"

# Test query
psql -h ${DB_HOST:-postgres} -U ${DB_USER} -d ${DB_NAME} -c "SELECT 1;" > /dev/null && \
echo "✅ PostgreSQL query successful" || (echo "❌ PostgreSQL query failed" && exit 1)
```

### MongoDB Connection Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 MongoDB Connection Test"

TIMEOUT=30
ELAPSED=0

# Wait for MongoDB to be ready
while ! mongosh --host ${MONGO_HOST:-mongodb} --port ${MONGO_PORT:-27017} \
  -u ${MONGO_USER} -p ${MONGO_PASSWORD} \
  --authenticationDatabase admin --eval "db.adminCommand('ping')" > /dev/null 2>&1; do
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "❌ MongoDB not ready after ${TIMEOUT}s"
    exit 1
  fi
  echo "  Waiting for MongoDB... ($ELAPSED/$TIMEOUT)"
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

echo "✅ MongoDB is accessible"

mongosh --host ${MONGO_HOST:-mongodb} -u ${MONGO_USER} -p ${MONGO_PASSWORD} \
  --authenticationDatabase admin --eval "db.stats()" > /dev/null && \
echo "✅ MongoDB query successful" || (echo "❌ MongoDB query failed" && exit 1)
```

### MySQL Connection Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 MySQL Connection Test"

TIMEOUT=30
ELAPSED=0

# Wait for MySQL to be ready
while ! mysqladmin ping -h ${DB_HOST:-mysql} -u ${DB_USER} -p${DB_PASSWORD} > /dev/null 2>&1; do
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "❌ MySQL not ready after ${TIMEOUT}s"
    exit 1
  fi
  echo "  Waiting for MySQL... ($ELAPSED/$TIMEOUT)"
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

echo "✅ MySQL is accessible"

mysql -h ${DB_HOST:-mysql} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} -e "SELECT 1;" > /dev/null && \
echo "✅ MySQL query successful" || (echo "❌ MySQL query failed" && exit 1)
```

### Redis Connection Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 Redis Connection Test"

TIMEOUT=30
ELAPSED=0

# Wait for Redis to be ready
while ! redis-cli -h ${REDIS_HOST:-redis} -p ${REDIS_PORT:-6379} -a ${REDIS_PASSWORD} ping > /dev/null 2>&1; do
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "❌ Redis not ready after ${TIMEOUT}s"
    exit 1
  fi
  echo "  Waiting for Redis... ($ELAPSED/$TIMEOUT)"
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

echo "✅ Redis is accessible"

redis-cli -h ${REDIS_HOST:-redis} -a ${REDIS_PASSWORD} PING | grep -q "PONG" && \
echo "✅ Redis query successful" || (echo "❌ Redis query failed" && exit 1)
```

---

## GIS Component Tests

### PostGIS Extension Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 PostGIS Extension Test"

# First ensure PostgreSQL is ready
pg_isready -h ${DB_HOST:-postgres} -p ${DB_PORT:-5432} -U ${DB_USER} || exit 1

# Check PostGIS extension
psql -h ${DB_HOST:-postgres} -U ${DB_USER} -d ${DB_NAME} -c "CREATE EXTENSION IF NOT EXISTS postgis;" || \
(echo "❌ PostGIS extension not available" && exit 1)

# Test spatial functions
POSTGIS_VERSION=$(psql -h ${DB_HOST:-postgres} -U ${DB_USER} -d ${DB_NAME} -tc "SELECT PostGIS_version();" | head -1)
echo "✅ PostGIS installed: $POSTGIS_VERSION"

# Test basic spatial query
psql -h ${DB_HOST:-postgres} -U ${DB_USER} -d ${DB_NAME} -c \
  "SELECT ST_AsText(ST_GeomFromText('POINT(0 0)', 4326));" > /dev/null && \
echo "✅ PostGIS spatial functions working" || (echo "❌ PostGIS spatial functions failed" && exit 1)
```

### GeoServer Availability Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 GeoServer Availability Test"

TIMEOUT=60
ELAPSED=0

# Wait for GeoServer to be ready
while ! curl -s -u ${GEO_ADMIN_USER}:${GEO_ADMIN_PASSWORD} \
  http://${GEO_SERVER_HOST:-geoserver}:${GEO_SERVER_PORT:-8080}/geoserver/web/ > /dev/null 2>&1; do
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "❌ GeoServer not ready after ${TIMEOUT}s"
    exit 1
  fi
  echo "  Waiting for GeoServer... ($ELAPSED/$TIMEOUT)"
  sleep 3
  ELAPSED=$((ELAPSED + 3))
done

echo "✅ GeoServer is running"

# Test REST API
curl -s -u ${GEO_ADMIN_USER}:${GEO_ADMIN_PASSWORD} \
  http://${GEO_SERVER_HOST:-geoserver}:${GEO_SERVER_PORT:-8080}/geoserver/rest/about/version.json | grep -q "Version" && \
echo "✅ GeoServer REST API working" || (echo "❌ GeoServer REST API failed" && exit 1)
```

### QGIS Server Availability Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 QGIS Server Availability Test"

TIMEOUT=30
ELAPSED=0

# Wait for QGIS Server to be ready
while ! curl -s "http://${QGIS_SERVER_HOST:-qgis-server}:${QGIS_SERVER_PORT:-9080}/" > /dev/null 2>&1; do
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "❌ QGIS Server not ready after ${TIMEOUT}s"
    exit 1
  fi
  echo "  Waiting for QGIS Server... ($ELAPSED/$TIMEOUT)"
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

echo "✅ QGIS Server is running"

# Test WMS GetCapabilities
curl -s "http://${QGIS_SERVER_HOST:-qgis-server}:${QGIS_SERVER_PORT:-9080}/?service=wms&version=1.3.0&request=GetCapabilities" | grep -q "WMS_Capabilities" && \
echo "✅ QGIS WMS service available" || (echo "⚠️  QGIS WMS not fully configured" && exit 0)
```

---

## Development Server Tests

### Frontend Dev Server Port Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 Frontend Dev Server Port Test (3000)"

TIMEOUT=30
ELAPSED=0

# Wait for port 3000 to open
while ! timeout 1 bash -c "cat < /dev/null > /dev/tcp/localhost/3000" 2>/dev/null; do
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "⚠️  Frontend server not accessible on port 3000 after ${TIMEOUT}s (may not be running)"
    exit 0
  fi
  echo "  Waiting for port 3000... ($ELAPSED/$TIMEOUT)"
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

echo "✅ Frontend dev server accessible on port 3000"

# Test HTTP response
curl -s http://localhost:3000 > /dev/null && \
echo "✅ Frontend dev server responding" || echo "⚠️  Frontend server not responding (may be in startup)"
```

### Backend API Server Port Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 Backend API Server Port Test (3001 or 8000)"

BACKEND_PORT=${BACKEND_PORT:-3001}
TIMEOUT=30
ELAPSED=0

# Wait for backend port to open
while ! timeout 1 bash -c "cat < /dev/null > /dev/tcp/localhost/${BACKEND_PORT}" 2>/dev/null; do
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "⚠️  Backend server not accessible on port ${BACKEND_PORT} after ${TIMEOUT}s (may not be running)"
    exit 0
  fi
  echo "  Waiting for port ${BACKEND_PORT}... ($ELAPSED/$TIMEOUT)"
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

echo "✅ Backend API accessible on port ${BACKEND_PORT}"

# Test health endpoint (customize as needed)
curl -s http://localhost:${BACKEND_PORT}/health > /dev/null 2>&1 && \
echo "✅ Backend health check passed" || echo "⚠️  Backend not responding on /health (may be custom endpoint)"
```

---

## Development Tools Tests

### Git Configuration Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 Git Configuration Test"

git --version > /dev/null && echo "✅ Git installed" || (echo "❌ Git not found" && exit 1)
git config user.name > /dev/null && echo "✅ Git user configured" || echo "⚠️  Git user not configured"
git status > /dev/null 2>&1 && echo "✅ Git repository detected" || echo "⚠️  No git repository in workspace"
```

### Docker CLI Test
**Command**:
```bash
#!/bin/bash
set -e

echo "🧪 Docker CLI Test"

docker --version > /dev/null && echo "✅ Docker CLI available" || (echo "❌ Docker not found" && exit 1)
docker ps > /dev/null && echo "✅ Docker daemon accessible" || (echo "❌ Docker daemon not accessible" && exit 1)
```

### Debugger Availability Test

#### Python Debugpy
```bash
#!/bin/bash
set -e

echo "🧪 Python Debugpy Test"

python -c "import debugpy; print('✅ debugpy available')" || \
(echo "❌ debugpy not installed" && exit 1)
```

#### Node Inspector (Built-in)
```bash
#!/bin/bash
set -e

echo "🧪 Node.js Debugger Test"

node --inspect-brk --version > /dev/null && \
echo "✅ Node.js debugger available" || (echo "❌ Node.js debugger failed" && exit 1)
```

---

## Master Test Script Template

**File**: `tests/run-all-tests.sh`

```bash
#!/bin/bash

# Master test runner
# Run all component tests and report summary

set -e

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASSED=0
FAILED=0
WARNED=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "  🚀 DEVCONTAINER COMPONENT TEST SUITE"
echo "================================================"
echo ""

# Load environment
if [ -f "$TESTS_DIR/../.env" ]; then
  export $(cat "$TESTS_DIR/../.env" | xargs)
fi

# Run individual test scripts
run_test() {
  local test_name="$1"
  local test_script="$2"
  
  if [ -f "$test_script" ]; then
    echo "Running: $test_name"
    if bash "$test_script"; then
      PASSED=$((PASSED + 1))
    else
      FAILED=$((FAILED + 1))
    fi
  else
    echo "Skipping: $test_name (not applicable)"
  fi
  echo ""
}

run_test "Workspace" "$TESTS_DIR/01-workspace.sh"
run_test "Python Runtime" "$TESTS_DIR/02-python.sh"
run_test "Node.js Runtime" "$TESTS_DIR/03-node.sh"
run_test "PostgreSQL" "$TESTS_DIR/04-postgres.sh"
run_test "PostGIS" "$TESTS_DIR/05-postgis.sh"
run_test "GeoServer" "$TESTS_DIR/06-geoserver.sh"
run_test "Redis" "$TESTS_DIR/07-redis.sh"
run_test "Git" "$TESTS_DIR/08-git.sh"
run_test "Docker" "$TESTS_DIR/09-docker.sh"

# Summary
echo "================================================"
echo "  📊 TEST SUMMARY"
echo "================================================"
echo -e "${GREEN}✅ Passed: $PASSED${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}⚠️  Some tests failed. Please review above.${NC}"
  exit 1
fi
```

---

## How Copilot Should Use These Tests

1. **After Configuration**, generate selected test scripts based on user's component choices
2. **Place in** `/workspace/tests/` directory
3. **Make executable**: `chmod +x tests/*.sh`
4. **Run**: `bash tests/run-all-tests.sh` OR individual tests
5. **Report results** to user with detailed output
6. **If failures**: Provide troubleshooting steps

**Example Output**:
```
================================================
  🚀 DEVCONTAINER COMPONENT TEST SUITE
================================================

Running: Workspace
✅ Workspace accessible
...
✅ PostgreSQL is accessible
✅ PostgreSQL query successful
...
================================================
  📊 TEST SUMMARY
================================================
✅ Passed: 9
❌ Failed: 0

🎉 All tests passed!
```
