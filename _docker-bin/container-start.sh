#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)
DCWD=$(pwd)
. $DCWD/container.rc 2>/dev/null && {
  $CDIR/BOOT.sh "${DOCKER_TAG}" ${BOOT_OPTIONS}
}
exit $?
