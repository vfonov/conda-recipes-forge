#! /bin/bash
set -e

mkdir -p build && cd build
# assume correct compilers will be setup by environment
# don't build visual tools though
# use external cache directory

export CMAKE_PREFIX_PATH=${CONDA_PREFIX}

# default configuration , trying to use as many prebuilt packages as possible

if [[ -z ${MACOSX_DEPLOYMENT_TARGET} ]];then
    # building on linux

    # HACK to make cmake be able to find libm
    # ln -sf ${CONDA_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/lib/libm.so.6 ${CONDA_PREFIX}/lib/libm.so
    # maybe not such a good adea after all

    export CMAKE_LIBRARY_PATH=${CONDA_PREFIX}/lib:${CONDA_PREFIX}/lib64:${CONDA_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/lib

else # building on MacOSX
    export CC=clang
    export CXX=clang++
    export LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib -headerpad_max_install_names $LDFLAGS"
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
    #export MACOSX_DEPLOYMENT_TARGET="10.9"
    export CMAKE_LIBRARY_PATH=${CONDA_PREFIX}/lib:${CONDA_PREFIX}/lib64:
fi



cmake .. \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_Fortran_FLAGS:STRING="" \
      -DCMAKE_CXX_FLAGS:STRING="" \
      -DCMAKE_C_FLAGS:STRING="" \
      -DHDF5_INCLUDE_DIR:PATH=${CONDA_PREFIX}/include \
      -DHDF5_LIBRARY:FILEPATH=${CONDA_PREFIX}/lib/libhdf5${SHLIB_EXT} \
      -DNETCDF_INCLUDE_DIR:PATH=${CONDA_PREFIX}/include \
      -DNETCDF_LIBRARY:FILEPATH=${CONDA_PREFIX}/lib/libnetcdf${SHLIB_EXT} \
      -DZLIB_INCLUDE_DIR:PATH=${CONDA_PREFIX}/include \
      -DZLIB_LIBRARY_RELEASE:FILEPATH=${CONDA_PREFIX}/lib/libz${SHLIB_EXT} 

# build and install
make -j${CPU_COUNT}

# fix a missing directory bug (?)
mkdir -p ${PREFIX}/share

make install

#create environment activation & deactivation
# ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
# DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
# mkdir -p $ACTIVATE_DIR
# mkdir -p $DEACTIVATE_DIR

# cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/minc-toolkit-v2-activate.sh
# cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/minc-toolkit-v2-deactivate.sh
