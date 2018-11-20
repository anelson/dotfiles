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

# make GNOME keyring available to CLI apps as well
if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

# use the user-local rust install if present
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
