#
# centos:centos7-systemd
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos:centos7-systemd"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7 AS build-stage

# Labels
LABEL \
 build-stage="true"

# Shell
SHELL \
 [ "/bin/bash", "-x", "-c" ]

# Set Workdir
WORKDIR \
 /root

# Env
ENV \
 container=docker

# SetUp
RUN \
 : "Modify yum-fastestmirror" && { \
  yum_fastmirror_conf="/etc/yum/pluginconf.d/fastestmirror.conf"; \
  [ -e "${yum_fastmirror_conf}" ] && \
  sed -ri 's/^verbose=0$/verbose=1/g' "${yum_fastmirror_conf}" && \
  sed -ri 's/^(#*)include_only=.*$/include_only=.jp,.org/g' "${yum_fastmirror_conf}" && \
  sed -ri '/^include_only=.*$/a prefer=www.ftp.ne.jp' "${yum_fastmirror_conf}" && \
  cat "${yum_fastmirror_conf}"; \
 } && \
 : "Install EPEL" && { \
  yum -v -y install epel-release; \
 } && \
 : "Install systemd" && { \
  yum -v -y update && \
  yum -v -y install systemd-sysv sudo && \
  yum -v -y clean all; rm -rf /var/cache/yum/*; \
 } && \
 : "Delete systemd files" && { \
  etc_systemd_sys_dir="/etc/systemd/system"; \
  usr_systemd_sys_dir="/usr/lib/systemd/system"; \
  rm -f "${etc_systemd_sys_dir}"/*.wants/*; \
  (cd "${usr_systemd_sys_dir}" && { \
    for item in \
    ./multi-user.target.wants/dbus.service \
    ./multi-user.target.wants/getty.target \
    ./multi-user.target.wants/systemd-ask-password-wall.path \
    ./multi-user.target.wants/systemd-update-utmp-runlevel.service \
    ./sockets.target.wants/dbus.socket \
    ./sockets.target.wants/systemd-initctl.socket \
    ./sockets.target.wants/systemd-udevd-control.socket \
    ./sockets.target.wants/systemd-udevd-kernel.socket \
    ./sysinit.target.wants/systemd-ask-password-console.path \
    ./sysinit.target.wants/systemd-udevd.service \
    ./sysinit.target.wants/systemd-udev-trigger.service \
    ./sysinit.target.wants/systemd-vconsole-setup.service \
    ./local-fs.target.wants/systemd-remount-fs.service ; \
    do rm -f "$item"; done; \
   } &>/dev/null; ); \
  (cd "${usr_systemd_sys_dir}"/sysinit.target.wants && { \
    for item in *; \
    do \
     echo "$item"|egrep '^systemd-tmpfiles-setup.*service' || \
     rm -f "$item"; \
    done; \
   } &>/dev/null; ); \
 }; \
 : "Cleanup" && { \
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done; \
  yum -v -y clean all; rm -rf /var/cache/yum/*; \
  rm -rf /root/*; \
 } 2>/dev/null || :; \
 echo;

# Reset Workdir
WORKDIR \
 /

# CentOS 7 with systemd
FROM scratch AS centos7-systemd-stage

# Maintainer
LABEL \
 maintainer "MT"

# Labels
LABEL \
 name="CentOS 7 with Systemd" \
 vendor="UGOOLE.ORG" \
 license=""

# Labels for build
LABEL \
 build-date="" \
 docker.build.options=""

# Set Workdir
WORKDIR \
 /root

# COPY from build-stage
COPY \
 --from=build-stage / /

# Reset Workdir
WORKDIR \
 /

# ONBUILD: Set Workdir
ONBUILD \
WORKDIR \
 /root

# ONBUILD: System locale
ONBUILD \
ARG \
 localedef="en_US.UTF-8"

# ONBUILD: keymap and timezone
ONBUILD \
ARG \
 keyboard="jp106"
ONBUILD \
ARG \
 timezone="Asia/Tokyo"

# ONBUILD: root password
ONBUILD \
ARG \
 ROOTPASSWD=""

# ONBUILD: Default login
ONBUILD \
ARG \
 DOCKER_UID=500
ONBUILD \
ARG \
 DOCKERUSER=dockeruser
ONBUILD \
ARG \
 DOCKERPASS=""

# ONBUILD: sshd
ONBUILD \
ARG \
 without_ssh=""

# ONBUILD: logrotate
ONBUILD \
ARG \
 without_logrotate=""

# ONBUILD: Additional Packages
ONBUILD \
ARG \
 packages=""

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -x; \
 : "ONBUILD: SetUp system locale: $localedef" && { \
  lc_cn=$(echo "${localedef}"|cut -d. -f1 2>/dev/null); \
  lc_lang=$(echo "${localedef}"|cut -d. -f2 2>/dev/null); \
  [ "${lc_cn:-en_US}" == "en_US" -a "${lc_lang:-UTF-8}" == "UTF-8" ] || { \
   localedef -v -c -i "${lc_cn:-en_US}" -f "${lc_lang:-UTF-8}" "${lc_cn:-en_US}.${lc_lang:-UTF-8}"; \
  }; \
 }; \
 : "ONBUILD: keymap: keyboard=$keyboard" && { \
  . /etc/vconsole.conf && \
  [ "$KEYMAP" = "$keyboard" ] || { \
   sed -ri 's/^KEYMAP=.*$/KEYMAP="'$keyboard'"/g' /etc/vconsole.conf; \
  }; \
 }; \
 : "ONBUILD: timezone: timezone=$timezone" && { \
  [ ! -e "/usr/share/zoneinfo/${timezone}" ] || { \
   cp -pf /etc/localtime{,.ORIG} && \
   ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime; \
  }; \
  ls -l /etc/localtime; \
 }; \
 : "ONBUILD: Set root password" && { \
  [ -z "${ROOTPASSWD}" ] || { \
   echo "root:${ROOTPASSWD}" |chpasswd; }; \
 }; \
 : "ONBUILD: SetUp default user" && { \
  if [ -n "${DOCKERUSER}" ]; \
  then \
   docker_uid="${DOCKER_UID:-500}"; \
   dockeruser="${DOCKERUSER:-dockeruser}"; \
   dockerpass="${DOCKERPASS}"; \
   groupadd -g "${docker_uid}" "${dockeruser}" && \
   useradd -u "${docker_uid}" -g "${dockeruser}" -m "${dockeruser}" && \
   if [ -n "${DOCKERPASS}" ]; \
   then echo "${dockeruser}:${dockerpass}"; \
   else echo "${dockeruser}:$(dd if=/dev/urandom count=50 2>/dev/null|md5sum)"; \
   fi |chpasswd; \
   sudoers="/etc/sudoers"; \
   newline="# For docker user\n${dockeruser}\tALL=(ALL)\tNOPASSWD: ALL"; \
   sed -ri '/^root[ \t]*ALL.*$/a '"${newline}" "${sudoers}"; \
  fi; \
 }; \
 if [ -n "${without_ssh}" \
   -o -n "${without_logrotate}" \
   -o -n "${packages}" ]; \
 then yum -v -y update; \
 fi; \
 if [ -n "${without_ssh}" ]; \
 then echo "Without SSHd, skipping this instruction."; \
 else \
  : "ONBUILD: sshd: Install openssh-server" && { \
   yum -v -y install openssh-server; \
  } && \
  : "ONBUILD: sshd: Configure sshd_config" && { \
   sshd_config="/etc/ssh/sshd_config"; \
   [ -s "${sshd_config}" ] && \
   sed -ri 's/^#PermitRootLogin[ ]*yes/PermitRootLogin yes/' "${sshd_config}" && \
   sed -ri 's/^UsePAM yes/UsePAM no/' "${sshd_config}" && \
   cat "${sshd_config}"; \
  } && \
  : "ONBUILD: sshd: Enable sshd.service" && { \
   systemctl enable sshd.service || :; \
  }; \
 fi; \
 if [ -n "${without_logrotate}" ]; \
 then echo "Without logrotate, skipping this instruction."; \
 else \
  : "ONBUILD: logrotate: install logrotate" && { \
   yum -v -y install logrotate; \
  } && \
  : "ONBUILD: logrotate: SetUp systemd files" && { \
   systemd_sys_dir="/etc/systemd/system"; \
   [ -d "${systemd_sys_dir}" ] || { \
    mkdir -p "${systemd_sys_dir}" && \
    chown root:root "${systemd_sys_dir}" && \
    chmod 0755 "${systemd_sys_dir}"; \
   }; \
   : && { \
    echo '# Systemd unit file for logrotate.service' && \
    echo '' && \
    echo '[Unit]' && \
    echo 'Description=logrotate' && \
    echo '' && \
    echo '[Service]' && \
    echo 'Type=simple' && \
    echo '' && \
    echo '# Exec Start,Stop,etc...' && \
    echo 'ExecStart=/etc/cron.daily/logrotate' && \
    echo ''; \
   } 1>"${systemd_sys_dir}/logrotate.service"; \
   : && { \
    echo '# Systemd unit file for logrotate.timer' && \
    echo '' && \
    echo '[Unit]' && \
    echo 'Description=Daily Log Rotation' && \
    echo '' && \
    echo '[Timer]' && \
    echo 'OnCalendar=*-*-* 02:00:00' && \
    echo 'Persistent=true' && \
    echo '' && \
    echo '[Install]' && \
    echo 'WantedBy=timers.target' && \
    echo ''; \
   } 1>"${systemd_sys_dir}/logrotate.timer"; \
   chown root:root "${systemd_sys_dir}"/logrotate.* && \
   chmod 0644 "${systemd_sys_dir}"/logrotate.*; \
  } && \
  : "ONBUILD: logrotate: Enable logrotate.timer" && { \
   systemctl enable logrotate.timer || : ; \
  }; \
 fi; \
 if [ -z "${packages}" ]; \
 then echo "No packages, skipping this instruction."; \
 else \
  : "ONBUILD: PKG: install packages are: ${packages}" && { \
   yum -v -y install ${packages}; \
  }; \
 fi; \
 : "ONBUILD: Cleanup" && { \
  for log in $(find /var/log -type f); \
  do [ -f "$log" ] && cat /dev/null 1>"$log"; done; \
  for log in {,/root,/tmp,/var/tmp}/*.log; \
  do rm -f "$log"; done; \
  yum -v -y clean all; rm -rf /var/cache/yum/*; \
  rm -rf /root/*; \
 } 2>/dev/null || :; \
 echo;

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR \
 /

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos7-systemd --privileged" \
 docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGINT

## Publish a container's port(s) to the host
#EXPOSE 22

# Volume
VOLUME [ "/sys/fs/cgroup" ]

# Start /sbin/init
CMD [ "/sbin/init" ]

