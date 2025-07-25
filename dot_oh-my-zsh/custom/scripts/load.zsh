_load_nvm () {
  echo 'Loading nvm...'
  source $ZSH/custom/config/nvm.zsh
}

_load_bun () {
  echo 'Loading bun...'
  source $ZSH/custom/config/bun.zsh
}

_load_op () {
  echo 'Loading 1password...'
  source $ZSH/custom/config/1password.zsh
}

_load_gcloud () {
  echo 'Loading gcloud...'
  source $ZSH/custom/config/gcloud.zsh
}

_load_navi () {
  echo 'Loading navi...'
  source $ZSH/custom/config/navi.zsh
}

_load_usage () {
  echo 'Usage: load [SCRIPT...]'
  echo 'Supported scripts: bun, op, gcloud, navi'
}

load () {
  if [ $# -ne 0 ]; then
    while [ $# != 0 ]; do
      case $1 in
        bun)
          _load_bun
          ;;

        op)
          _load_op
          ;;

        gcloud)
          _load_gcloud
          ;;

        navi)
          _load_navi
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
    _load_bun
    _load_op
    _load_gcloud
    _load_navi
  fi

  echo 'Done!'
}

_load_completion () {
  _shared_generate_completion 'bun op gcloud navi'
}

complete -F _load_completion load
