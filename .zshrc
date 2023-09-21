export ZSH=$HOME/.oh-my-zsh
export BREW=/opt/homebrew
export DOTFILES=$HOME/dotfiles

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(base16-shell vi-mode git gh)

# User configuration
export PATH="$HOME/.composer/vendor/bin"
export PATH="$PATH:$BREW/opt/coreutils/libexec/gnubin"
export PATH="$PATH:$BREW/opt/findutils/libexec/gnubin"
export PATH="$PATH:$BREW/opt/gnu-sed/libexec/gnubin"
export PATH="$PATH:$BREW/opt/gnu-tar/libexec/gnubin"
export PATH="$PATH:$BREW/opt/curl/bin"
export PATH="$PATH:$BREW/bin:$BREW/sbin"
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

# fix key bindings
bindkey '^B' backward-char
bindkey '^F' forward-char
bindkey '^N' down-line-or-history
bindkey '^P' up-line-or-history

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="ag --hidden --skip-vcs-ignores --ignore=.git -g ''"

# navi
[ -x "$(command -v navi)" ] && eval "$(navi widget zsh)"
export NAVI_FZF_OVERRIDES="--height ${FZF_TMUX_HEIGHT:-40%}"

# Powerline
source /opt/homebrew/lib/python3.11/site-packages/powerline/bindings/zsh/powerline.zsh

# scripts
source $DOTFILES/scripts/shared
source $DOTFILES/scripts/ssh

# keys
[ -f ~/.keys ] && source ~/.keys

# aliases
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
