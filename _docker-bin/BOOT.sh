#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)
DDIR=$(pwd)

DOCKER_HOST="${DOCKER_HOST:-tcp://127.0.0.1:4243}"
DOCKER_TAG="${DOCKER_TAG:-}"

export DOCKER_HOST DOCKER_TAG

# docker build options
DOCKER_BUILDER_OPTS=""
# docker startup(run) options
DOCKER_STARTUP_OPTS=""

# Dockerfile
[ -r "$DDIR/Dockerfile" ] && {

  SED=""
  [ -z "$SED" -a -n "$(type -P gaed)" ] &&
  SED="$(type -P gsed)"
  [ -z "$SED" -a -n "$(type -P sed)" ] &&
  SED="$(type -P sed)"
  
  eval $(cat "$DDIR/Dockerfile" |$SED -ne \
  's;^#@[ ]*\([^ =]*\)[ ]*=[ ]*\([^ ]*\)[ ]*$;echo \1=\2 && \1=\2;gp' \
  ) 2>/dev/null

} || :

# docker container ID
DOCKER_CONTAINER_ID=""

# BOOT options
__docker_build_only=0
_in_docker_ext_opts=0
_check_process_name=""

# Parsing an options
while [ $# -gt 0 ]
do
  if [ $_in_docker_run_opts -eq 0 ]
  then
    case "$1" in
    -b|-build*|--build*)
      __docker_build_only=1
      ;;
    -p|-proc*|--proc*)
      _check_process_name="$2"
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
      if [ -z "$DOCKER_TAG" ]
      then
        DOCKER_TAG="$1"
      fi
      ;;
    esac
  else
    case "$1" in
    -X[Ee])
      _in_docker_ext_opts=0
      ;;
    *)
      [ $_in_docker_ext_opts -eq 1 ] &&
      DOCKER_BUILDER_OPTS=$(echo ${DOCKER_BUILDER_OPTS} $1)
      [ $_in_docker_ext_opts -eq 2 ] &&
      DOCKER_STARTUP_OPTS=$(echo ${DOCKER_STARTUP_OPTS} $1)
      ;;
    esac
  fi
  shift
done

[ -n "${DOCKER_HOST}" ] || {
  echo "$THIS: ERROR: 'DOCKER_HOST' not set." 1>&2
  exit 127
}

[ -n "${DOCKER_TAG}" ] || {
  echo "$THIS: ERROR: 'DOCKER_TAG' not set." 1>&2
  exit 127
}

export DOCKER_HOST DOCKER_TAG

# Exit status
EXIT_STATE=0

# Build and run
: && {

  DOCKER_CONTAINER_ID=$($CDIR/get-container-id.sh "${DOCKER_TAG}")

  if [ -z "$DOCKER_CONTAINER_ID" ]
  then

    echo "$THIS: docker not found."
    echo "$THIS: docker build and run: tag='${DOCKER_TAG}'."

    cd "${DDIR:-.}" && {

      echo "$THIS: BUILD: START." &&
      echo "$THIS: BUILD: docker build -t ${DOCKER_TAG} ${DOCKER_BUILDER_OPTS} ." &&
      docker build -t "${DOCKER_TAG}" ${DOCKER_BUILDER_OPTS} . 2>&1 |
      while read stdoutln
      do
        echo "$THIS: BUILD: $stdoutln"
      done &&
      echo "$THIS: BUILD: END."

    } && {

      [ $__docker_build_only -ne 0 ] || {
      
        echo "$THIS: RUN: START." &&
        echo "$THIS: RUN: docker run -P -d ${DOCKER_STARTUP_OPTS} ${DOCKER_TAG}" &&
        docker run -P -d ${DOCKER_STARTUP_OPTS} "${DOCKER_TAG}" 2>&1 |
        while read stdoutln
        do
          echo "$THIS: RUN: $stdoutln"
        done &&
        echo "$THIS: RUN: END."
      
      }

    }

    EXIT_STATE=$?

  else

    echo "$THIS: docker found: tag=$DOCKER_TAG, ID=$DOCKER_CONTAINER_ID."
    EXIT_STATE=0

  fi # if [ -z "$DOCKER_CONTAINER_ID" ]

}

# Checking exit status
[ $EXIT_STATE -eq 0 ] &&
DOCKER_CONTAINER_ID=$($CDIR/get-container-id.sh "${DOCKER_TAG}")
[ $EXIT_STATE -eq 0 ] ||
DOCKER_CONTAINER_ID=""

# Checking build only mode
[ $__docker_build_only -ne 0 ] &&
DOCKER_CONTAINER_ID="" || :

# Print ports
[ -n "$DOCKER_CONTAINER_ID" ] && {

  echo "$THIS: DOCKER ID=$DOCKER_CONTAINER_ID was started."

  docker port "$DOCKER_CONTAINER_ID" 2>/dev/null |
  while read stdoutln
  do
    echo "$THIS: DOCKER ID=$DOCKER_CONTAINER_ID: portmap $stdoutln"
  done

}

# Check running process
[ -n "$DOCKER_CONTAINER_ID" ] &&
[ -n "$_check_process_name" ] && {

  retry_cnt=0 
  retryover=1

  sleep 1s

  echo "$THIS: DOCKER ID=$DOCKER_CONTAINER_ID: Check the status of the process '$_check_process_name'."

  while [ $retry_cnt -le 5 ]
  do
    _proc_cnt=$(
      docker top "$DOCKER_CONTAINER_ID" |
      grep "$_check_process_name" |wc -l 2>/dev/null )
    [ -n "$_proc_cnt" ] &&
    [ $_proc_cnt -ge 1 ] 1>/dev/null 2>&1 && {
      echo "$THIS: DOCKER ID=$DOCKER_CONTAINER_ID: process ($_check_process_name) was started."
      retryover=0
      break
    }
    retry_cnt=$(expr $retry_cnt + 1 2>/dev/null)
    echo "$THIS: DOCKER ID=$DOCKER_CONTAINER_ID: Wait for the process ($_check_process_name) to start ($retry_cnt/5)."
    sleep 5s 
  done

  if [ $retryover -ne 0 ]
  then
    echo "$THIS: DOCKER ID=$DOCKER_CONTAINER_ID: Wait for the process ($_check_process_name) to start -> give up."
  fi

} # [ -n "$DOCKER_CONTAINER_ID" ] && [ -n "$_check_process_name" ]

# end
exit $EXIT_STATE
