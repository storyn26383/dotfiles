_t_login () {
  tsh status >/dev/null 2>&1 && return

  export TSH_PROXY=$(op item get Teleport --fields label=proxy --reveal)
  export TSH_PASSWORD=$(op item get Teleport --fields label=password --reveal)
  export TSH_OTP=$(op item get Teleport --otp)

  if [ -z "$TSH_PROXY" -o -z "$TSH_PASSWORD" -o -z "$TSH_OTP" ]; then
    unset TSH_PROXY TSH_PASSWORD TSH_OTP
    echo 'Failed to read credentials from 1Password'
    return 1
  fi

  expect - <<'EOF'
set timeout 30
log_user 0

spawn tsh login --proxy=$env(TSH_PROXY) --mfa-mode=otp

expect {
  "Enter password for Teleport user" { send -- "$env(TSH_PASSWORD)\r" }
  timeout { puts "Timed out waiting for password prompt"; exit 1 }
}

expect {
  "Enter an OTP code" { send -- "$env(TSH_OTP)\r" }
  timeout { puts "Timed out waiting for OTP prompt"; exit 1 }
}

expect eof
catch wait result
exit [lindex $result 3]
EOF

  local login_status=$?
  unset TSH_PROXY TSH_PASSWORD TSH_OTP

  [ $login_status -eq 0 ] && tsh status
  return $login_status
}

_t_sh () {
  host=$1
  user=${2:-root}
  tsh ssh $user@$host
}

_t_db () {
  db=$1
  listen_args=()
  [ -n "$2" ] && listen_args=(--port $2)
  [ -n "$3" ] && listen_args=(--insecure-listen-anywhere --listen $3:$2)
  tsh proxy db --tunnel $db $listen_args
}

_t_usage () {
  echo 'Usage: t <command>'
  echo 't login                    log in with 1password credentials'
  echo 't sh <host> [user]         ssh to node, default login root'
  echo 't db <db> [port] [host]    start local db proxy, default random port on localhost'
}

t () {
  case $1 in
    login)
      _t_login
      ;;

    sh)
      shift
      _t_sh $@
      ;;

    db)
      shift
      _t_db $@
      ;;

    help|-h|-help|--help)
      _t_usage
      ;;

    *)
      echo 'Unknown command:' $1
      _t_usage
      ;;
  esac
}

_t_nodes () {
  tsh ls --format=names
}

_t_dbs () {
  tsh db ls --format json | jq -r '.[].metadata.name'
}

_t_logins () {
  tsh status --format=json | jq -r '.active.logins[]'
}

_t_cached () {
  local cache_file=${TMPDIR:-/tmp}/.t-cache-$1
  local output

  if [ -n "$(find $cache_file -mmin -1 2>/dev/null)" ]; then
    cat $cache_file
    return
  fi

  output=$($1)
  [ -n "$output" ] && printf '%s\n' "$output" > $cache_file
  printf '%s\n' "$output"
}

_t_nodes_completion () {
  _shared_generate_completion "$(_t_cached _t_nodes)"
}

_t_dbs_completion () {
  _shared_generate_completion "$(_t_cached _t_dbs)"
}

_t_logins_completion () {
  _shared_generate_completion "$(_t_cached _t_logins)"
}

_t_commands_completion () {
  _shared_generate_completion 'login sh db help'
}

_t_completion () {
  if [ $COMP_CWORD -eq 1 ]; then
    _t_commands_completion
    return
  fi

  if [ $COMP_CWORD -eq 2 ]; then
    case "${COMP_WORDS[1]}" in
      sh) _t_nodes_completion;;
      db) _t_dbs_completion;;
    esac
    return
  fi

  if [ $COMP_CWORD -eq 3 -a "${COMP_WORDS[1]}" = 'sh' ]; then
    _t_logins_completion
    return
  fi

  COMPREPLY=()
}

complete -F _t_completion t
