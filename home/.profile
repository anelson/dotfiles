# This causes an error if the system ruby doesn't have gems
# and also doesn't play well with RVM
# If you want to install gems for access as a user use RVM
#PATH=$PATH:$(ruby -rubygems -e "puts Gem.user_dir")/bin

export EDITOR=nvim
export VISUAL=nvim
export DIFFPROG='nvim -d'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Detect if this is a local or remote session so we can base other conditional logic
# on these results
export IS_SSH_SESSION=0
export IS_TMUX_SESSION=0
export IS_LOCAL_SESSION=0
export IS_MACOS=0

if [ -n "$DESKTOP_SESSION" ]; then
  # We're running under some kind of desktop environment
  export IS_LOCAL_SESSION=1
fi

if [ -n "$TMUX" ]; then
  # We're running under tmux; maybe local or maybe remote
  export IS_TMUX_SESSION=1
fi

if [ -n "$SSH_TTY" ]; then
  # There is an SSH TTY so this must be an SSH session
  export IS_SSH_SESSION=1
fi

case "$OSTYPE" in
  "darwin"*) export IS_MACOS=1
esac

#echo "IsLocal: ${IS_LOCAL_SESSION}"
#echo "IsTmux: ${IS_TMUX_SESSION}"
#echo "IsSSH: ${IS_SSH_SESSION}"
#echo "IsMacOs: ${IS_MACOS}"

# If this is a mac, homebrew needs to be in the path.
#
# note that there are two homebrew directories, /opt/homebrew for Apple Silicon and /usr/local for Intel macs
#
# Apple Silicon macs support both, but obviously all things being equal we want the Apple Silicon version to take priority
if [ "$IS_MACOS" -eq 1 ]; then
  if [ -x /opt/homebrew/bin/brew ]; then
    eval $(/opt/homebrew/bin/brew shellenv)
  elif [ -x /usr/local/bin/brew ]; then
    eval $(/usr/local/bin/brew shellenv)
  fi
fi

# Put my own binaries on the path.  Note this specifically must be done BEFORE lookign for alacritty
# since I like to install it in the user-specific binary path
export PATH="$HOME/.local/bin:$PATH"

# Make sure the directory where pip3 installs --user binaries is also in the path
#
# On my Linux systems this is `$HOME/.local/bin` but on macOS and maybe other Linux distros this
# is something else.
pip_user_bin="$(python3 -m site --user-base)/bin"

if [ "$pip_user_bin" != "$HOME/.local/bin" ]; then
  export PATH="$pip_user_bin:$PATH"
fi


# Set a TERMINAL variable so i3 will use alacritty if alacritty is installed
command -v alacritty >/dev/null 2>&1 && export TERMINAL=`command -v alacritty`

# make GNOME keyring available to CLI apps as well.  Note that GNOME Keyring also has a feature whereby it acts a
# replacement for ssh-agent.  That I am _NOT_ interested in.  This article goes into detail about how to disable
# this behavior: https://wiki.archlinux.org/index.php/GNOME/Keyring#Disable_keyring_daemon_components
#
# I don't _think_ I need to do that since after this I'm starting the gpg-agent which will use its own socket for the ssh-agent
# protocol.
if [ "$IS_LOCAL_SESSION" -eq 1 ];then
    eval $(gnome-keyring-daemon --start --components=secrets)
    # NB: I specifically do NOT want to export SSH_AUTH_SOCK because I'm not interested in using GNOME Keyring as my SSH agent
    #export SSH_AUTH_SOCK

    # Terminate any gpg agent that might have been run by the system, then start it and ensure it's SSH agent socket is the one
    # ssh clients will be using
    gpgconf --kill gpg-agent >/dev/null 2>&1
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

    # Ensure the gpg-agent we just started is the one used by SSH.  We do NOT want to use the gnome-keyring OR the built-in ssh-agent
    unset SSH_AGENT_PID
    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
      # This is how we force ssh clients to use the GPG agent to get ssh keys from the Yubikey
      export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    fi

fi

# If this session is running over SSH but is not part of a tmux session, try to make it one
# Note this should only detect when the SSH session has a tty, so things like ansible should
# still work
if type "tmux" >/dev/null 2>&1 && [ "$IS_SSH_SESSION" -eq 1 ] && [ "$IS_TMUX_SESSION" -eq 0 ]; then
  echo Automatically switching to TMUX session
  tmux attach -t login-shell || tmuxp load login-shell --yes || tmux new-session -t login-shell

  # exit this shell when tmux exits
  exit
fi;

. "$HOME/.cargo/env"
