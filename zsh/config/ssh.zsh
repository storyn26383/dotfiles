# ssh hostname completion
[ -r ~/.ssh/config ] && hosts=($(cat ~/.ssh/config | sed -ne 's/Host[=\t ]//p')) || hosts=()
zstyle ':completion:*:hosts' hosts $hosts
zstyle ':completion:*' users off
compdef csshX=ssh
compdef mosh=ssh
compdef scp=ssh
