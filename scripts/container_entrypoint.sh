#!/usr/bin/env bash

init_chia () {
    update_chia.sh

    cd ${chia_dir}
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
