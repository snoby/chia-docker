#!/usr/bin/env bash

update_chia () {
  version_before_fetch=`git log -n1 --format=format:"%H"`
  git fetch
  git checkout latest
  git reset --hard FETCH_HEAD
  git status
  version_after_fetch=`git log -n1 --format=format:"%H"`

  if [[ ${version_before_fetch} != ${version_after_fetch} ]]; then
    bash ./install.sh
  fi
}

init_chia () {
  cd /chia-blockchain
  update_chia
  . ./activate
  chia init
}

init_network () {
  if [[ ${testnet} == "true" ]]; then
    if [[ -z $full_node_port || $full_node_port == "null" ]]; then
      chia configure --set-fullnode-port 58444
    else
      chia configure --set-fullnode-port ${full_node_port}
    fi
  fi
}

init_keys () {
  if [[ ${keys} == "generate" ]]; then
    echo "To use your own keys pass them as a text file. Generating keys now."
    chia keys generate
  else
    chia keys add -f ${keys}
  fi
}

init_plots () {
  chia plots add -d /plots
}

case ${start} in
  null|none|plotter)
    init_chia
  ;;
  *)
    init_chia
    init_network
    init_keys
    init_plots
    chia start ${start}
  ;;
esac

while true; do sleep 30; done;
