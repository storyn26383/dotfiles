_forge_commands_completion () {
  _shared_generate_completion "$(forge list -n --raw | awk '{ print $1 }')"
}

_forge_servers_completion () {
  _shared_generate_completion "$(forge server:list -n | grep -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{ print $2 }')"
}

_forge_sites_completion () {
  _shared_generate_completion "$(forge site:list -n | grep -E '[0-9]+\.[0-9]+' | awk '{ print $2 }')"
}

_forge_completion () {
  if [ ${#COMP_WORDS[@]} -gt 1 ]; then
    case "${COMP_WORDS[1]}" in
      ssh|command|server:switch) _forge_servers_completion;;
      deploy|tinker) _forge_sites_completion;;
      *) _forge_commands_completion;;
    esac
  else
    _forge_commands_completion
  fi
}

complete -F _forge_completion forge
