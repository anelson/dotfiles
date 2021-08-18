# Source default FZF aliases
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
  . /usr/share/fzf/key-bindings.zsh
elif [ -f /usr/share/fzf/shell/key-bindings.zsh ]; then
  . /usr/share/fzf/shell/key-bindings.zsh
elif [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]; then
  . /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi

if [ -f /usr/share/fzf/completion.zsh ]; then
  . /usr/share/fzf/completion.zsh
elif [ -f /usr/share/fzf/shell/completion.zsh ]; then
  . /usr/share/fzf/shell/completion.zsh
elif [ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]; then
  . /opt/homebrew/opt/fzf/shell/completion.zsh
fi

# Better FZF
# use 'fd' to find files and directories since it's much faster and respects both .gitignore and .ignore
export FZF_TMUX=1  # use tmux by default
export FZF_TMUX_OPTS="-p"  # tmux popup!?  LOLWUT?
export FZF_DEFAULT_OPTS="--history=$HOME/.fzf_history --ansi"

# When using tmux popup windows, the PATH isn't set by our zsh init scripts so only $HOME/.local/bin is in the PATH.
# Rather than figure out why that is, just use the full path to the tools we use
fd=$(which fd)
export FZF_DEFAULT_COMMAND="$fd --type file --color=always --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$fd --type directory --color=always --hidden --follow --exclude .git"

