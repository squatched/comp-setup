#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# BASH_SOURCE is a bare filename when the script is invoked from its own directory.
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null
SOURCE_DIR=$(pwd)
popd >/dev/null

DEST_DIR="${HOME}/.local/bin"
MOUNT_POINT="${HOME}/Network/McCombalot NAS"
REMAPPER_SRC="${SOURCE_DIR}/input-remapper"
# xmodmap.json is regenerated from the session keymap, so it stays put.
REMAPPER_DEST="${XDG_CONFIG_HOME:-${HOME}/.config}/input-remapper-2"

refuse() {
    printf 'Refusing to replace %s; it differs from %s\n' "$1" "$2" >&2
    exit 1
}

# A regular file must match src. An existing symlink is retargeted.
assert_file_replaceable() {
    local src=$1 dest=$2
    if [[ -e "${dest}" && ! -L "${dest}" ]] && ! cmp --silent "${src}" "${dest}"; then
        refuse "${dest}" "${src}"
    fi
}

# Empty live files that the repo does not track (the GUI's "new preset.json")
# can be dropped. Any other live-only or changed file blocks the swap.
assert_preset_dir_replaceable() {
    local src=$1 dest=$2
    local live rel repo_file

    if [[ -L "${dest}" || ! -e "${dest}" ]]; then
        return 0
    fi
    if [[ ! -d "${dest}" ]]; then
        printf 'Refusing to replace %s; expected a directory of presets\n' "${dest}" >&2
        exit 1
    fi

    while IFS= read -r -d '' live; do
        rel="${live#"${dest}/"}"
        repo_file="${src}/${rel}"
        if [[ ! -f "${repo_file}" ]]; then
            if [[ -s "${live}" ]]; then
                printf 'Refusing to replace %s; it is not in %s\n' "${live}" "${src}" >&2
                exit 1
            fi
            continue
        fi
        if ! cmp --silent "${repo_file}" "${live}"; then
            refuse "${live}" "${repo_file}"
        fi
    done < <(find "${dest}" -type f -print0)
}

link_file() {
    local src=$1 dest=$2
    mkdir --parents "$(dirname "${dest}")"
    ln --verbose --symbolic --force "${src}" "${dest}"
}

link_preset_dir() {
    local src=$1 dest=$2
    local current backup

    mkdir --parents "$(dirname "${dest}")"
    if [[ -L "${dest}" ]]; then
        current=$(readlink "${dest}")
        if [[ "${current}" == "${src}" ]]; then
            return 0
        fi
        rm "${dest}"
        ln --verbose --symbolic "${src}" "${dest}"
        return 0
    fi
    if [[ ! -e "${dest}" ]]; then
        ln --verbose --symbolic "${src}" "${dest}"
        return 0
    fi

    backup=$(mktemp -d)
    mv "${dest}" "${backup}/presets"
    if ! ln --verbose --symbolic "${src}" "${dest}"; then
        mv "${backup}/presets" "${dest}"
        rm -rf "${backup}"
        exit 1
    fi
    rm -rf "${backup}"
}

mkdir --parents "${DEST_DIR}"
if [[ ! -d "${MOUNT_POINT}" ]]; then
    mkdir --parents "${MOUNT_POINT}"
    printf 'Created %s\n' "${MOUNT_POINT}"
fi

pending=()
for src in "${SOURCE_DIR}"/* "${SOURCE_DIR}"/*/*; do
    name="${src##*/}"
    if [[ "${name}" == "setup.sh" || "${src}" == "${SOURCE_DIR}/input-remapper" || "${src}" == "${SOURCE_DIR}/input-remapper/"* ]]; then
        continue
    fi
    if [[ ! -f "${src}" || ! -x "${src}" ]]; then
        continue
    fi

    assert_file_replaceable "${src}" "${DEST_DIR}/${name}"
    pending+=("${src}")
done

if [[ -d "${REMAPPER_SRC}" ]]; then
    assert_file_replaceable "${REMAPPER_SRC}/config.json" "${REMAPPER_DEST}/config.json"
    assert_preset_dir_replaceable "${REMAPPER_SRC}/presets" "${REMAPPER_DEST}/presets"
fi

for src in "${pending[@]}"; do
    link_file "${src}" "${DEST_DIR}/${src##*/}"
done

if [[ -d "${REMAPPER_SRC}" ]]; then
    link_file "${REMAPPER_SRC}/config.json" "${REMAPPER_DEST}/config.json"
    link_preset_dir "${REMAPPER_SRC}/presets" "${REMAPPER_DEST}/presets"
fi
