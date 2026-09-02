_T_CACHE_DIR=~/.cache/t

_t_clear_cache () {
  rm -rf $_T_CACHE_DIR
}

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

spawn tsh login --proxy=$env(TSH_PROXY) --mfa-mode=otp --ttl=525600

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
  local host=$1
  local user=${2:-$(_t_cached _t_logins | head -n 1)}

  if [ -z "$user" ]; then
    echo 'Failed to resolve default login, try: t login'
    return 1
  fi

  tsh ssh $user@$host
}

_t_db () {
  local db=$1
  local user=${2:-$(_t_db_users $db | head -n 1)}
  local listen_args=()

  if [ -z "$user" ]; then
    echo 'Failed to resolve default db user for' $db
    return 1
  fi

  [ -n "$3" ] && listen_args=(--port $3)
  [ -n "$4" ] && listen_args=(--insecure-listen-anywhere --listen $4:$3)

  tsh proxy db --tunnel --db-user $user $db $listen_args
}

_t_usage () {
  echo 'Usage: t <command>'
  echo 't login                          log in with 1password credentials'
  echo 't sh <host> [user]               ssh to node, default first allowed login'
  echo 't db <db> [user] [port] [host]   start local db proxy, default first allowed db user, random port on localhost'
  echo 't clear-cache                    clear cached completion data'
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

    clear-cache)
      _t_clear_cache
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
  tsh db ls --format json
}

_t_db_names () {
  _t_cached _t_dbs | jq -r '.[].metadata.name'
}

_t_db_users () {
  _t_cached _t_dbs | jq -r --arg db "$1" '.[] | select(.metadata.name == $db) | .users.allowed[]'
}

_t_logins () {
  tsh status --format=json | jq -r '.active.logins[]'
}

_t_cached () {
  local cache_file=$_T_CACHE_DIR/$1
  local output

  if [ -f $cache_file ]; then
    cat $cache_file
    return
  fi

  output=$($1)

  if [ -n "$output" ]; then
    mkdir -p $_T_CACHE_DIR
    printf '%s\n' "$output" > $cache_file
  fi

  printf '%s\n' "$output"
}

_t_nodes_completion () {
  _shared_generate_completion "$(_t_cached _t_nodes)"
}

_t_dbs_completion () {
  _shared_generate_completion "$(_t_db_names)"
}

_t_db_users_completion () {
  _shared_generate_completion "$(_t_db_users $1)"
}

_t_logins_completion () {
  _shared_generate_completion "$(_t_cached _t_logins)"
}

_t_commands_completion () {
  _shared_generate_completion 'login sh db clear-cache help'
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

  if [ $COMP_CWORD -eq 3 ]; then
    case "${COMP_WORDS[1]}" in
      sh) _t_logins_completion;;
      db) _t_db_users_completion "${COMP_WORDS[2]}";;
    esac
    return
  fi

  COMPREPLY=()
}

complete -F _t_completion t
