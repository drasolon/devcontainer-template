# VS Code Extensions Minimal Policy

## Overview
This template uses a strict minimal extension strategy for portability and speed.

Install only what is required:
1. GitHub Copilot
2. One primary linting extension for selected stack
3. One docs/intellisense extension for function/class info

Target: usually 2-4 extensions total.

---

## Baseline (Always)

```json
[
  "github.copilot"
]
```

---

## Stack-Based Minimal Set

### Python

```json
[
  "github.copilot",
  "charliermarsh.ruff",
  "ms-python.vscode-pylance"
]
```

- Linting: `charliermarsh.ruff`
- Function/class docs + typing info: `ms-python.vscode-pylance`

### Node.js / TypeScript

```json
[
  "github.copilot",
  "dbaeumer.vscode-eslint",
  "ms-vscode.vscode-typescript-next"
]
```

- Linting: `dbaeumer.vscode-eslint`
- Function/class docs + type info: `ms-vscode.vscode-typescript-next`

### Go

```json
[
  "github.copilot",
  "golang.go"
]
```

- Linting + docs/intellisense: `golang.go`

### Java

```json
[
  "github.copilot",
  "redhat.java"
]
```

- Linting/diagnostics + docs/intellisense: `redhat.java`

---

## Multi-Language Rule

When more than one language is selected:
- Keep `github.copilot`
- Add one linting + one docs extension for each selected primary language
- Prefer overlap when an extension already provides both
- Frameworks use the same language docs/intellisense extension by default (no extra framework bundle unless user asks)

Example (Node.js + Python):

```json
[
  "github.copilot",
  "dbaeumer.vscode-eslint",
  "ms-vscode.vscode-typescript-next",
  "charliermarsh.ruff",
  "ms-python.vscode-pylance"
]
```

---

## Generator Rule for `devcontainer.json`

Write these under:

```json
{
  "customizations": {
    "vscode": {
      "extensions": []
    }
  }
}
```

Copilot should explain why each extension is included and avoid adding optional bundles unless user asks.

---

## Optional (Only if user explicitly asks)

- `ms-vscode-remote.remote-containers`
- `ms-azuretools.vscode-docker`
- `cweijan.vscode-postgresql-client2`
- `mongodb.mongodb-vscode`
- `RandomFractalsInc.geo-data-viewer`

These are not installed by default in this template.
