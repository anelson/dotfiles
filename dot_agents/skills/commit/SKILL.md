---
name: commit
description: Create a Git commit after the user explicitly asks for one. Use this skill before reviewing, staging, or committing changes; it applies the user's repository-aware commit format and staging safeguards.
compatibility: Requires Git.
---

# Create a commit

Commit only when the user explicitly asks. A request to change files does not imply permission to commit, and a request to commit does not imply permission to push.

Follow the `git` skill for the user's broader rules about staging, authentication, remotes, and pushes.

## Choose the message

Prefer the repository's established message style. Inspect recent subjects when the convention is not already clear:

```bash
git log -n 50 --pretty=format:%s
```

For the user's dotfiles and other repositories that use the same convention, default to:

```text
[scope] Imperative summary
```

Choose a short noun for `scope`, such as `pi`, `agents`, `tmux`, or `nvim`. Use sentence case, no trailing period, and keep the subject concise. Do not force Conventional Commits syntax into a repository that does not use it.

Add a body only when it explains motivation, non-obvious constraints, or consequences that the subject cannot carry. Do not add generated attribution, assistant credit, or sign-off trailers.

## Review and stage

1. Run `git status --short`.
2. Review `git diff` and any relevant untracked files. If some work is already staged, review `git diff --cached` separately.
3. Separate the requested work from unrelated changes. Never assume that every modified or untracked file belongs in the commit.
4. Ask before staging ambiguous files.
5. Run focused checks appropriate to the changed files when practical.
6. Stage only the intended paths. Avoid broad `git add -A` when the worktree contains unrelated changes.
7. Review `git diff --cached --stat` and `git diff --cached` before committing.
8. Create the commit, then report its short hash and subject.

Use additional arguments from the caller as commit guidance. File paths or globs limit the commit unless the user says otherwise; free-form text guides the scope, subject, and body.

Do not push after committing unless the user separately and explicitly requests a push.
