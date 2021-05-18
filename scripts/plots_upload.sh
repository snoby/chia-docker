#!/usr/bin/env bash

[ -n "$1" ] && plots_final_dir=$1

plots_uploading=`ps -ef | grep "curl --upload-file" | grep "${plots_final_dir}" | grep -v "grep" | wc -l`

# Allow only 1 upload file process per final_dir
if [[ ${plots_uploading} -ge 1 ]]; then
    echo "INFO: Curl upload-file running on ${plots_final_dir}"
else
    echo "INFO: Uploading any finished plots from ${plots_final_dir}."
    echo "INFO: Curl target ${plots_curl_target}."
    eval ${prevent_sleep} find ${plots_final_dir} \
        -name '*.plot' \
        -type f \
        -exec curl --upload-file "{}" ${plots_curl_target} \; \
        -exec rm "{}" \;
fi