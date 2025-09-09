_k_use () {
  kubectl config use-context $1
}

_k_nodes () {
  kubectl get nodes | grep Ready | awk '{ print $1 }'
}

_k_pods () {
  kubectl get pods | grep Running | awk '{ print $1 }' | sed -e 's/-deploy.*$//'
}

_k_sh () {
  kubectl exec -it `kubectl get pods | grep Running | grep $1 | awk '{ print $1 }'` -- sh
}

_k_command () {
  pod=$1
  shift
  kubectl exec -it `kubectl get pods | grep Running | grep $pod | awk '{ print $1 }'` -- $@
}

_k_logs () {
  kubectl logs `kubectl get pods | grep Running | grep $1 | awk '{ print $1 }'`
}

_k_port_forward () {
  pod=$1
  shift
  kubectl port-forward `kubectl get pods | grep Running | grep $pod | awk '{ print $1 }'` $@
}

_k_node () {
  kubectl debug node/$1 -it --image=ubuntu -- chroot /host /bin/bash
}

_k_usage () {
  echo 'Usage: k <command>'
  echo 'k use <context>                                  set current context'
  echo 'k nodes                                          list running nodes'
  echo 'k node <node>                                    enter node'
  echo 'k pods                                           list running pods'
  echo 'k sh <pod>                                       enter pod'
  echo 'k command <pod> <command>                        run command on pod'
  echo 'k logs <pod>                                     show pod logs'
  echo 'k port-forward <pod> [local_port:]remote_port    forward port to pod'
}

k () {
  case $1 in
    use)
      _k_use $2
      ;;

    nodes)
      _k_nodes
      ;;

    node)
      _k_node $2
      ;;

    pods)
      _k_pods
      ;;

    sh)
      _k_sh $2
      ;;

    command)
      shift
      _k_command $@
      ;;

    logs)
      _k_logs $2
      ;;

    port-forward)
      shift
      _k_port_forward $@
      ;;

    help|-h|-help|--help)
      _k_usage
      ;;

    *)
      echo 'Unknown command:' $1
      _k_usage
      ;;
  esac
}

_k_contexts_completion () {
  _shared_generate_completion "$(kubectl config get-contexts | grep -v NAME | sed 's/\*/ /' | awk '{ print $1 }')"
}

_k_nodes_completion () {
  _shared_generate_completion "$(_k_nodes)"
}

_k_pods_completion () {
  _shared_generate_completion "$(_k_pods)"
}

_k_commands_completion () {
  _shared_generate_completion "use nodes node pods sh command logs port-forward"
}

_k_completion () {
  if [ ${#COMP_WORDS[@]} -gt 1 ]; then
    case "${COMP_WORDS[1]}" in
      use) _k_contexts_completion;;
      node) _k_nodes_completion;;
      sh|command|logs|port-forward) _k_pods_completion;;
      *) _k_commands_completion;;
    esac
  else
    _k_commands_completion
  fi
}

complete -F _k_completion k
