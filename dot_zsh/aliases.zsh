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
  # Set up eza completions if not already present
  _setup_eza_completions() {
    # echo "DEBUG: setting up eza completions"
    local zsh_comp_dir="$HOME/.local/share/zsh/site-functions"
    local bash_comp_dir="$HOME/.local/share/bash-completion/completions"
    local zsh_comp_file="$zsh_comp_dir/_eza"
    local bash_comp_file="$bash_comp_dir/eza"
    local eza_version=$(eza --version 2>/dev/null | sed -n '2p' | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | tr -d 'v')

    # Set up zsh completions.  Sadly this means downloading a separate completions file from the release
    # echo "DEBUG: checking existence of eza zsh completion file $zsh_comp_file for eza version $eza_version"
    if [[ ! -f "$zsh_comp_file" ]] && [[ -n "$eza_version" ]]; then
      echo "DEBUG: eza zsh completion file $zsh_comp_file does not exist, setting up completions for eza version $eza_version"
      if command -v curl >/dev/null 2>&1; then
        mkdir -p "$zsh_comp_dir"
        local temp_dir=$(mktemp -d)
        local completion_url="https://github.com/eza-community/eza/releases/download/v${eza_version}/completions-${eza_version}.tar.gz"

        if curl -sL "$completion_url" | tar -xz -C "$temp_dir" 2>/dev/null; then
          ls -al "$temp_dir"
          if [[ -f "$temp_dir/target/completions-${eza_version}/_eza" ]]; then
            cp "$temp_dir/target/completions-${eza_version}/_eza" "$zsh_comp_file"
            # Add to fpath if not already there
            if [[ -z "${fpath[(r)$zsh_comp_dir]}" ]]; then
              fpath=("$zsh_comp_dir" $fpath)
            fi
          fi
          # Also copy bash completion if available
          if [[ -f "$temp_dir/target/completions-${eza_version}/eza" ]]; then
            mkdir -p "$bash_comp_dir"
            cp "$temp_dir/target/completions-${eza_version}/eza" "$bash_comp_file"
          fi
        fi
      fi
      rm -rf "$temp_dir"
    fi

    # cat "$zsh_comp_file"
  }

  # Run the setup function
  _setup_eza_completions
  unfunction _setup_eza_completions

  # Instead of aliases, define functions that look and feel like `ls` commands that use eza under the covers
  # oh-mh-zsh defines aliases and I don't see a way to tell it not so, so just delete those aliases
  unalias ls ll

  function ls { eza "$@"; }
  function ll { eza -l "$@"; }
  function lll { eza -l "$@" | less; }
  function lla { eza -la "$@"; }
  function llt { eza -T "$@"; }
  function llfu { eza -bghHliS --git "$@"; }

  # make sure the eza completions are loaded
  autoload -Uz _eza

  # treat auto-completion for these functions as if they were the `eza` comand (which they basically are)
  compdef _eza ls ll lll lla llt llfu
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
