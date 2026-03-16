# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## New Machine Setup

### Linux / macOS

Install chezmoi and apply dotfiles in one command:

    chezmoi init anelson --apply

This will:
1. Clone this repo to `~/.local/share/chezmoi`
2. Prompt for machine-specific values (git email, name)
3. Apply all dotfiles to your home directory

After applying, set up secrets:

    # Create ~/.secrets with API tokens (not tracked by chezmoi)
    cat > ~/.secrets << 'EOF'
    export CLOUDSMITH_AUTH_TOKEN=<your-token-here>
    EOF

Restart your shell for everything to take effect.

### Windows

    winget install twpayne.chezmoi
    chezmoi init anelson --apply

Most Unix-specific configs are automatically skipped on Windows.

## Migrating from homeshick

If this machine still has the old homeshick setup, run the migration
script instead of `chezmoi init`:

    cd ~/.homesick/repos/dotfiles
    git pull
    bash migrate-to-chezmoi.sh

## Daily Usage

    chezmoi edit ~/.zshrc       # Edit a managed file (opens source copy)
    chezmoi diff                # Preview what chezmoi would change
    chezmoi apply               # Apply changes from source to home dir
    chezmoi add ~/.newfile      # Start managing a new file
    chezmoi cd                  # cd into the source repo
    chezmoi update              # Pull latest from git and apply

### Editing workflow

Option A -- edit via chezmoi (recommended):

    chezmoi edit ~/.zshrc
    chezmoi apply

Option B -- edit the source repo directly:

    cd $(chezmoi source-path)
    # edit files directly (remember chezmoi naming: dot_zshrc, etc.)
    chezmoi apply

Option C -- edit the live file, then pull changes back:

    vim ~/.zshrc
    chezmoi re-add              # Copy changes from ~ back into source

### Templates

Files ending in `.tmpl` are Go templates processed at apply time.
Available variables:

| Variable | Source | Example value |
|----------|--------|---------------|
| `{{ .chezmoi.os }}` | Built-in | `linux`, `darwin`, `windows` |
| `{{ .chezmoi.hostname }}` | Built-in | `dijkstra` |
| `{{ .chezmoi.username }}` | Built-in | `cornelius` |
| `{{ .chezmoi.homeDir }}` | Built-in | `/home/cornelius` |
| `{{ .email }}` | Init prompt | `anelson@users.noreply.github.com` |
| `{{ .name }}` | Init prompt | `Adam Nelson` |

To re-run the init prompts: `chezmoi init`

### Secrets

Secrets are **never** stored in this repo. API tokens and credentials
go in `~/.secrets`, which is sourced by `.zshrc` but not managed by
chezmoi.

### OS-conditional files

`.chezmoiignore` skips Linux desktop configs (i3, sway, polybar, etc.)
on non-Linux systems, and skips most Unix configs on Windows.
