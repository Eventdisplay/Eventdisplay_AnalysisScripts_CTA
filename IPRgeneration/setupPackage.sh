#!/bin/bash

# make sure zstd is available
source /cvmfs/sw.cta-observatory.org/software/centos7/gcc48_noOpt/tools/zstd/v1.5.2/setupPackage.sh
# use our version of gsl (for random numbers in sim_telarray) - reset LD_LIBRARY_PATH
source /cvmfs/sw.cta-observatory.org/software/centos7/gcc48_noOpt/tools/gsl/v1.15/setupPackage.sh

# Main directory
# USER: Change this path to the grid package you want to use! # TODO
export CTA_PROD6_PATH="/cvmfs/sw.cta-observatory.org/software/centos7/gcc83_noOpt/simulations/corsika_simtelarray/2024-02-05/"
export CTA_PATH=${CTA_PROD6_PATH}

# CORSIKA and SIMTEL
export CORSIKA_PATH=${CTA_PATH}/corsika-run
export SIM_TELARRAY_PATH=${CTA_PATH}/sim_telarray
export HESSIO_PATH=${CTA_PATH}/hessioxxx
export LD_LIBRARY_PATH=${HESSIO_PATH}/lib:${LD_LIBRARY_PATH}
export PATH=${HESSIO_PATH}/bin:${SIM_TELARRAY_PATH}/bin:${PATH}
export SIMTEL_CONFIG_PREPROCESSOR="${SIM_TELARRAY_PATH}/bin/pfp -v -I."

# DATA PATHS
export MCDATA_PATH=${PWD}/Data
export CORSIKA_DATA=${MCDATA_PATH}/corsika
export SIM_TELARRAY_DATA=${MCDATA_PATH}/sim_telarray
