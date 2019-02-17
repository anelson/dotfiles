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

# If exa is present use it instead of ls
# There are two possible exa variants:
# The standard exa from https://github.com/ogham/exa, and the modified one from the
# pull request at https://github.com/ogham/exa/pull/368.  Hopefully someday that PR is merged
# and this distinction isn't needed.
#
# Until that day we deal with this.  The PR adds an `--icons` option which inserts devicons in the
# output.  I like that and want to use it if it's present
if command -v exa >/dev/null 2>&1; then
  # exa is present.  good, that's a start.
  if exa --icons >/dev/null 2>&1; then
    icons="--icons"
  else
    icons=""
  fi

  alias ls="exa $icons"
  alias ll="exa -l $icons"
  alias lll="exa -l $icons | less"
  alias lla="exa -la $icons"
  alias llt="exa -T $icons"
  alias llfu="exa -bghHliS --git $icons"
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
