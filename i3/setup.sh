#!/bin/bash

set -eou pipefail
IFS=$'\n\t'

# Won't work in 100% of our cases (http://mywiki.wooledge.org/BashFAQ/028) but it'll do for now.
pushd "${BASH_SOURCE[@]%/*}/" >/dev/null
SOURCE_DIR=$(pwd)
popd >/dev/null

CONFIG_DIR=${HOME}/.config/i3/config.d
[[ -d ${CONFIG_DIR} ]] || mkdir --parent "${CONFIG_DIR}"

for f in ${SOURCE_DIR}/*; do
    [[ $f == *${0##*/} ]] && continue

    ln --symbolic --force "${f}" "${CONFIG_DIR}"
done
