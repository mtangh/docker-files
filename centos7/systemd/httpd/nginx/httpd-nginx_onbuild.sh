#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

work_dir=$(pwd)

ng_rel_url="http://nginx.org/packages/centos/%V/noarch/RPMS"
ng_rel_url="${ng_rel_url}/nginx-release-centos-%V-0.el%V.ngx.noarch.rpm"
ng_rel_url=$(echo "${ng_rel_url}" |sed -re 's/%V/'"${CENTOS_VER:-7}"'/g')

packages=""

if [ -x "${NGINX_PKG_LIST:-nginx_packages.sh}" ]
then 
  packages=$(echo $(
    /bin/bash -ux "${NGINX_PKG_LIST:-nginx_packages.sh}"))
elif [ -s "${NGINX_PKG_LIST:-nginx_packages.txt}" ]
then 
  packages=$(echo $(
    cat "${NGINX_PKG_LIST:-nginx_packages.txt}"))
elif [ -n "${NGINX_PKG_LIST:-}" ]
then
  packages="${NGINX_PKG_LIST}"
fi

[ -n "${packages}" ] || {
  packages="nginx nginx-all-modules"
  echo "The Nginx Package List is empty, using default: '${packages}'."
}

: "Install" && {

  ngx_repo="/etc/yum.repos.d/nginx.repo"

  rpm -Uvh "${ng_rel_url}" &&
  [ -e "${ngx_repo}" ] && {
    sed -ri 's/^enabled=.+$/enabled=1/g' "${ngx_repo}" &&
    yum -v -y update &&
    yum -v -y install ${packages}
  }

} &&
: "Update nginx.conf" && {

  nginxcnf="/etc/nginx/nginx.conf"

  : && {
    [ -e "${nginxcnf}.ORIG" ] ||
    cp -pf "${nginxcnf}"{,.ORIG}
  } &&
  if [ -e "./nginx.conf" -a -s "./nginx.conf" ]
  then
    cat "./nginx.conf" 1>"${nginxcnf}"
  else

    cat "${nginxcnf}.ORIG" |
    sed -r \
     -e '/^[[:space:]]*include[[:space:]]+.+mime[.]types;$/i \    server_tokens off;' \
     -e 's/^([#[:space:]]*gzip)[[:space:]]+.*;$/\1 on;/g' \
     -e '/gzip[[:space:]]/a \    server_names_hash_bucket_size 128;' \
     -e 's/^([#[:space:]]*keepalive_timeout)[[:space:]]+.*;$/\1 15;/g' \
     1>"${nginxcnf}"

  fi &&
  /usr/sbin/nginx -t

} &&
: "Update conf.d/default.conf" && {

  nginxcnf="/etc/nginx/conf.d/default.conf"

  : && {
    [ -e "${nginxcnf}.ORIG" ] ||
    cp -pf "${nginxcnf}"{,.ORIG}
  } &&
  if [ -s "./nginx-default.conf" ]
  then
    cat "./nginx-default.conf" 1>"${nginxcnf}"
  else

    cat "${nginxcnf}.ORIG" |
    sed -r \
      -e 's#^([[:space:]]*root)[[:space:]]+/.*;$#\1 /var/www/html;#g' \
      1>"${nginxcnf}"

  fi &&
  /usr/sbin/nginx -t

} &&
: "Done."

exit $?