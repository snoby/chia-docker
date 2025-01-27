#!/usr/bin/env bash
set +x

init_chia () {
    if [[ ${chia_update_on_init} == "true" ]]; then
        chia_update.sh
    fi

    cd ${chia_dir}
    . ./activate

    chia init
    #
    #If the user is using us in multimachine mode we need his ca, he has passed it in we must import the ca into our config
    #

    if [[ "${CA_PROVIDED}" == "true" ]]; then
        echo "CA has been provided, importing..."
        chia init -c /mnt/passed-ca
    fi

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
	echo "adding keys from mnemonic"
        chia keys add -f "${keys}"
    fi
}

init_plots () {
    chia plots add -d ${plots_final_dir}
}

init_plotman(){

PLOTMAN_CONFIG=/root/.config/plotman/plotman.yaml
#
# We assume that chia init has already
# taken place.
# Need to have,everything you normmally would for plotting along with
# the plotman config.
if [ ! -f "${PLOTMAN_CONFIG}" ]; then
    echo "You must have a plotman config bind mounted to ${PLOTMAN_CONFIG}"
    exit 1
fi
    #
    # Background the plotter
    #
    plotman plot &

}

case ${start} in
    null|none|plotter)
	echo "Setting up for just plotter"
        init_chia
    ;;
    plotman)
        init_chia
        init_keys
        init_plotman
    ;;
    *)
	echo "Starting everything"
        init_chia
        init_network
        init_keys
        init_plots
        chia start ${start}
    ;;
esac


#
# Make it so that we actually shutdown properly
#
cleanup() {
    echo "Cleaning up..."
    case ${start} in
        plotman)
            echo "Shutting down plotman"
            exit
        ;;
        *)
            chia stop ${start}
            exit
        ;;
    esac
}

trap cleanup INT TERM

while :; do
    sleep 1s
done
