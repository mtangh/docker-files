#!/bin/bash -u
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}" 2>/dev/null; pwd)

# Docker HOST
DOCKER_HOST="${DOCKER_HOST:-tcp://127.0.0.1:4243}"
export DOCKER_HOST

# docker-bin functions
. "${CDIR}/docker-make_funcs.sh" 1>/dev/null 2>&1 || {
  exit 127
}

# docker container name
DOCKER_CONTAINER=""
# docker container image path
DOCKER_IMAGEPATH=""
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
_docker_c_image_ent=""
_docker_rebuild_obj=0
_docker_cleanuponly=0
_docker_not_running=0
_confirm_start_cmnd=""

# Flags
_in_docker_ext_opts=0

# Options
_get_options_params="
f|file:=__docker_build_path
|tag:=_docker_c_image_tag
|name:=_docker_object_name
b|build-only=_docker_not_running
|rebuild=_docker_rebuild_obj
|clean=_docker_cleanuponly
c|command:=_confirm_start_cmnd
p|proc:=_confirm_start_cmnd
"
# Parsing an options
eval $(getoptions "${_get_options_params}" $@)
# Get options
while getoptions_has_next
do
  eval $(getoptions_shift)
  [ ${_in_docker_ext_opts} -eq 0 ] &&
  case "${_getopt_V:=}" in
  -X[Bb])
    _in_docker_ext_opts=1
    ;;
  -X[RrSs])
    _in_docker_ext_opts=2
    ;;
  -*)
    ;;
  *)
    if [ -z "${_docker_img_tagname}" ]
    then _docker_img_tagname="${_getopt_V}"
    elif [ -z "${_docker_img_cntname}" ]
    then _docker_img_cntname="${_getopt_V}"
    fi
    ;;
  esac
  [ ${_in_docker_ext_opts} -eq 0 ] ||
  case "${_getopt_V:=}" in
  -X[Ee])
    _in_docker_ext_opts=0
    ;;
  *)
    if [ ${_in_docker_ext_opts} -eq 1 ]
    then
      _docker_c_buildopts="${_docker_c_buildopts:+${_docker_c_buildopts} }"
      _docker_c_buildopts="${_docker_c_buildopts:-}${_getopt_V}"
    elif [ ${_in_docker_ext_opts} -eq 2 ]
    then
      _docker_c_boot_opts="${_docker_c_boot_opts:+${_docker_c_boot_opts} }"
      _docker_c_boot_opts="${_docker_c_boot_opts:-}${_getopt_V}"
    fi
    ;;
  esac
done
eval $(getoptions_end)

# Dockerfile
__docker_build_path=$(dockerfile-get-path "${__docker_build_path}")
[ -n "${__docker_build_path}" ] &&
__docker_build_file="${__docker_build_path##*/}"
[ -n "${__docker_build_path}" ] &&
__docker_build_wdir="${__docker_build_path%/*}"

# Verify DOCKER_HOST
[ -n "${DOCKER_HOST}" ] || {
  echo "$THIS: ERROR: 'DOCKER_HOST' not set." 1>&2
  exit 128
}

# Verify Dockerfile
[ -r "${__docker_build_path}" ] || {
  echo "$THIS: ERROR: Dockerfile '${__docker_build_path}' no such file or directory." 1>&2
  exit 129
}

# Print build file
: && {
  cat <<_EOM_
#* Pwd        : $(pwd).
#* Dockerfile : ${__docker_build_path}.
#* Context-Dir: ${__docker_build_wdir}.
#* Build-File : ${__docker_build_file}.
_EOM_
} |__stdout_with_ts ""

# FIND CONTAINER IDs BY Dockerfile
[ -r "${__docker_build_path}" ] && {

: && {
  cat <<_EOM_
#* Built Images >>>
_EOM_
} |__stdout_with_ts ""

  # Each images
  for _docker_c_image_ent in $(dockerfile-imagetag-get "" "${__docker_build_path}")
  do

    # Reset container ID
    _docker_containerid=""

    [ -n "${_docker_c_image_ent}" ] && {

      container-image-is-runnable "${_docker_c_image_ent}" -f "${__docker_build_path}"

      if [ $? -eq 0 ]
      then
        _docker_containerid=$(
          container-get-id-last -f "${__docker_build_path}" \
          "${_docker_c_image_ent}")
        echo "#* + ${_docker_c_image_ent} (Runnable)"
        if [ -n "${_docker_containerid}" ]
        then echo "#*   - Container ... Found - ID='${_docker_containerid}'."
        else echo "#*   - Container ... Not found."
        fi
      else
        echo "#* + ${_docker_c_image_ent} (Not Runnable)"
      fi

      # Cleanup ?
      if [ -n "${_docker_containerid}" ] &&
         [ ${_docker_rebuild_obj} -ne 0 -o ${_docker_cleanuponly} -ne 0 ]
      then

        # rebuild
        ( cd "${__docker_build_wdir}" && {
          echo "#*     docker stop and rm: ID='${_docker_containerid}'."
          docker-stop "${_docker_containerid}" 1>/dev/null 2>&1 &&
          echo "#*     docker container ID='${_docker_containerid}' was stoped."
          docker rm "${_docker_containerid}" 1>/dev/null 2>&1 &&
          echo "#*     docker container ID='${_docker_containerid}' was removed."
        }; )

        # Cleanup status
        EXIT_STATE=$?

        # Cleanup only ?
        [ ${_docker_cleanuponly} -eq 0 ] || {
          exit ${EXIT_STATE}
        }

      fi

    } || :
  done 1> >(__stdout_with_ts "") 2>&1

} || :

