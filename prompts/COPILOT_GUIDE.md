# Copilot Chat Integration Guide

## How to Use the Devcontainer Template with Copilot Chat

This guide explains how **Copilot Chat** should interact with the devcontainer template to guide users through the complete setup process.

---

## Command: `/devcontainer init`

When a user types `/devcontainer init` in Copilot Chat, follow this complete flow:

---

## 🎯 Stage 1: Project Detection (2-3 minutes)

### Step 1.1: Greeting
```
👋 Welcome to the Devcontainer Setup Wizard!

I'll help you create a standardized, fully-tested devcontainer for your project.
Let me start by understanding your project.
```

### Step 1.2: Check for Existing Project
```
question: Do you already have an existing project in this workspace?

If yes, I'll analyze what files are present and suggest appropriate components.
If no, I'll ask you everything from scratch.

[Yes] [No]
```

**If Yes**: Scan workspace for:
- `package.json` → Node.js/TypeScript project
- `requirements.txt` / `pyproject.toml` → Python project
- `go.mod` → Go project
- `pom.xml` / `build.gradle` → Java project
- `docker-compose.yml` → Existing services
- `.git/` → Git repository

Then display:
```
📁 Project Analysis:
✅ Found package.json → Node.js project detected
✅ Found requirements.txt → Python support detected
✅ Found docker-compose.yml → Using existing services

This looks like a Python + Node.js fullstack project.
Should I use these findings for recommendations?

[Yes, use detected] [No, start fresh]
```

### Step 1.3: Deployment Intent
```
question: Will this devcontainer be used for:

A) Development only (local environment)
B) Deployed as Docker image (production)
C) Semi-dev (app local, databases on remote servers)

[A] [B] [C]
```

Based on choice, adjust later questions about Dockerfile generation and .env strategy.

### Step 1.4: Base Image Selection
```
question: Choose your base container image:

📚 IMAGE OPTIONS:

1️⃣  UBUNTU (Lightweight, flexible)
   └─ mcr.microsoft.com/devcontainers/base:ubuntu
   └─ ~700MB | Best for: Fullstack, learning, customization

2️⃣  PYTHON (Python-optimized)
   └─ mcr.microsoft.com/devcontainers/python:3.11-bullseye
   └─ ~900MB | Best for: Pure Python projects, data science

3️⃣  NODE.JS (JavaScript/TypeScript-optimized)
   └─ mcr.microsoft.com/devcontainers/typescript-node:20-bullseye
   └─ ~1GB | Best for: React, Next.js, Express, NestJS

4️⃣  GO (Go-optimized)
   └─ mcr.microsoft.com/devcontainers/go:1.21-bullseye
   └─ ~600MB | Best for: Go microservices, APIs

5️⃣  JAVA (Java-optimized)
   └─ mcr.microsoft.com/devcontainers/java:21-bullseye
   └─ ~1.2GB | Best for: Spring Boot, enterprise apps

6️⃣  CUSTOM (Specify your own)
   └─ You provide the full image reference

For your project, I recommend: [RECOMMENDATION based on analysis]

Which image would you like? [1-6]
```

If detected project, suggest strongly:
```
📌 Based on your project files, I recommend:
   → [IMAGE] because [REASON]

Would you like to use this? [Yes] [No, show all]
```

---

## 🎯 Stage 2: Language & Framework (3-5 minutes)

### Step 2.1: Primary Language
```
question: What is your primary programming language?

[Python] [Node.js] [Go] [Java] [Other]

Sub-question (if language detected from files):
  Your project was detected as [LANGUAGE].
  Is this correct? [Yes] [Change]
```

### Step 2.2: Language Version
```
question: Which version of [LANGUAGE]?

[Versions available]

Recommended: [VERSION|LTS|Latest]
```

### Step 2.3: Framework / Runtime
```
question: What framework/runtime are you using?

Examples for Python:
[Django] [FastAPI] [Flask] [None/Custom]

Examples for Node.js:
[Express] [NestJS] [Next.js] [Fastify] [None/Custom]

Examples for Go:
[Gin] [Echo] [Buffalo] [None/Custom]

(Customize based on language selected)
```

