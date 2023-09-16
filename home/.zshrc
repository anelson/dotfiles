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

# If starship is available, use that instead of the configured zsh theme for the prompt
#
# If it's not present or an old version, do `cargo install --force starship`
if [[ -x "$HOME/.cargo/bin/starship" ]]; then
    # Bullshit hoop-jumping to get the default zsh prompt turned off so that starship can be activated
    #
    # This is discussed in https://github.com/starship/starship/issues/2525 and a potential fix in
    # https://github.com/starship/starship/issues/1994
    autoload -U promptinit && promptinit
    prompt off
    eval $(starship init zsh)
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
