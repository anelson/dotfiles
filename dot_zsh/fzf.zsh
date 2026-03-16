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


# Solarized colors
fzf_solarized_dark='
  --color=bg+:#073642,bg:#002b36,spinner:#719e07,hl:#586e75
  --color=fg:#839496,header:#586e75,info:#cb4b16,pointer:#719e07
  --color=marker:#719e07,fg+:#839496,prompt:#719e07,hl+:#719e07
'

export FZF_TMUX=1  # use tmux by default
export FZF_TMUX_OPTS="-p 60%,80%"  # tmux popup!?  LOLWUT?  Params are width and height of popup
export FZF_DEFAULT_OPTS="--history=$HOME/.fzf_history --ansi ${fzf_solarized_dark}"

# Better FZF
# use 'fd' to find files and directories since it's much faster and respects both .gitignore and .ignore
# When using tmux popup windows, the PATH isn't set by our zsh init scripts so only $HOME/.local/bin is in the PATH.
# Rather than figure out why that is, just use the full path to the tools we use
fd=$(which fd)
export FZF_DEFAULT_COMMAND="$fd --type file --color=always --follow --ignore"

# Ctrl-T invokes fzf to auto-complete files specifically.  Directories are not in the list
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Use the bind feature of FZF so that after pressing Ctrl-T, I can use Ctrl-D to switch to directories and Ctrl-F to switch back to files
export FZF_CTRL_T_OPTS="
  --bind \"ctrl-a:change-prompt(Everything (Ctrl-f for files, Ctrl-d for dirs)> )+reload($fd --hidden --follow --no-ignore --color=always)\"
  --bind \"ctrl-d:change-prompt(Directories (Ctrl-f for files, Ctrl-a for everything)> )+reload($fd --type d --color=always --hidden --follow --ignore)\"
  --bind \"ctrl-f:change-prompt(Files (Ctrl-d for dirs, Ctrl-a for everything)> )+reload($FZF_DEFAULT_COMMAND)\"
  --prompt \"Files (Ctrl-d for dirs, Ctrl-a for everything)> \""

export FZF_ALT_C_COMMAND="$fd --type directory --color=always --hidden --follow --no-ignore"

# By default can use Ctrl-/ and Alt-/ to toggle wrapping but I want that on all the time
export FZF_CTRL_R_OPTS="--wrap"
