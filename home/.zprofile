# equivalent of .profile for zsh login shells
# fall back to the bash .profile in sh mode
# per https://superuser.com/questions/187639/zsh-not-hitting-profile
emulate sh
. ~/.profile
emulate zsh

