# Configuration Generators Guide

## Overview
Based on user selections from the wizard, generate appropriate configuration files:
1. `.devcontainer/devcontainer.json` (Main devcontainer config)
2. `docker-compose.yml` (Services orchestration)
3. `.env.template` / `.env.example` (Environment variables)
4. `Dockerfile` (If deployment required)
5. Backend config files (For framework-specific database connections)
6. Test scripts (In `tests/` directory)

Generation must support both interactive and non-interactive runs.

---

## Run Modes

### Interactive Mode (default)
- Ask all questions from the wizard.
- Confirm critical decisions (image, deployment mode, ports, framework).

### Non-Interactive Mode (`--non-interactive`)
- If answers are missing, use safe defaults and continue.
- Never block waiting for user input.
- Emit a final inferred-defaults summary so CI behavior is predictable.

Suggested defaults when missing:
- Deployment: `development-local`
- Base image: language-optimized image or `mcr.microsoft.com/devcontainers/base:ubuntu`
- Database ports: standard defaults with conflict-aware remap
- Secrets: placeholders only (or generated random values only when explicitly local-only)
- Java framework: `spring-boot` with a `plain-java` fallback profile

Required end-of-run summary fields:
- missing inputs detected
- defaults inferred
- any auto-remapped ports
- files created/updated

---

## 1. devcontainer.json Generator

### Template Structure
```json
{
  "name": "[PROJECT_NAME]",
  "image": "[SELECTED_BASE_IMAGE]",
  "features": {
    // Language features based on selection
  },
  "forwardPorts": [
    // Ports from selected services
  ],
  "portsAttributes": {
    // Port labels and auto-forward settings
  },
  "mounts": [
    // Volume mounts
  ],
  "remoteEnv": {
    // Environment variables
  },
  "postCreateCommand": "[SETUP_COMMANDS]",
  "customizations": {
    "vscode": {
      "extensions": [
        // Recommended vs code extensions
      ],
      "settings": {}
    }
  }
}
```

### Generation Logic

**Step 1: Determine Base Image**
- User selected from: Ubuntu, Python, Node.js, Go, Java, or Custom
- Map to official image URL
- Before finalizing, validate architecture compatibility for both `amd64` and `arm64` tags.
- Output reasoning for the selected image:
  - chosen image/tag
  - why it was chosen
  - tradeoffs (size, flexibility, preinstalled tools)

Example reasoning output:
```text
Image selected: mcr.microsoft.com/devcontainers/typescript-node:20-bullseye
Reason: Node.js/TypeScript detected as primary stack.
Tradeoffs: larger than base Ubuntu, but faster setup due to preinstalled toolchain.
Arch check: amd64=ok, arm64=ok
```

**Step 2: Add Language Features**
```json
{
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.11"  // if Python selected
    },
    "ghcr.io/devcontainers/features/node:1": {
      "version": "20"    // if Node.js selected
    }
  }
}
```

**Step 3: Add Port Forwarding**
- Collect all service ports from user selections
- Python/FastAPI: 8000
- React/Vue: 3000
- Express: 3001
- PostgreSQL: 5432
- MongoDB: 27017
- Redis: 6379
- GeoServer: 8080
- QGIS Server: 9080

```json
{
  "forwardPorts": [3000, 3001, 5432, 8000, 8080],
  "portsAttributes": {
    "3000": {"label": "Frontend Dev Server", "onAutoForward": "notify"},
    "3001": {"label": "Backend API", "onAutoForward": "notify"},
    "5432": {"label": "PostgreSQL", "onAutoForward": "silent"},
    "8000": {"label": "PyServer", "onAutoForward": "notify"},
    "8080": {"label": "GeoServer", "onAutoForward": "notify"}
  }
}
```

**Step 3.1: Port Preflight & Remap**
- Before writing files, check host port conflicts.
- If a requested host port is in use, suggest the next available port and auto-remap when approved (or in non-interactive mode).
- Reflect remapped ports consistently in:
  - `docker-compose.yml`
  - `.env.template` and `.env`
  - backend config files
  - test scripts

Suggested check commands:
```bash
ss -ltn | awk '{print $4}'
docker ps --format '{{.Ports}}'
```

Remap example:
```text
Requested: 5432
In use: yes
Remapped to: 55432
```

**Step 4: Add Development Tools**
- If Docker selected: add docker-in-docker feature
- If Git selected: add git feature
- Debuggers: configure in VS Code extensions

**Step 5: Add Minimal Extensions (strict policy)**
Keep extension installation intentionally small:

**Always install**:
- `github.copilot` - GitHub Copilot

**Install one primary linting extension based on stack**:
- Python: `charliermarsh.ruff`
- Node.js/TypeScript: `dbaeumer.vscode-eslint`
- Go: `golang.go` (includes lint and language tooling)
- Java: `redhat.java` (language tooling and diagnostics)

