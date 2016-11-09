export ZSH=$HOME/.oh-my-zsh
export DOTFILES=$HOME/dotfiles

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git base16-shell vi-mode)

# User configuration
export PATH="$HOME/.composer/vendor/bin"
export PATH="$PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin"
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Load on my zsh
source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_COLLATE=C
export LC_CTYPE=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR=vim

# history file
export HISTSIZE=2000
export SAVEHIST=2000

# ssh hostname completion
[ -r ~/.ssh/config ] && hosts=($(cat ~/.ssh/config | sed -ne 's/Host[=\t ]//p')) || hosts=()
zstyle ':completion:*:hosts' hosts $hosts
zstyle ':completion:*' users off
compdef csshX=ssh
compdef mosh=ssh
compdef scp=ssh

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="ag --hidden --skip-vcs-ignores --ignore=.git -g ''"

# Powerline
source /usr/local/lib/python2.7/dist-packages/powerline/bindings/zsh/powerline.zsh

# nvm & rvm & php
source $DOTFILES/scripts/load

# aliases
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
