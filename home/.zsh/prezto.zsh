# Configure prezto before it's loaded via antigen
# NOTE: I don't like how prezto works and antigen does what I need itself
# so this will be dissabled by excluding it from the .zshrc
zstyle ':prezto:*:*' color 'yes'
zstyle ':prezto:module:editor' dot-expansion 'yes'
zstyle ':prezto:load' pmodule \
  'environment' \
  'editor'      \
  'history'     \
  'directory'   \
  'completion'  \
  'prompt'      \
'archive'
