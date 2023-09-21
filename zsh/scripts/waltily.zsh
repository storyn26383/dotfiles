_node16 () {
  docker run \
    -it \
    --rm \
    -v `pwd`:/app \
    -v ~/.yarn:/.yarn \
    -v ~/.cache:/.cache \
    -v ~/.yarnrc:/.yarnrc \
    -w /app \
    -u `id -u`:`id -g` \
    -p 3000:3000 \
    node:16-alpine $@
}

_waltily_usage () {
  echo 'Usage: waltily PROJECT COMMAND'
  echo 'Supported projects: backend, frontend'
  echo 'Supported commands:'
  echo '  backend: build-docker-image shell artisan serve'
  echo '  frontend: shell serve'
}

_waltily_projects_completion () {
  _shared_generate_completion "backend frontend"
}

_waltily_backend_commands_completion () {
  _shared_generate_completion "build-docker-image shell artisan serve"
}

_waltily_frontend_commands_completion () {
  _shared_generate_completion "shell serve"
}

_waltily_completion () {
  if [ ${#COMP_WORDS[@]} -gt 1 ]; then
    case "${COMP_WORDS[1]}" in
      backend) _waltily_backend_commands_completion;;
      frontend) _waltily_frontend_commands_completion;;
      *) _waltily_projects_completion;;
    esac
  else
    _waltily_projects_completion
  fi
}

waltily () {
  case $1 in
    backend)
      case $2 in
        build-docker-image)
          cd ${WALTILY_PROJECT_ROOT}/laravel/docker && docker build . -f app.docker -t waltily.laravel && cd -
          ;;

        shell)
          docker run --rm -it -v `pwd`:/app -v ~/.composer:/.composer --link mysql -w /app -u `id -u`:`id -g` waltily.laravel bash
          ;;

        artisan)
          shift
          shift
          docker run --rm -it -v `pwd`:/app -v ~/.composer:/.composer --link mysql -w /app -u `id -u`:`id -g` -p 8000:8000 waltily.laravel php artisan $@
          ;;

        serve)
          docker run --rm -it -v `pwd`:/app -v ~/.composer:/.composer --link mysql -w /app -u `id -u`:`id -g` -p 8000:8000 waltily.laravel php artisan serve --host 0.0.0.0
          ;;

        *)
          echo 'Unknow command:' $1
          _waltily_usage
          return
          ;;
      esac
      ;;

    frontend)
      case $2 in
        shell)
          if [ $# -gt 2 ]; then
            shift
            shift
            _node16 $@
          else
            _node16 sh
          fi
          ;;

        serve)
          _node16 yarn serve --port 3000 --public ${TUNNEL_DOMAIN}
          ;;

        *)
          echo 'Unknow command:' $1
          _waltily_usage
          return
          ;;
      esac
      ;;

    help|-h|-help|--help)
      _waltily_usage
      ;;

    *)
      echo 'Unknow project:' $1
      _waltily_usage
      ;;
  esac
}

complete -F _waltily_completion waltily
