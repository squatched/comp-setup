#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# BASH_SOURCE is a bare filename when the script is invoked from its own directory.
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null
SOURCE_DIR=$(pwd)
popd >/dev/null

DEST_DIR="${HOME}/.local/bin"
MOUNT_POINT="${HOME}/Network/McCombalot NAS"

mkdir --parents "${DEST_DIR}"
if [[ ! -d "${MOUNT_POINT}" ]]; then
    mkdir --parents "${MOUNT_POINT}"
    printf 'Created %s\n' "${MOUNT_POINT}"
fi

pending=()
for src in "${SOURCE_DIR}"/*; do
    name="${src##*/}"
    if [[ "${name}" == "setup.sh" ]]; then
        continue
    fi
    if [[ ! -f "${src}" || ! -x "${src}" ]]; then
        continue
    fi

    dest="${DEST_DIR}/${name}"
    if [[ -e "${dest}" && ! -L "${dest}" ]] && ! cmp --silent "${src}" "${dest}"; then
        printf 'Refusing to replace %s; it differs from %s\n' "${dest}" "${src}" >&2
        exit 1
    fi
    pending+=("${src}")
done

for src in "${pending[@]}"; do
    ln --verbose --symbolic --force "${src}" "${DEST_DIR}/${src##*/}"
done