**Install one docs/intellisense extension for function/class info**:
- Python: `ms-python.vscode-pylance`
- Node.js/TypeScript: `ms-vscode.vscode-typescript-next`
- Go: `golang.go`
- Java: `redhat.java`

Do not install large bundles by default. Keep it to 2-4 extensions total depending on selected stack.

**Example devcontainer.json**:
```json
{
  "name": "GIS Fullstack App",
  "image": "mcr.microsoft.com/devcontainers/typescript-node:20-bullseye",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/python:1": {"version": "3.11"}
  },
  "forwardPorts": [3000, 3001, 5432, 8080],
  "portsAttributes": {
    "3000": {"label": "Frontend", "onAutoForward": "notify"},
    "3001": {"label": "Backend API", "onAutoForward": "notify"},
    "5432": {"label": "PostgreSQL", "onAutoForward": "silent"},
    "8080": {"label": "GeoServer", "onAutoForward": "notify"}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "github.copilot",
        "dbaeumer.vscode-eslint",
        "ms-vscode.vscode-typescript-next"
      ]
    }
  },
  "postCreateCommand": "npm install && pip install -r requirements.txt || true"
}
```

---

## 2. docker-compose.yml Generator

### Template Structure
```yaml
version: '3.8'

services:
  # Service entries based on selections

volumes:
  # Volume definitions

networks:
  # Network configuration
```

### Generation Logic

**Step 1: Determine Services to Include**
Based on user selections:
- [ ] PostgreSQL
- [ ] MongoDB
- [ ] MySQL
- [ ] Redis
- [ ] GeoServer
- [ ] QGIS Server
- [ ] Custom services

**Step 2: Build Service Entries**

All services must include healthchecks where practical. If a service image lacks native health probes, add a readiness command in test scripts.

**PostgreSQL Service**:
```yaml
services:
  postgres:
    image: postgis/postgis:16-3.4  # PostGIS if selected OR postgres:16-alpine if not
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: ${DB_USER:-devuser}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-devpass}
      POSTGRES_DB: ${DB_NAME:-appdb}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-devuser}"]
      interval: 10s
      timeout: 5s
      retries: 5
```

**MongoDB Service**:
```yaml
  mongodb:
    image: mongo:7.0
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER:-devuser}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD:-devpass}
    volumes:
      - mongodb_data:/data/db
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/test --quiet
      interval: 10s
      timeout: 5s
      retries: 5
```

**Redis Service**:
```yaml
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --requirepass ${REDIS_PASSWORD:-devpass}
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
```

**GeoServer Service**:
```yaml
  geoserver:
    image: kartoza/geoserver:2.23.0
    ports:
      - "8080:8080"
    environment:
      GEOSERVER_ADMIN_USER: ${GEO_ADMIN_USER:-admin}
      GEOSERVER_ADMIN_PASSWORD: ${GEO_ADMIN_PASSWORD:-geoserver}
    volumes:
      - geoserver_data:/opt/geoserver/data_dir
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/geoserver/web/"]
      interval: 30s
      timeout: 10s
      retries: 3
```

**Step 3: Define Volumes**
```yaml
volumes:
  postgres_data:
    driver: local
  mongodb_data:
    driver: local
  geoserver_data:
    driver: local
```

**Step 4: Link Services (Networks)**
All services on same network for internal communication:
```yaml
networks:
  app_network:
    driver: bridge
```

Each service gets:
```yaml
services:
  postgres:
    networks:
      - app_network
```

**Complete docker-compose.yml Example**:
```yaml
version: '3.8'

services:
  postgres:
    image: postgis/postgis:16-3.4
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: ${DB_USER:-devuser}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-devpass}
      POSTGRES_DB: ${DB_NAME:-appdb}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-devuser}"]
      interval: 10s
      timeout: 5s
      retries: 5

  geoserver:
    image: kartoza/geoserver:2.23.0
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    environment:
      GEOSERVER_ADMIN_USER: ${GEO_ADMIN_USER:-admin}
      GEOSERVER_ADMIN_PASSWORD: ${GEO_ADMIN_PASSWORD:-geoserver}
    volumes:
      - geoserver_data:/opt/geoserver/data_dir
    networks:
      - app_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/geoserver/web/"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
    driver: local
  geoserver_data:
    driver: local

networks:
  app_network:
    driver: bridge
```

---

## 3. .env Template Generator

### Generation Logic

**Step 1: Create .env.template**
All variables with explanations, NO real secrets.

Security requirements:
- Never commit real credentials.
- Use placeholders only in `.env.template`.
- Optional: generate random passwords only for local-only dev when user opts in.
- Add unsafe-default detection (for values like `password`, `admin`, `changeme`, `devpass`).

