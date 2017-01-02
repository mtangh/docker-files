#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

DOCKER_HOST="${DOCKER_HOST:-tcp://127.0.0.1:4243}"
export DOCKER_HOST

# docker-bin functions
. $CDIR/_docker-functions.sh 1>/dev/null 2>&1 ||
  exit 127

# docker container name 
DOCKER_CONTAINER=""
# docker container image tag
DOCKER_IMAGE_TAG=""
# docker build options
DOCKER_BUILDOPTS=""
# docker startup(run) options
DOCKER_BOOT_OPTS=""
# check boot up
CONFIRM_BOOT_CMD=""
# Not boot
DEFAULT_NOT_BOOT=""

# Dockerfile PATH
__docker_build_path=""
# Dockerfile Work dir
__docker_build_wdir=""
# Dockerfile name
__docker_build_file=""

# docker container ID
_docker_containerid=""
# docker instance NAME
_docker_object_name=""
# docker image TAG
_docker_c_image_tag=""

# Build and run parameters
_docker_c_buildopts=""
_docker_c_boot_opts=""

# Build and run parameters
_docker_stop_and_rm=0
_docker_not_running=0
_confirm_start_cmnd=""

# Flags
_in_docker_ext_opts=0

# Parsing an options
while [ $# -gt 0 ]
do
  [ $_in_docker_ext_opts -eq 0 ] &&
  case "$1" in
  -f*)
    if [ -n "${1##*-f}" ]
    then __docker_build_path="${1##*-f}"
    elif [ -n "$2" ]
    then __docker_build_path="$2"; shift
    fi
    ;;
  --tag*)
    if [ -n "${1##*--tag=}" ]
    then _docker_c_image_tag="${1##*--tag=}"
    elif [ -n "$2" ]
    then _docker_c_image_tag="$2"; shift
    fi
    ;;
  --name*)
    if [ -n "${1##*--name=}" ]
    then _docker_object_name="${1##*--name=}"
    elif [ -n "$2" ]
    then _docker_object_name="$2"; shift
    fi
    ;;
  --rebuild)
    [ $_docker_stop_and_rm -eq 0 ] &&
    _docker_stop_and_rm=1
    ;;
  --clean)
    [ $_docker_stop_and_rm -eq 0 ] &&
    _docker_stop_and_rm=2
    ;;
  -b|-build*|--build*)
    _docker_not_running=1
    ;;
  -c|-command*|--command*)
    _confirm_start_cmnd="$2"
    shift
    ;;
  -p|-proc*|--proc*)
    _confirm_start_cmnd="ps -ef|grep '$2'"
    shift
    ;;
  -X[Bb])
    _in_docker_ext_opts=1
    ;;
  -X[RrSs])
    _in_docker_ext_opts=2
    ;;
  -*)
    ;;
  *)
    if [ -z "$_docker_img_tagname" ]
    then
      _docker_img_tagname="$1"
    elif [ -z "$_docker_img_cntname" ]
    then
      _docker_img_cntname="$1"
    fi
    ;;
  esac
  [ $_in_docker_ext_opts -eq 0 ] ||
  case "$1" in
  -X[Ee])
    _in_docker_ext_opts=0
    ;;
  *)
    [ $_in_docker_ext_opts -eq 1 ] &&
    _docker_c_buildopts=$(echo ${_docker_c_buildopts} $1)
    [ $_in_docker_ext_opts -eq 2 ] &&
    _docker_c_boot_opts=$(echo ${_docker_c_boot_opts} $1)
    ;;
  esac
  shift
done

# Dockerfile
[ -z "$__docker_build_path" ] &&
__docker_build_path="$(pwd)/Dockerfile"
[ "${__docker_build_path}" = "${__docker_build_path##*/}" ] &&
__docker_build_path="$(pwd)/$__docker_build_path"
[ -n "${__docker_build_path}" ] &&
__docker_build_file="${__docker_build_path##*/}"
[ -n "${__docker_build_path}" ] &&
__docker_build_wdir="${__docker_build_path%/*}"

# Work dir
__docker_build_wdir=$(
  [ -n "$__docker_build_wdir" ] && cd "$__docker_build_wdir" 2>/dev/null;
  pwd)

# Docker file path
__docker_build_path="$__docker_build_wdir/$__docker_build_file"

# Verify DOCKER_HOST
[ -n "${DOCKER_HOST}" ] || {
  echo "$THIS: ERROR: 'DOCKER_HOST' not set." 1>&2
  exit 128
}

# Verify Dockerfile
[ -r "${__docker_build_path}" ] || {
  echo "$THIS: ERROR: Dockerfile '$__docker_build_path' no such file or directory." 1>&2
  exit 129
}

# FIND CONTAINER ID BY Dockerfile
[ -r "${__docker_build_path}" ] &&
[ -z "${_docker_containerid}" ] &&
_docker_containerid=$(get-container-id -f "$__docker_build_path")

