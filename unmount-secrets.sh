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

# Unmount device
umount ./secrets.mount

# Close encrypted device
"${CRYPTSETUP}" close "${DEVNAME}"

# Done
if [ -n "`git status --porcelain \"${CRYPTFILE}\"`" ]; then
    cat << xxEOFxx

You have made modifications to ${CRYPTFILE}. Please now either commit or revert.

xxEOFxx
fi
