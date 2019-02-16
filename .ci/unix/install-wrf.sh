#!/bin/bash

# Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set -ex

SCRIPTDIR=$(dirname "$0")
cd $SCRIPTDIR/../..

if [ $BUILD_SYSTEM == 'CMake' ]; then

    mkdir build && cd build
    cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=install \
          -DENABLE_GRIB1=${GRIB1} -DENABLE_GRIB2=${GRIB2} -DMODE=${MODE} -DNESTING=${NESTING} \
          -DDEBUG_ARCH=ON -DDEBUG_GLOBAL_DEFINITIONS=ON -LA ..
    
    # It sometimes happens that the compiler runs out of memory due to parallel compilation.
    # The construction below means "try with 2 cores, and if it fails, try again with 1 core".
    cmake --build . --target install -- -j2 \
        || cmake --build . --target install \
        || cmake --build . --target install
    
    cd ..

elif [ $BUILD_SYSTEM == 'Make' ]; then

    # WRF does not use CC/FC, so let's check what gcc/gfortran actually points to.
    which gcc
    gcc --version
    which gfortran
    gfortran --version

    export NETCDF4=1 # Compile with netCDF-4 support
    export WRF_EM_CORE=1 # Select ARW core

    if [[ $BUILD_TYPE == 'Debug' ]]; then
        debug=-d
    else
        debug=
    fi

    if [ "$(uname)" == "Linux" ]; then

        case $MODE in
            serial) cfg=32 ;;
            dmpar)  cfg=34 ;;
            *) echo "Invalid: $MODE" ;;
        esac

        if [ "$(lsb_release -c -s)" == "trusty" ]; then
            export HDF5=/usr
            export NETCDF=/usr
        else
            # Need to create symlinked folder hierarchy that WRF expects...
            mkdir netcdf
            ln -s /usr/include netcdf/include
            ln -s /usr/lib/x86_64-linux-gnu netcdf/lib

            export HDF5=/usr/lib/x86_64-linux-gnu/hdf5/serial
            export NETCDF=`pwd`/netcdf
        fi

    elif [ "$(uname)" == "Darwin" ]; then

        case $MODE in
            serial) cfg=15 ;;
            dmpar)  cfg=17 ;;
            *) echo "Invalid: $MODE" ;;
        esac

        export HDF5=$(brew --prefix hdf5)

        # macOS doesn't support "readlink -f" and brew's coreutils provides a replacement called greadlink.
        # We use readlink to get the absolute path of the netCDF library folder as WRF's setup scripts
        # can't handle symlinks properly.
        export NETCDF=$(greadlink -f $(brew --prefix netcdf)) # see comment above about greadlink

    else
        echo "The environment is not recognised"
    fi

    # 1 = basic nesting
    echo "./configure $debug <<< $cfg\n1\n"
    ./configure $debug <<< $cfg$'\n1\n'

    echo "==== configure.wrf ===="
    cat configure.wrf
    echo "==== end configure.wrf ===="

    echo "./compile em_real"
    ./compile em_real

    if [ ! -f main/wrf.exe ]; then
        # Try again in case we ran out of memory, this time without parallel compilation.
        export J=
        ./compile em_real
    fi

    if [ ! -f main/wrf.exe ]; then
        # Last chance.
        ./compile em_real
    fi

    if [ ! -f main/wrf.exe ]; then
        exit 1
    fi

else
    echo "Unknown system: $(uname)"
    exit 1
fi
