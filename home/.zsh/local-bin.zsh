# IMPORTANT: This should be the LAST THING that is sourced from .zshrc.
#
# Ensure ~/.local/bin has highest priority in PATH
# This moves ~/.local/bin to the front, even if it was added earlier in .profile
# but got pushed back by package managers (npm, pnpm, etc.) that prepend to PATH.
# We want the priority order: ~/.local/bin > other user-specific stuff > (user) package managers > system paths
#
# This is important because we sometimes put scripts in ~/.local/bin that wrap executables that are elsewhere in the
# path, and we must guarantee that nothing else in the path will supercede them.

if [ -d "$HOME/.local/bin" ]; then
    # Remove any existing ~/.local/bin from PATH to avoid duplicates
    PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "^$HOME/.local/bin$" | tr '\n' ':' | sed 's/:$//')
    # Add it back at the front
    export PATH="$HOME/.local/bin:$PATH"
fi

