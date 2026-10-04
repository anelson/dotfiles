---
name: uv
description: Use uv for Python interpreters, project environments, dependencies, scripts, locking, and pure-Python builds. Trigger for Python setup or execution and whenever a task might otherwise use pip, python, virtualenv, Poetry, or ad-hoc dependency installation.
compatibility: Requires uv; commands target the installed uv 0.12 series or later.
---

# Use uv for Python work

Prefer uv over direct `pip`, `python`, `python3`, `venv`, or Poetry commands. Preserve a repository's existing Python version constraints, dependency groups, indexes, lockfiles, and build backend. Do not migrate a project to uv or rewrite its packaging metadata unless the user asks.

## Choose the right form

```bash
uv run script.py                         # Run a script in the project environment
uv run --no-project script.py            # Run without installing the current project
uv run --with requests script.py         # Add an ephemeral dependency
uv run python -m module                   # Run a module in the project environment
uv add requests                           # Add a runtime dependency
uv add --dev pytest                       # Add a development dependency
uv sync                                   # Reconcile the environment with the lockfile
uv lock --check                           # Verify that the lockfile is current
```

Use the project's established test and task commands through `uv run`, for example `uv run pytest`. Do not use `uv pip install` as a routine substitute for `uv add`; `uv pip` is for compatibility or explicitly unmanaged environments.

To check syntax without writing bytecode caches:

```bash
uv run python -m ast path/to/file.py >/dev/null
```

## Standalone scripts

For a temporary one-off command, use `uv run --with PACKAGE`. For a script worth keeping, declare its interpreter and dependencies with inline metadata:

```python
# /// script
# requires-python = ">=3.14"
# dependencies = [
#   "httpx<1",
# ]
# ///
```

Create and maintain this metadata with uv rather than editing dependency lists by hand when possible:

```bash
uv init --script example.py
uv add --script example.py httpx
uv lock --script example.py
uv run example.py
```

When a project or script already declares `requires-python`, honor it. For new work, let the installed uv choose from the available interpreters unless the task requires a specific version. See [scripts.md](scripts.md) for execution, locking, shebangs, and reproducibility.

## Projects and builds

Use `uv init`, `uv add`, `uv remove`, `uv sync`, and `uv lock` for project metadata and environments. Before changing dependencies, inspect `pyproject.toml`, `uv.lock`, workspace configuration, and repository instructions.

For a new pure-Python library, let this machine's uv generate a compatible `uv_build` constraint:

```bash
uv init --lib --build-backend uv package-name
```

Use another backend when the project already chose one or when native extension modules require it. See [build.md](build.md).
