# tmuxp nags if this is not enabled.  it doesn't matter anyway
# since I don't have tmux configured to allow the windows to be renamed
if [ -n "$TMUX" ]; then
  export DISABLE_AUTO_TITLE='true'
else
  export DISABLE_AUTO_TITLE='false'
fi

# Tell the zsh agnoster theme my normal usename
export DEFAULT_USER=rupert

# the gpg-agent manpage insists GPG_TTY should be set so GPG knows the current TTY.  I'm not sure that's
# required since I use the gnome3 pinentry program but better safe than sorry.
GPG_TTY=$(tty)
export GPG_TTY

# If the bcc-tools are installed in the location the Arch package puts them they won't be
# on the path by default
if [ -d /usr/share/bcc/man ]; then
  MANPATH=$MANPATH:/usr/share/bcc/man
fi

if [ -d /usr/share/bcc/tools ]; then
  PATH=$PATH:/usr/share/bcc/tools
fi
