#!/usr/bin/env bash

cd ${chia_dir}
. ./activate
chia stop -d all
deactivate
version_before_fetch=`git log -n1 --format=format:"%H"`
git fetch
git checkout latest
git reset --hard FETCH_HEAD
git status
version_after_fetch=`git log -n1 --format=format:"%H"`

if [[ ${version_before_fetch} != ${version_after_fetch} ]]; then
    bash ./install.sh
fi
