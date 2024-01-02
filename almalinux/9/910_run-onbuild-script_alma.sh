#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

rpm_packages="${ONBUILD_RPM_PACKAGES:-}"
build_script="${ONBUILD_SHELL_SCRIPT:-onbuild.sh}"

: "Install additional RPM packages" && {

  if [ -x "./${rpm_packages:-rpm_packages.sh}" ]
  then
    rpm_packages=$(eval echo $(
      /bin/bash -ux "./${rpm_packages:=rpm_packages.sh}"))
  elif [ -s "./${rpm_packages:-rpm_packages.txt}" ]
  then
    rpm_packages=$(eval echo $(
      cat "./${rpm_packages:-rpm_packages.txt}"))
  else :
  fi || :

  if [ -n "${rpm_packages}" ]
  then

    dnf -v -y update &&
    dnf -v -y install ${rpm_packages} && {
      dnf -v -y remove --exclude=binutils \
        $(echo $(dnf -q repoquery --unneeded 2>/dev/null)) || :
    }

  else : "noop"
  fi || exit 1

} &&
: "Run the Onbuild script" && {

  for shellscr in ${build_script}
  do
    if [ -s "${shellscr:-X}" ]
    then
      echo "{{{ Run the '${shellscr}'." &&
      /bin/bash -ux -o errtrace -o functrace -o pipefail "./${shellscr}" &&
      echo "}}} End of '${shellscr}'."
    else : "noop"
    fi || exit 1
  done

} &&
[ $? -eq 0 ]

exit $?
