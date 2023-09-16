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
alias "hcd=hs cd"
alias "hp=hs pull"
alias "hlink=hp link"
alias "htrack=hp track"

# Ugly hack:
# If this is a TMUX session over SSH, alias ssh so it also pulls in
# the updated SSH_AUTH_SOCK
if [ -n "$TMUX" ] && [ -n "$SSH_TTY" ] && [ -x "$HOME/.local/bin/tmux-ssh" ]; then
  alias ssh="$HOME/.local/bin/tmux-ssh"
  alias git="GIT_SSH_COMMAND=$HOME/.local/bin/tmux-ssh git"
fi

# Sometimes I trust a host enough to pass through agent auth
alias ssha=ssh -A

# If eza is present use it instead of ls
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons"
  alias ll="eza -l --icons"
  alias lll="eza -l --icons | less"
  alias lla="eza -la --icons"
  alias llt="eza -T --icons"
  alias llfu="eza -bghHliS --git --icons"
else
  alias ls="ls --color=auto"
  alias ll="ls -l --color=auto"
  alias lll="ls -l --color=auto | less"
  alias lla="ls -la --color=auto"
  alias llfu=lla
fi

alias la=lla
alias llt1="llt -L 1"
alias llt2="llt -L 2"
alias llt3="llt -L 3"
