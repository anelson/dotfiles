# Running scripts with uv

## Project and non-project execution

Run a script in the current project environment:

```bash
uv run script.py
uv run script.py arg1 arg2
uv run --python 3.13 script.py
```

Use `--no-project` when a repository's package and dependency groups are irrelevant:

```bash
uv run --no-project script.py
printf 'print("hello")\n' | uv run --no-project -
```

Do not add `--no-project` when the script imports the current package or needs project dependencies.

## Ephemeral dependencies

Use `--with` for disposable commands that should not modify project metadata:

```bash
uv run --with requests script.py
uv run --with 'requests>=2,<3' --with rich script.py
```

If the script will be kept, prefer inline metadata so future runs are self-describing.

## Inline script metadata

```python
# /// script
# requires-python = ">=3.14"
# dependencies = [
#   "requests<3",
#   "rich",
# ]
# ///

import requests
from rich import print
```

Create and update metadata with uv:

```bash
uv init --script example.py
uv add --script example.py requests rich
uv add --script example.py --index https://example.com/simple requests
```

Do not add a private package index URL containing embedded credentials. Use uv's supported credential configuration outside the repository.

## Locking and reproducibility

```bash
uv lock --script example.py
uv run --locked example.py
```

A script lockfile is named after the script, such as `example.py.lock`. Use `--locked` when the run must fail rather than update a stale lock.

To exclude releases newer than a fixed instant:

```python
# /// script
# dependencies = ["requests"]
# [tool.uv]
# exclude-newer = "2025-01-01T00:00:00Z"
# ///
```

## Executable scripts

```python
#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["httpx"]
# ///

import httpx
print(httpx.get("https://example.com"))
```

Then mark the file executable and invoke it directly. Keep the shebang first and the metadata block near the top.

## Safe verification

Avoid `py_compile` when a clean worktree matters because it writes `__pycache__`. Parse through the AST instead:

```bash
uv run python -m ast path/to/file.py >/dev/null
```
