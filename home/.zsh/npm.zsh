# Set up some env vars to support NPM packages installed at the user level
NPM_PACKAGES=${HOME}/.npm-packages

[ -d $NPM_PACKAGES ] || mkdir -p $NPM_PACKAGES

export PATH="$NPM_PACKAGES/bin:$PATH"
export MANPATH="$NPM_PACKAGES/share/man:$MANPATH"

export PNPM_HOME="$HOME/.local/share/pnpm"
mkdir -p "$PNPM_HOME"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


