# Devcontainer Template Wizard - Main Prompt

## Overview
This prompt guides the user through creating a standardized, fully-tested devcontainer configuration for their project.

---

## Stage 1: Project Detection & Image Selection

### Mode Selection:
- Interactive (ask all questions)
- Non-interactive (`--non-interactive`): if answers are missing, use safe defaults and continue
- At the end of non-interactive runs, return inferred defaults summary

### User Questions:
1. **Has your project already started?** (Yes/No)
   - If Yes: Scan for existing files (package.json, requirements.txt, docker-compose.yml, etc.) to suggest best components
   - If No: Proceed to manual selection

2. **Is this a deployment or development setup?**
   - Development only (local)
   - Will be deployed as Docker image
   - Semi-dev (app local, services on remote servers)

3. **Base Image Selection** (provide options with explanations):
   - `mcr.microsoft.com/devcontainers/base:ubuntu` → Lightweight, great for most fullstack
   - `mcr.microsoft.com/devcontainers/python:3.11-bullseye` → Python-optimized, includes pip
   - `mcr.microsoft.com/devcontainers/typescript-node:20-bullseye` → Node.js + TypeScript ready
   - `mcr.microsoft.com/devcontainers/go:1.21-bullseye` → Go-optimized
   - `custom` → User specifies their own

4. **Image Guardrails (mandatory before finalize):**
   - Output chosen image and why
   - Output tradeoffs (size, flexibility, preinstalled tools)
   - Check architecture compatibility for `amd64` and `arm64`

---

## Stage 2: Language & Framework Selection

### Components to Ask:

**Primary Language:**
- [ ] Python (3.8+, 3.9, 3.10, 3.11, 3.12)
- [ ] Node.js (16, 18, 20+)
- [ ] Go (1.19+)
- [ ] Java (11, 17, 21)
- [ ] Other (user specifies)

**Frameworks (based on language):**
- If Python: Django, FastAPI, Flask, etc.
- If Node.js: Express, NestJS, Next.js, etc.
- If Go: Gin, Echo, etc.
- If Java: ask Spring Boot vs plain Java
- If Java framework remains unknown: generate Spring-compatible config plus minimal plain-Java fallback profile

**Build/Runtime Tools:**
- Package managers (npm, yarn, pip, poetry, cargo, etc.)
- Build tools (make, webpack, gradle, etc.)

---

## Stage 3: Component Selection

### Databases:
- [ ] PostgreSQL (+ PostGIS extension for GIS)
- [ ] MongoDB
- [ ] MySQL
- [ ] Redis (caching/sessions)
- [ ] None

### GIS Services:
- [ ] PostGIS (with PostgreSQL)
- [ ] GeoServer
- [ ] QGIS Server
- [ ] None

### Development Tools:
- [ ] Docker (CLI)
- [ ] Git
- [ ] Debuggers (Python, Node.js, etc.)
- [ ] Terraform/Ansible (if infrastructure as code)
- [ ] None

### Additional Services (user can add):
- Message queues (RabbitMQ, Kafka)
- Search (Elasticsearch)
- Other services

---

## Stage 4: Service Configuration

For each selected service:

1. **Database Configuration:**
   - Port (default or custom)
   - Username/Password (suggest template)
   - Initial database name
   - Persistent volume? (Yes/No)
   - Remote connection option (for semi-dev setup)

2. **GIS Configuration:**
   - PostGIS version
   - GeoServer credentials
   - QGIS Server settings

3. **Dev Server Configuration:**
   - Dev server port
   - Hot reload enabled?
   - Debug port

4. **Port Preflight:**
   - Check if requested host ports are already in use
   - Suggest alternatives and remap when needed
   - Apply remapped ports consistently in compose/env/backend configs/tests

---

## Stage 5: Deployment Configuration

### If "Will be deployed as Docker image":

1. **Multi-stage or single build?**
2. **Production base image choice:**
   - `node:20-alpine` (minimal, for Node.js)
   - `python:3.11-slim` (minimal, for Python)
   - `scratch` (barebone)
   - Custom

3. **Environment configuration:**
   - Which variables from .env to bake into image vs inject at runtime
   - Health checks to include

---

## Stage 6: Review & Confirm

Display summary:
```
PROJECT CONFIGURATION SUMMARY
==============================
Base Image: [selected]
Languages: [list]
Frameworks: [list]
Databases: [list with versions]
GIS Services: [list]
Dev Tools: [list]
Deployment: [yes/no/semi-dev]

Continue? [Y/N]
```

---

## Stage 7: Generate & Test

### Generate:
1. `devcontainer.json`
2. `docker-compose.yml`
3. `.env.template` or `.env.example`
4. `Dockerfile` (if deployment)
5. Backend config files (if needed)
6. Test scripts
7. Machine-readable report (`reports/devcontainer-init-report.json`)

### Run Tests:
Execute validation tests for each component:
- [ ] Base image builds
- [ ] All services start
- [ ] Databases are accessible
- [ ] Connections work (app → DB, backend → services)
- [ ] Dev servers are accessible from host browser
- [ ] All required directories/volumes exist
- [ ] Readiness waits use bounded retries and clear failure reasons
- [ ] Deployment-mode specific connectivity checks:
   - Local dev: host-to-service + service-to-service
   - Docker image mode: build + run smoke test
   - Semi-dev: remote DB reachability + TLS option checks

### Report:
```
✅ All tests passed!
⚠️ Warning: [if any]
❌ Failed: [if any - provide fix]
```

---

## Notes for Copilot Implementation:
- Store user answers in a session object
- Auto-suggest based on detected project files
- Provide explanations for each choice
- Generate actual config files based on responses
- Run validation tests automatically
- Show clear status for each step
- Keep VS Code extensions minimal by default: `github.copilot` + one linting extension + one docs/intellisense extension per selected language
- Verify required tools before generation/tests: Docker, Compose, curl, and language-specific CLIs
- If tools are missing, print actionable install steps per OS
- Never write real secrets to generated files; use placeholders only
- Optional local-only random passwords can be generated when user opts in
- Validate env files for unsafe defaults before finalizing
- Re-runs must be idempotent: merge minimally and preserve user custom sections
- Provide cleanup/recovery commands if setup partially fails