### Step 2.4: Build Tools / Package Manager
```
question: Which build/package tools?

For Python:
[pip] [Poetry] [Conda] [all]

For Node.js:
[npm] [Yarn] [pnpm] [all]

For Go:
[go mod] (standard)

(Customize based on language)
```

### Step 2.5: Multi-Language Check
```
question: Will this project use multiple languages?

Example: Node.js frontend + Python backend

[Yes, add another language] [No, just LANGUAGE]

If yes, repeat language selection for secondary language(s)
```

---

## 🎯 Stage 3: Database & Services (5-7 minutes)

### Step 3.1: Database Selection
```
question: Which database(s) will you use?

☐ PostgreSQL (powerful, relational, recommended for GIS)
☐ MongoDB (document-based, flexible schema)
☐ MySQL (lightweight, widely supported)
☐ Redis (caching, sessions, real-time)
☐ None

⚠️  PostgreSQL is recommended for GIS projects.
    Will you need geographic/spatial data?
    [Yes] [No]

If Yes:
  ☑  PostgreSQL + PostGIS extension
```

For each selected database, ask:
```
question: PostgreSQL Configuration:

1. Version: [12] [13] [14] [15] [16] ← (16 recommended)
2. Port: [5432] or [custom port]
3. Where should it run?
   [Local (in docker-compose)] [Remote server]
4. Volume persistence?
   [Keep data between sessions] [Fresh start each time]
```

### Step 3.2: GIS Services (if applicable)
```
question: Do you need GIS services?

(Only shown if PostgreSQL + PostGIS selected)

☐ PostGIS only (in PostgreSQL, no separate server)
☐ GeoServer (full GIS web server)
☐ QGIS Server (lightweight alternative)
☐ Both GeoServer and QGIS Server
☐ None

📌 Recommended for GIS fullstack: PostGIS + GeoServer

If selected, configure:
  - Version
  - Port (usually 8080)
  - Admin credentials (username/password)
  - Volume persistence
```

### Step 3.3: Development Tools
```
question: Which development tools?

☐ Docker CLI (build images, manage containers)
☐ Git (version control)
☐ Language debuggers (Python debugpy, Node Inspector, Delve, etc.)
☐ Linters & Formatters (Black, Ruff, ESLint, Prettier, etc.)

All recommended for professional development.
Include all? [Yes] [Custom selection]

If custom:
  Select each individually with descriptions
```

### Step 3.4: Additional Services
```
question: Need any other services?

☐ RabbitMQ (message queue)
☐ Kafka (event streaming)
☐ Elasticsearch (search engine)
☐ Other (user specifies)

[Done with services] [Add custom service]

If custom service:
  Docker image: [user input]
  Port: [user input]
  Environment variables: [user input]
```

---

## 🎯 Stage 4: Service Configuration (5-10 minutes)

For each selected service, gather configuration:

### For Databases:

**PostgreSQL Example**:
```
question: PostgreSQL Configuration:

Connection Details:
  Database name: [appdb] (suggested)
  Username: [devuser] (suggested)
  Password: [devpass123] (suggested)

Storage:
  Keep data between container restarts? [Yes] [No]

Initialization:
  Run .sql files on startup? [Yes] [No]
  If yes, path: [.devcontainer/init.sql] (suggested)

Is this correct?
  [✅ Confirm] [Edit] [Re-suggest]
```

**MongoDB Example**:
```
question: MongoDB Configuration:

Connection Details:
  Database: [appdb]
  Admin user: [admin]
  Admin password: [password]
  Auth database: [admin]

Replication set? [No] [Yes, configure]

Continue? [✅ Confirm] [Edit]
```

### For GeoServer:

```
question: GeoServer Configuration:

Admin Access:
  Username: [admin] (suggested)
  Password: [geoserver] (suggested)

Database:
  Connect to PostgreSQL? [Yes] [No]
  If yes: Use the PostgreSQL configured above? [Yes] [No]

Workspace name: [myworkspace] (for layers)

Data directory:
  Persistent volume? [Yes] [No]

Continue? [✅ Confirm] [Edit]
```

