#!/bin/bash -u
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}" 2>/dev/null; pwd)

# Docker HOST
DOCKER_HOST="${DOCKER_HOST:-tcp://127.0.0.1:4243}"
export DOCKER_HOST

# docker-bin functions
. "${CDIR}/docker-make_funcs.sh" 1>/dev/null 2>&1 || {
  exit 2
}

# docker container name
DOCKER_CONTAINER=""
# docker container image path
DOCKER_IMAGEPATH=""
# Specify docker build command options.
DOCKER_BUILDOPTS=""
# Specify docker run command options.
DOCKER_BOOT_OPTS=""
# Specify the docker image to publish.
DOCKER_PUBLISHED=""
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
# Number of stages
__docker_num_of_stg=0

# docker container ID
_docker_containerid=""
# docker container ID list
_docker_contid_list=""
# docker image TAG
_docker_img_tagname=""
# docker instance NAME
_docker_img_cntname=""

# Build and run parameters
_docker_c_buildopts=""
_docker_c_boot_opts=""

# Build and run parameters
_docker_c_image_ent=""
_docker_target_arch=""
_docker_rebuild_obj=0
_docker_cleanuponly=0
_docker_not_running=0
_docker_run_command=""
_confirm_start_cmnd=""
_logging_std_output=0

# Flags
_in_docker_ext_opts=0

# Options
_get_options_params="
f|file:=__docker_build_path
|tag:=_docker_img_tagname
|name:=_docker_img_cntname
b|build-only=_docker_not_running
|rebuild=_docker_rebuild_obj
P|platform:=_docker_target_arch
c|command:=_docker_run_command
p|proc:=_confirm_start_cmnd
|with-log=_logging_std_output
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
  echo "${THIS}: ERROR: 'DOCKER_HOST' not set." 1>&2
  exit 113
}

# Verify Dockerfile
[ -r "${__docker_build_path}" ] || {
  echo "${THIS}: ERROR: Dockerfile '${__docker_build_path}' no such file or directory." 1>&2
  exit 2
} && {
  __docker_num_of_stg=$(
    dockerfile-num-of-stage "${__docker_build_path}" 2>/dev/null; )
}

# Verify Tag name if specified
if [ -n "${_docker_img_tagname}" ]
then
  dockerfile-imagepath-get "" "${__docker_build_path}" |
  egrep '^'"${_docker_img_tagname}"'$' 1>/dev/null 2>&1 || {
    echo "${THIS}: ERROR: Tag '${_docker_img_tagname}' not found in Dockerfile '${__docker_build_path}'." 1>&2
    exit 22
  }
else
  if [ -n "${_docker_img_cntname}" ] &&
     [ ${__docker_num_of_stg:-0} -gt 1 ]
  then
    echo "${THIS}: ERROR: Name '${_docker_img_cntname}' was specified in a multi-stage build. However, the tag is unspecified." 1>&2
    exit 22
  fi
fi

# Logging
if [ ${_logging_std_output:-0} -ne 0 ]
then
  _make_log_file_name="$(date +'%Y%m%dT%H%M%S').log"
  exec 1> >(tee -a "${_make_log_file_name}") 2>&1
fi

# Reset status
EXIT_STATE=0

# First section
dmf_section && {

  dmf_proc_start "${_docker_not_running:-0}"

cat <<_EOM_
#*
#* Pwd          : $(pwd)
#* Dockerfile   : ${__docker_build_path}
#* Context-Dir  : ${__docker_build_wdir}
#* Build-File   : ${__docker_build_file}
#* Target-Image : ${_docker_img_tagname:--}
#* Target-ARCH  : ${_docker_target_arch:--}
#* Instance-Name: ${_docker_img_cntname:--}
#*
_EOM_

  # Push dir
  pushd "${__docker_build_wdir}" 1>/dev/null 2>&1 || :

} 1> >(dmf_stdout_with_ts) 2>&1

