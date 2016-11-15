#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)
DCWD=$(pwd)
. $DCWD/container.rc 2>/dev/null && {
  $CDIR/HALT.sh "${DOCKER_TAG}"
}
exit $?
