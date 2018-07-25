# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="ys"
# ZSH_THEME="bullet-train"

# [ -r ~/.themerc ] && . ~/.themerc

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git base16-shell)

# User configuration
export PATH="vendor/bin:$HOME/.composer/vendor/bin"
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="$PATH:/usr/local/bin:/usr/local/opt/coreutils/libexec/gnubin"
export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"

# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_COLLATE=C
export LC_CTYPE=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

export EDITOR=vim

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# ssh hostname completion
[ -r ~/.ssh/config ] && hosts=($(cat ~/.ssh/config | sed -ne 's/Host[=\t ]//p')) || hosts=()
zstyle ':completion:*:hosts' hosts $hosts
zstyle ':completion:*' users off
compdef mosh=ssh
compdef scp=ssh

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

# load scripts completion
_load-completion () { compadd -- nvm rvm }
compdef _load-completion load

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ag="ag --ignore '*.lock'"
alias ls="ls --color"
alias y="ydict.js"
alias v="vagrant"
alias a="php artisan"
alias s="php artisan serve --host=0.0.0.0"
alias gta="git tag -a"
alias gtl="git tag -l"
alias gtd="git tag -d"
alias fm="find ./ -type f -print0 | xargs -0 chmod 644
find ./ -type d -print0 | xargs -0 chmod 755"
