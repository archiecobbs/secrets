#!/bin/bash

# Bail out on error
set -e

# Constants
MIN_SIZE="3"
CRYPTSETUP="/sbin/cryptsetup"
DEFAULT_CRYPTFILE="filesystem.bin"
if [ -n "${SUDO_USER}" ]; then
    DEFAULT_DEVNAME="secrets_${SUDO_USER}"
else
    DEFAULT_DEVNAME="secrets_${USER}"
fi

# Get device name
if [ -n "${SUDO_USER}" ]; then
    DEVNAME="secrets_${SUDO_USER}"
else
    DEVNAME="secrets_${USER}"
fi

# Usage message
usage()
{
    echo "Usage: initialize-secrets.sh [options] size-in-megabytes" 1>&2
    echo "Options:" 1>&2
    echo "    -d devname    Specify device name (default \"${DEFAULT_DEVNAME}\")" 1>&2
    echo "    -f file       Specify image file (default \"${DEFAULT_CRYPTFILE}\")" 1>&2
    echo "    -h,--help     Show this help mesage" 1>&2
}

# Parse flags passed in on the command line
DEVNAME="${DEFAULT_DEVNAME}"
CRYPTFILE="${DEFAULT_CRYPTFILE}"
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
    1)
        SIZE="$1"
        ;;
    *)
        usage
        exit 1
        ;;
esac

# Sanity check size
if ! [[ "${1}" =~ [0-9]+ ]]; then
    echo "${0}: invalid size \"${1}\"" 1>&2
    exit 1
fi
if [ "${SIZE}" -lt "${MIN_SIZE}" ]; then
    echo "${0}: size must be at least ${MIN_SIZE}" 1>&2
    exit 1
fi

# Verify we are root
if [ "`id -u`" -ne 0 ]; then
    echo "${0}: you must run this as root" 1>&2
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
