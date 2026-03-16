#!/bin/bash
set -euo pipefail

DOTFILES_REPO="$HOME/.homesick/repos/dotfiles"
CHEZMOI_DIR="$HOME/.local/share/chezmoi"

echo "=== Dotfiles Migration: homeshick -> chezmoi ==="

# Verify preconditions
if [ ! -d "$DOTFILES_REPO" ]; then
    echo "ERROR: homeshick dotfiles repo not found at $DOTFILES_REPO"
    exit 1
fi
if [ ! -f "$DOTFILES_REPO/.chezmoi.toml.tmpl" ]; then
    echo "ERROR: chezmoi config not found. Pull latest master first."
    exit 1
fi

# Step 1: Install chezmoi
if ! command -v chezmoi &> /dev/null; then
    echo "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

# Step 2: Remove homeshick symlinks pointing into the dotfiles repo
echo "Removing homeshick symlinks..."
find "$HOME" -maxdepth 1 -type l -lname "$DOTFILES_REPO/home/*" -delete 2>/dev/null || true
for dir in .config .zsh .tmux .tmuxp .local .gnupg .ssh .cargo .sbt .vim .wallpaper .aws-sso; do
    target="$HOME/$dir"
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -d "$target" ]; then
        find "$target" -type l -lname "$DOTFILES_REPO/home/*" -delete 2>/dev/null || true
    fi
done

# Step 3: Move the repo to chezmoi's default location
echo "Moving repo to $CHEZMOI_DIR..."
if [ -d "$CHEZMOI_DIR" ]; then
    echo "ERROR: $CHEZMOI_DIR already exists. Remove it first."
    exit 1
fi
mkdir -p "$(dirname "$CHEZMOI_DIR")"
mv "$DOTFILES_REPO" "$CHEZMOI_DIR"

# Step 4: Initialize and apply chezmoi
echo "Initializing chezmoi..."
chezmoi init --source "$CHEZMOI_DIR" --apply

# Step 5: Verify
echo ""
chezmoi doctor
echo ""
chezmoi status

echo ""
echo "=== Migration complete ==="
echo ""
echo "Next steps:"
echo "  1. Run 'chezmoi diff' to verify files look correct"
echo "  2. Set up secrets: create ~/.secrets with API tokens"
echo "  3. Remove homeshick: rm -rf ~/.homesick/repos/homeshick"
echo "  4. Optionally: rm -rf ~/.homesick (if empty)"
echo "  5. Restart your shell"
