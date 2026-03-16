# if we're not running in a tmux session, start one
if [[ -z "$TMUX" ]]; then
  exec tmux new
fi


