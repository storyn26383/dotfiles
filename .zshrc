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
export PATH="$PATH:$HOME/.bun/bin"
export PATH="$PATH:$HOME/.cargo/bin"
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
export EDITOR=nvim

# history file
export HISTSIZE=2000
export SAVEHIST=2000

# env
[ -f ~/.env ] && source ~/.env

# config
source $DOTFILES/zsh/config/key-bindings.zsh
source $DOTFILES/zsh/config/aliases.zsh
source $DOTFILES/zsh/config/powerline.zsh
source $DOTFILES/zsh/config/scripts.zsh
source $DOTFILES/zsh/config/ssh.zsh
source $DOTFILES/zsh/config/fzf.zsh
source $DOTFILES/zsh/config/navi.zsh
source $DOTFILES/zsh/config/bun.zsh
source $DOTFILES/zsh/config/rustup.zsh
source $DOTFILES/zsh/config/one-password.zsh
source $DOTFILES/zsh/config/gcloud.zsh
