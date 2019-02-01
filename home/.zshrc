# configure my zsh environment

source $HOME/.zsh/environment.zsh
source $HOME/.zsh/aliases.zsh
source $HOME/.zsh/homeshick.zsh

# configure plugins
#source $HOME/.zsh/prezto.zsh
source $HOME/.zsh/antigen.zsh
source $HOME/.zsh/zsh-notify.zsh
source $HOME/.zsh/fzf.zsh

# use the user-local rust install if present
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
