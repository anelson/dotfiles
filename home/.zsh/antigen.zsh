# load the antigen plugin manager
if [[ -a $HOME/.zsh/antigen-git.zsh ]] then
  source $HOME/.zsh/antigen-git.zsh
else
  echo "antigen is missing; downloading it"
  curl -L git.io/antigen > $HOME/.zsh/antigen-git.zsh
  source $HOME/.zsh/antigen-git.zsh
fi

# Disable 'magic' functions which are breaking paste operations on Fedora 31
DISABLE_MAGIC_FUNCTIONS=true
antigen use oh-my-zsh

antigen bundles <<EOB
  robbyrussell/oh-my-zsh plugins/git
  robbyrussell/oh-my-zsh plugins/gitfast
  robbyrussell/oh-my-zsh plugins/git-extras
  robbyrussell/oh-my-zsh plugins/bundler
  robbyrussell/oh-my-zsh plugins/rake
  robbyrussell/oh-my-zsh plugins/ruby
  robbyrussell/oh-my-zsh plugins/aws
  robbyrussell/oh-my-zsh plugins/gitignore
  robbyrussell/oh-my-zsh plugins/sublime
  robbyrussell/oh-my-zsh plugins/tmux
  robbyrussell/oh-my-zsh plugins/vi-mode
  hlissner/zsh-autopair
  rupa/z
  changyuheng/fz
  changyuheng/zsh-interactive-cd
  Tarrasch/zsh-bd
  zsh-users/zsh-syntax-highlighting
EOB

# Use the official agnoster repo instead of the one in oh-my-zsh
setopt prompt_subst # try to fix the $(prompt_agnoster_main) issue; based on    https://github.com/agnoster/agnoster-zsh-theme/pull/114
antigen theme agnoster/agnoster-zsh-theme agnoster

antigen apply
