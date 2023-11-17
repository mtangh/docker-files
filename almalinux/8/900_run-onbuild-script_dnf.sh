#!/bin/bash -ux

rpm_packages="${RPM_PACKAGES:-}"
onbuildscrpt="${ONBUILDSCRPT:-}"

: "Install additional RPM packages" && {

  if [ -s "./${rpm_packages:-rpm_packages.txt}" ]
  then
    rpm_packages=$(eval echo $(
      cat "./${rpm_packages:-rpm_packages.txt}"))
  fi || :

  if [ -n "${rpm_packages}" ]
  then

    dnf -v -y update &&
    dnf -v -y install ${rpm_packages}

  else : "noop"
  fi || exit 1

  [ -n "${rpm_packages}" ] && {
    dnf -v -y remove \
      --exclude=procps-ng \
      $(echo $(dnf -q repoquery --unneeded 2>/dev/null))
    dnf -v -y clean all
    rm -rf /var/cache/dnf/*
  } || :

} &&
: "Run the Onbuild script" && {

  if [ -s "./${onbuildscrpt:-onbuild.sh}" ]
  then

    echo "{{{ Run the '${onbuildscrpt:-onbuild.sh}'." &&
    bash -ux "./${onbuildscrpt:-onbuild.sh}" &&
    echo "}}} End of '${onbuildscrpt:-onbuild.sh}'."

  else : "noop"
  fi

} &&
[ $? -eq 0 ]

exit $?
