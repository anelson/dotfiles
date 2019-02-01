# This causes an error if the system ruby doesn't have gems
# and also doesn't play well with RVM
# If you want to install gems for access as a user use RVM
#PATH=$PATH:$(ruby -rubygems -e "puts Gem.user_dir")/bin

export EDITOR=nvim
export VISUAL=nvim
export DIFFPROG='nvim -d'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Put my own binaries on the path.  Note this specifically must be done BEFORE lookign for alacritty
# since I like to install it in the user-specific binary path
export PATH="$HOME/.local/bin:$PATH"

# Set a TERMINAL variable so i3 will use alacritty if alacritty is installed
command -v alacritty >/dev/null 2>&1 && export TERMINAL=`command -v alacritty`

# make GNOME keyring available to CLI apps as well.  Note that GNOME Keyring also has a feature whereby it acts a
# replacement for ssh-agent.  That I am _NOT_ interested in.  This article goes into detail about how to disable
# this behavior: https://wiki.archlinux.org/index.php/GNOME/Keyring#Disable_keyring_daemon_components
#
# I don't _think_ I need to do that since after this I'm starting the gpg-agent which will use its own socket for the ssh-agent
# protocol.
if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start --components=secrets)
    # NB: I specifically do NOT want to export SSH_AUTH_SOCK because I'm not interested in using GNOME Keyring as my SSH agent
    #export SSH_AUTH_SOCK
fi

# Terminate any gpg agent that might have been run by the system, then start it and ensure it's SSH agent socket is the one
# ssh clients will be using
gpgconf --kill gpg-agent >/dev/null 2>&1
gpg-connect-agent /bye >/dev/null 2>&1

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  # This is how we force ssh clients to use the GPG agent to get ssh keys from the Yubikey
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

# If this session is running over SSH but is not part of a tmux session, try to make it one
# Note this should only detect when the SSH session has a tty, so things like ansible should
# still work
if type "tmux" >/dev/null 2>&1 && [ -n "$SSH_TTY" ] && [ -z "$TMUX" ]; then
  echo Automatically switching to TMUX session
  tmux attach -t login-shell || tmuxp load login-shell --yes || tmux new-session -t login-shell

  # exit this shell when tmux exits
  exit
fi;

