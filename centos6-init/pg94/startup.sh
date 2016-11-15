#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)
. $CDIR/container.rc 2>/dev/null &&
$CDIR/bin/BOOT.sh "${DOCKER_TAG}" ${BOOT_OPTIONS}
exit $?
