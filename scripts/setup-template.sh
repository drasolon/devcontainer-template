#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="1.2.0"
REPO_RAW_BASE="https://raw.githubusercontent.com/drasolon/devcontainer-template/main"
INSTRUCTIONS_PATH=".github/copilot-instructions.md"

ALL_TEMPLATE_PATHS=(
  ".github/copilot-instructions.md"
  "prompts/MAIN_WIZARD.md"
  "prompts/COPILOT_GUIDE.md"
  "components/LANGUAGES.md"
  "components/DATABASES.md"
  "components/GIS.md"
  "components/DEV_TOOLS.md"
  "templates/IMAGE_SELECTION.md"
  "templates/GENERATORS_GUIDE.md"
  "templates/EXTENSIONS_GUIDE.md"
  "tests/TEST_TEMPLATES.md"
)

usage() {
  cat <<EOF
Usage:
  setup-template.sh [TARGET_DIR] [--force] [--minimal]
  setup-template.sh --help
  setup-template.sh --version

Arguments:
  TARGET_DIR   Target repository directory (default: current directory)
  --force      Overwrite existing template files
  --minimal    Install only .github/copilot-instructions.md

Examples:
  setup-template.sh
  setup-template.sh /path/to/repo
  setup-template.sh /path/to/repo --force
  setup-template.sh /path/to/repo --minimal
EOF
}

TARGET_DIR="."
FORCE=""
MINIMAL=""

for arg in "$@"; do
  case "$arg" in
    --help|-h)
      usage
      exit 0
      ;;
    --version|-v)
      echo "$SCRIPT_VERSION"
      exit 0
      ;;
    --force)
      FORCE="--force"
      ;;
    --minimal)
      MINIMAL="--minimal"
      ;;
    *)
      if [[ "$TARGET_DIR" == "." ]]; then
        TARGET_DIR="$arg"
      else
        echo "❌ Unexpected argument: $arg"
        echo ""
        usage
        exit 1
      fi
      ;;
  esac
done

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "❌ Target directory does not exist: $TARGET_DIR"
  exit 1
fi

download_with_curl() {
  local source_url="$1"
  local target_file="$2"
  curl -fsSL "$source_url" -o "$target_file"
}

download_with_wget() {
  local source_url="$1"
  local target_file="$2"
  wget -qO "$target_file" "$source_url"
}

download_file() {
  local rel_path="$1"
  local source_url="$REPO_RAW_BASE/$rel_path"
  local target_file="$TARGET_DIR/$rel_path"

  mkdir -p "$(dirname "$target_file")"

  if [[ -f "$target_file" && "$FORCE" != "--force" ]]; then
    echo "ℹ️ Skipped existing: $rel_path"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    download_with_curl "$source_url" "$target_file"
  elif command -v wget >/dev/null 2>&1; then
    download_with_wget "$source_url" "$target_file"
  else
    echo "❌ Neither curl nor wget is installed."
    exit 1
  fi

  echo "✅ Installed: $rel_path"
  INSTALLED=$((INSTALLED + 1))
}

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  echo "❌ Neither curl nor wget is installed."
  exit 1
fi

INSTALLED=0
SKIPPED=0

if [[ "$MINIMAL" == "--minimal" ]]; then
  download_file "$INSTRUCTIONS_PATH"
else
  for path in "${ALL_TEMPLATE_PATHS[@]}"; do
    download_file "$path"
  done
fi

echo ""
echo "Install summary:"
echo "- Installed: $INSTALLED"
echo "- Skipped (already existed): $SKIPPED"
echo "- Target: $TARGET_DIR"
echo ""
echo "Next steps:"
echo "1) Open that repo in VS Code"
echo "2) Open Copilot Chat"
echo "3) Run: /devcontainer init"
