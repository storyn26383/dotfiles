[ -x "$(command -v navi)" ] && eval "$(navi widget zsh)"
export NAVI_FZF_OVERRIDES="--height ${FZF_TMUX_HEIGHT:-40%}"
