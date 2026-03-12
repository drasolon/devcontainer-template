# Configuration Generators Guide

## Overview
Based on user selections from the wizard, generate appropriate configuration files:
1. `.devcontainer/devcontainer.json` (Main devcontainer config)
2. `docker-compose.yml` (Services orchestration)
3. `.env.template` / `.env.example` (Environment variables)
4. `Dockerfile` (If deployment required)
5. Backend config files (For framework-specific database connections)
6. Test scripts (In `tests/` directory)

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
All variables with explanations, NO actual passwords

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
DB_PASSWORD=devpass
DB_NAME=appdb
DATABASE_URL=postgresql://devuser:devpass@postgres:5432/appdb
```

**GIS Variables**:
```bash
# GeoServer
GEO_SERVER_HOST=geoserver
GEO_SERVER_PORT=8080
GEO_ADMIN_USER=admin
GEO_ADMIN_PASSWORD=geoserver

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
REDIS_PASSWORD=devpass
REDIS_URL=redis://:devpass@redis:6379
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
DB_PASSWORD=devpass123  # Change this!
DB_NAME=gisdb

# Connection string for ORMs
DATABASE_URL=postgresql://devuser:devpass123@postgres:5432/gisdb

# ==================================
# GeoServer Configuration
# ==================================
GEO_SERVER_HOST=geoserver
GEO_SERVER_PORT=8080
GEO_ADMIN_USER=admin
GEO_ADMIN_PASSWORD=geoserver  # Change this!

# ==================================
# Redis Configuration
# ==================================
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=redis_devpass  # Change this!

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
- [ ] Create `.devcontainer/` directory if missing
- [ ] Save all files to workspace
- [ ] Output summary of generated files
- [ ] Prompt user to open `.env` and customize values
- [ ] Run test suite automatically
- [ ] Report test results
