_server_cube () {
  mosh cube -- tmux new -ADs cube
}

_server_mini () {
  mosh pi -- ssh mini -t "source ~/.zshrc && tmux new -ADs Sasaya"
}

_server_shared () {
  mosh cube -- ssh mini -t "source ~/.zshrc && tmux new -t Sasaya -s Shared"
}

server () {
  case $1 in
    cube)
      _server_cube
      ;;

    mini)
      _server_mini
      ;;

    shared)
      _server_shared
      ;;

    *)
      echo 'Unknown server:' $1
      ;;
  esac
}

_servers_completion () {
  _shared_generate_completion 'cube mini shared'
}

complete -F _servers_completion server
