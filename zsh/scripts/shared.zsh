_shared_generate_completion() {
  COMPREPLY=($(compgen -W "$1" -- "${COMP_WORDS[COMP_CWORD]}"))
}
