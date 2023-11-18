#!/bin/bash
THIS="${BASH_SOURCE##*/}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}" &>/dev/null; pwd)

# Run tests
echo "[${tests_name:-${THIS}}] syntax-check.sh" && {

  hadolint=$(type -P hadolint)

  # Error
  syntax_err=0

  cd "${tests_wdir:-${CDIR}/..}" &>/dev/null &&    
  for dockerfile in $(
    find . -name "Dockerfile*" | sort|
    egrep -v '/_docker-bin/'; )
  do

    docker_dir="${dockerfile%/*}"
    dfctx_name="${docker_dir#./}"

    dflint_err=0
    dfscrpterr=0

    echo "@${dfctx_name}: "

    if [ -n "${hadolint}" ]
    then

      echo "@${dfctx_name}: ${dockerfile##*/}:"
      ${hadolint} --no-color -t warning "${dockerfile}" || dflint_err=$?
      if [ ${dflint_err:-0} -eq 0 ]
      then
        echo "@${dfctx_name}: ${dockerfile##*/}: OK."
      else
        echo "@${dfctx_name}: ${dockerfile##*/}: NG."
        syntax_err="${dflint_err:-1}"
        continue
      fi

    else
      echo "@${dfctx_name}: The 'hadolint' command is missing."
      echo "@${dfctx_name}: Skip syntax checking of dockerfile '${dockerfile##*docker-files/}'."
    fi

    echo "@${dfctx_name}: Shell-Scripts:"

    # Syntax check for shell script
    for shscript in $(set +x && {
      find "${docker_dir:-X}" -type f -a -name "*.sh*" |sort
      } 2>/dev/null; )
    do
      echo "@${dfctx_name}: ${shscript##*docker-files/}:"
      bash -n "${shscript}" || dfscrpterr=$?
    done &&
    if [ ${dfscrpterr:-1} -le 0 ]
    then
      echo "@${dfctx_name}: Shell-Scripts: OK."
    else
      echo "@${dfctx_name}: Shell-Scripts: NG."
      syntax_eff="${dfscrpterr:-1}";
    fi

  done &&
  [ ${syntax_err:-1} -le 0 ] &&
  echo "OK."

} &&
echo "[${tests_name:-${THIS}}] DONE."

# End
exit $?
