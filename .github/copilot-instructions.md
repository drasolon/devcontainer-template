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
   - Support non-interactive mode (`--non-interactive`): if answers are missing, use safe defaults and continue

2. Generate all required files based on answers:
   - `.devcontainer/devcontainer.json`
   - `docker-compose.yml`
   - `.env.template` (and `.env` if user wants)
   - `Dockerfile` if deployment as docker image is needed
   - Framework-specific backend config for DB connection
   - Machine-readable report: `reports/devcontainer-init-report.json`
   - Test scripts for services and connectivity

   Java rule:
   - If Java framework is unknown, ask Spring Boot vs plain Java.
   - If still unknown, generate Spring-compatible config and a minimal plain-Java fallback profile.
   - Optionally generate Maven/Gradle build files with dependency hints.

3. Run validation tests automatically after generation:
   - Services start successfully
   - Required ports open
   - App/service to DB connectivity works
   - GIS service connectivity works when selected
   - Dev servers are reachable from host
   - Use bounded readiness retries and clear failure reasons
   - Deployment mode checks:
     - local dev: host-to-service and service-to-service
     - docker-image mode: build + run smoke test
     - semi-dev: remote DB reachability and TLS options

4. Report test status clearly and fix obvious config issues when possible.
5. Enforce idempotency: reruns should merge minimally, preserve user custom sections, and avoid duplicated blocks.
6. Before generation/tests, verify required tools (Docker, Compose, curl, and language-specific CLIs). If missing, print actionable per-OS install steps.
7. Port preflight: detect host-port conflicts and remap consistently in all generated files.
8. Secrets policy: placeholders only by default, optional random local-only passwords, and unsafe-default scan.
9. Provide cleanup commands and minimal recovery path when setup partially fails.

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

Validate generated extension list and flag unexpected extras.

## Output Quality

- Prefer simple, maintainable defaults.
- Explain image choices briefly before user selects.
- Require image reasoning output (choice, why, tradeoffs) and `amd64`/`arm64` compatibility check.
- Keep generated config minimal but complete.
- Ensure result is reusable by multiple developers.
