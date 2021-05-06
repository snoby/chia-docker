#!/usr/bin/env bash

# Usage: create_plot.sh <tmp_dir>
#   Script will use system value plots_tmp_dir in case tmp_dir not passed
#   as first command line argument
#   Script will use system value plots_final_dir in case final_dir not passed
#   as second command line argument

[ -n "$1" ] && plots_tmp_dir=$1
[ -n "$2" ] && plots_final_dir=$2

plots_creating=`ps -ef | grep "plots create" | grep "${plots_tmp_dir}" | grep -v "grep" | wc -l`

# Allow only 1 plots create process per tmp_dir
if [[ ${plots_creating} -ge 1 ]]; then
    echo ${plots_creating} plots creating
else
    plots_date=`date +%Y-%m-%d-%H-%M`
    plots_id="plot-k${plots_size}-${plots_date}"

    mkdir ${plots_tmp_dir}/${plots_id}

    cd ~/chia-blockchain
    . ./activate

    # Create new plot
    echo "Creating plot ${plots_tmp_dir}/${plots_id}. Final directory ${plots_final_dir}." >> /proc/1/fd/1
    chia plots create \
        --tmp_dir ${plots_tmp_dir}/${plots_id} \
        --final_dir ${plots_final_dir} \
        --size ${plots_size} \
        --num_threads ${plots_num_threads} \
        --farmer_public_key ${plots_farmer_public_key} \
        --pool_public_key ${plots_pool_public_key} \
        ${plots_options} > ${plots_tmp_dir}/${plots_id}.txt

    if [[ ${plots_curl_upload} == "true" ]]; then
        echo "Uploading plot ${plots_final_dir}/${plots_id}-*.plot to ${plots_curl_target}." >> /proc/1/fd/1
        curl --upload-file ${plots_final_dir}/${plots_id}-*.plot ${plots_curl_target}
    fi
fi
