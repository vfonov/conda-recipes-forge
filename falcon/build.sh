#! /bin/bash

set -e -x
rm -rf build # remove stale build
mkdir -p build && cd build
# assume correct compilers will be setup by environment
# don't build visual tools though
# use external cache directory
export CMAKE_PREFIX_PATH=${CONDA_PREFIX}

if [[ -z ${MACOSX_DEPLOYMENT_TARGET} ]];then
    # building on linux
    # HACK to make cmake be able to find libm
    ln -sf ${CONDA_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/lib/libm.so.6 ${CONDA_PREFIX}/lib/libm.so
    export CMAKE_LIBRARY_PATH=${CONDA_PREFIX}/lib:${CONDA_PREFIX}/lib64:${CONDA_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/lib
else # building on MacOSX
    export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
    export CC=clang
    export CXX=clang++
    export LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib -headerpad_max_install_names $LDFLAGS"
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
    export CMAKE_LIBRARY_PATH=${CONDA_PREFIX}/lib:${CONDA_PREFIX}/lib64:
fi

cmake .. \
      -DLIBIGL_WITH_OPENGL:BOOL=OFF \
      -DLIBIGL_WITH_OPENGL_GLFW:BOOL=OFF \
      -DLIBIGL_WITH_OPENGL_GLFW_IMGUI:BOOL=OFF \
      -DLIBIGL_WITH_EMBREE:BOOL=ON \
      -DLIBIGL_WITH_PNG:BOOL=ON \
      -DLIBIGL_WITH_COMISO:BOOL=OFF \
      -DLIBIGL_USE_STATIC_LIBRARY:BOOL=OFF \
      -DEMBREE_FILTER_FUNCTION:BOOL=OFF \
      -DEMBREE_GEOMETRY_CURVE:BOOL=OFF \
      -DEMBREE_GEOMETRY_GRID:BOOL=OFF \
      -DEMBREE_GEOMETRY_INSTANCE:BOOL=OFF \
      -DEMBREE_GEOMETRY_POINT:BOOL=ON \
      -DEMBREE_GEOMETRY_QUAD:BOOL=ON \
      -DEMBREE_GEOMETRY_SUBDIVISION:BOOL=OFF \
      -DEMBREE_GEOMETRY_TRIANGLE:BOOL=ON \
      -DEMBREE_GEOMETRY_USER:BOOL=OFF \
      -DEMBREE_IGNORE_CMAKE_CXX_FLAGS:BOOL=OFF \
      -DEMBREE_IGNORE_INVALID_RAYS:BOOL=OFF \
      -DEMBREE_INSTALL_DEPENDENCIES:BOOL=OFF \
      -DEMBREE_STATIC_LIB:BOOL=ON \
      -DEMBREE_TUTORIALS:BOOL=OFF  \
      -DEMBREE_ISPC_SUPPORT:BOOL=OFF \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DBUILD_NVK:BOOL=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DHAVE_POVRAY:BOOL=ON \
      -DMINC_TOOLKIT_DIR:PATH=${CONDA_PREFIX} \
      -DLIBMINC_DIR:PATH=${CONDA_PREFIX}/lib \
      -DTIFF_INCLUDE_DIR:PATH=${CONDA_PREFIX}/lib \
      -DTIFF_LIBRARY_RELEASE:FILEPATH=${CONDA_PREFIX}/lib/libtiff${SHLIB_EXT}

if [[ -z ${MACOSX_DEPLOYMENT_TARGET} ]];then
    cmake ..  -DUSE_OPENMP:BOOL=ON
else
    # OpenMP is not available on MacOSX
    cmake ..  -DUSE_OPENMP:BOOL=OFF
fi

# build and install
make -j${CPU_COUNT} && make install #

#create environment activation & deactivation
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d

mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp $RECIPE_DIR/scripts/activate.sh   $ACTIVATE_DIR/falcon-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/falcon-deactivate.sh
