#!/usr/bin/env bash

getopt --test >/dev/null
if [[ ${?} -ne 4 ]]; then
    printf "Missing the right `getopt` version.\n"
    exit 1
fi

set -euo pipefail
IFS=$'\n\t'

function show_help() {
    cat <<EOF
Usage: ${0##*/} [options] <systemd unit file>
Install some systemd unit file and enable/start it.
  -h | --help                Display this help.
  -s | --system              Install the unit as a system service.
  -i | --install-only        Do not enable or start the service.
EOF
}

INSTALL_PATH_USER="${HOME}/.config/systemd/user"
INSTALL_PATH_SYSTEM="/etc/systemd/system"
SHORT_OPTS="hsi"
LONG_OPTS="help,system,install-only"
PARSED_ARGS=$(getopt \
    --options="${SHORT_OPTS}" \
    --longoptions="${LONG_OPTS}" \
    --name ${0##*/} \
    -- "$@")
if [[ ${?} -ne 0 ]]; then
    # Getopt has complained about invalid arguments.
    exit 2
fi

systemd_user_arg="--user"
install_as_system=false
install_path="${INSTALL_PATH_USER}"
install_only=false
eval set -- "${PARSED_ARGS}"
while [[ ${#} -gt 0 ]]; do
    case "${1}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--system)
            install_as_system=true
            systemd_user_arg=
            install_path="${INSTALL_PATH_SYSTEM}"
            ;;
        -i|--install-only)
            install_only=true
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
    shift
done

systemd_unit_path="${1}"
if [[ -z ${systemd_unit_path} ]]; then
    printf "No systemd unit file given.\n"
    exit 4
fi
if [[ ! -f ${systemd_unit_path} ]]; then
    printf "Invalid file given.\n"
    exit 5
fi
if [[ ${EUID} -eq 0 ]] && ! ${install_as_system}; then
    printf "Will not install a user systemd unit as root.\n"
    exit 6
fi
if [[ ${EUID} -ne 0 ]] && ${install_as_system}; then
    printf "Must run script as root to install a system scope systemd unit file.\n"
    exit 7
fi

# -D = Create all components of --target-directory
install -D --target-directory="${install_path}" "${systemd_unit_path}"

${install_only} && exit 0

systemd_unit=$(basename "${systemd_unit_path}")
systemctl ${systemd_user_arg} reload-daemon
systemctl ${systemd_user_arg} start ${systemd_unit}
systemctl ${systemd_user_arg} enable ${systemd_unit}
