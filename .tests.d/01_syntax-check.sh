#!/bin/bash
THIS="${BASH_SOURCE##*/}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}" &>/dev/null; pwd)

# Run tests
echo "[${tests_name:-${THIS}}] syntax-check.sh" && {

  # Path
  docker_bin=$(cd "${tests_wdir:-${CDIR}/..}/_docker-bin"; pwd)
  dockerfncs="${docker_bin}/functions"

  # Error
  syntax_err=0

  # Pwd
  echo "Dir: ${docker_bin}"

  # Syntax check
  for shscript in $(set +x && {
    find "${docker_bin}" -type f -a -name "*.sh*" |sort
    find "${dockerfncs}" -type f |sort
    } 2>/dev/null; )
  do
    echo "_docker-bin/${shscript##*/_docker-bin/}:"
    bash -n "${shscript}" && {
      if [[ "${shscript}" =~ /functions/ ]]
      then (. "${shscript}")
      else :
      fi
    } || syntax_err=$?
  done &&
  [ ${syntax_err:-1} -le 0 ] &&
  echo "OK."

} &&
echo "[${tests_name:-${THIS}}] DONE."

# End
exit $?