**Step 2: Reference Components**

**Python/Framework Variables**:
```bash
# Application
APP_ENV=development
APP_DEBUG=true
APP_PORT=8000
SECRET_KEY=your-secret-key-here

# Database
DATABASE_URL=postgresql://devuser:devpass@postgres:5432/appdb
SQLALCHEMY_DATABASE_URL=postgresql://devuser:devpass@postgres:5432/appdb
```

**Node.js/Express Variables**:
```bash
# Application
NODE_ENV=development
PORT=3001
DEBUG=*

# Database
DB_HOST=postgres
DB_PORT=5432
DB_USER=devuser
DB_PASSWORD=__REPLACE_WITH_SECURE_VALUE__
DB_NAME=appdb
DATABASE_URL=postgresql://devuser:__REPLACE_WITH_SECURE_VALUE__@postgres:5432/appdb
```

**GIS Variables**:
```bash
# GeoServer
GEO_SERVER_HOST=geoserver
GEO_SERVER_PORT=8080
GEO_ADMIN_USER=__REPLACE_WITH_SECURE_VALUE__
GEO_ADMIN_PASSWORD=__REPLACE_WITH_SECURE_VALUE__

# PostGIS
POSTGIS_DB_HOST=postgres
POSTGIS_DB_PORT=5432
POSTGIS_DB_USER=devuser
POSTGIS_DB_PASSWORD=devpass
POSTGIS_DB_NAME=gisdb
```

**Redis Variables**:
```bash
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=__REPLACE_WITH_SECURE_VALUE__
REDIS_URL=redis://:__REPLACE_WITH_SECURE_VALUE__@redis:6379
```

**Complete .env.template Example**:
```bash
# ==================================
# Application Configuration
# ==================================
APP_ENV=development
APP_NAME=gis-fullstack-app
DEBUG=true

# ==================================
# Backend Server
# ==================================
BACKEND_PORT=3001
BACKEND_HOST=0.0.0.0

# ==================================
# Database (PostgreSQL + PostGIS)
# ==================================
DB_HOST=postgres
DB_PORT=5432
DB_USER=devuser
DB_PASSWORD=__REPLACE_WITH_SECURE_VALUE__
DB_NAME=gisdb

# Connection string for ORMs
DATABASE_URL=postgresql://devuser:__REPLACE_WITH_SECURE_VALUE__@postgres:5432/gisdb

# ==================================
# GeoServer Configuration
# ==================================
GEO_SERVER_HOST=geoserver
GEO_SERVER_PORT=8080
GEO_ADMIN_USER=__REPLACE_WITH_SECURE_VALUE__
GEO_ADMIN_PASSWORD=__REPLACE_WITH_SECURE_VALUE__

# ==================================
# Redis Configuration
# ==================================
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=__REPLACE_WITH_SECURE_VALUE__

# ==================================
# Development Tools
# ==================================
LOG_LEVEL=debug
TESTING=false
```

---

## 4. Dockerfile Generator (If Deployment Selected)

### Generation Logic

**Step 1: Choose Base Image (Production)**
- Python: `python:3.11-slim`
- Node.js: `node:20-alpine`
- Go: `golang:1.21-alpine` (build) + `alpine:latest` (runtime)

**Step 2: Multi-stage Build (If Node.js)**
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3001
CMD ["node", "server.js"]
```

**Step 3: Python Example**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["gunicorn", "app:app"]
```

**Step 4: Add Health Checks**
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1
```

---

## 5. Backend Config File Generator

### Framework-aware Java Bootstrapping

If Java is selected:
- If framework is unknown, ask: `Spring Boot` vs `Plain Java`.
- If still unknown (or non-interactive), generate:
  - Spring-compatible config as default
  - minimal fallback profile for plain Java

Optional scaffolding:
- Maven: generate `pom.xml` template with dependency hints
- Gradle: generate `build.gradle` template with dependency hints

Dependency hints should include only essentials:
- web starter/framework core
- database driver
- test starter

Example fallback strategy:
```text
java.framework=unknown
generated profile: spring-boot (default)
generated fallback profile: plain-java
```

### For FastAPI (Python)
**File**: `backend/config.py`
```python
import os
from sqlalchemy import create_engine

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://devuser:devpass@postgres:5432/appdb"
)

engine = create_engine(DATABASE_URL)

# GIS-specific
GEOSERVER_URL = f"http://{os.getenv('GEO_SERVER_HOST', 'geoserver')}:{os.getenv('GEO_SERVER_PORT', '8080')}/geoserver"
```

### For Express (Node.js)
**File**: `backend/config.js`
```javascript
require('dotenv').config();

