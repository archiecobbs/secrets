#!/bin/bash

# Bail out on error
set -e

# Verify we are root
if [ "`id -u`" -ne 0 ]; then
    echo "${0}: you must run this as root" 1>&2
    exit 1
fi

# Variables
CRYPTSETUP="/sbin/cryptsetup"
CRYPTFILE="./filesystem.bin"
MNTDIR="./secrets.mount"
if [ -n "${SUDO_USER}" ]; then
    DEVNAME="secrets_${SUDO_USER}"
else
    DEVNAME="secrets_${USER}"
fi

# Open encrypted device
"${CRYPTSETUP}" --type luks open "${CRYPTFILE}" "${DEVNAME}"

# Mount device
mount -o noatime,nodiratime /dev/mapper/"${DEVNAME}" "${MNTDIR}"

# Done
cat << xxEOFxx

You may now access the secrets in ${MNTDIR}.

When you're done, remember to run "sudo ./unmount-secrets.sh"
and then commit (or revert) ${CRYPTFILE} if you've made changes.

xxEOFxx
