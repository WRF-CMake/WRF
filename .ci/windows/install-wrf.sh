#!/bin/bash

# WRF-CMake (https://github.com/WRF-CMake/wrf).
# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

SCRIPTDIR=$(dirname "$0")
cd $SCRIPTDIR/../..

if [ $BUILD_SYSTEM == "CMake" ]; then

    mkdir build && cd build

    # TODO remove -DMPI_* variables once these get auto-detected
    # Note that -DMODE alone decides whether MPI is used or not.
    cmake -GNinja \
        -DCMAKE_INSTALL_PREFIX=install -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
        -DMODE=$MODE -DNESTING=${NESTING} -DUSE_REAL8=${REAL8} \
        -DENABLE_GRIB1=${GRIB1} -DENABLE_GRIB2=${GRIB2} \
        -DMPI_INCLUDE_PATH=$MINGW_PREFIX/include -DMPI_C_LIBRARY="$MSMPI_LIB64/msmpi.lib" \
        -DMPI_Fortran_LIBRARY="$MSMPI_LIB64/msmpifec.lib" \
        -DDEBUG_ARCH=ON -DDEBUG_GLOBAL_DEFINITIONS=ON -LA ..

    # It sometimes happens that the compiler runs out of memory due to parallel compilation.
    # The construction below means "try with full parallelism, and if it fails, try again with 1 core".
    export VERBOSE=1
    cmake --build . --target install \
        || cmake --build . --target install -- -j 1 \
        || cmake --build . --target install -- -j 1

else
    echo "Unknown system: ${BUILD_SYSTEM}"
    exit 1
fi