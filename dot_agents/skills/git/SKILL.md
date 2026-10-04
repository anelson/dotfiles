---
name: git
description: Apply the user's personal Git workflow preferences when a task involves commits, staging, branches, rebases, merges, tags, remotes, pushes, worktrees, or pull requests. Use this skill before making decisions that change Git state for the user, or invoking the `git` CLI.
---

# When to `commit`

NEVER commit ANY changes without explicit instructions to do so.

When you have been instructed to commit, refer to the /commit skill for additional guidance on commit message structure
and contents, although any specific commit message guidance that accompanied the command to commit always take
precedence.

Unless otherwise instructed, the scope of the work to commit is whatever work you have done. It will very often be the
case that unrelated files are untracked, or have unstaged changes. Do not just assume that these should be committed as
well.

# When to `push`

NEVER push without explicit instructions to do so. An explicit instruction to commit DOES NOT imply `push`. I ALMOST
NEVER want you to push changes yourself.

If `push` has been explicitly requested, that does not imply force push. Never force push ever; that must be done by a
human.

# SSH auth

Unless otherwise instructed, Git operations that require authentication to an `ssh` remote (including but not limited to `push`
and `pull`) should be assumed to be using SSH agent auth. See the /ssh skill for guidance on how SSH auth works on my
systems.
