#!/usr/bin/env bash
# Pick a Claude Code output style and turn it on.
#
# Run it with no arguments and it asks you what you want:
#
#   ./install.sh
#
# Or name a style loosely, if you already know: concise, plain, strict, default
#
#   ./install.sh concise
#   ./install.sh strict project
#
# Or install the rewrite skill on its own, changing no style:
#
#   ./install.sh skill
#
# It merges one field into your settings file and backs that file up first.
# It never replaces settings you already have. It needs jq.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command -v jq >/dev/null || { echo "jq is required. Install it and run this again." >&2; exit 1; }

# ---------------------------------------------------------------- pick a style

STYLE=""
FILE=""

set_style() {
  case "$1" in
    skill)    STYLE="__SKILL__"                  ; FILE="" ;;
    concise)  STYLE="Concise"                    ; FILE="" ;;
    plain)    STYLE="Plain technical"            ; FILE="plain-technical.md" ;;
    strict)   STYLE="Plain technical (strict)"   ; FILE="plain-technical-strict.md" ;;
    default)  STYLE="__REMOVE__"                 ; FILE="" ;;
    *) return 1 ;;
  esac
}

# A loose first argument skips the menu.
if [ "${1:-}" != "" ]; then
  ARG="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  case "$ARG" in
    concise|built-in|builtin)                set_style concise ;;
    plain|plain-technical|normal|standard)   set_style plain ;;
    strict|plain-technical-strict|ste)       set_style strict ;;
    default|none|off|revert)                 set_style default ;;
    skill|rewrite|apply)                     set_style skill ;;
    *) echo "Do not recognise \"$1\"." >&2
       echo "Use: concise, plain, strict, default or skill." >&2
       echo "Or run with no arguments to choose." >&2
       exit 2 ;;
  esac
fi

if [ -z "$STYLE" ]; then
  if [ ! -t 0 ]; then
    echo "Nothing to do: no style named and no terminal to ask on." >&2
    echo "Use: $0 [concise|plain|strict|default|skill] [user|project]" >&2
    exit 2
  fi
  cat <<'MENU'

Which output style do you want?

  1) Concise                   Built into Claude Code. Leads with the result, skips
                               preamble and narration. Nothing is installed. Try this
                               first: it may be all you need.

  2) Plain technical           This repo. Everything Concise does, plus active voice,
                               shorter sentences, one term per concept, and a filler
                               cut-list.

  3) Plain technical (strict)  This repo. Adds the mechanical writing limits of
                               ASD-STE100: 20-word procedural sentences, imperatives,
                               no -ing forms, no contractions. For documentation.

  4) Default                   Turn any style off and go back to stock Claude Code.

  5) Rewrite skill only        Install apply-style-to-existing, which rewrites the
                               docstrings and comments of an existing codebase to match
                               whichever style you have active. Changes no style.

MENU
  while :; do
    read -r -p "Enter 1-5 [1]: " CHOICE
    CHOICE="${CHOICE:-1}"
    case "$CHOICE" in
      1) set_style concise; break ;;
      2) set_style plain;   break ;;
      3) set_style strict;  break ;;
      4) set_style default; break ;;
      5) set_style skill;   break ;;
      *) echo "Enter a number from 1 to 5." ;;
    esac
  done
fi

# ---------------------------------------------------------------- pick a scope

SCOPE="${2:-}"
if [ -z "$SCOPE" ]; then
  if [ -t 0 ]; then
    cat <<'MENU'

Where should it apply?

  1) Everywhere                ~/.claude/settings.json, every project you work on.
  2) This project only         ./.claude/settings.local.json, in the current directory.

MENU
    while :; do
      read -r -p "Enter 1-2 [1]: " CHOICE
      CHOICE="${CHOICE:-1}"
      case "$CHOICE" in
        1) SCOPE="user";    break ;;
        2) SCOPE="project"; break ;;
        *) echo "Enter 1 or 2." ;;
      esac
    done
  else
    SCOPE="user"
  fi
fi

case "$SCOPE" in
  user)    DIR="$HOME/.claude";  SETTINGS="$DIR/settings.json" ;;
  project) DIR="$PWD/.claude";   SETTINGS="$DIR/settings.local.json" ;;
  *) echo "Scope must be \"user\" or \"project\", not \"$SCOPE\"." >&2; exit 2 ;;
esac

# ---------------------------------------------------------------------- do it

echo
mkdir -p "$DIR"

if [ "$STYLE" = "__SKILL__" ]; then
  SRC="$REPO/skills/apply-style-to-existing"
  [ -d "$SRC" ] || { echo "Skill not found: $SRC" >&2; exit 1; }
  mkdir -p "$DIR/skills"
  rm -rf "$DIR/skills/apply-style-to-existing"
  cp -r "$SRC" "$DIR/skills/"
  echo "Installed apply-style-to-existing to $DIR/skills/"
  echo
  echo "It loads on demand. No style changed, and no settings file touched."
  echo "Ask for it by name, or say \"rewrite the docstrings in your current style\"."
  exit 0
fi

if [ -n "$FILE" ]; then
  SRC="$REPO/output-styles/$FILE"
  [ -f "$SRC" ] || { echo "Style file not found: $SRC" >&2; exit 1; }
  mkdir -p "$DIR/output-styles"
  cp "$SRC" "$DIR/output-styles/"
  echo "Copied $FILE to $DIR/output-styles/"
fi

if [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "$SETTINGS.bak"
  echo "Backed up $SETTINGS to $SETTINGS.bak"
else
  echo '{}' > "$SETTINGS"
  echo "Created $SETTINGS"
fi

TMP="$(mktemp)"
if [ "$STYLE" = "__REMOVE__" ]; then
  jq 'del(.outputStyle)' "$SETTINGS" > "$TMP"
  mv "$TMP" "$SETTINGS"
  echo "Removed outputStyle from $SETTINGS"
else
  jq --arg s "$STYLE" '. + {outputStyle: $s}' "$SETTINGS" > "$TMP"
  mv "$TMP" "$SETTINGS"
  echo "Set outputStyle to \"$STYLE\" in $SETTINGS"
fi

echo
echo "Run /clear, or start a new session, for it to take effect."
