#!/usr/bin/env bash
set -euo pipefail

REPO_RAW_BASE="https://raw.githubusercontent.com/drasolon/devcontainer-template/main"
INSTRUCTIONS_PATH=".github/copilot-instructions.md"
SOURCE_URL="$REPO_RAW_BASE/$INSTRUCTIONS_PATH"

TARGET_DIR="${1:-.}"
FORCE="${2:-}"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "❌ Target directory does not exist: $TARGET_DIR"
  exit 1
fi

TARGET_FILE="$TARGET_DIR/$INSTRUCTIONS_PATH"
mkdir -p "$TARGET_DIR/.github"

if [[ -f "$TARGET_FILE" && "$FORCE" != "--force" ]]; then
  echo "ℹ️ $TARGET_FILE already exists."
  echo "   Use --force as second argument to overwrite."
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
