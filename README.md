# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## New Machine Setup

### Linux / macOS

Install chezmoi and apply dotfiles in one command:

    chezmoi init anelson --apply

This will:
1. Clone this repo to `~/.local/share/chezmoi`
2. Prompt for machine-specific values (see defaults below)
3. Apply all dotfiles to your home directory

Init prompts and their defaults:

| Prompt | Default |
|--------|---------|
| Git email address | `anelson@users.noreply.github.com` |
| Git user name | `Adam Nelson` |

To re-run the prompts later: `chezmoi init`

After applying, set up secrets:

    cat > ~/.secrets << 'EOF'
    export CLOUDSMITH_AUTH_TOKEN=<your-token-here>
    EOF
    chmod 600 ~/.secrets

Restart your shell for everything to take effect.

### Windows

    winget install twpayne.chezmoi
    chezmoi init anelson --apply

Most Unix-specific configs are automatically skipped on Windows.

## Migrating from homeshick

If this machine still has the old homeshick setup, run the migration
script instead of `chezmoi init`:

    cd ~/.homesick/repos/dotfiles
    git checkout experiment/chezmoi
    bash migrate-to-chezmoi.sh

## Daily Usage

### Checking for uncommitted changes

With homeshick the workflow was `hs cd dotfiles && git status` to find
files you'd edited and forgotten to commit. With chezmoi, it's different:
chezmoi copies files into `~` rather than symlinking them, so edits to
live files (e.g. `~/.zshrc`) don't automatically appear in the source
repo.

To see what's drifted:

    chezmoi status

This shows files where the live copy in `~` differs from what chezmoi
would write. A line like `MM .zshrc` means the file was modified both
in the source state and in the target.

To see the actual diff:

    chezmoi diff

To pull all those changes back into the source repo at once:

    chezmoi re-add

Then commit as usual:

    chezmoi cd
    git add -A && git commit -m "message"
    git push

### Editing files

**Option A** -- edit via chezmoi (recommended):

    chezmoi edit ~/.zshrc       # Opens the source copy in $EDITOR
    chezmoi apply               # Writes it to ~

**Option B** -- edit the live file directly, then pull changes back:

    vim ~/.zshrc
    chezmoi re-add              # Copies changes from ~ back into source

**Option C** -- edit the source repo directly:

    chezmoi cd
    # edit files (remember chezmoi naming: dot_zshrc, etc.)
    chezmoi apply

### Adding new files

    chezmoi add ~/.some-new-config

This copies the file into the source repo with the appropriate chezmoi
naming convention, then you commit it.

### Pulling changes from another machine

    chezmoi update

This does a `git pull` on the source repo and then applies.

### Quick reference

    chezmoi status              # What's drifted between ~ and source?
    chezmoi diff                # Show the diffs
    chezmoi re-add              # Pull live changes back into source
    chezmoi apply               # Push source state out to ~
    chezmoi edit <file>         # Edit a managed file's source copy
    chezmoi add <file>          # Start managing a new file
    chezmoi cd                  # cd into the source repo
    chezmoi update              # git pull + apply
    chezmoi doctor              # Health check

## Templates

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

## Secrets

Secrets are **never** stored in this repo. API tokens and credentials
go in `~/.secrets`, which is sourced by `.zshrc` but not managed by
chezmoi.

## OS-conditional files

`.chezmoiignore` skips Linux desktop configs (i3, sway, polybar, etc.)
on non-Linux systems, and skips most Unix configs on Windows.
