# Add my personal bin directory to the path
PATH=$PATH:$HOME/apps/bin
PATH=$PATH:$HOME/.local/bin
PATH=$PATH:$(ruby -rubygems -e "puts Gem.user_dir")/bin

