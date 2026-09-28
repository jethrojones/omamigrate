#!/usr/bin/env bash
# install omamigrate: single-file python3 app into ~/.local/bin + omarchy menu entry
# works from a checkout, or piped:  curl -fsSL <raw install.sh> | bash
set -euo pipefail

VERSION="${OMAMIGRATE_VERSION:-1.1.0}"

SRC="${1:-}"
if [ -z "$SRC" ]; then
  local_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/omamigrate"
  if [ -f "$local_dir" ]; then
    SRC="$local_dir"
  fi
fi
if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
  tmp="$(mktemp)"
  curl -fsSL "https://raw.githubusercontent.com/jethrojones/omamigrate/v${VERSION}/omamigrate" -o "$tmp"
  SRC="$tmp"
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found. installing via omarchy pkg add..."
  omarchy pkg add python || sudo pacman -S --noconfirm python
fi

DEST="$HOME/.local/bin/omamigrate"
mkdir -p "$HOME/.local/bin"
cp "$SRC" "$DEST"
chmod +x "$DEST"

if command -v omarchy >/dev/null 2>&1; then
  "$DEST" install-menu || true
fi

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
  line='export PATH="$HOME/.local/bin:$PATH"'
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -qF '.local/bin' "$rc"; then
      echo "$line" >> "$rc"
    fi
  done
  echo "note: added ~/.local/bin to your shell rc (open a new shell to pick it up)"
fi

echo "installed: $DEST"
echo
echo "  omamigrate          open the dashboard"
echo "  omamigrate gui      same thing (explicit)"
echo "  omamigrate scan     list everything you could carry"
echo "  omamigrate pack     build a bundle"
echo "  omamigrate apply B  restore a bundle"
echo "  omamigrate agent    let the default agent walk you through it"
echo
echo "starting the dashboard..."
exec "$DEST" gui
