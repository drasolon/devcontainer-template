#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="1.1.0"
REPO_RAW_BASE="https://raw.githubusercontent.com/drasolon/devcontainer-template/main"
INSTRUCTIONS_PATH=".github/copilot-instructions.md"
SOURCE_URL="$REPO_RAW_BASE/$INSTRUCTIONS_PATH"

usage() {
  cat <<EOF
Usage:
  setup-template.sh [TARGET_DIR] [--force]
  setup-template.sh --help
  setup-template.sh --version

Arguments:
  TARGET_DIR   Target repository directory (default: current directory)
  --force      Overwrite existing .github/copilot-instructions.md

Examples:
  setup-template.sh
  setup-template.sh /path/to/repo
  setup-template.sh /path/to/repo --force
EOF
}

TARGET_DIR="."
FORCE=""

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

TARGET_FILE="$TARGET_DIR/$INSTRUCTIONS_PATH"
mkdir -p "$TARGET_DIR/.github"

if [[ -f "$TARGET_FILE" && "$FORCE" != "--force" ]]; then
  echo "ℹ️ $TARGET_FILE already exists."
  echo "   Use --force to overwrite."
  echo "   Example: ./scripts/setup-template.sh /path/to/repo --force"
  exit 0
fi

download_with_curl() {
  curl -fsSL "$SOURCE_URL" -o "$TARGET_FILE"
}

download_with_wget() {
  wget -qO "$TARGET_FILE" "$SOURCE_URL"
}

if command -v curl >/dev/null 2>&1; then
  download_with_curl
elif command -v wget >/dev/null 2>&1; then
  download_with_wget
else
  echo "❌ Neither curl nor wget is installed."
  exit 1
fi

echo "✅ Installed $INSTRUCTIONS_PATH into: $TARGET_DIR"
echo ""
echo "Next steps:"
echo "1) Open that repo in VS Code"
echo "2) Open Copilot Chat"
echo "3) Run: /devcontainer init"
