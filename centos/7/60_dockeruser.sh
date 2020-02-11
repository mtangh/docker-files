#!/bin/bash -ux
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}"; pwd)

: "SetUp default user" && {

  if [ -n "${DOCKERUSER:-}" ]
  then

    docker_uid="${DOCKER_UID:-500}"
    dockeruser="${DOCKERUSER:-dockeruser}"
    dockerpass="${DOCKERPASS:-}"

    [ -n "${dockerpass:-}" ] || {
      dockerpass=$({
        dd "if=/dev/urandom" count=50 |
        md5sum;
        }; )
    }

    groupadd -g "${docker_uid}" "${dockeruser}" &&
    useradd -u "${docker_uid}" -g "${dockeruser}" -m "${dockeruser}" && {
      echo "${dockerpass}" |
      passwd --stdin "${dockeruser}"
    } || exit 1

    sudoerfile="/etc/sudoers"
    insertline="# For docker user\n${dockeruser}\tALL=(ALL)\tNOPASSWD: ALL"

    sed -ri \
      '/^root[ \t]*ALL.*$/a '"${insertline}" \
      "${sudoerfile}" || exit 1

  fi

} &&
[ $? -eq 0 ]

exit $?
