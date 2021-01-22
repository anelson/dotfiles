# use the user-local rust install if present
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# configure plugins
source $HOME/.zsh/antigen.zsh
source $HOME/.zsh/zsh-notify.zsh
source $HOME/.zsh/fzf.zsh

# configure my zsh environment
source $HOME/.zsh/history.zsh
source $HOME/.zsh/environment.zsh
source $HOME/.zsh/homeshick.zsh
source $HOME/.zsh/aliases.zsh
source $HOME/.zsh/npm.zsh

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
