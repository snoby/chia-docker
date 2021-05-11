#!/usr/bin/env bash

# Usage: create_plot.sh <tmp_dir>
#   Script will use system value plots_tmp_dir in case tmp_dir not passed
#   as first command line argument.
#   There is upload_plot.sh which can be used to upload finished plots to
#   the farmer in case plotter and farmer run on different systems.

[ -n "$1" ] && plots_tmp_dir=$1

plots_creating=`ps -ef | grep "plots create" | grep "${plots_tmp_dir}" | grep -v "grep" | wc -l`

# Allow only 1 plots create process per tmp_dir
if [[ ${plots_creating} -ge 1 ]]; then
    echo "plots create running on ${plots_tmp_dir}"
else
    chia_update.sh

    plots_date=`date +%Y-%m-%d-%H-%M`
    plots_id="plot-k${plots_size}-${plots_date}"

    mkdir ${plots_tmp_dir}/${plots_id}

    cd ${chia_dir}
    . ./activate

    # Create new plot
    echo "Creating plot into temporary directory ${plots_tmp_dir}/${plots_id}."
    echo "Final directory ${plots_final_dir}."
    eval ${prevent_sleep} chia plots create \
        --tmp_dir ${plots_tmp_dir}/${plots_id} \
        --final_dir ${plots_final_dir} \
        --size ${plots_size} \
        --num_threads ${plots_num_threads} \
        --farmer_public_key ${plots_farmer_public_key} \
        --pool_public_key ${plots_pool_public_key} \
        ${plots_options} > ${plots_tmp_dir}/${plots_id}.txt
    
    rm -rf ${plots_tmp_dir}/${plots_id}
fi