#!/usr/bin/env bash

init_chia () {
    if [[ ${chia_update_on_init} == "true" ]]; then
        chia_update.sh
    fi

    cd ${chia_dir}
    . ./activate
    chia init

    sed -i 's/localhost/127.0.0.1/g' ~/.chia/mainnet/config/config.yaml
}

init_network () {
    if [[ ${start} == 'harvester' ]]; then
        if [[ -z ${farmer_address} || -z ${farmer_port} ]]; then
            echo "A farmer_address and farmer_port are required to start a harvester."
            exit
        else
            chia configure --set-farmer-peer ${farmer_address}:${farmer_port}
        fi
    fi

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
    chia plots add -d ${plots_final_dir}
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
