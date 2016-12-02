#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)
DDIR=$([ -n "$CDIR" ] && cd "$CDIR/../" 2>/dev/null; pwd)

DOCKER_HOST="${DOCKER_HOST:-tcp://127.0.0.1:4243}"
DOCKER_TAG="${DOCKER_TAG:-}"

export DOCKER_HOST DOCKER_TAG

# Dockerfile
[ -r "$DDIR/Dockerfile" ] && {

  eval $(
  $CDIR/get-opts-from-dockerfile.sh "$DDIR/Dockerfile"
  )

} || :

# Parse options
while [ $# -gt 0 ]
do
  case "$1" in
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

RET=0

: && {

  DOCKER_CONTAINER_ID=$($CDIR/get-container-id.sh "${DOCKER_TAG}")

  if [ -n "$DOCKER_CONTAINER_ID" ]
  then
    echo "$THIS: docker found: tag=$DOCKER_TAG, ID=$DOCKER_CONTAINER_ID." &&
    echo "$THIS: Stop and remove docker-container '${DOCKER_CONTAINER_ID}'." &&
    cd "${DDIR:-.}" 2>/dev/null && {
      docker stop $DOCKER_CONTAINER_ID 2>&1 |
      while read stdout_line
      do
        echo "$THIS: STOP: $stdout_line"
      done
    } && {
      docker rm "$DOCKER_CONTAINER_ID" 2>&1 |
      while read stdout_line
      do
        echo "$THIS: REMOVE: $stdout_line"
      done
    } &&
    echo "$THIS: docker-container '${DOCKER_CONTAINER_ID}' was removed."
    RET=$?
  else
    echo "$THIS: ERROR: docker not found: tag=$DOCKER_TAG." 1>&2
    RET=1
  fi

}

exit $RET
