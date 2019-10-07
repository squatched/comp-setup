#!/usr/bin/env /bin/bash

# Stupid obfuscation/deobfuscation tool to confuse simple string searches.
function obfuscate() {
    tr '[a-z]' '[n-za-m]' <<<"${@}" | tr '[A-Z]' '[N-ZA-M]'
}

function deobfuscate() {
    tr '[N-ZA-M]' '[A-Z]' <<<"${@}" | tr '[n-za-m]' '[a-z]'
}
