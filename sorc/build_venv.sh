#!/bin/bash

set -ex

readonly HOMEaigefs=$(cd $(dirname $(readlink -f -n "${BASH_SOURCE[0]}"))/.. && pwd -P)

source "${HOMEaigefs}/versions/build.ver"
set +x
# TODO: Make this work for non-WCOSS platforms
#module reset
source /opt/intel/oneapi/compiler/${intel_ver:?}/env/vars.sh
source /opt/intel/oneapi/mpi/${impi_ver:?}/env/vars.sh
module use /lfs/work/alexander_richert/stack/spack-stack/envs/nco-sci-oneapi-${intel_ver}.0/modules_flat/Core
module load "g2c/${g2c_ver:?}"

#build GPU version
module use /lfs/work/alexander_richert/stack/spack/var/spack/environments/cuda/modules_flat/linux-rocky9-x86_64/Core
module load cuda/12.9.1-3hoj3a5

module list

set -x

# Needed for grib2io
export G2C_DIR="${g2c_ROOT}"
# g2C installed modulefile from spack-stack prepends to LD_LIBRARY_PATH.  TODO: Remove
LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${g2c_ROOT}/lib64"
export LD_LIBRARY_PATH

# Target venv path
venv_dir="${HOMEaigefs}/venv"
rm -rf "${venv_dir}"

# Needed for WCOSS (TMPDIR is not writable for users)
# Does not hurt for other platforms, but is unnecesary elsewhere
export TMPDIR="${venv_dir}/tmpdir"
rm -rf "${TMPDIR}"
mkdir -p "${TMPDIR}"

# Start creating the venv
#python3 -m virtualenv --relocatable "${venv_dir}" # virtualenv version < 20.0
/lfs/work/alexander_richert/stack/spack/var/spack/environments/python-3_12/.spack-env/view/bin/python -m venv "${venv_dir}"
source "${venv_dir}/bin/activate"

# Prepare the venv requirements.txt file and save it in venv
rm -f "${venv_dir}/requirements.txt"
sed "s|{{ HOMEaigefs }}|${HOMEaigefs}|g" "${HOMEaigefs}/sorc/requirements.txt.j2" > "${venv_dir}/requirements.txt"

# modify venv/bin/activate to remove hard-coded path and use $HOMEaigefs
sed -i 's|^VIRTUAL_ENV=.*|VIRTUAL_ENV="$HOMEaigefs/venv"|' ${venv_dir}/bin/activate

pip install -r "${venv_dir}/requirements.txt"
pip list
