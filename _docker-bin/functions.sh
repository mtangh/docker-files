# functions.sh
DOCKERFUNC_SRC="${BASH_SOURCE##*/}"
DOCKERFUNC_DIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}" 2>/dev/null; pwd)

# awk
AWK="${AWK:-$(type -P gawk)}"
AWK="${AWK:-$(type -P awk)}"

# sed
SED="${SED:-$(type -P gsed)}"
SED="${SED:-$(type -P sed)}"

# Root
DOCKERFILES_ROOT_DIR=$(cd "${DOCKERFUNC_DIR}/.." 1>/dev/null 2>&1; pwd)

# Load the functins
if [ -n "${DOCKERFUNC_DIR}" -a -d "${DOCKERFUNC_DIR}/functions" ]
then
  for func in "${DOCKERFUNC_DIR}"/functions/*
  do
   [ -f "${func}" ] && {
      . "${func}"
    } || :
  done 2>/dev/null
  unset func
fi

# vim: set ff=unix ts=2 sw=2 sts=2 et : This line is VIM modeline
return 0
