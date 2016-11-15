#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)
. $CDIR/container.rc 2>/dev/null &&
$CDIR/bin/HALT.sh "${DOCKER_TAG}"
exit $?