### For Redis:

```
question: Redis Configuration:

Access:
  Password: [devpass123] (suggested)
  Public access from host? [Yes] [No]

Persistence:
  Keep data between restarts? [Yes] [No]

Continue? [✅ Confirm] [Edit]
```

---

## 🎯 Stage 5: Deployment Configuration (2-3 minutes)

*Only if user selected "Deployed as Docker image" in Stage 1.3*

```
question: Production Dockerfile Configuration:

Build Strategy:
  [Single stage] (simple)
  [Multi-stage] (optimized, smaller image)

Production Base Image:
  For Node.js: [node:20-alpine] [node:20-slim] [custom]
  For Python: [python:3.11-slim] [python:3.11-alpine] [custom]
  For Go: [alpine:latest] (recommended for compiled apps)

Health Check:
  Include health check in Dockerfile? [Yes] [No]
  Endpoint: [/health] [/api/health] [custom]

Environment Strategy:
  [Bake into image] - Config at build time
  [Inject at runtime] - Config via ENV vars
  [Mix both] - Some baked, some injected

Which variables to inject at runtime?
  (from your .env)
  ☐ DATABASE_URL
  ☐ API_KEY
  ☐ [other variables]

Continue? [✅ Confirm] [Edit]
```

---

## 🎯 Stage 6: Review & Confirm (2-3 minutes)

Display complete summary:

```
===============================================
  📋 DEVCONTAINER CONFIGURATION SUMMARY
===============================================

🏗️  BASE SETUP
   Base Image: mcr.microsoft.com/devcontainers/typescript-node:20-bullseye
   Deployment: Development + Deployment (Dockerfile included)

💻 LANGUAGES & FRAMEWORKS
   ├─ Node.js 20 (Primary)
   │  └─ Next.js framework
   ├─ Python 3.11 (Secondary)

🗄️  DATABASES
   ├─ PostgreSQL 16
   │  ├─ Database: appdb
   │  ├─ User: devuser
   │  └─ With PostGIS extension
   ├─ MongoDB 7.0
   ├─ Redis 7

🗺️  GIS SERVICES
   ├─ PostGIS (in PostgreSQL)
   ├─ GeoServer 2.23.0
   │  ├─ Admin: admin/*****
   │  └─ Port: 8080

🛠️  DEVELOPMENT TOOLS
   ├─ Docker CLI
   ├─ Git
   ├─ Node debugger
   ├─ Python debugger
   ├─ ESLint & Prettier
   ├─ Black & Ruff

📦 PORTS FORWARDED
   ├─ 3000 (Next.js dev server)
   ├─ 3001 (Backend API)
   ├─ 5432 (PostgreSQL)
   ├─ 27017 (MongoDB)
   ├─ 6379 (Redis)
   ├─ 8080 (GeoServer)

🧪 TESTS
   ✅ Auto-run after generation
   ✅ 12 component validations

⚙️  FILES TO BE GENERATED
   ├─ .devcontainer/devcontainer.json
   ├─ docker-compose.yml
   ├─ .env (with suggested values)
   ├─ Dockerfile (for production)
   ├─ backend/config.ts
   └─ tests/run-all-tests.sh + individual tests

📚 EXTENSIONS
  Minimal extension set (2-4)
  - github.copilot
  - Primary linter for selected stack
  - Docs/intellisense extension for selected stack

===============================================

Ready to generate? This will create all files above.

[✅ YES, GENERATE] [No, EDIT] [No, CANCEL]
```

If Edit: Ask which section to change, go back to relevant stage.

---

## 🎯 Stage 7: Generate & Test (5-10 minutes)

### Step 7.1: Generate Files

