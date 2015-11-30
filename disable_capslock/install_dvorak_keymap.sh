#!/bin/bash -e

# Ensure only root is running this script.
if [ "0" != "$(id -u)" ]; then
    echo "This script must be run as root" 1>&2;
    exit 1;
fi

# Zip up the keymap into the proper location.
cp dvorak-capslock-to-ctrl.map /usr/share/kbd/keymaps/i386/dvorak/
gzip /usr/share/kbd/keymaps/i386/dvorak/dvorak-capslock-to-ctrl.map

# Replace the keymap in vconsole to point at this new one.
sed --in-place --expression=s/^KEYMAP=.*$/KEYMAP=dvorak-capslock-to-ctrl/ /etc/vconsole.conf
