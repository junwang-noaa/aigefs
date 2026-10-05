#! /usr/bin/env bash
set -eux

readonly HOMEaigefs=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}")")/.." && pwd -P)
progname=aigefs_ensstat

source "${HOMEaigefs}/versions/build.ver"

set +x
module use "${HOMEaigefs}/modulefiles/aigefs"
module load ${progname}
module list
set -x

# to use debug flags export DEBUG='Y' before compiling
if [[ "${DEBUG:-N}" == "Y" ]]; then
  build_type=Debug
else
  build_type=Release
fi

src_dir="${HOMEaigefs}/sorc/${progname}.fd"
build_dir="${src_dir}/build"
rm -rf "${build_dir}"

cmake -S "${src_dir}" -B "${build_dir}" \
  -DCMAKE_Fortran_COMPILER="${FCMP:-ifx}" \
  -DCMAKE_BUILD_TYPE="${build_type}" \
  -DCMAKE_INSTALL_PREFIX="${HOMEaigefs}" \
  -DCMAKE_INSTALL_BINDIR=exec
cmake --build "${build_dir}" -j "${BUILD_JOBS:-4}"
cmake --install "${build_dir}"

rm -rf "${build_dir}"
