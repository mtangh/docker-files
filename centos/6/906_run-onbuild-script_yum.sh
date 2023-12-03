#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

rpm_packages="${ONBUILD_RPM_PACKAGES:-}"
build_script="${ONBUILD_SHELL_SCRIPT:-onbuild.sh}"

: "Install additional RPM packages" && {

  if [ -s "./${rpm_packages:-rpm_packages.txt}" ]
  then rpm_packages=$(eval echo $(cat "./${rpm_packages:=rpm_packages.txt}"))
  else :
  fi || :

  if [ -n "${rpm_packages}" ]
  then

    yum -v -y update &&
    yum -v -y install ${rpm_packages} && {
      yum -v -y remove $(echo $(package-cleanup --leaves)) || :
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
