#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)
DDIR=$(pwd)

DOCKER_HOST="${DOCKER_HOST:-tcp://127.0.0.1:4243}"
DOCKER_TAG="${DOCKER_TAG:-}"

export DOCKER_HOST DOCKER_TAG

# docker-bin functions
. $CDIR/functions.sh 1>/dev/null 2>&1 ||
  exit 127

# Dockerfile
[ -r "$DDIR/Dockerfile" ] && {

  eval $(
  $CDIR/get-opts-from-dockerfile.sh "$DDIR/Dockerfile"
  )

} || :

# Flags
_stop_only_noremove=0

# Parse options
while [ $# -gt 0 ]
do
  case "$1" in
  -stop|--stop|-norem*|--no-remove)
    _stop_only_noremove=1
    ;;
  -*)
    ;;
  *)
    if [ -z "$DOCKER_TAG" ]
    then
      DOCKER_TAG="$1"
    fi
    ;;
  esac
  shift
done

[ -n "${DOCKER_HOST}" ] || {
  echo "$THIS: ERROR: 'DOCKER_HOST' not set." 1>&2
  exit 127
}
[ -n "${DOCKER_TAG}" ] || {
  echo "$THIS: ERROR: 'DOCKER_TAG' not set." 1>&2
  exit 1
}

export DOCKER_HOST DOCKER_TAG

# Exit status
EXIT_STATE=0

# FIND CONTAINER ID BY TAG
DOCKER_CONTAINER_ID=$($CDIR/get-container-id.sh "${DOCKER_TAG}")

# Found container ?
if [ -z "$DOCKER_CONTAINER_ID" ]
then
  echo "$THIS: ERROR: docker not found: tag=$DOCKER_TAG." 1>&2
  exit 1
fi

# Stop and remove
: && {
  echo "docker found: tag=$DOCKER_TAG, ID=$DOCKER_CONTAINER_ID."
  [ $_stop_only_noremove -ne 0 ] &&
  echo "Stop docker-container '${DOCKER_CONTAINER_ID}'."
  [ $_stop_only_noremove -ne 0 ] ||
  echo "Stop and remove docker-container '${DOCKER_CONTAINER_ID}'."
} |
__outfilter

# Stop
: && {
  __echo_start \
  docker stop "$DOCKER_CONTAINER_ID"
  docker stop "$DOCKER_CONTAINER_ID"
  __echo_end $?
} 2>&1 |
__outfilter "STOP"

EXIT_STATE=${PIPESTATUS[0]}
test $EXIT_STATE -eq 0 || {
  exit $EXIT_STATE
}

# Remove
[ $_stop_only_noremove -ne 0 ] || {

  : && {
    __echo_start \
    docker rm "$DOCKER_CONTAINER_ID"
    docker rm "$DOCKER_CONTAINER_ID"
    __echo_end $?
  } 2>&1 |
  __outfilter "REMOVE"

  EXIT_STATE=${PIPESTATUS[0]}
  test $EXIT_STATE -eq 0 || {
    exit $EXIT_STATE
  }

}

# Complete
: && {
  [ $_stop_only_noremove -ne 0 ] &&
  echo "docker-container '${DOCKER_CONTAINER_ID}' was stopped."
  [ $_stop_only_noremove -ne 0 ] ||
  echo "docker-container '${DOCKER_CONTAINER_ID}' was removed."
} 2>&1 |
__outfilter

# end
exit 0
