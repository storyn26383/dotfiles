if [ -x "$(command -v op)" ]; then
  eval "$(op completion zsh)"; compdef _op op
fi