# Section "IMG"
dmf_section "IMG" && {

cat <<_EOM_
The image to build is as follows:
_EOM_

  # Each images
  for _docker_c_image_ent in $(
    if [ -z "${_docker_img_tagname}" ]
    then dockerfile-imagepath-get "" "${__docker_build_path}"
    else echo "${_docker_img_tagname}"
    fi 2>/dev/null; )
  do

    # Reset container ID
    _docker_containerid=""

    # Have an Image ?
    [ -n "${_docker_c_image_ent}" ] ||
    continue

    # Image is runnable ?
    container-image-is-runnable "${_docker_c_image_ent}" -f "${__docker_build_path}"
    # Runnable ?
    if [ $? -eq 0 ]
    then
      _docker_containerid=$(
        container-get-id-last -f "${__docker_build_path}" \
        "${_docker_c_image_ent}")
      echo " ${_docker_c_image_ent} (Runnable)"
      if [ -n "${_docker_containerid}" ]
      then echo "#*   - Container ... Found - ID='${_docker_containerid}'."
      else echo "#*   - Container ... Not found."
      fi
    else
      echo " ${_docker_c_image_ent} (Not Runnable)"
    fi

    # Container ID list
    if [ -n "${_docker_containerid}" ]
    then
      _docker_contid_list="${_docker_contid_list:+${_docker_contid_list} }"
      _docker_contid_list="${_docker_contid_list}${_docker_containerid}"
    else :
    fi

  done

  echo

} 1> >(dmf_stdout_with_ts "IMG") 2>&1

# Section "BUILD"
dmf_section "BUILD" && {

  _docker_tmp_options=""
  [ -z "${_docker_target_arch:-}" ] || {
    _docker_tmp_options="${_docker_tmp_options:+${_docker_tmp_options} }"
    _docker_tmp_options="${_docker_tmp_options}--platform=${_docker_target_arch}"; }
  [ -z "${_docker_c_buildopts:-}" ] || {
    _docker_tmp_options="${_docker_tmp_options+${_docker_tmp_options} }"
    _docker_tmp_options="${_docker_tmp_options}${_docker_c_buildopts}"; }

  if [ -s "./${__docker_build_file}.build" ]
  then
cat <<_EOM_
Found file './${__docker_build_path}.build'.
Build the file './${__docker_build_path}.build' first.
_EOM_
    dmf_invoke \
    docker-build --for-each-stage -f "${__docker_build_file}.build" ${_docker_tmp_options}
  else :
  fi &&
  : "Build" && {
    dmf_invoke \
    docker-build --for-each-stage -f "${__docker_build_file}" ${_docker_tmp_options} .  &&
    unset _docker_tmp_options
  }

} 1> >(dmf_stdout_with_ts "BUILD") 2>&1

# Section "RUN"
[ ${_docker_not_running:-0} -eq 0 ] &&
dmf_section "RUN" && {

  # Stop and remove
  if [ ${_docker_rebuild_obj:-0} -ne 0 ] &&
     [ -n "${_docker_contid_list:-}" ]
  then

    _docker_status_temp=0

    dmf_echo_start

    for _docker_contid_temp in ${_docker_contid_list}
    do
      [ -n "${_docker_contid_temp:-}" ] ||
      continue
      # Stop and remove
      ( cd "${__docker_build_wdir}" && {
        echo "[${_docker_contid_temp}] docker stop and rm."
        dockre-stop "${_docker_contid_temp}" 1>/dev/null 2>&1 &&
        echo "[${_docker_contid_temp}] docker container was stoped."
        docker-rm "${_docker_contid_temp}" 1>/dev/null 2>&1 &&
        echo "[${_docker_contid_temp}] docker container was removed."
      }; ) || {
        _docker_status_temp=$?
        break
      }
    done

    dmf_echo_end ${_docker_status_temp:-1}
    unset _docker_status_temp

  else :
  fi

  # Each images
  for _docker_c_image_ent in $(
    if [ -z "${_docker_img_tagname}" ]
    then dockerfile-imagepath-get "" "${__docker_build_path}"
    else echo "${_docker_img_tagname}"
    fi 2>/dev/null; )
  do

    # Stage
    _docker_stage_alias=$(
      echo "${_docker_c_image_ent}" |
      ${AWK} -F: '{print($2);}' 2>/dev/null; )

     # Container ID
    _docker_containerid=""

    # Image
    [ -z "${_docker_c_image_ent}" ] || {

      # Runnable ?
      container-image-is-runnable \
      "${_docker_c_image_ent}" -f "${__docker_build_path}" || {
        echo "Not runnable"
        continue
      }

      # Image
      echo "Image: name:tag=${_docker_c_image_ent}"
      echo "Stage=[${_docker_stage_alias}]"

      # Run
      : "docker-run" && {
        _docker_tmp_options=""
        [ -n "${_docker_img_cntname:-}" ] &&
        [ -n "${_docker_img_tagname}" -o ${__docker_num_of_stg:-} -le 1 ] && {
          _docker_tmp_options="${_docker_tmp_options:+${_docker_tmp_options} }"
          _docker_tmp_options="${_docker_tmp_options}--name=${_docker_img_cntname}"; } || :
        [ -z "${_docker_c_boot_opts:-}" ] || {
          _docker_tmp_options="${_docker_tmp_options:+${_docker_tmp_options} }"
          _docker_tmp_options="${_docker_tmp_options}${_docker_c_boot_opts}"; }
        [ -z "${_docker_run_command:-}" ] || {
          _docker_tmp_options="${_docker_tmp_options:+${_docker_tmp_options} }"
          _docker_tmp_options="${_docker_tmp_options}-- ${_docker_run_command}"; }
        dmf_invoke \
        docker-run -f "${__docker_build_file}" "${_docker_c_image_ent}" ${_docker_tmp_options} &&
        unset _docker_tmp_options
      }

      # Container ID
      _docker_containerid=$(
        container-get-id-last -f "${__docker_build_path}" \
        "${_docker_c_image_ent}")

      # Print ports
      if [ -n "${_docker_containerid}" ]
      then

        : "port" && {
          # Start
          dmf_echo_start
          # Print
          echo "ID '${_docker_containerid}' was started."
          # Print portmap
          ${DOCKER_CMD} port "${_docker_containerid}" |
          ${AWK} '{printf("portmap - %s\n",$0);}'
          # End
          dmf_echo_end $?
        }

      else
        echo "Not running."
      fi

    } 1> >(dmf_stdout "${_docker_stage_alias}") 2>&1

  done

} 1> >(dmf_stdout_with_ts "RUN") 2>&1 || :

