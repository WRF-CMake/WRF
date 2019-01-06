# WRF-CMake [![Build status](https://ci.appveyor.com/api/projects/status/86508wximkvmf95g/branch/wrf-cmake?svg=true)](https://ci.appveyor.com/project/WRF-CMake/wrf/branch/wrf-cmake) [![Build Status](https://travis-ci.com/WRF-CMake/WRF.svg?branch=wrf-cmake)](https://travis-ci.com/WRF-CMake/WRF)

## Why WRF-CMake?

WRF-CMake adds CMake support to the latest version of the [Advanced Research Weather Research and Forecasting](https://www.mmm.ucar.edu/weather-research-and-forecasting-model) model (here WRF, for short) with the intention of streamlining and simplifying its configuration and build process. In our view, the use of CMake provides model developers, code maintainers, and end-users with several advantages such as robust incremental rebuilds, flexible library dependency discovery, native tool-chains for Windows, macOS, and Linux with minimal external dependencies, thus increasing portability, and automatic generation of project files for different platforms.

WRF-CMake is designed to work alongside the current releases of WRF therefore you can still compile your code using the legacy Makefiles included in WRF and WPS for any of the currently unsupported features.


### Currently supported platforms

- Configurations for special environments like supercomputers
- Linux with gcc/gfortran, Intel, and Cray compilers
- macOS with gcc/gfortran and Intel compilers
- Windows with MinGW-w64 and gcc/gfortran


### Currently unsupported features

- WRF-DA
- WRFPLUS
- WRF-Chem
- WRF-Hydro
- Promotion of Fortran's REAL to DOUBLE
- WRF-NMM (discontinued -- see https://dtcenter.org/wrf-nmm/users/)


## Installation

The installation of WRF-CMake is straightforward thanks to the downloadable pre-built binaries for Windows, macOS and any Linux (see [binary distribution](#binary-distribution-experimental) below) -- most users wishing to run WRF on their system can simply download the pre-compiled binaries without the need of building from source. Alternately, to build WRF from source, please refer to the [source distribution](#source-distribution) section below.


### Binary distribution (Experimental)

To download the latest pre-compiled binary releases, see below -- please note that these distributions are currently experimental therefore please report any issues [here](https://github.com/WRF-CMake/WRF/issues).

- WRF-CMake (`serial` and `dmpar`): [https://github.com/WRF-CMake/WRF/releases](https://github.com/WRF-CMake/WRF/releases).
- WPS-CMake (`serial` and `dmpar`): [https://github.com/WRF-CMake/WPS/releases](https://github.com/WRF-CMake/WPS/releases).


#### Note on MPI

If you want to launch WRF-CMake and WPS-CMake built in `dmpar` to run on multiple processes, you need to have MPI installed on your system.

- On Windows, download and install Microsoft MPI (`msmpisetup.exe`) from [https://www.microsoft.com/en-us/download/details.aspx?id=56727](https://www.microsoft.com/en-us/download/details.aspx?id=56727).
- On macOS you can get it though [Homebrew](https://brew.sh/) using `brew update && brew install mpich`.
- On Linux, use your package manager to download mpich (version ≥ 3.0.4). E.g. `sudo apt-get update && sudo apt-get install mpich` on Debian-based systems or `sudo yum install mpich` on RPM-based system like CentOS.


### Source distribution
To build WRF-CMake from source, see [this page](doc/cmake/INSTALL.md).

## Testing

In our current GitHub set-up, we perform a series of compilation and regression tests at each commit using the [WRF-CMake Automated Testing Suite](https://github.com/WRF-CMake/wats) for Windows, macOS, and Linux. You can find the results of such tests [here](https://travis-ci.com/WRF-CMake), [here](https://ci.appveyor.com/project/WRF-CMake/wrf), and [here](https://ci.appveyor.com/project/WRF-CMake/wps).


## Changes to be upstreamed

The following is a list of changes to be upsteamed:

- `dyn_em/module_big_step_utilities_em.F`: Fix non-standard line continuation character (`\` instead of `&`) leading to compile errors on Cray compilers
- `external/io_grib1/MEL_grib1/{grib_enc.c,gribputgds.c,pack_spatial.c}`: Remove redundant header includes causing symbol conflicts in Windows
- `external/io_grib2/g2lib/{dec,enc}_png.c`: Changed type 'voidp' to 'png_voidp' to make it compatible with newer libpng versions. See: https://trac.macports.org/ticket/36470
- `external/io_grib2/g2lib/enc_jpeg2000.c`: Removed redundant `image.inmem_=1;` to make it compatible with newer libjasper versions >= 1.900.25
- `external/io_grib_share/open_file.c`, `external/io_grib2/bacio-1.3/bacio.v1.3.c`, `external/io_int/io_int_idx.c`, `external/RSL_LITE/c_code.c`: Fixed file opening on Windows which is text-mode by default and has been changed to binary mode
- `external/io_netcdf/wrf_io.F90`: Added alternative `XDEX(A,B,C)` macro for systems without M4
- `external/RSL_LITE/c_code.c`: Fixed condition of preprocessing definition for `minf` to be Windows compatible
- `phys/module_sf_clm.F`: Fixed missing `IFPORT` module import needed for non-standard subroutine `abort` when using Intel Fortran
- `share/landread.c`: Fixed header includes for Windows (`io.h` instead of `unistd.h`)
- `tools/gen_{interp,irr_diag}.c`: Fixed missing function aliasing for Windows for `strcasecmp`, `rindex`, `index`
- `tools/gen_irr_diag.c`: Remove redundant `sys/resource.h` header include which would be unavailable on Windows
- `tools/registry.c`: Fixed incorrect Windows-conditional header include for `string.h` (needed in all cases, not just non-Windows)
- `var/run/crtm_coeffs`: Removed broken absolute UNIX symlink as this causes trouble with git operations in Windows


## Copyright and license

General WRF copyright and license applies for any files part of the original WRF distribution -- see the [README](README) file for more details.

Additional files provided by WRF-CMake are licensed according to [LICENSE_CMAKE.txt](LICENSE_CMAKE.txt) if the relevant file contains the following header at the beginning of the file, otherwise the general WRF copyright and license applies.
```
Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.
```