---
name: github
description: Work with GitHub through the `gh` CLI. Use for GitHub repositories, issues, pull requests, reviews, checks, Actions runs, releases, and GitHub API queries; prefer structured CLI output over browser scraping.
compatibility: Requires the GitHub CLI (`gh`); authenticated operations require an existing `gh` login.
---

# GitHub CLI

Use `gh` for GitHub-specific work. Use ordinary `git` for local repository state, and follow the `git` and `ssh` skills before changing Git state or using an SSH remote.

The user's usual host is `github.com`, with Git authentication handled by existing `gh` or SSH-agent configuration. Never print tokens, credential-file contents, or secret-valued environment variables. If authentication is uncertain, use:

```bash
gh auth status --hostname github.com
```

## Select the repository explicitly

Inside a worktree, confirm the repository when ambiguity matters:

```bash
gh repo view --json nameWithOwner,url --jq '{name: .nameWithOwner, url}'
```

Outside a worktree, or when operating on another repository, always pass `--repo owner/repo` or use the full GitHub URL. Do not rely on whichever repository `gh` happens to infer.

## Prefer structured output

Use `--json` with `--jq` for data that another command or the agent must inspect. Avoid parsing human-formatted tables when a structured field is available.

```bash
gh issue list --repo owner/repo \
  --json number,title,state,updatedAt \
  --jq '.[] | "#\(.number) [\(.state)] \(.title)"'

gh pr view 55 --repo owner/repo \
  --json number,title,state,author,headRefName,baseRefName,url
```

Use `gh api` for fields or operations not exposed by a dedicated subcommand:

```bash
gh api repos/owner/repo/pulls/55 \
  --jq '{title, state, author: .user.login, mergeable}'
```

Use pagination when an API endpoint can return more than one page:

```bash
gh api --paginate repos/owner/repo/issues --jq '.[] | .number'
```

## Pull requests and Actions

```bash
# Show a pull request and its review/check state.
gh pr view 55 --repo owner/repo \
  --json title,state,reviewDecision,statusCheckRollup,url

gh pr checks 55 --repo owner/repo

# Inspect recent workflow runs and a failing run.
gh run list --repo owner/repo --limit 10
gh run view RUN_ID --repo owner/repo
gh run view RUN_ID --repo owner/repo --log-failed
```

Do not merge, close, approve, comment, dispatch, rerun, cancel, delete, or publish unless the user's request authorizes that mutation. Show the relevant repository, issue, pull request, run, or release URL after a successful mutation.

For multiline issue or pull-request text, prefer `--body-file` over complicated shell quoting. Put temporary bodies outside the repository unless they are intended project files, and remove them after use.

## Creating Issues and Pull Requests

Never create issues or pull requests without explicit instruction.

When doing so, utilize the /ai-slop skill to properly denote AI provenance.
