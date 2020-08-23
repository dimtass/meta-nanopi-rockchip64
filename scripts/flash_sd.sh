#!/bin/bash
: ${MACHINE:=nanopi-neo3}
: ${IMAGE:=console}
: ${SD:=$1}
: ${IMAGE_FILE:=build/tmp/deploy/images/${MACHINE}/rk-${IMAGE}-image-${MACHINE}.wic.bz2}

if [ "$(whoami)" != "root" ]; then
    echo "You need to run the script as root..."
    exit 1
fi

if [ -z "${MACHINE}" ]; then
    cat <<EOF
You need to set which MACHINE image to flash to the SD. eg.:
$ sudo IMAGE=multimedia MACHINE=nanopi-k1-plus ./flash_sd.sh /dev/sdX
EOF
    exit 1
fi

umount ${SD}*
bmaptool copy ${IMAGE_FILE} ${SD}