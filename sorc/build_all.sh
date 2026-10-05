#!/bin/bash
set -eu

# Build all AIGEFS components:
#   1. aigefs_ensstat executable (CMake) -> ${HOMEaigefs}/exec
#   2. Python virtual environment        -> ${HOMEaigefs}/venv
#
# to use debug flags export DEBUG='Y' before compiling
export DEBUG=${DEBUG:-'N'}

readonly sorc_dir=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}")")" && pwd -P)
readonly HOMEaigefs=$(cd "${sorc_dir}/.." && pwd -P)
cd "${sorc_dir}"

logs_dir=${sorc_dir}/logs
mkdir -p "${logs_dir}" "${HOMEaigefs}/exec"

build() {
  local name=$1
  local log=${logs_dir}/${name}.log
  echo " .... Building ${name#build_} (log: ${log}) .... "
  if ! "./${name}.sh" > "${log}" 2>&1; then
    echo "FATAL ERROR: ${name}.sh failed, see ${log}"
    tail -20 "${log}"
    exit 1
  fi
}

#------------------------------------
# build aigefs_ensstat
#------------------------------------
build build_aigefs_ensstat

#------------------------------------
# build virtual environment
#------------------------------------
build build_venv

echo; echo " .... Build system finished .... "
