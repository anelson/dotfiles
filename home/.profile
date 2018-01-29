# Add my personal bin directory to the path
PATH=$PATH:$HOME/apps/bin
PATH=$PATH:$HOME/.local/bin

# This causes an error if the system ruby doesn't have gems
# and also doesn't play well with RVM
# If you want to install gems for access as a user use RVM
#PATH=$PATH:$(ruby -rubygems -e "puts Gem.user_dir")/bin


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
