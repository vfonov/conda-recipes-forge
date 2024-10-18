#! /bin/bash
set -e

# assume correct compilers will be setup by environment

export CMAKE_PREFIX_PATH=${CONDA_PREFIX}

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

mkdir -p build && cd build
cmake .. \
      -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DZLIB_INCLUDE_DIR:PATH=${CONDA_PREFIX}/include \
      -DZLIB_LIBRARY_RELEASE:FILEPATH=${CONDA_PREFIX}/lib/libz${SHLIB_EXT} \
      -DLIBMINC_DIR:PATH=${CONDA_PREFIX}/lib/cmake \
      -DNETPBM_INCLUDE_DIR:PATH=${CONDA_PREFIX}/include/netpbm \
      -DNETPBM_LIBRARY:FILEPATH=${CONDA_PREFIX}/lib/libnetpbm${SHLIB_EXT} \
      -DBUILD_TESTING:BOOL=OFF 

# build and install
make -j${CPU_COUNT}

# fix a missing directory bug (?)
#mkdir -p ${PREFIX}/share
make install

#create environment activation & deactivation
#ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
#DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
#mkdir -p $ACTIVATE_DIR
#mkdir -p $DEACTIVATE_DIR

#cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/minctools-activate.sh
#cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/minctools-deactivate.sh