# Section "CHK"
[ ${_docker_not_running:-0} -eq 0 ] &&
dmf_section "CHK" && {
	  
  # Retry and interval
  _retrymax=5
  _wait_for=3

  # Interval
  sleep 1s

  # Each images
  for _docker_c_image_ent in $(
    if [ -z "${_docker_img_tagname}" ]
    then dockerfile-imagepath-get "" "${__docker_build_path}"
    else echo "${_docker_img_tagname}"
    fi 2>/dev/null; )
  do

    # Stage
    _docker_stage_alias=$(
      echo "${_docker_c_image_ent}" |
      ${AWK} -F: '{print($2);}' 2>/dev/null; )

	  # Container ID
    _docker_containerid=""

    # Confirm
    _confirm_start_cmnd=""

    # retry
    retry_cnt=0
    retryover=1
    dexec_ret=1

    # Runnable ?
    [ -n "${_docker_c_image_ent}" ] ||
    continue
    container-image-is-runnable \
    "${_docker_c_image_ent}" -f "${__docker_build_path}" || {
      echo
      continue
    }

    # Checking build only mode
    _docker_containerid=$(
      container-get-id-last -f "${__docker_build_path}" \
      "${_docker_c_image_ent}")
    _confirm_start_cmnd=$(
      container-image-property_CONFIRM-STARTUP -f "${__docker_build_path}" \
      "${_docker_c_image_ent}")

    # Check running process ?
    [ -n "${_docker_containerid}" -a \
      -n "${_confirm_start_cmnd}" ] && {

      # Start
      dmf_echo_start
      # Print
      echo "Check the status of the command '${_confirm_start_cmnd}'."
      # Check
      while [ ${retry_cnt} -le ${_retrymax} ]
      do
        eval $(
        echo ${DOCKER_CMD} exec -it "${_docker_containerid}" ${_confirm_start_cmnd}
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
      dmf_echo_end 0

    } 1> >(dmf_stdout "${_docker_stage_alias}") 2>&1 || :

  done

} 1> >(dmf_stdout_with_ts "CHK") 2>&1 || :

# End section
dmf_section && {

  # Pop dir
  popd 1>/dev/null 2>&1 || :

  # echo exit
  dmf_proc_exit ${EXIT_STATE:-1}

} 1> >(dmf_stdout_with_ts "") 2>&1

# end
exit ${EXIT_STATE:-1}
# vim: set ff=unix ts=2 sw=2 sts=2 et : This line is VIM modeline
