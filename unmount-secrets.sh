#!/bin/bash

# Bail out on error
set -e

# Constants
CRYPTSETUP="/sbin/cryptsetup"
DEFAULT_CRYPTFILE="filesystem.bin"
DEFAULT_MNTDIR="secrets.mount"
if [ -n "${SUDO_USER}" ]; then
    DEFAULT_DEVNAME="secrets_${SUDO_USER}"
else
    DEFAULT_DEVNAME="secrets_${USER}"
fi

# Usage message
usage()
{
    echo "Usage: unmount-secrets.sh [options]" 1>&2
    echo "Options:" 1>&2
    echo "    -d devname    Specify device name (default \"${DEFAULT_DEVNAME}\")" 1>&2
    echo "    -f file       Specify image file (default \"${DEFAULT_CRYPTFILE}\")" 1>&2
    echo "    -m dir        Specify mount directory (default \"${DEFAULT_MNTDIR}\")" 1>&2
    echo "    -h,--help     Show this help mesage" 1>&2
}

# Parse flags passed in on the command line
DEVNAME="${DEFAULT_DEVNAME}"
CRYPTFILE="${DEFAULT_CRYPTFILE}"
MNTDIR="${DEFAULT_MNTDIR}"
while [ ${#} -gt 0 ]; do
    case "$1" in
        -d)
            shift
            DEVNAME="${1}"
            shift
            ;;
        -f)
            shift
            CRYPTFILE="${1}"
            shift
            ;;
        -m)
            shift
            MNTDIR="${1}"
            shift
            ;;
        -h|--help)
            usage
            exit
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
done
case "${#}" in
    0)
        ;;
    *)
        usage
        exit 1
        ;;
esac

# Verify we are root
if [ "`id -u`" -ne 0 ]; then
    echo "${0}: you must run this as root" 1>&2
    exit 1
fi

# Unmount device
umount "${MNTDIR}"

# Close encrypted device
"${CRYPTSETUP}" close "${DEVNAME}"

# Done
if [ -n "`git status --porcelain \"${CRYPTFILE}\"`" ]; then
    cat << xxEOFxx

You have made modifications to ${CRYPTFILE}. Please now either commit or revert.

xxEOFxx
fi
