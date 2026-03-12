# Development Tools Components

## Docker (CLI in Container)

### Why Include Docker CLI?
- Build images from within devcontainer
- Push to registries
- Debug container-related issues
- Test containerization

### .devcontainer.json Configuration
```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  }
}
```

### Alternative: Docker Socket Binding
```json
{
  "mounts": ["source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"]
}
```

### Usage in Container
```bash
# Build image
docker build -t myapp:latest .

# List images
docker images

# Run container
docker run -d myapp:latest

# Push to registry
docker push myapp:latest
```

### Environment Variables (.env)
```
DOCKER_BUILDKIT=1
DOCKER_CLI_HINTS=false
```

---

## Git

### Why Include Git?
- Version control operations
- Commit, push, pull from within devcontainer
- GitHub/GitLab access
- Branch management

### .devcontainer.json Configuration
```json
{
  "features": {
    "ghcr.io/devcontainers/features/git:1": {}
  }
}
```

### Configuration in Container
```bash
# Already available in most base images
git --version

# Configure (if needed)
git config --global user.name "Developer"
git config --global user.email "dev@example.com"
```

### SSH/HTTPS Setup
```json
{
  "mounts": [
    "source=${localEnv:HOME}/.ssh,target=/root/.ssh,type=bind,readonly"
  ],
  "remoteEnv": {
    "GIT_AUTHOR_NAME": "Developer",
    "GIT_AUTHOR_EMAIL": "dev@example.com"
  }
}
```

---

## Debuggers

### Python Debugger (Python Debugpy)

**Installation in .devcontainer.json:**
```json
{
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.11"
    }
  },
  "postCreateCommand": "pip install debugpy ipython"
}
```

**VS Code Launch Configuration (.vscode/launch.json):**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: Debug Current File",
      "type": "python",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal"
    }
  ]
}
```

### Node.js Debugger

**Port Configuration:**
```json
{
  "forwardPorts": [9229],
  "portsAttributes": {
    "9229": {"label": "Node Debug", "onAutoForward": "notify"}
  }
}
```

**package.json Script:**
```json
{
  "scripts": {
    "debug": "node --inspect-brk server.js"
  }
}
```

**VS Code Launch Configuration (.vscode/launch.json):**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "attach",
      "name": "Attach Node Debugger",
      "port": 9229,
      "skipFiles": ["<node_internals>/**"],
      "localRoot": "${workspaceFolder}",
      "remoteRoot": "/workspace"
    }
  ]
}
```

### Go Debugger (Delve)

**Installation in Dockerfile:**
```dockerfile
RUN go install github.com/go-delve/delve/cmd/dlv@latest
```

**VS Code Launch Configuration (.vscode/launch.json):**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Go: Debug",
      "type": "go",
      "request": "launch",
      "mode": "debug",
      "program": "./"
    }
  ]
}
```

---

## Development Servers & Port Forwarding

### Typical Dev Server Ports

| Service | Default Port | Purpose |
|---------|-------------|---------|
| React/Vue Dev Server | 3000 | Frontend development |
| Express API | 3001 | Backend API |
| Next.js | 3000 | Full-stack framework |
| Django | 8000 | Python backend |
| FastAPI | 8000 | Python async API |
| Go Gin | 8080 | Go REST API |
| PostgreSQL | 5432 | Database |
| MongoDB | 27017 | NoSQL Database |
| Redis | 6379 | Cache/Session |
| GeoServer | 8080 | GIS Web Server |

### .devcontainer.json Port Configuration
```json
{
  "forwardPorts": [3000, 3001, 8000, 5432, 27017, 6379, 8080],
  "portsAttributes": {
    "3000": {"label": "Frontend", "onAutoForward": "notify"},
    "3001": {"label": "Backend API", "onAutoForward": "notify"},
    "8000": {"label": "Dev Server", "onAutoForward": "notify"},
    "5432": {"label": "PostgreSQL", "onAutoForward": "silent"},
    "8080": {"label": "GeoServer/Gin", "onAutoForward": "notify"}
  }
}
```

### Hot Reload / File Watching Setup

**For Node.js (nodemon in package.json):**
```json
{
  "devDependencies": {
    "nodemon": "latest"
  },
  "scripts": {
    "dev": "nodemon src/index.js"
  }
}
```

**For Python (watchdog in requirements.txt):**
```
watchdog==3.0.0
flask>=2.0.0
```

**For Go (air in docker-compose):**
```dockerfile
RUN go install github.com/cosmtrek/air@latest
```

---

## Linters & Formatters

### Python (Black, Ruff, Pylint)
```dockerfile
RUN pip install black ruff pylint pytest
```

**Usage:**
```bash
black --check src/
ruff check src/
pylint src/
pytest tests/
```

### Node.js (ESLint, Prettier)
```json
{
  "devDependencies": {
    "eslint": "latest",
    "prettier": "latest"
  },
  "scripts": {
    "lint": "eslint src/",
    "format": "prettier --write src/"
  }
}
```

### Go (golangci-lint)
```dockerfile
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/go/bin
```

**Usage:**
```bash
golangci-lint run ./...
```

---

## Recommended Dev Tool Combinations

### Minimal (Just basics)
- Git
- Debugger for primary language

### Standard (Full development)
- Docker
- Git
- Language-specific debugger
- Linter + Formatter
- Port forwarding for dev servers

### Full (Enterprise/Complex)
- Docker + Docker Compose
- Git
- Debuggers for all languages
- Linters + Formatters + Tests
- Development servers with hot reload
- Environment variable management

---

## Testing Framework Installation

### Python (pytest)
```bash
pip install pytest pytest-cov pytest-asyncio
```

### Node.js (Jest/Mocha)
```bash
npm install --save-dev jest @testing-library/react
```

### Go (golang testing + testify)
```bash
go get github.com/stretchr/testify
```

---

## Health Checks for Dev Tools

### Git Accessibility
```bash
git --version && git config --global user.name
```

### Docker CLI
```bash
docker --version && docker ps
```

### Debugger Availability
```bash
# Python
python -c "import debugpy; print('debugpy ready')"

# Node.js
node --version

# Go
go version
```
