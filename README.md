# Devcontainer Template for Copilot Chat

A comprehensive, AI-guided template system for standardizing devcontainer configuration across projects using GitHub Copilot Chat.

## 🎯 Purpose

This template enables **Copilot Chat** to guide you through an interactive wizard that:
- ✅ **Detects** your project type and existing files
- ✅ **Asks** about every component (languages, databases, GIS services, dev tools)
- ✅ **Generates** standardized `.devcontainer.json`, `docker-compose.yml`, and test scripts
- ✅ **Installs minimal VS Code extensions** (Copilot + linter + docs/intellisense)
- ✅ **Tests** all components automatically (ports, database connectivity, service communication)
- ✅ **Supports** both dev and semi-dev setups (local app + remote databases)

---

## 📂 Template Structure

```
devcontainer-template/
├── README.md                          # This file
├── prompts/
│   └── MAIN_WIZARD.md                # Core wizard flow for Copilot
├── components/
│   ├── LANGUAGES.md                  # Python, Node.js, Go, Java details
│   ├── DATABASES.md                  # PostgreSQL, MongoDB, MySQL, Redis
│   ├── GIS.md                        # PostGIS, GeoServer, QGIS Server
│   └── DEV_TOOLS.md                  # Docker, Git, Debuggers, Dev Servers
├── templates/
│   ├── IMAGE_SELECTION.md            # Base image explanations & decision matrix
│   ├── GENERATORS_GUIDE.md           # How to generate config files
│   └── EXTENSIONS_GUIDE.md           # VS Code extension recommendations
├── scripts/
│   └── setup-template.sh             # One-command installer for any repo
└── tests/
    └── TEST_TEMPLATES.md             # Test scripts for each component
```

---

## 🚀 Quick Start

### In GitHub Copilot Chat:

1. **Start the wizard**:
   ```
   /devcontainer init
   ```

2. **Follow the prompts**:
   - Copilot will ask about your project type
   - Select your languages, frameworks, databases, and services
   - Review selections and confirm

3. **Auto-generation**:
   - `.devcontainer/devcontainer.json`
   - `docker-compose.yml`
   - `.env.template` and `.env`
   - Test scripts in `tests/`
   - Backend config files (if needed)

4. **Auto-testing**:
   ```bash
   # Run automatically or manually
   bash tests/run-all-tests.sh
   ```

5. **Rebuild container**:
   - Cmd+Shift+P → "Rebuild Container"
   - All tests pass → Ready to develop! ✅

---

## 🌍 Use from Anywhere (Public Repo)

To reuse this template in any project with minimal effort:

