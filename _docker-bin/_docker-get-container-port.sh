#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

DOCKER_HOST="${DOCKER_HOST:-tcp://127.0.0.1:4243}"
export DOCKER_HOST

imgtag_or_name=""
t_container_id=""
docker_port_no=""

while [ $# -gt 0 ]
do
  case "$1" in
  -id)
    if [ -n "${1##*-id}" ]
    then
      t_container_id="${1##*-id}"
    elif [ -n "$2" ]
    then
      t_container_id="${2}"
      shift
    fi
    ;;
  -*)
    ;;
  *)
    if [ -z "${imgtag_or_name}" ]
    then
      if expr "${1}" + 1 1>/dev/null 2>&1
      then
        docker_port_no="$1"
      else
        imgtag_or_name="$1"
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

[ -n "$imgtag_or_name" ] &&
[ -z "$t_container_id" ] && {
  t_container_id=$(
  $CDIR/_docker-get-container-id.sh "${imgtag_or_name}" 2>/dev/null)
}

[ -n "${t_container_id}" ] && {
  docker port "${t_container_id}" "$docker_port_no" 2>/dev/null |
  while read docker_portmap 
  do
    [ -n "$docker_port_no" ] &&
    echo "${docker_portmap##*:}"
    [ -n "$docker_port_no" ] ||
    echo "${docker_portmap##*:}" ${docker_portmap%->*}
  done | sort -u
}

exit $?
