export POWERLINE_PATH=/opt/homebrew/lib/python3.13/site-packages/powerline
export POWERLINE_CONFIG_PATHS=$POWERLINE_PATH/config_files

_powerline_command=$POWERLINE_COMMAND
eval "$(oh-my-posh init zsh --config $HOME/.oh-my-posh/themes/zsh.omp.json)"
export POWERLINE_COMMAND=$_powerline_command

# hook
function set_poshcontext() {
  export POSH_JOBNUM=${(%):-%j}
  export POSH_VI_KEYMAP=${VI_KEYMAP}
}

# hook
function after_keymap_changed() {
  _omp_precmd
  zle reset-prompt
}
