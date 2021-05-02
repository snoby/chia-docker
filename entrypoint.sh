#!/usr/bin/bash

function init_chia {
  cd /chia-blockchain
  git pull
  bash ./install.sh

  . ./activate
  chia init

  sed -i 's/localhost/127.0.0.1/g' ~/.chia/mainnet/config/config.yaml
  
  if [[ ${testnet} == "true" ]]; then
    if [[ -z $full_node_port || $full_node_port == "null" ]]; then
      chia configure --set-fullnode-port 58444
    else
      chia configure --set-fullnode-port ${full_node_port}
    fi
  fi
}

function init_keys {
  if [[ ${keys} == "generate" ]]; then
    echo "To use your own keys pass them as a text file. Generating keys now."
    chia keys generate
  else
    chia keys add -f ${keys}
  fi
}

function init_plots {
  chia plots add -d /plots
}


case ${start} in
  null|none|plotter)
    init_chia
  ;;
  *)
    init_chia
    init_keys
    init_plots
    chia start ${start}
  ;;
esac

while true; do sleep 30; done;
