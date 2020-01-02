#!/bin/bash

getopt --test >/dev/null
if [[ ${?} -ne 4 ]]; then
    printf "Missing the right `getopt` version.\n"
    exit 1
fi

set -euo pipefail
IFS=$'\n\t'

main() {
    local dest_dir="${1}"
    local source_dir="${2:-$(pwd)}"

    # Normalize these vars if given.
    [[ -n ${dest_dir}  ]] && dest_dir="$(realpath "${dest_dir}")"
    [[ -n ${source_dir}  ]] && source_dir="$(realpath "${source_dir}")"

    if [[ -z ${dest_dir}  ]]; then
        printf "No destination directory specified.\n";
        exit 3
    fi
    if [[ -n ${source_dir} ]] && [[ ! -d  ${source_dir} ]]; then
        printf "Given target environment \"${source_dir}\" does not exist.\n"
        exit 3
    fi

    # Find all files or symbolic links in the given source directory.
    for file in $(find "${source_dir}" -type f -or -type l); do
        # If the file is a symlink somewhere else, then let's point the symlink there.
        # However, let's keep the file's name and name the symlink that. (${file_name})
        target_file="$(readlink --canonicalize-existing "${file}")"
        file_source_dir=$(dirname "$(realpath "${file}")")
        file_name=$(basename "${file}")

        # Replace the prefix of ${source_dir} with ${dest_dir}
        file_dest_dir="${file_source_dir/#${source_dir}/${dest_dir}}"

        # Make the target directory if necessary.
        [[ -d ${file_dest_dir} ]] || mkdir --parent "${file_dest_dir}"

        # We might be refreshing links so force overwrite.
        ln --verbose --symbolic --force "${target_file}" "${file_dest_dir}/${file_name}"
    done
}

show_help() {
    cat <<EOF
Usage: ${0##*/} [options] [TARGET]
Setup the proprietary portion of my bash environment given some particular
TARGET environment which is a directory. If no TARGET given, works from cwd.

Options:
  -h | --help  Display this help.

Example Usage:
  ${0##*/} ./laptop - Setup symlinks for all items in the directory 'laptop' at
      the home directory of the current machine.
EOF
}

PARSED_ARGS=$(getopt --options=h --longoption=help --name ${0##*/} -- "$@")
[[ ${?} -eq 0 ]] || exit 2

eval set -- "${PARSED_ARGS}"
while [[ ${#} -gt 0 ]]; do
    case "${1}" in
        -h|--help)
            show_help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            printf "Programming error... Go yell at Caleb.\n"
            exit 3
            ;;
    esac
done

main "${HOME}" "${1:-}"
