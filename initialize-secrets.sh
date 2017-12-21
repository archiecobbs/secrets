#!/bin/bash

# Bail out on error
set -e

# Verify we are root
if [ "`id -u`" -ne 0 ]; then
    echo "${0}: you must run this as root" 1>&2
    exit 1
fi

# Variables
MIN_SIZE="3"
CRYPTSETUP="/sbin/cryptsetup"
CRYPTFILE="./filesystem.bin"
if [ -n "${SUDO_USER}" ]; then
    DEVNAME="secrets_${SUDO_USER}"
else
    DEVNAME="secrets_${USER}"
fi

# Get size
if [ $# -eq 1 ] && [[ "${1}" =~ [0-9]+ ]]; then
    SIZE="${1}"
else
    echo "Usage: ${0} size-in-megabytes" 1>&2
    exit 1
fi
if [ "${SIZE}" -lt "${MIN_SIZE}" ]; then
    echo "${0}: size must be at least ${MIN_SIZE}" 1>&2
    exit 1
fi

# Initialize file
dd if=/dev/zero of="${CRYPTFILE}" bs=1048576 count="${SIZE}" 2>/dev/null
"${CRYPTSETUP}" luksFormat "${CRYPTFILE}"

# Open encrypted device
echo ""
echo "Please re-enter the same password you just entered"
echo ""
"${CRYPTSETUP}" --type luks open "${CRYPTFILE}" "${DEVNAME}"

# Close encrypted device when done
trap "${CRYPTSETUP} close ${DEVNAME}" 0 2 3 5 10 13 15

# Format filesystem
echo ""
echo "Now formatting ext4 filesystem"
echo ""
mkfs.ext4 "/dev/mapper/${DEVNAME}"

# Done
cat << xxEOFxx

Done!

The secrets file "${CRYPTFILE}" has been (re)initialized.

The password you just entered is now in slot zero; please update README.md accordingly.

To access the secrets file, run "./mount-secrets.sh".

xxEOFxx
