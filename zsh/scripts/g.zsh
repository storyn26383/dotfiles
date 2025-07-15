_g_merge_and_push () {
  git checkout $2 && git pull origin $2 && git merge $1 && git checkout $1 && git push origin $1 $2
}

_g_push () {
  git push origin $(git branch --show-current)
}

_k_usage () {
  echo 'Usage: g <command>'
  echo 'g merge-and-push <branch> <target_branch>    merge branch and push to target branch'
}

k () {
  case $1 in
    merge-and-push)
      _g_merge_and_push $(git branch --show-current) $2
      ;;

    push)
      _g_push
      ;;

    help|-h|-help|--help)
      _g_usage
      ;;

    *)
      echo 'Unknow command:' $1
      _g_usage
      ;;
  esac
}

_g_branches_completion () {
  _shared_generate_completion "$(git branch --all | sed 's/^[ *]*//' | grep -v 'HEAD' | grep -v remotes)"
}

_g_commands_completion () {
  _shared_generate_completion "merge-and-push push help"
}

_g_completion () {
  if [ ${#COMP_WORDS[@]} -gt 1 ]; then
    case "${COMP_WORDS[1]}" in
      use) _g_branches_completion;;
      *) _g_commands_completion;;
    esac
  else
    _g_commands_completion
  fi
}

complete -F _g_completion g
