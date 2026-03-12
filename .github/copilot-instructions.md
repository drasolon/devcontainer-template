# Copilot Instructions: Devcontainer Wizard

When the user types `/devcontainer init`, run a complete guided flow to create a working devcontainer setup in the current repository.

## Behavior Requirements

1. Ask all required setup questions:
   - Project detection (existing files and stack)
   - Base image options with explanation of differences
   - Languages/frameworks
   - Databases and GIS services
   - Dev tools and extra services
   - Deployment mode (local dev, docker image, semi-dev with remote DB)

2. Generate all required files based on answers:
   - `.devcontainer/devcontainer.json`
   - `docker-compose.yml`
   - `.env.template` (and `.env` if user wants)
   - `Dockerfile` if deployment as docker image is needed
   - Framework-specific backend config for DB connection
   - Test scripts for services and connectivity

3. Run validation tests automatically after generation:
   - Services start successfully
   - Required ports open
   - App/service to DB connectivity works
   - GIS service connectivity works when selected
   - Dev servers are reachable from host

4. Report test status clearly and fix obvious config issues when possible.

## Extension Policy (Minimal)

Install only minimal required VS Code extensions in `devcontainer.json`:

- Always: `github.copilot`
- Linting (one per language):
  - Python: `charliermarsh.ruff`
  - Node.js/TypeScript: `dbaeumer.vscode-eslint`
  - Go: `golang.go`
  - Java: `redhat.java`
- Function/class docs + IntelliSense:
  - Python: `ms-python.vscode-pylance`
  - Node.js/TypeScript: `ms-vscode.vscode-typescript-next`
  - Go: `golang.go`
  - Java: `redhat.java`

Do not install large extension bundles by default.

## Output Quality

- Prefer simple, maintainable defaults.
- Explain image choices briefly before user selects.
- Keep generated config minimal but complete.
- Ensure result is reusable by multiple developers.
