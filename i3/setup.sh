#!/bin/bash

set -eou pipefail
IFS=$'\n\t'

# Won't work in 100% of our cases (http://mywiki.wooledge.org/BashFAQ/028) but it'll do for now.
pushd "${BASH_SOURCE[@]%/*}/" >/dev/null
SOURCE_DIR=$(pwd)
popd >/dev/null

CONFIG_DIR=${HOME}/.config/i3
[[ -d ${CONFIG_DIR} ]] || mkdir --parent "${CONFIG_DIR}"

for f in ${SOURCE_DIR}/* ${SOURCE_DIR}/**/*; do
    file_name=$(basename "${f}")
    dir_name=$(dirname "${f##${SOURCE_DIR}}")

    # Skip this script.
    [[ ${file_name} == ${0##*/} ]] && continue

    # Skip directories.
    [[ -d ${f} ]] && continue

    # Make the target directory if necessary.
    dest_dir=${CONFIG_DIR}${dir_name}
    [[ -d ${dest_dir} ]] || mkdir --parent "${dest_dir}"

    # Don't setup the link if file exists.
    [[ -e ${dest_dir}/${file_name} ]] && continue

    ln --symbolic --force "${f}" "${dest_dir}"
done
