#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

DOCKER_HOST="${DOCKER_HOST:-tcp://127.0.0.1:4243}"
DOCKER_TAG="${DOCKER_TAG:-}"

export DOCKER_HOST DOCKER_TAG

docker_tagname=""
docker_port_no=""

while [ $# -gt 0 ]
do
  case "$1" in
  -*)
    ;;
  *)
    if [ -z "${docker_tagname}" ]
    then
      if [ -n "${DOCKER_TAG}" ] &&
         expr "${1}" + 1 1>/dev/null 2>&1
      then
        docker_tagname="${DOCKER_TAG}"
        docker_port_no="$1"
      else
        docker_tagname="$1"
      fi
    elif [ -z "${docker_port_no}" ]
    then
      expr "${1}" + 1 1>/dev/null 2>&1 &&
      docker_port_no="$1"
    fi 
    ;;
  esac
  shift
done

DOCKER_CONTAINER_ID=$(
  $CDIR/get-container-id.sh "${docker_tagname}" 2>/dev/null)

[ -n "${docker_tagname}" ] || {
  echo "$THIS: ERROR: 'docker-tag' not set." 1>&2
  exit 127
}

[ -n "${docker_port_no}" ] || {
  echo "$THIS: ERROR: 'docker-port' not set." 1>&2
  exit 127
}

[ -n "$DOCKER_CONTAINER_ID" ] || {
  echo "$THIS: container '${docker_tagname}' not running." 1>&2
  exit 1
}

docker port "${DOCKER_CONTAINER_ID}" "${docker_port_no}" 2>/dev/null |
sort |
head
exit $?
