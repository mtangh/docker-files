#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

DOCKER_HOST="${DOCKER_HOST:-tcp://127.0.0.1:4243}"
DOCKER_TAG="${DOCKER_TAG:-}"

export DOCKER_HOST DOCKER_TAG

docker_tagname=""
docker_ps_opts=""

docker_tag_cnt=0

while [ $# -gt 0 ]
do
  case "$1" in
  -a|--all)
    docker_ps_opts="-a"
    ;;
  -*)
    ;;
  *)
    if [ -n "${1}" ]
    then
      docker_tagname="${docker_tagname} $1"
      docker_tag_cnt=$(( $docker_tag_cnt + 1 ))
    fi
    ;;
  esac
  shift
done

[ -n "${docker_tagname}" ] || {
  docker_tagname="${DOCKER_TAG}"
}

[ -n "${docker_tagname}" ] || {
  echo "$THIS: ERROR: 'docker-tag' not set." 1>&2
  exit 127
}

for tag_name in $docker_tagname
do
  [ -z "$tag_name" ] &&
    continue
  dockerid=$(
    docker ps $docker_ps_opts |
    grep -E '[ \t]'"${docker_tagname}"'[ \t]' |
    awk '{print($1)}' ) 2>/dev/null
  [ $docker_tag_cnt -le 1 ] &&
  [ -z "$dockerid" ] &&
    break
  echo "${dockerid:--}"
done

exit $?
