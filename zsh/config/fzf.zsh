[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="rg --hidden --no-ignore-vcs --glob '!.git/*' --files"
export FZF_DEFAULT_OPTS='--preview-window hidden,right,50%,border-left,\<70\(hidden,up,50%,border-down\) --bind ctrl-/:toggle-preview'
