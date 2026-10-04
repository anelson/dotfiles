# Working on these dotfiles

This repository is the chezmoi source state for the user's home directory. Make persistent configuration changes here rather than editing generated files under `$HOME` unless the task explicitly concerns live state.

## Map source files to targets

Follow chezmoi's source naming conventions:

- `dot_name` becomes `~/.name`.
- `private_name` becomes a target with private permissions.
- `executable_name` becomes an executable target.
- `symlink_name` contains the symlink target as text.
- Files ending in `.tmpl` are Go templates rendered by chezmoi.
- Files beginning with `modify_` transform an existing target and should preserve unrelated live settings.

Use `.chezmoitemplates/` for content shared by multiple rendered files. Keep repository-only files in `.chezmoiignore` so they are not rendered into the home directory.

## Make changes safely

1. Inspect both the source file and relevant live target before changing a managed configuration.
2. Edit the source state in this repository.
3. Use `chezmoi diff` to inspect the proposed target changes.
4. Run `chezmoi apply` only when the task includes updating live home-directory state.
5. Use `chezmoi status` after applying when verification is useful.

Avoid broad `chezmoi re-add` operations in automated work. If live state must be imported, re-add only the named target so generated files, machine-local state, and credentials are not copied accidentally.

## Protect local and secret state

Do not store credentials, tokens, authentication files, session data, machine-generated caches, or other secrets in this repository. The user's shell secrets belong in `~/.secrets`, which is intentionally unmanaged.

Preserve conditional behavior in `.chezmoiignore`, especially the operating-system-specific exclusions. Do not turn mutable application state into ordinary managed files when a `modify_` template or narrower source file can preserve unrelated settings.

## Agent configuration

The shared response voice lives in `.chezmoitemplates/ai/VOICE.md` and is included by the Claude, Codex, and Pi instruction templates. Change the shared template when guidance should apply to all three harnesses.

Shared personal Agent Skills belong in:

```text
dot_agents/skills/<skill-name>/SKILL.md
```

They deploy to `~/.agents/skills/`. Codex and Pi discover that directory natively; `~/.claude/skills` is a managed symlink to it. Keep shared skills in the portable Agent Skills directory format, put each skill directly below `dot_agents/skills/`, match the frontmatter `name` to the directory name, and use only portable fields unless host-specific behavior is intentional.

Pi-specific personal skills belong in:

```text
dot_pi/agent/skills/<skill-name>/SKILL.md
```

They deploy to `~/.pi/agent/skills/`. Project-local Pi skills may instead live in a project's `.pi/skills/` directory.

Do not replace `~/.codex/skills`; Codex uses it for bundled system skills. Do not commit the runtime contents of `~/.agents/skills/synced/` unless the user explicitly asks to manage those synchronized skills with chezmoi.
