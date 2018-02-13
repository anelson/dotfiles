# Source default FZF aliases
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
  . /usr/share/fzf/key-bindings.zsh
fi

if [ -f /usr/share/fzf/completion.zsh ]; then
  . /usr/share/fzf/completion.zsh
fi

# Better FZF
# use 'fd' to find files and directories since it's much faster and respects both .gitignore and .ignore
export FZF_TMUX=1  # use tmux by default
export FZF_DEFAULT_OPTS="--history=$HOME/.fzf_history --ansi"
export FZF_DEFAULT_COMMAND='fd --type file --color=always --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type directory --color=always --hidden --follow --exclude .git"

