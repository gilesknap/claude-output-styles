#!/usr/bin/env bash
# Install a style from this repo and select it, without clobbering your settings.
#
#   ./examples/install.sh                                  # Plain technical, user level
#   ./examples/install.sh "Plain technical (strict)"        # the strict style
#   ./examples/install.sh "Plain technical" project         # into ./.claude instead
#
# Requires jq. Backs up the settings file it edits.
set -euo pipefail

STYLE="${1:-Plain technical}"
SCOPE="${2:-user}"

case "$STYLE" in
  "Plain technical")          FILE="plain-technical.md" ;;
  "Plain technical (strict)") FILE="plain-technical-strict.md" ;;
  *) echo "Unknown style: $STYLE" >&2
     echo 'Use "Plain technical" or "Plain technical (strict)".' >&2
     exit 2 ;;
esac

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO/output-styles/$FILE"
[ -f "$SRC" ] || { echo "Style file not found: $SRC" >&2; exit 1; }

if [ "$SCOPE" = "user" ]; then
  DIR="$HOME/.claude"
  SETTINGS="$DIR/settings.json"
else
  DIR="$PWD/.claude"
  SETTINGS="$DIR/settings.local.json"
fi

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

mkdir -p "$DIR/output-styles"
cp "$SRC" "$DIR/output-styles/"
echo "Copied $FILE to $DIR/output-styles/"

if [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "$SETTINGS.bak"
  echo "Backed up $SETTINGS to $SETTINGS.bak"
else
  echo '{}' > "$SETTINGS"
fi

TMP="$(mktemp)"
jq --arg s "$STYLE" '. + {outputStyle: $s}' "$SETTINGS" > "$TMP"
mv "$TMP" "$SETTINGS"
echo "Set outputStyle to \"$STYLE\" in $SETTINGS"

echo
echo "Run /clear, or start a new session, for it to take effect."
