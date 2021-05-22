#!/usr/bin/env bash

# Usage: create_plot.sh <tmp_dir>
#   Script will use system value plots_tmp_dir in case tmp_dir not passed
#   as first command line argument. Second argument would override the final_dir.
#   There is upload_plot.sh which can be used to upload finished plots to
#   the farmer in case plotter and farmer run on different systems.

[ -n "$1" ] && plots_tmp_dir=$1
[ -n "$2" ] && plots_final_dir=$2

process_available () {
    process_available_return=0

    plots_creating=`ps -ef | grep "plots create" | grep "tmp_dir ${plots_tmp_dir}" | grep -v "grep" | wc -l`
    [[ ${plots_creating} -ge 1 ]] && process_available_return=1

    return ${process_available_return}
}

enough_space_available () {
    enough_space_available_return=0

    export POSIXLY_CORRECT=true
    free_space_tmp_dir_512_blocks=`df -P ${plots_tmp_dir} | sed '1d' | awk '{print $4}'`
    free_space_tmp_dir_gb=`expr ${free_space_tmp_dir_512_blocks} / 2097152`
    [[ ${plots_size} -eq 32 && ${free_space_tmp_dir_gb} -le 257 ]]  && enough_space_available_return=1
    [[ ${plots_size} -eq 33 && ${free_space_tmp_dir_gb} -le 550 ]]  && enough_space_available_return=1
    [[ ${plots_size} -eq 34 && ${free_space_tmp_dir_gb} -le 1118 ]] && enough_space_available_return=1
    [[ ${plots_size} -eq 35 && ${free_space_tmp_dir_gb} -le 2335 ]] && enough_space_available_return=1

    return ${enough_space_available_return}
}

ready_to_plot () {
    script_exit=0

    if [[ ! -d ${plots_tmp_dir} ]]; then
        echo "ERROR: Directory ${plots_tmp_dir} does not exist."
        script_exit=1
        return 1
    fi

    if [[ ! -w ${plots_tmp_dir} ]]; then
        echo "ERROR: Directory ${plots_tmp_dir} is not writeable."
        script_exit=1
        return 1
    fi

    if ! process_available; then
        echo "INFO: Plots create running on ${plots_tmp_dir}."
        script_exit=0
        return 1
    fi

    if ! enough_space_available; then
        echo "ERROR: Not enough space on ${plots_tmp_dir}."
        script_exit=1
        return 1
    fi
}

if ready_to_plot; then
    plots_date=`date +%Y-%m-%d-%H-%M`
    plots_id="plot-k${plots_size}-${plots_date}"

    mkdir ${plots_tmp_dir}/${plots_id}

    cd ${chia_dir}
    . ./activate

    echo "INFO: Creating plot into temporary directory ${plots_tmp_dir}/${plots_id}."
    echo "INFO: Final directory ${plots_final_dir}."
    eval ${prevent_sleep} chia plots create \
        --tmp_dir ${plots_tmp_dir}/${plots_id} \
        --final_dir ${plots_final_dir} \
        --size ${plots_size} \
        --num_threads ${plots_num_threads} \
        --farmer_public_key ${plots_farmer_public_key} \
        --pool_public_key ${plots_pool_public_key} \
        ${plots_options} > ${plots_tmp_dir}/${plots_id}.txt
    
    rm -rf ${plots_tmp_dir}/${plots_id}
else
    echo "INFO: Not triggering plots create."
    exit ${script_exit}
fi