_multipass_commands_completion () {
  _shared_generate_completion "alias aliases delete exec find get help info launch list mount networks purge recover restart set shell start stop suspend transfer umount unalias version"
}

_multipass_instances_completion () {
  _shared_generate_completion "$(multipass list | grep -v IPv4 | awk '{ print $1 }')"
}

_multipass_completion () {
  if [ ${#COMP_WORDS[@]} -gt 1 ]; then
    case "${COMP_WORDS[1]}" in
      delete|exec|info|restart|shell|start|stop|suspend) _multipass_instances_completion;;
      *) _multipass_commands_completion;;
    esac
  else
    _multipass_commands_completion
  fi
}

complete -F _multipass_completion multipass
