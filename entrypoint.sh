function init_chia {
  cd /chia-blockchain
  . ./activate
  chia init
  sed -i 's/localhost/127.0.0.1/g' ~/.chia/mainnet/config/config.yaml
  
  if [[ ${testnet} == "true" ]]; then
    if [[ -z $full_node_port || $full_node_port == "null" ]]; then
      chia configure --set-fullnode-port 58444
    else
      chia configure --set-fullnode-port ${var.full_node_port}
    fi
  fi
}

function init_keys {
  if [[ ${keys} == "generate" ]]; then
    echo "To use your own keys pass them as a text file -v /path/to/mnemonic.txt:/root/.chia/mnemonic.txt and -e keys=\"/root/.chia/mnemonic.txt\""
    chia keys generate
  else
    chia keys add -f ${keys}
  fi
}

function init_plots {
  if [[ ! "$(ls -A ${plots_dir})" ]]; then
    echo "Plots directory appears to be empty and you have not specified another, try mounting a plot directory with the docker -v command "
  fi
  chia plots add -d ${plots_dir}
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
