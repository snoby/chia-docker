#!/usr/bin/env bash

plots_creating=`ps -ef | grep "plots create" | grep -v "grep" | wc -l`

# plots_maximum is set through Docker environment variables
if [[ ${plots_creating} -ge ${plots_maximum} ]];then
	echo ${plots_creating} plots creating
else
	plot_date=`date +%Y-%m-%d-%H-%M`
	plotting_directory=/plotting/plot-k${plot_size}-${plot_date}
	mkdir ${plotting_directory}
    
    cd /chia-blockchain
    . ./activate

	# wallet_fingerprint, farmer_public_key, pool_public_key and plot_size are set through Docker environment variables
	chia plots create -a ${wallet_fingerprint} -f ${farmer_public_key} -p ${pool_public_key} \
    -k ${plot_size} -t ${plotting_directory} -d /plots &> /plotting/plot-k${plot_size}-${plot_date}.txt &
fi