# Print build file
: && {
  echo "#* Dockerfile : ${__docker_build_path}."
  echo "#* Context-Dir: ${__docker_build_wdir}."
  echo "#* Build-File : ${__docker_build_file}."
  if [ -n "$_docker_containerid" ]
  then echo "#* Container ... Found - ID='${_docker_containerid}'."
  else echo "#* Container ... Not found."
  fi
} 2>&1 |
while read stdoutln
do
  echo "$THIS: "$(echo "$stdoutln"|col -bx)
done

# Exit status
EXIT_STATE=0

# Cleanup ?
if [ -n "$_docker_containerid" ] &&
   [ $_docker_stop_and_rm -ne 0 ]
then

  __section

  # rebuild
  ( cd "$__docker_build_wdir" && {
    echo "docker stop and rm: ID='${_docker_containerid}'."
    docker-stop "${_docker_containerid}" 1>/dev/null 2>&1 &&
    echo "docker container ID='${_docker_containerid}' was stoped."
    docker rm "${_docker_containerid}" 1>/dev/null 2>&1 &&
    echo "docker container ID='${_docker_containerid}' was removed."
  } 2>&1 |
  while read stdoutln
  do
    echo "$THIS: CLEAN: "$(echo "$stdoutln"|col -bx)
  done; )

  EXIT_STATE=${PIPESTATUS[0]}

  # reset
  _docker_containerid=""

  if [ $_docker_stop_and_rm -ge 2 ]
  then
    exit $EXIT_STATE
  else
    EXIT_STATE=0
  fi

fi

# Build and run
if [ -z "$_docker_containerid" ]
then

  # Build
  __section

  ( cd "$__docker_build_wdir" && {
    __echo_start \
    docker-build -f "$__docker_build_file" ${_docker_c_buildopts} .
    docker-build -f "$__docker_build_file" ${_docker_c_buildopts} .
    __echo_end $?
  } 2>&1 |
  while read stdoutln
  do
    echo "$THIS: BUILD: "$(echo "$stdoutln"|col -bx)
  done; )

  EXIT_STATE=${PIPESTATUS[0]}
  [ $EXIT_STATE -eq 0 ] || {
    exit $EXIT_STATE
  }

  # Run
  [ $_docker_not_running -ne 0 ] || {
      
    __section

    ( cd "$__docker_build_wdir" && {
      __echo_start \
      docker-run -f "$__docker_build_path" -P -d ${_docker_c_boot_opts}
      docker-run -f "$__docker_build_path" -P -d ${_docker_c_boot_opts}
      __echo_end $?
    } 2>&1 |
    while read stdoutln
    do
      echo "$THIS: RUN: $stdoutln"
    done; )

    EXIT_STATE=${PIPESTATUS[0]}
    [ $EXIT_STATE -eq 0 ] || {
      exit $EXIT_STATE
    }

  } # [ $_docker_not_running -ne 0 ] || {

  EXIT_STATUS=0

fi # if [ -z "$_docker_containerid" ]

# Checking exit status
[ $EXIT_STATE -eq 0 ] && {
  [ -r "${__docker_build_path}" ] &&
  [ -z "${_docker_containerid}" ] &&
  _docker_containerid=$(get-container-id -f "$__docker_build_path")
}
[ $EXIT_STATE -eq 0 ] || {
  _docker_containerid=""
}

# Checking build only mode
[ $_docker_not_running -ne 0 ] && {
  _docker_containerid=""
}

# Print ports
[ -n "$_docker_containerid" ] && {

  __section

  : && {

    echo "ID '$_docker_containerid' was started."
  
    docker port "$_docker_containerid" 2>&1 |
    while read stdoutln
    do
      echo "portmap - $stdoutln"
    done

  } 2>&1 |
  while read stdoutln
  do
    echo "$THIS: $_docker_containerid: $stdoutln"
  done

}

# Check running process
[ -n "$_docker_containerid" ] &&
[ -n "$_confirm_start_cmnd" ] && {

  _retrymax=5
  _wait_for=3
  
  retry_cnt=0 
  retryover=1
  dexec_ret=1

  sleep 1s

  __section

  : && {
  
    echo "Check the status of the command '$_confirm_start_cmnd'."

    while [ $retry_cnt -le $_retrymax ]
    do
      eval $(
      echo docker exec -it "$_docker_containerid" $_confirm_start_cmnd
      ) 1>/dev/null 2>&1
      dexec_ret=$?
      [ $dexec_ret -eq 0 ] && {
        echo "SUCCESS; command=[$_confirm_start_cmnd]"
        retryover=0
        break
      }
      retry_cnt=$(expr $retry_cnt + 1 2>/dev/null)
      echo "FAILED($retry_cnt/$_retrymax); command=[$_confirm_start_cmnd], ret=[$dexec_ret]"
      sleep $_wait_for
    done

    if [ $retryover -ne 0 ]
    then
      echo "GIVE-UP; command=[$_confirm_start_cmnd]"
    fi
  
  } 2>&1 |
  while read stdoutln
  do
    echo "$THIS: $_docker_containerid: $stdoutln"
  done

} # [ -n "$_docker_containerid" ] && ...

# end
exit $EXIT_STATE
