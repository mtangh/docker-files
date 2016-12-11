#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

DOCKER_HOST="${DOCKER_HOST:-tcp://127.0.0.1:4243}"
export DOCKER_HOST

docker_ps_opts=""
docker_key_cnt=0
docker_out_cnt=0

imgimgtag_or_name=""

while [ $# -gt 0 ]
do
  case "$1" in
  -a*|--all)
    docker_ps_opts=$(echo ${docker_ps_opts} "-a")
    ;;
  -*)
    ;;
  *)
    if [ -n "${1}" ]
    then
      imgtag_or_name=$(echo "${imgtag_or_name}" "$1")
      docker_key_cnt=$(( $docker_key_cnt + 1 ))
    fi
    ;;
  esac
  shift
done

[ -n "$imgtag_or_name" ] &&
for key in $imgtag_or_name
do
  [ -n "$key" ] ||
    continue
  containerid=$(
    docker ps $docker_ps_opts --format='{{.ID}} {{.Image}} {{.Names}}' |
    grep -E '[ ]'"${key}"'([ ].*|$)' |
    awk '{print($1)}'
  ) 2>/dev/null
  if [ -n "$containerid" ]
  then
    [ $docker_key_cnt -le 1 ] &&
    echo "$containerid"
    [ $docker_key_cnt -le 1 ] ||
    echo "$containerid" "$key"
    docker_out_cnt=$(( $docker_out_cnt + 1 ))
  fi
done

[ $docker_out_cnt -ge 1 ]
exit $?