1. Run the one-command bootstrap from your target repository root:
   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/drasolon/devcontainer-template/main/scripts/setup-template.sh)
   ```

   Default behavior installs the full template set:
   - `.github/copilot-instructions.md`
   - `prompts/*`
   - `components/*`
   - `templates/*`
   - `tests/TEST_TEMPLATES.md`

   Show options/version:
   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/drasolon/devcontainer-template/main/scripts/setup-template.sh) --help
   bash <(curl -fsSL https://raw.githubusercontent.com/drasolon/devcontainer-template/main/scripts/setup-template.sh) --version
   ```

   Optional target directory + overwrite:
   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/drasolon/devcontainer-template/main/scripts/setup-template.sh) /path/to/repo --force
   ```

   Optional minimal mode (instructions only):
   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/drasolon/devcontainer-template/main/scripts/setup-template.sh) --minimal
   ```

2. Open Copilot Chat in that project and run:
   ```
   /devcontainer init
   ```

3. Copilot follows the wizard and generates all required files in your current repository.

---

## 📋 What Copilot Will Ask

### Stage 1: Project Detection
- "Has this project already started?"
- "Will this be deployed as a Docker image?"
- **Base image selection** (Ubuntu, Python, Node.js, Go, Java, Custom)

### Stage 2: Language & Framework
- Primary language
- Framework (FastAPI, Express, NestJS, Spring Boot, etc.)
- Build/runtime tools

### Stage 3: Components
- **Databases**: PostgreSQL (with PostGIS?), MongoDB, MySQL, Redis, or none
- **GIS Services**: PostGIS, GeoServer, QGIS Server, or none
- **Dev Tools**: Docker, Git, Debuggers, DevServers
- **Additional**: Custom services user can add

### Stage 4: Service Configuration
- For each service: port, credentials, volumes, remote vs local

### Stage 5: Deployment (if applicable)
- Multi-stage build?
- Production base image
- Environment variables strategy

### Stage 6: Review & Confirm
- Display summary
- Ask user to confirm before generation

### Stage 7: Generate & Test
- Create all config files
- Run test suite
- Report results

---

## 🔧 Component Reference

### Languages Supported
- **Python** (3.8 - 3.12)
- **Node.js** (16, 18, 20, 22)
- **Go** (1.19 - 1.22)
- **Java** (11, 17, 21)
- **Multi-language** combinations

### Databases Supported
- **PostgreSQL** (12 - 16, with PostGIS)
- **MongoDB** (5.0 - 7.0)
- **MySQL** (5.7 - 8.1)
- **Redis** (6.x - 7.x)

### GIS Services
- **PostGIS** (3.2 - 3.4) - In PostgreSQL
- **GeoServer** (2.22.x - 2.23.x)
- **QGIS Server** (3.28+)

### Development Tools
- Docker CLI
- Git
- Language-specific debuggers (Python debugpy, Node Inspector, Delve)
- Linters & formatters (Black, Ruff, ESLint, Prettier, golangci-lint)
- Testing frameworks (pytest, Jest, Go test)

---

## 📝 File Reference

### Component Details

| File | Purpose |
|------|---------|
| [LANGUAGES.md](components/LANGUAGES.md) | Language runtimes, versions, installation |
| [DATABASES.md](components/DATABASES.md) | Database configs, docker-compose snippets, connection examples |
| [GIS.md](components/GIS.md) | PostGIS, GeoServer, QGIS Server setup and usage |
| [DEV_TOOLS.md](components/DEV_TOOLS.md) | Docker, Git, debuggers, dev servers, linters |

### Templates & Guides

| File | Purpose |
|------|---------|
| [IMAGE_SELECTION.md](templates/IMAGE_SELECTION.md) | Base image explanations, decision matrix, guidelines |
| [GENERATORS_GUIDE.md](templates/GENERATORS_GUIDE.md) | How to generate configs, code snippets for each file type |
| [EXTENSIONS_GUIDE.md](templates/EXTENSIONS_GUIDE.md) | VS Code extension recommendations by language/framework |
| [TEST_TEMPLATES.md](tests/TEST_TEMPLATES.md) | Test scripts for all components |

### Prompts

| File | Purpose |
|------|---------|
| [MAIN_WIZARD.md](prompts/MAIN_WIZARD.md) | Complete wizard flow for Copilot to follow |

---

## 🧪 Testing Components

After generation, the test suite validates:

### Basic Health
- ✅ Container running
- ✅ Workspace accessible

### Language Runtimes
- ✅ Python/Node.js/Go/Java installed and working

### Database Connectivity
- ✅ PostgreSQL/MongoDB/MySQL/Redis accessible
- ✅ Can execute queries
- ✅ PostGIS extension available (if selected)

### Service Communication
- ✅ Backend can connect to database
- ✅ GeoServer responding to requests
- ✅ Dev servers accessible from host browser

### Development Tools
- ✅ Git configured
- ✅ Docker CLI available
- ✅ Debuggers ready

---

## 🎓 Example Scenarios

### Scenario 1: GIS Fullstack App

**Choices**:
- Base Image: Node.js
- Language: JavaScript/TypeScript
- Framework: Next.js
- Database: PostgreSQL + PostGIS
- GIS: GeoServer
- Dev Tools: Docker, Git, ESLint, Prettier

**Generated**:
```
✅ .devcontainer/devcontainer.json
✅ docker-compose.yml (Node.js + PostgreSQL + GeoServer)
✅ .env template
✅ Dockerfile (for deployment)
✅ Tests (Node.js runtime, Postgres, PostGIS, GeoServer)
✅ VS Code extensions (minimal: Copilot + ESLint + TS docs)
```

### Scenario 2: Python Data Science + GIS

**Choices**:
- Base Image: Python 3.11
- Language: Python
- Framework: FastAPI
- Database: PostgreSQL + PostGIS
- GIS: PostGIS only (no GeoServer)
- Dev Tools: Docker, Git, Pytest, Jupyter

**Generated**:
```
✅ .devcontainer/devcontainer.json
✅ docker-compose.yml (PostgreSQL with PostGIS)
✅ .env template with FastAPI variables
✅ Tests (Python, FastAPI, Postgres, PostGIS)
✅ VS Code extensions (minimal: Copilot + Ruff + Pylance)
```

### Scenario 3: Multi-service Backend Architecture

**Choices**:
- Base Image: Ubuntu
- Languages: Python + Node.js
- Services: PostgreSQL, MongoDB, Redis, GeoServer
- Dev Setup: Semi-dev (app local, remote databases)

**Generated**:
```
✅ .devcontainer/devcontainer.json (Python + Node.js)
✅ docker-compose.yml (PostgreSQL, MongoDB, Redis, GeoServer)
✅ .env template with remote DB connection options
✅ Tests for all services
✅ VS Code extensions (minimal multi-language set)
```

---

## 🔌 Integration with Existing Projects

Copilot will detect:
- `package.json` → suggests Node.js
- `requirements.txt` → suggests Python
- `go.mod` → suggests Go
- `docker-compose.yml` → reuses existing config
- `.git/` → confirms Git is available

**No data loss**: All work in `/workspace` persists when rebuilding containers.

---

## 🛠️ Customization

After generation, you can manually edit:

### `.devcontainer/devcontainer.json`
- Add Features
- Change ports
- Add environment variables
- Customize extensions

### `docker-compose.yml`
- Adjust service versions
- Add custom services
- Modify volumes
- Configure networks

### `.env`
- Add your actual credentials
- Configure remote database connections
- Customize ports

### Tests
- Add framework-specific tests
- Customize health checks
- Add performance tests

---

## 🌍 Remote Database Configuration (Semi-Dev)

For app running locally with databases on remote servers:

1. **Copilot asks**: "Is this a remote setup?"
2. **User provides**: Remote DB credentials
3. **Generated .env**:
   ```bash
   REMOTE_DB_HOST=your-server.example.com
   REMOTE_DB_PORT=5432
   REMOTE_DB_USER=username
   REMOTE_DB_PASSWORD=secure_password
   ```
4. **docker-compose.yml**: NO local database service
5. **Backend config**: Uses remote connection strings

---

## 📊 Test Execution

### Auto-run (Recommended)
After generation, Copilot automatically runs:
```bash
bash tests/run-all-tests.sh
```

**Output**:
```
================================================
  🚀 DEVCONTAINER COMPONENT TEST SUITE
================================================

✅ Workspace
✅ Python Runtime
✅ Node.js Runtime
✅ PostgreSQL Connection
✅ PostGIS Spatial Functions
✅ GeoServer REST API
✅ Git Configuration
✅ Docker CLI

================================================
  📊 TEST SUMMARY
================================================
✅ Passed: 8
❌ Failed: 0

🎉 All tests passed!
```

### Manual Testing
```bash
# Test specific component
bash tests/04-postgres.sh

# Run all tests
bash tests/run-all-tests.sh

# Verbose output
bash tests/run-all-tests.sh -v
```

---

## 🎯 VS Code Extension Recommendations

Copilot automatically recommends extensions based on your stack:

### Always Installed
- `github.copilot` - GitHub Copilot

### Primary Linter (one per language)
- **Python**: Ruff
- **Node.js/TypeScript**: ESLint
- **Go**: Go extension (built-in lint/language tooling)
- **Java**: Java extension (diagnostics/language tooling)

### Function/Class Docs + IntelliSense (one per language)
- **Python**: Pylance
- **Node.js/TypeScript**: TypeScript Next
- **Go**: Go extension
- **Java**: Java extension

Optional extras are only added when user explicitly asks.

---

## ⚠️ Troubleshooting

### "Container won't start"
1. Check Docker daemon is running
2. Rebuild: Cmd+Shift+P → "Rebuild Container"
3. Check `.devcontainer/devcontainer.json` syntax

### "Tests failing"
```bash
# Check specific service
bash tests/04-postgres.sh

# Review logs
docker logs postgres

# Manually test connection
psql -h postgres -U devuser -d appdb
```

### "Port already in use"
1. Edit `docker-compose.yml`
2. Change port mapping: `"5433:5432"` (change first number)
3. Rebuild container

### "Database not persisting"
Check `docker-compose.yml` has volume:
```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data
```

---

## 📚 Additional Resources

- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostGIS Documentation](https://postgis.net/docs/)

---

## 💡 Best Practices

1. **Use `.env.template`** to track which variables are needed
2. **Never commit `.env`** (add to `.gitignore`)
3. **Test all components** after changing configurations
4. **Keep `docker-compose.yml` simple** for development
5. **Use persistent volumes** for databases in development
6. **Document custom services** in your project README

---

## 🤝 Contributing

To improve this template:
1. Test new component combinations
2. Report edge cases to Copilot
3. Suggest new services/frameworks
4. Share working configurations

---

## 📄 License

This template is provided as-is for standardizing devcontainer setup across projects.

---

**Ready to standardize your devcontainer setup?**

In Copilot Chat, type:
```
/devcontainer init
```

And let the wizard guide you! 🚀