module.exports = {
  database: {
    host: process.env.DB_HOST || 'postgres',
    port: process.env.DB_PORT || 5432,
    user: process.env.DB_USER || 'devuser',
    password: process.env.DB_PASSWORD || 'devpass',
    database: process.env.DB_NAME || 'appdb'
  },
  geoserver: {
    url: `http://${process.env.GEO_SERVER_HOST || 'geoserver'}:${process.env.GEO_SERVER_PORT || 8080}/geoserver`
  }
};
```

---

## Generation Summary Table

| File | When | How |
|------|------|-----|
| `.devcontainer/devcontainer.json` | Always | Base image + features + ports + extensions |
| `docker-compose.yml` | Always | Services selected by user |
| `.env.template` | Always | All service variables, no secrets |
| `.env` | On first run | Copy from template, user adds secrets |
| `Dockerfile` | If deployment=yes | Multi-stage, optimized for production |
| `backend/config.py/js` | If framework detected | Framework-specific configuration |
| `tests/*.sh` | Always | Based on selected components |
| `reports/devcontainer-init-report.json` | Always | Machine-readable setup and test report |

---

## Copilot Generation Checklist

After gathering all user inputs:

- [ ] Generate `.devcontainer/devcontainer.json`
- [ ] Generate `docker-compose.yml`
- [ ] Generate `.env.template`
- [ ] Generate `.env` (with suggested defaults)
- [ ] Generate Dockerfile (if deployment selected)
- [ ] Generate backend config file (if framework detected)
- [ ] Generate test scripts (based on services)
- [ ] Preflight check required tools: Docker, Compose, curl, language-specific CLIs
- [ ] If tool missing, print actionable install steps per OS (Linux/macOS/Windows)
- [ ] Validate image architecture compatibility (`amd64`, `arm64`)
- [ ] Run host-port conflict detection and remap consistently
- [ ] Enforce idempotent merge when files already exist (preserve user custom sections)
- [ ] Validate extension policy (minimal-only)
- [ ] Run unsafe-default secret scan on generated env files
- [ ] Create `.devcontainer/` directory if missing
- [ ] Save all files to workspace
- [ ] Output machine-readable report + human summary
- [ ] Prompt user to open `.env` and customize values
- [ ] Run test suite automatically
- [ ] Report test results

---

## Dependency & Tool Verification Contract

Before generation and before running tests, verify:
- Docker CLI
- Docker Compose (`docker compose` or `docker-compose`)
- `curl`
- CLI tools used by selected test scripts (example: `psql`, `mongosh`, `redis-cli`)

If missing, do not fail silently. Print actionable install guidance per OS and stop with a clear reason.

---

## Connectivity Tests by Deployment Mode

### Local Dev
- host-to-service checks (mapped ports)
- service-to-service checks (internal network DNS/service names)

### Docker Image Workflow
- `docker build` succeeds
- `docker run` smoke test succeeds
- health endpoint responds

### Semi-Dev with Remote DB
- verify remote endpoint reachability from container
- run connection probe using env-supplied host/port/db name
- include TLS option checks (`sslmode`, CA path, strict/verify flags)

---

## Readiness and Retry Quality

All validation scripts must:
- wait for readiness with bounded retries and timeout
- print clear failure reason (service unreachable, auth failure, DNS failure, TLS failure)
- exit non-zero on real failures

---

## Idempotency and Merge Rules

Re-running init must not duplicate or corrupt config.

Rules:
- merge minimally when files exist
- preserve user-defined custom blocks/sections
- keep stable key ordering where practical
- do not re-add duplicate services, env vars, or ports

---

## Extension Policy Enforcement

Enforce minimal extension policy by selected language only:
- always `github.copilot`
- one primary linting extension per selected language
- one docs/intellisense extension per selected language

Validation step:
- parse generated extension list
- flag extra/unexpected extensions
- print remediation hint before final report

---

## Output Contract

At end of run, emit machine-readable report:
`reports/devcontainer-init-report.json`

Example schema:
```json
{
  "mode": "interactive|non-interactive",
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
    {
      "name": "postgres-connectivity",
      "status": "pass|fail",
      "details": "..."
    }
  ],
  "fixesApplied": [],
  "remainingManualSteps": []
}
```

Also print a short human-readable summary.

---

## Rollback and Cleanup

If setup fails partially:
- print cleanup commands
- provide minimal recovery path
- keep scripts self-contained and re-runnable

Suggested cleanup template:
```bash
docker compose down -v
docker rm -f $(docker ps -aq --filter "name=<project>") 2>/dev/null || true
docker volume prune -f
```

Recovery path:
1. Fix reported issue (missing tool/port conflict/credentials)
2. Re-run init in idempotent mode
3. Re-run generated test suite
