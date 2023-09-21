_load_nvm () {
  echo 'Loading nvm...'
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

_load_rvm () {
  echo 'Loading rvm...'
  export RVM_DIR="$HOME/.rvm"
  export PATH="$PATH:$RVM_DIR/bin"
  [ -s "$RVM_DIR/scripts/rvm" ] && \. "$RVM_DIR/scripts/rvm"
}

_load_php () {
  echo 'Loading phpbrew...'
  export PHPBREW_DIR="$HOME/.phpbrew"
  [ -s "$PHPBREW_DIR/bashrc" ] && \. "$PHPBREW_DIR/bashrc"
}

_load_cargo () {
  echo 'Loading cargo...'
  export CARGO_DIR="$HOME/.cargo"
  [ -s "$CARGO_DIR/env" ] && \. "$CARGO_DIR/env"
}

_load_usage () {
  echo 'Usage: load [SCRIPT...]'
  echo 'Supported scripts: nvm, rvm, php'
}

load () {
  if [ $# -ne 0 ]; then
    while [ $# != 0 ]; do
      case $1 in
        nvm)
          _load_nvm
          ;;

        rvm)
          _load_rvm
          ;;

        php)
          _load_php
          ;;

        cargo)
          _load_cargo
          ;;

        help|-h|-help|--help)
          _load_usage
          return
          ;;

        *)
          echo 'Unknow script:' $1
          _load_usage
          return
          ;;
      esac

      shift
    done
  else
    _load_nvm
    _load_php
  fi

  echo 'Done!'
}

_load_completion () {
  _shared_generate_completion "nvm rvm php cargo"
}

complete -F _load_completion load
