# load the antigen plugin manager
if [[ -a $HOME/.zsh/antigen-git.zsh ]] then
  source $HOME/.zsh/antigen-git.zsh
else
  echo "antigen is missing; downloading it"
  curl -L git.io/antigen > $HOME/.zsh/antigen-git.zsh
  source $HOME/.zsh/antigen-git.zsh
fi


# I stopped using prezto, antigen provides all the functionality i need
#antigen use prezto
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
  robbyrussell/oh-my-zsh plugins/sbt
  robbyrussell/oh-my-zsh plugins/scala
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

# this uses the agnoster oh-my-zsh theme
# antigen theme agnoster
# Use the official agnoster repo instead of the one in oh-my-zsh
antigen theme agnoster/agnoster-zsh-theme agnoster

antigen apply
