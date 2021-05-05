#!/usr/bin/env bash

# Usage: create_plot.sh <tmp_dir>
#   Script will use system value plots_tmp_dir in case tmp_dir not passed
#   as first command line argument

[ -n "$1" ] && plots_tmp_dir=$1

plots_creating=`ps -ef | grep "plots create" | grep "${plots_tmp_dir}" | grep -v "grep" | wc -l`

# Allow only 1 plots create process per tmp_dir
if [[ ${plots_creating} -ge 1 ]];then
	echo ${plots_creating} plots creating
else
	plots_date=`date +%Y-%m-%d-%H-%M`
	plots_log_dir=${plots_tmp_dir}
	plots_tmp_dir=${plots_tmp_dir}/plot-k${plots_size}-${plots_date}
	mkdir ${plots_tmp_dir}
    
    cd /chia-blockchain
    . ./activate

	# variables are set in Docker environment
	chia plots create \
		--tmp_dir ${plots_tmp_dir} \
		--final_dir ${plots_final_dir} \
	    --size ${plots_size} \
		--num_threads ${plots_num_threads} \
		--farmer_public_key ${plots_farmer_public_key} \
		--pool_public_key ${plots_pool_public_key} &> ${plots_log_dir}/plot-k${plots_size}-${plots_date}.txt &
	echo "Creating plot ${plots_tmp_dir}" >> /proc/1/fd/1
fi
