#!/bin/bash

# make sure zstd is available
source /cvmfs/cta.in2p3.fr/software/centos7/gcc48_default/tools/zstd/v1.4.5/setupPackage.sh
# use our version of gsl (for random numbers in sim_telarray) - reset LD_LIBRARY_PATH
source /cvmfs/cta.in2p3.fr/software/centos7/gcc48_default/tools/gsl/v1.15/setupPackage.sh

# Main directory
# USER: Change this path to the grid package you want to use! # TODO
export CTA_PROD5_PATH="/cvmfs/cta.in2p3.fr/software/centos7/gcc83_noOpt/simulations/corsika_simtelarray/2020-06-29b/"
export CTA_PATH=${CTA_PROD5_PATH}

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

