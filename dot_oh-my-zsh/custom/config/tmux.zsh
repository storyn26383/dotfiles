init-tmux() {
  api_path=~/Coding/UniverseTech/api
  hyperf_path=~/Coding/UniverseTech/hyperf-api
  openim_api_path=~/Coding/UniverseTech/openim/openim-api
  openim_app_path=~/Coding/UniverseTech/openim/openim-app
  openim_server_path=~/Coding/UniverseTech/openim/openim-server
  docker_path=~/Coding/UniverseTech/dev-env/docker

  tmux \
    rename-window -t 0 k9s \; \
    new-window -n api -c $api_path \; split-window -t api -l 10 -c $docker_path \; select-pane -t 0 \; \
    new-window -n hyperf -c $hyperf_path \; split-window -t hyperf -l 10 -c $docker_path \; select-pane -t 0 \; \
    new-window -n openim -c $openim_api_path \; split-window -t openim -l 10 -c $openim_api_path \; select-pane -t 0 \; \
    new-window -n app -c $openim_app_path \; split-window -t app -l 10 -c $openim_app_path \; select-pane -t 0 \; \
    new-window -n server -c $openim_server_path \; \
    select-window -t k9s
}
