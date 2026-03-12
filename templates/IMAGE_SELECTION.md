# Base Image Selection Guide

## Overview
The base image is the foundation of your devcontainer. Choosing the right one impacts:
- Build time
- Container size
- Pre-installed tools
- Compatibility with your stack

---

## Official Images Explained

### 1. Ubuntu Base (Recommended for Fullstack)
**Image**: `mcr.microsoft.com/devcontainers/base:ubuntu` or `mcr.microsoft.com/devcontainers/base:ubuntu-22.04`

**What it includes:**
- Ubuntu Linux (22.04 LTS)
- Basic development tools (curl, wget, git)
- Docker CLI support
- \~700MB size

**Best for:**
- Fullstack applications
- Multiple languages in one project
- Maximum flexibility
- Learning/prototyping

**Pros:**
- Very flexible - install anything
- Good community support
- Regular updates
- Works with any language

**Cons:**
- Requires manual setup of language runtimes
- Larger than specialized images
- More dependencies to manage

**Example**: GIS fullstack app mixing Node.js frontend + Python backend

---

### 2. Python Optimized
**Image**: `mcr.microsoft.com/devcontainers/python:{VERSION}-bullseye`

**Versions available**: 3.8, 3.9, 3.10, 3.11, 3.12

**What it includes:**
- Python pre-installed with selected version
- pip, venv, pipx
- Common Python dev tools
- \~900MB size

**Best for:**
- Pure Python projects
- Data Science / ML applications
- Python APIs (FastAPI, Django)
- Python microservices

**Pros:**
- Python + pip ready to use
- Optimized for Python development
- Poetry/Pipenv compatible
- Virtual environment pre-configured

**Cons:**
- Only Python (can still add other languages but less optimal)
- Overkill if you need minimal Python

**Example**: FastAPI + PostgreSQL backend

---

### 3. Node.js / TypeScript Optimized
**Image**: `mcr.microsoft.com/devcontainers/typescript-node:{VERSION}-bullseye`

**Versions available**: 16, 18, 20, 22

**What it includes:**
- Node.js + npm/yarn
- TypeScript installed globally
- Development tools (make, git, etc.)
- \~1GB size

**Best for:**
- JavaScript/TypeScript projects
- React, Vue, Angular frontends
- Next.js, Express backends
- Full-stack Node.js apps

**Pros:**
- Node.js + npm ready immediately
- TypeScript pre-configured
- npm/yarn/pnpm compatible
- Great for modern web dev

**Cons:**
- Node-centric (other languages need installation)
- Larger than minimal alternatives
- Not ideal for non-JS projects

**Example**: Next.js fullstack app with Node.js backend

---

### 4. Go Optimized
**Image**: `mcr.microsoft.com/devcontainers/go:{VERSION}-bullseye`

**Versions available**: 1.19, 1.20, 1.21, 1.22

**What it includes:**
- Go compiler pre-installed
- go mod ready
- Common Go tools (dlv debugger, etc.)
- \~600MB size

**Best for:**
- Pure Go projects
- Go microservices
- Go CLI tools
- Go + PostGIS GIS backends

**Pros:**
- Go compiler pre-configured
- Fast compilation
- Small image size
- Go tools (Delve, etc.) included

**Cons:**
- Go-only (adding other languages less natural)
- Not for polyglot projects

**Example**: Go Gin API with PostGIS

---

### 5. Java Optimized
**Image**: `mcr.microsoft.com/devcontainers/java:{VERSION}-bullseye`

**Versions available**: 11, 17, 21

**What it includes:**
- JDK pre-installed
- Maven or Gradle available
- Common Java dev tools
- \~1.2GB size

**Best for:**
- Pure Java projects
- Spring Boot applications
- Enterprise Java apps
- Java + PostgreSQL systems

**Pros:**
- JDK ready to use
- Maven/Gradle pre-configured
- Large framework ecosystem
- Enterprise-grade tools

**Cons:**
- Heavy image
- Java-centric
- Not minimal

**Example**: Spring Boot REST API + PostgreSQL

---

## Specialized Images for GIS

### PostGIS + PostgreSQL
**Image**: `postgis/postgis:{VERSION}` (NOT a devcontainer image)

**Important**: This is for the database SERVICE in docker-compose, NOT the devcontainer base image.

```yaml
# docker-compose.yml
services:
  postgres:
    image: postgis/postgis:16-3.4  # PostgreSQL 16 + PostGIS 3.4
```

**Then**, choose your devcontainer base on your backend language:
- Python backend → `python:3.11-bullseye`
- Node.js backend → `typescript-node:20-bullseye`
- Go backend → `go:1.21-bullseye`

---

## Decision Matrix

| Project Type | Recommended Image | Why |
|--------------|-------------------|-----|
| Node.js SPA frontend | `typescript-node:20` | JavaScript/TypeScript native |
| Python FastAPI backend | `python:3.11` | Python optimized |
| Go Gin API | `go:1.21` | Go native |
| Python + Node.js fullstack | `base:ubuntu` | Both languages needed |
| Python + GIS (PostGIS backend) | `python:3.11` | Python primary, GIS in DB |
| Node.js + GIS (PostGIS backend) | `typescript-node:20` | JavaScript primary, GIS in DB |
| Multi-language microservices repo | `base:ubuntu` | Flexibility for multiple languages |
| Java Spring Boot + PostGIS | `java:21` | Java enterprise standard |

---

## Image Size Comparison

```
base:ubuntu              ~700MB
go:1.21-bullseye        ~600MB
python:3.11-bullseye    ~900MB
typescript-node:20      ~1GB
java:21-bullseye        ~1.2GB
```

---

## Language-Specific Images (In devcontainer)

### Install Multiple Languages

**Option 1**: Start with `base:ubuntu`, add features
```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/python:1": {"version": "3.11"},
    "ghcr.io/devcontainers/features/node:1": {"version": "20"}
  }
}
```

**Option 2**: Use language-specific image, add other languages
```json
{
  "image": "mcr.microsoft.com/devcontainers/python:3.11-bullseye",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {"version": "20"}
  }
}
```

---

## Quick Recommendation for GIS Fullstack

**Most common case**: Node.js or Python backend + PostgreSQL + PostGIS

**Recommended base image**:
- **Python backend**: `mcr.microsoft.com/devcontainers/python:3.11-bullseye`
- **Node.js backend**: `mcr.microsoft.com/devcontainers/typescript-node:20-bullseye`

**Why**:
- Optimized for primary language
- All dev tools pre-installed
- Minimal overhead
- Database (with PostGIS) runs as separate service in docker-compose

---

## Custom Dockerfile Base Images

If you need something not available:

```dockerfile
FROM ubuntu:22.04

# Install multiple languages
RUN apt-get update && apt-get install -y \
    python3.11 \
    nodejs \
    golang \
    git \
    curl

# ... additional setup
```

**Use case**: Very specific requirements not covered by provided images

---

## Changing Image Later

If you choose wrong initially:
1. Edit `.devcontainer/devcontainer.json` → change `"image"` field
2. Rebuild container: `Cmd+Shift+P` → "Rebuild Container"
3. All your work in `/workspace` persists (if using volume mount)

**No data loss!**
