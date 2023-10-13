[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="ag --hidden --skip-vcs-ignores --ignore=.git -g ''"
export FZF_DEFAULT_OPTS='--preview-window hidden,right,50%,border-left,\<70\(hidden,up,50%,border-down\) --bind ctrl-/:toggle-preview'
