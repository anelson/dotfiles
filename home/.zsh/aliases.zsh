# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias vi=nvim
alias vim=nvim
alias gvim=gnvim
alias fzf=fzf-tmux
alias hs=homeshick
alias hcd=homeshick cd
alias hp=homeshick pull
alias hlink=homeshick link
alias htrack=homeshick track

# Ugly hack:
# If this is a TMUX session over SSH, alias ssh so it also pulls in
# the updated SSH_AUTH_SOCK
if [ -n "$TMUX" ] && [ -n "$SSH_TTY" ] && [ -x "$HOME/.local/bin/tmux-ssh" ]; then
  alias ssh=$HOME/.local/bin/tmux-ssh
fi

# Sometimes I trust a host enough to pass through agent auth
alias ssha=ssh -A
