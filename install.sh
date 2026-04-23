#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp "$DOTFILES_DIR/portableBash.sh" "$HOME/portableBash.sh"

if ! grep -qF 'portableBash.sh' "$HOME/.bashrc" 2>/dev/null; then
    echo '[ -f ~/portableBash.sh ] && source ~/portableBash.sh' >> "$HOME/.bashrc"
fi