# Build and run
if [ -z "${_docker_containerid}" ]
then

  # Reset status
  EXIT_STATE=0

  # Push dir
  pushd "${__docker_build_wdir}" 1>/dev/null 2>&1 || :

  # Separator
  __section

  # Build
  : && {

    if [ -s "./${__docker_build_file}.build" ]
    then
      cat <<_EOM_
Found file './${__docker_build_path}.build'.
Build the file './${__docker_build_path}.build' first.
_EOM_
      __echo_start \
      docker-build --stage-all -f "./${__docker_build_file}.build" ${_docker_c_buildopts} .
      docker-build --stage-all -f "./${__docker_build_file}.build" ${_docker_c_buildopts} .
      __echo_end $?
    else :
    fi &&
    __echo_start \
    docker-build --stage-all -f "${__docker_build_file}" ${_docker_c_buildopts} .
    docker-build --stage-all -f "${__docker_build_file}" ${_docker_c_buildopts} .
    __echo_end $?

  } 1> >(__stdout_with_ts "BUILD") 2>&1

  # Build status
  EXIT_STATE=$?

  # Has error ?
  [ ${EXIT_STATE} -eq 0 ] || {
    exit ${EXIT_STATE}
  }

  # Pop dir
  popd 1>/dev/null 2>&1 || :

  # Run
  [ ${_docker_not_running} -ne 0 ] || {

    # Push dir
    pushd "${__docker_build_wdir}" 1>/dev/null 2>&1 || :

    # Each images
    for _docker_c_image_ent in $(dockerfile-imagetag-get "" "${__docker_build_path}")
    do

      # Reset status
      EXIT_STATE=0

      # Container ID
      _docker_containerid=""

      # Runnable ?
      [ -n "${_docker_c_image_ent}" ] &&
      container-image-is-runnable "${_docker_c_image_ent}" -f "${__docker_build_path}" && {

        # Separator
        __section

        # Image
        echo "Image=${_docker_c_image_ent}"

        # Run
        : && {
          __echo_start \
          docker-run "${_docker_c_image_ent}" -f "${__docker_build_path}" ${_docker_c_boot_opts}
          docker-run "${_docker_c_image_ent}" -f "${__docker_build_path}" ${_docker_c_boot_opts}
          __echo_end $?
        }

        # Running status
        EXIT_STATE=$?

        # Has error ?
        [ ${EXIT_STATE} -eq 0 ] || {
          exit ${EXIT_STATE}
        }

        # Checking build only mode
        [ ${_docker_not_running} -eq 0 -a -r "${__docker_build_path}" ] && {
          _docker_containerid=$(
            container-get-id-last -f "${__docker_build_path}" \
            "${_docker_c_image_ent}")
          _confirm_start_cmnd=$(
            container-image-property_CONFIRM-STARTUP -f "${__docker_build_path}" \
            "${_docker_c_image_ent}")
        }

        # Portmap
        [ -n "${_docker_containerid}" ] && {

          # Separator
          __section

          # Print ports
          : && {
            # Start
            __echo_start
            # Print
            echo "ID '${_docker_containerid}' was started."
            # Print portmap
            docker port "${_docker_containerid}" |
            ${AWK} '{printf("portmap - %s\n",$0);}'
            # End
            __echo_end $?
          }

        } # [ -n "${_docker_containerid}" ]

        # Check running process
        [ -n "${_docker_containerid}" -a -n "${_confirm_start_cmnd}" ] && {

          _retrymax=5
          _wait_for=3

          retry_cnt=0
          retryover=1
          dexec_ret=1

          # Interval
          sleep 1s

          # Separator
          __section

          # Check the status of the command
          : && {

            # Start
            __echo_start
            # Print
            echo "Check the status of the command '${_confirm_start_cmnd}'."
            # Check
            while [ ${retry_cnt} -le ${_retrymax} ]
            do
              eval $(
              echo docker exec -it "${_docker_containerid}" ${_confirm_start_cmnd}
              ) 1>/dev/null 2>&1
              # Status of docker exec
              dexec_ret=$?
              # Check the status of docker-exec
              [ ${dexec_ret} -eq 0 ] && {
                echo "SUCCESS; command=[${_confirm_start_cmnd}]"
                retryover=0
                break
              }
              # Decrement retry counter
              retry_cnt=$(expr ${retry_cnt} + 1 2>/dev/null)
              # Print
              echo "FAILED(${retry_cnt}/${_retrymax}); command=[${_confirm_start_cmnd}], ret=[${dexec_ret}]"
              # Retry count over ?
              if [ ${retryover} -ne 0 ]
              then echo "GIVE-UP; command=[${_confirm_start_cmnd}]"
              else sleep ${_wait_for}
              fi
            done
            # End
            __echo_end 0

          }

        } # [ -n "${_docker_containerid}" -a ...

      } || :

    done 1> >(__stdout_with_ts "RUN") 2>&1

    # Pop dir
    popd 1>/dev/null 2>&1 || :

  } # [ ${_docker_not_running} -ne 0 ] || {

fi # if [ -z "${_docker_containerid}" ]

# end
exit ${EXIT_STATE}
# vim: set ff=unix ts=2 sw=2 sts=2 et : This line is VIM modeline