```
📝 Generating configuration files...

✅ .devcontainer/devcontainer.json
✅ docker-compose.yml
✅ .env (with suggested values)
✅ .env.template (without values)
✅ Dockerfile
✅ backend/config.ts
✅ tests/run-all-tests.sh
✅ tests/01-workspace.sh
✅ tests/02-nodejs.sh
✅ tests/03-python.sh
✅ tests/04-postgres.sh
✅ tests/05-postgis.sh
✅ tests/06-geoserver.sh
✅ tests/07-mongodb.sh
✅ tests/08-redis.sh
✅ tests/09-git.sh
✅ tests/10-docker.sh

All files generated in /workspace/.devcontainer/ and /workspace/tests/

Next steps:
1. Review .env and customize passwords
2. Start testing
```

### Step 7.2: Run Tests

```
🧪 Running component tests...

[Running tests and showing real-time output]

================================================
  🚀 DEVCONTAINER COMPONENT TEST SUITE
================================================

✅ Workspace is accessible
✅ Node.js 20 runtime ready
✅ Python 3.11 runtime ready
✅ Docker CLI accessible
✅ Git configured
✅ PostgreSQL responding
✅ PostgreSQL query successful
✅ PostGIS spatial functions working
✅ MongoDB responding
✅ Redis responding
✅ GeoServer is running
✅ GeoServer REST API working

================================================
  📊 TEST SUMMARY
================================================
✅ Passed: 12
❌ Failed: 0
⚠️  Warnings: 0

🎉 All tests passed! Your devcontainer is ready! 🎉
```

### Step 7.3: Rebuild Container

```
Final step:

In VS Code:
  1. Press Cmd+Shift+P (or Ctrl+Shift+P)
  2. Type: "Rebuild Container"
  3. Wait for build to complete (~3-5 minutes)

OR via CLI:
  devcontainer build --workspace-folder .

Extensions will install automatically.

After rebuild completes, you're ready to develop! 🚀

---

📚 Documentation:
  • Run tests again: bash tests/run-all-tests.sh
  • View configuration: cat .devcontainer/devcontainer.json
  • Edit database: Edit docker-compose.yml
  • Add secrets: Edit .env (not committed)
  • Check ports: docker ps --no-trunc

Need help?
  • Check individual test: bash tests/04-postgres.sh
  • View logs: docker logs postgres
  • Reset data volumes: docker volume rm postgres_data

Happy coding! 🎯
```

---

## 🔄 Re-running the Wizard

If user wants to reconfigure:

```
/devcontainer init --reconfigure

This will:
1. Backup current .devcontainer/
2. Run wizard again
3. Generate new configs
4. Compare with backup
5. Show what changed

Proceed? [Yes] [No]
```

---

## 💡 Key Principles for Copilot

1. **Be conversational**: Use emoji, formatting, clear questions
2. **Explain choices**: Always provide rationale for recommendations
3. **Suggest defaults**: Have smart defaults ready, let user override
4. **Detect & adapt**: Use file detection to personalize suggestions
5. **Show progress**: Display visual progress (🏗️ → ✅)
6. **Test everything**: Always run tests automatically
7. **Be helpful**: Provide troubleshooting if tests fail
8. **Document**: Generate comments in config files explaining choices

---

## Example Conversation Flow

```
User: /devcontainer init

Copilot: 👋 Welcome! I'll create your devcontainer...

Copilot: Do you have an existing project?

User: Yes

Copilot: [Detects files]
Found package.json and requirements.txt.
Python + Node.js fullstack detected!
Recommend: Ubuntu base image for flexibility.
Agree? [Yes] [Show all]

User: [Yes]

Copilot: Great! Next: languages...
[Continue through all stages]
...

Copilot: ✅ All tests passed!
[Shows summary]

User is ready to develop! ✅
```

---

## Testing the Wizard

After creating this template, test with:

- [ ] New Python project detection
- [ ] New Node.js project detection
- [ ] GIS fullstack detection
- [ ] Multi-language setup
- [ ] Remote database configuration
- [ ] Deployment mode (with Dockerfile)
- [ ] Edge cases (monorepo, microservices, etc.)

---

This guide ensures Copilot Chat provides a smooth, intuitive, comprehensive devcontainer setup experience! 🚀
