# Set up some env vars to support NPM packages installed at the user level
NPM_PACKAGES=${HOME}/.npm-packages

[ -d $NPM_PACKAGES ] || mkdir -p $NPM_PACKAGES

export PATH="$NPM_PACKAGES/bin:$PATH"
export MANPATH="$NPM_PACKAGES/share/man:$MANPATH"


