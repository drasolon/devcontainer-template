# Language Components

## Python

### Supported Versions
- 3.8 (EOL: Oct 2024)
- 3.9 (EOL: Oct 2025)
- 3.10 (EOL: Oct 2026)
- 3.11 (LTS)
- 3.12 (Latest)

### Installation Methods
- **Base Image**: `mcr.microsoft.com/devcontainers/python:{VERSION}-bullseye`
- **Package Manager**: pip, poetry, conda

### .devcontainer.json Config
```json
{
  "image": "mcr.microsoft.com/devcontainers/python:3.11-bullseye",
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.11"
    }
  }
}
```

### Environment Setup
- **Virtual Environment**: Yes (venv or poetry)
- **Requirements File**: `requirements.txt` or `pyproject.toml`
- **Entry Point**: Typically app.py or main.py

### Popular Frameworks
- **FastAPI**: Great for REST APIs + async
- **Django**: Full-featured framework + ORM
- **Flask**: Lightweight, flexible
- **Celery**: Task queue (often paired with other frameworks)

---

## Node.js

### Supported Versions
- 16.x (EOL: Sept 2023)
- 18.x (LTS until April 2025)
- 20.x (LTS until April 2026)
- 22.x (Latest)

### Installation Methods
- **Base Image**: `mcr.microsoft.com/devcontainers/typescript-node:{VERSION}-bullseye`
- **Package Manager**: npm, yarn, pnpm

### .devcontainer.json Config
```json
{
  "image": "mcr.microsoft.com/devcontainers/typescript-node:20-bullseye",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "20"
    }
  }
}
```

### Environment Setup
- **Package Manager**: npm (default) / yarn / pnpm
- **Build Tool**: npm scripts, webpack, vite, esbuild
- **Node Version Manager**: nvm (optional)

### Popular Frameworks
- **Express.js**: Lightweight, minimal
- **NestJS**: Full-featured, TypeScript-first
- **Next.js**: Full-stack React framework
- **Fastify**: Fast HTTP server
- **Hapi**: Enterprise-grade framework

---

## Go

### Supported Versions
- 1.19 (EOL: Dec 2023)
- 1.20 (EOL: Aug 2024)
- 1.21 (LTS)
- 1.22 (Latest)

### Installation Methods
- **Base Image**: `mcr.microsoft.com/devcontainers/go:{VERSION}-bullseye`
- **Package Manager**: go mod

### .devcontainer.json Config
```json
{
  "image": "mcr.microsoft.com/devcontainers/go:1.21-bullseye",
  "features": {
    "ghcr.io/devcontainers/features/go:1": {
      "version": "1.21"
    }
  }
}
```

### Environment Setup
- **Module System**: go mod (required)
- **GOPATH**: Automatically configured
- **Workspace**: `/workspace` or project root

### Popular Frameworks
- **Gin**: High-performance web framework
- **Echo**: Fast and minimalist
- **GORM**: Popular ORM
- **Buffalo**: Full-stack framework

---

## Java

### Supported Versions
- 11 (LTS)
- 17 (LTS)
- 21 (Latest LTS)

### Installation Methods
- **Base Image**: `mcr.microsoft.com/devcontainers/java:{VERSION}-bullseye`
- **Package Manager**: Maven, Gradle

### .devcontainer.json Config
```json
{
  "image": "mcr.microsoft.com/devcontainers/java:21-bullseye",
  "features": {
    "ghcr.io/devcontainers/features/java:1": {
      "version": "21"
    }
  }
}
```

### Environment Setup
- **Build Tool**: Maven or Gradle
- **Package Manager**: Maven Central or Gradle Central
- **JAVA_HOME**: Auto-configured

### Popular Frameworks
- **Spring Boot**: Most popular, enterprise-grade
- **Quarkus**: Cloud-native, low memory
- **Micronaut**: Lightweight, fast startup

---

## Multi-Language Setup

If project uses multiple languages:
- Use base image from dominant language
- Or use `base:ubuntu` and install multiple
- Ensure compatibility of versions

### Example: Node.js + Python
```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {"version": "20"},
    "ghcr.io/devcontainers/features/python:1": {"version": "3.11"}
  }
}
```
