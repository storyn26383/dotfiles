SANDBOX_DIR=~/Coding/Sandbox

_sandbox_shell () {
  cd $SANDBOX_DIR && make shell
}

_sandbox_usage () {
  echo 'Usage: sandbox [command...]'
  echo 'Supported commands: cd, workspace, shell'
}

sandbox () {
  if [ $# -ne 0 ]; then
    while [ $# != 0 ]; do
      case $1 in
        cd)
          cd $SANDBOX_DIR
          ;;

        workspace)
          cd $SANDBOX_DIR/workspace
          ;;

        shell)
          _sandbox_shell
          ;;

        help|-h|-help|--help)
          _sandbox_usage
          return
          ;;

        *)
          echo 'Unknown command:' $1
          _sandbox_usage
          return
          ;;
      esac

      shift
    done
  else
    _sandbox_shell
  fi
}

_sandbox_completion () {
  _shared_generate_completion 'cd workspace shell'
}

complete -F _sandbox_completion sandbox
