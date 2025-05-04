#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail
# AlmaLinux built "stage-builder" image
THIS="${BASH_SOURCE}"
NAME="${THIS##*/}"
BASE="${NAME%.*}"
CDIR=$([ -n "${THIS%/*}" ] && cd "${THIS%/*}" &>/dev/null; pwd)

IMAGE_BUILDER="${BASE}-${1:-chroot}.sh"

[ -n "${ALMALINUX_VER:-}" ] || exit 1
[ -n "${ALMALINUXROOT:-}" ] || exit 1
[ -e "${IMAGE_BUILDER:-}" ] || exit 1

# DNF
dnf=""
[ -x "${dnf:-}" ] || dnf="$(type -P dnf)"
[ -x "${dnf:-}" ] || dnf="$(type -P microdnf)"
[ -x "${dnf:-}" ] || exit 1
case "${dnf:-}" in
*/microdnf)
  ;;
*)
  dnf="${dnf} -v"
  ;;
esac

cat <<_EOD_
#*
#* ALMALINUX_VER=${ALMALINUX_VER:-}
#* ALMALINUXROOT=${ALMALINUXROOT:-}
#*
#* INSTALLEPEL=${INSTALLEPEL:-}
#*
#* Using dnf: ${dnf}
#*
_EOD_

dnf_config_update() {
  local dnf_config="${1:-}"; shift
  [ -s "${dnf_config}" ] || return 2

  cat "${dnf_config}" |
  if egrep '^errorlevel=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(errorlevel)=*$/\1=8/g'
  else sed -re '/^gpgcheck=.*/a errorlevel=8'
  fi |
  if egrep '^debuglevel=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(debuglevel)=.*$/\1=8/g'
  else sed -re '/^errorlevel=.*/a debuglevel=8'
  fi |
  if egrep '^install_weak_deps=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(install_weak_deps)=.*$/\1=False/g'
  else sed -re '/^best=.*/a install_weak_deps=False'
  fi |
  if egrep '^tsflags=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(tsflags)=.*$/\1=nodocs/g'
  else sed -re '/^install_weak_deps=.*/a tsflags=nodocs'
  fi |
  if egrep '^fastestmirror=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(fastestmirror)=.*$/\1=True/g'
  else sed -re '/^tsflags=.*$/a fastestmirror=True'
  fi |
  cat 1>"${dnf_config}.tmp" && {
    echo
    echo "[${dnf_config}]"
    if [ -x "$(type -P diff)" ]
    then
      diff "${dnf_config}"{,.tmp}
    else
      cat "${dnf_config}.tmp"
    fi || :
    echo
  } &&
  mv -f "${dnf_config}"{.tmp,} ||
  return $?

  return 0
}

: "Change the config of DNF" && {

  case "${dnf}" in
  */microdnf)
    ${dnf} -y \
      install --nodocs \
      dnf-data
    ;;
  *)
    ;;
  esac

  if [ -s "/etc/dnf/dnf.conf" ]
  then
    dnf_config_update \
      "/etc/dnf/dnf.conf" \
      || exit 1
  fi

} &&
: "Initialize Chroot Dir." && {

  rpm_gpgkey="/etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux"

  mkdir -p "${ALMALINUXROOT}" && {

    ${dnf} -y \
      clean all &&
    ${dnf} -y \
      --nodocs \
      update &&
    case "${dnf}" in
    */microdnf)
      ${dnf} -y \
        download \
        almalinux-release
      ;;
    *)
      ${dnf} -y \
        reinstall --downloadonly --downloaddir . \
        almalinux-release
      ;;
    esac &&
    rpm -v \
      --root ${ALMALINUXROOT} \
      --initdb &&
    rpm -v \
      --root ${ALMALINUXROOT} \
      --nodeps --excludedocs -ivh almalinux-*.rpm &&
    rpm -v \
      --root ${ALMALINUXROOT} \
      --import "${ALMALINUXROOT}${rpm_gpgkey}" &&
    case "${dnf}" in
    */microdnf)
      ${dnf} -y \
        --releasever=${ALMALINUX_VER} \
        --installroot=${ALMALINUXROOT} \
        --config=/etc/dnf/dnf.conf --nodocs --noplugins \
        --setopt=cachedir=${ALMALINUXROOT}/var/cache/dnf \
        --setopt=reposdir=/etc/yum.repos.d \
        --setopt=varsdir=${ALMALINUXROOT}/etc/dnf/vars/ \
        --setopt=install_weak_deps=0 \
        --setopt=tsflags=nodocs \
        install dnf dnf-data
      ;;
    *)
      ${dnf} -y \
        --releasever=${ALMALINUX_VER} \
        --installroot=${ALMALINUXROOT} \
        --nodocs \
        --setopt=install_weak_deps=0 \
        --setopt=tsflags=nodocs \
        install dnf dnf-data
      ;;
    esac

  } || exit 1

  rm -f almalinux-*.rpm || :

} &&
: "Change the config of DNF under ALMALINUXROOT." && {

  dnf_config_update \
    "${ALMALINUXROOT}/etc/dnf/dnf.conf" \
    || exit 1

  # dnf vars
  echo "container" 1>"${ALMALINUXROOT}/etc/dnf/vars/infra"

} &&
: "Chroot Setup." && {

  cp -pf {,"${ALMALINUXROOT}"}/etc/resolv.conf &&
  chroot "${ALMALINUXROOT}" /bin/bash -ux <"./${IMAGE_BUILDER}"

} &&
: "Cleanup." && {
  work_dir=$(pwd)
  cd / && {
    for lf in /var/log/*
    do
      [ -f "${lf}" ] && : 1>"${lf}"
    done
    rm -f {,/var}/tmp/*
    ${dnf} -y clean all
    rm -rf /var/lib/dnf/repos || :
    rm -f /var/lib/dnf/modulefailsafe/* \
          /var/lib/dnf/history.* || :
    rm -f /var/lib/rpm/__db.*
  } 2>/dev/null || :
} &&
: "Done."

exit $?
