#!/usr/bin/env /bin/bash

# Stupid obfuscation/deobfuscation tool to confuse simple string searches.
function obfuscate() {
    tr '[a-z]' '[n-za-m]' <<<"${@}" | tr '[A-Z]' '[N-ZA-M]'
}

function deobfuscate() {
    tr '[N-ZA-M]' '[A-Z]' <<<"${@}" | tr '[n-za-m]' '[a-z]'
}

function urldecode() {
    local input="${1}"

    if [[ -z ${input} ]]; then
        printf "urldecode: urldecode <string>\n    URL Decode a string.\n"
        return 0
    fi

    # Replace '+' with ' '
    input="${input//+/ }"

    # Replace '%' with '\x'
    input="${input//%/\\x}"

    printf "%b\n" "${input}"
}
