export ZSH=$HOME/.oh-my-zsh

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git base16-shell)

# User configuration
export PATH="vendor/bin"
export PATH="$PATH:$HOME/.composer/vendor/bin"
export PATH="$PATH:/usr/local/bin:/usr/local/opt/coreutils/libexec/gnubin"
export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"

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
compdef mosh=ssh
compdef scp=ssh

# load scripts completion
_load-completion () { compadd -- nvm rvm }
compdef _load-completion load

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Powerline
source /usr/local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh

# nvm
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# rvm
# export RVM_DIR="$HOME/.rvm"
# export PATH="$PATH:$RVM_DIR/bin"
# [ -s "$NVM_DIR/scripts/rvm" ] && \. "$NVM_DIR/scripts/rvm"


# aliases
alias ag="ag --ignore '*.lock'"
alias ls="ls --color"
alias y="ydict.js"
alias v="vagrant"
alias a="php artisan"
alias s="php artisan serve --host=0.0.0.0"
alias gta="git tag -a"
alias gtl="git tag -l"
alias gtd="git tag -d"
