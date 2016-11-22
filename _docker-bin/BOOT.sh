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

  eval $(
  $CDIR/get-opts-from-dockerfile.sh "$DDIR/Dockerfile"
  )
  
  # Build only
  [ -n "$CONTAINER_NOT_START" ] &&
  _docker_not_running=1

  # Confirm startup
  [ -n "$CONFIRM_STARTUP_CMD" ] &&
  _confirm_start_cmnd="$CONFIRM_STARTUP_CMD"

} || :

# docker container ID
DOCKER_CONTAINER_ID=""

# BOOT options
_docker_not_running=0
_confirm_start_cmnd=""

# Flags
_in_docker_ext_opts=0

# Parsing an options
while [ $# -gt 0 ]
do
  if [ $_in_docker_run_opts -eq 0 ]
  then
    case "$1" in
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

# FIND CONTAINER ID BY TAG
DOCKER_CONTAINER_ID=$($CDIR/get-container-id.sh "${DOCKER_TAG}")

# Build and run
if [ -z "$DOCKER_CONTAINER_ID" ]
then

  echo "$THIS: docker container not found."
  echo "$THIS: docker build and run: tag='${DOCKER_TAG}'."

  cd "${DDIR:-.}" && {

    : && {
      echo "START." &&
      echo "docker build -t ${DOCKER_TAG} ${DOCKER_BUILDER_OPTS} ." &&
      docker build -t "${DOCKER_TAG}" ${DOCKER_BUILDER_OPTS} . ||
      echo "ERROR OCCURED; ret($?)."
      echo "END."
    } 2>&1 |
    while read stdoutln
    do
      echo "$THIS: BUILD: $stdoutln"
    done

  } && {

    [ $_docker_not_running -ne 0 ] || {
      
      : && {
        echo "START." &&
        echo "docker run -P -d ${DOCKER_STARTUP_OPTS} ${DOCKER_TAG}" &&
        docker run -P -d ${DOCKER_STARTUP_OPTS} "${DOCKER_TAG}" ||
        echo "ERROR OCCURED; ret($?)."
        echo "END."
      } 2>&1 |
      while read stdoutln
      do
        echo "$THIS: RUN: $stdoutln"
      done
      
    } # [ $_docker_not_running -ne 0 ] || {

  }

  EXIT_STATE=$?

else

  echo "$THIS: docker container found."
  echo "$THIS:  Tag: $DOCKER_TAG"
  echo "$THIS:  ID : $DOCKER_CONTAINER_ID"
  EXIT_STATE=0

fi # if [ -z "$DOCKER_CONTAINER_ID" ]

# Checking exit status
[ $EXIT_STATE -eq 0 ] &&
DOCKER_CONTAINER_ID=$($CDIR/get-container-id.sh "${DOCKER_TAG}")
[ $EXIT_STATE -eq 0 ] ||
DOCKER_CONTAINER_ID=""

# Checking build only mode
[ $_docker_not_running -ne 0 ] &&
DOCKER_CONTAINER_ID="" || :

# Print ports
[ -n "$DOCKER_CONTAINER_ID" ] && {

  echo "$THIS: $DOCKER_CONTAINER_ID: ID '$DOCKER_CONTAINER_ID' was started."
  
  docker port "$DOCKER_CONTAINER_ID" 2>/dev/null |
  while read stdoutln
  do
    echo "$THIS: $DOCKER_CONTAINER_ID: portmap $stdoutln"
  done

} # [ -n "$DOCKER_CONTAINER_ID" ] && {

# Check running process
[ -n "$DOCKER_CONTAINER_ID" ] &&
[ -n "$_confirm_start_cmnd" ] && {

  _retrymax=5
  _wait_for=3
  
  retry_cnt=0 
  retryover=1
  dexec_ret=1

  sleep 1s

  : && {
  
    echo "Check the status of the command '$_confirm_start_cmnd'."

    while [ $retry_cnt -le $_retrymax ]
    do
      docker exec \
        "$DOCKER_CONTAINER_ID" "$_confirm_start_cmnd" 1>/dev/null 2>&1
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
    echo "$THIS: $DOCKER_CONTAINER_ID: $stdoutln"
  done

} # [ -n "$DOCKER_CONTAINER_ID" ] && ...

# end
exit $EXIT_STATE
