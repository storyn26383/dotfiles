_server_cube () {
  mosh cube -- tmux new -ADs cube
}

_server_mini () {
  mosh cube -- ssh mini -t 'tmux new -ADs Sasaya'
}

server () {
  case $1 in
    cube)
      _server_cube
      ;;

    mini)
      _server_mini
      ;;

    *)
      echo 'Unknown server:' $1
      ;;
  esac
}

_servers_completion () {
  _shared_generate_completion 'cube mini'
}

complete -F _servers_completion server
