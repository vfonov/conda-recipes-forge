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



if [[ -z ${MACOSX_DEPLOYMENT_TARGET} ]];then
# linux
    CMAKE_FLAGS="${CMAKE_FLAGS} \ 
    -DOPENGL_EGL_INCLUDE_DIR:PATH=${CONDA_PREFIX}/include \
    -DOPENGL_GLX_INCLUDE_DIR:PATH=${CONDA_PREFIX}/include \
    -DOPENGL_INCLUDE_DIR:PATH=${CONDA_PREFIX}/include \
    -DOPENGL_gl_LIBRARY:FILEPATH=${CONDA_PREFIX}/lib/libGL${SHLIB_EXT} \
    -DOPENGL_glu_LIBRARY:FILEPATH=${CONDA_PREFIX}/lib/libGLU${SHLIB_EXT} \
    -DGLUT_Xmu_LIBRARY:FILEPATH=${CONDA_PREFIX}/lib/libXmu${SHLIB_EXT} \
    -DX11_X11_INCLUDE_PATH:PATH=${CONDA_PREFIX}/include \
    -DX11_Xdamage_INCLUDE_PATH:PATH=${CONDA_PREFIX}/include \
    -DX11_Xi_INCLUDE_PATH:PATH=${CONDA_PREFIX}/include \
    -DX11_Xinerama_INCLUDE_PATH:PATH=${CONDA_PREFIX}/include \
    -DX11_Xcursor_INCLUDE_PATH:PATH=${CONDA_PREFIX}/include \
    -DX11_Xrandr_INCLUDE_PATH:PATH=${CONDA_PREFIX}/include "
#else
# macos
fi


# SET(GLUT_LIBRARY     ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libfreeglut.a )
# # ${GLUT_Xmu_LIBRARY}  ${GLUT_Xi_LIBRARY} ${GLUT_X11_LIBRARY}
# SET(GLUT_LIBRARIES   ${GLUT_LIBRARY} ${X11_X11_LIB} ${OPENGL_gl_LIBRARY} ${OPENGL_opengl_LIBRARY} ${OPENGL_glx_LIBRARY} ${X11_Xrandr_LIB}  ${X11_Xi_LIB} ${X11_Xxf86vm_LIB} )
# SET(GLUT_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )




mkdir -p build && cd build
cmake .. \
      -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DZLIB_INCLUDE_DIR:PATH=${CONDA_PREFIX}/include \
      -DZLIB_LIBRARY_RELEASE:FILEPATH=${CONDA_PREFIX}/lib/libz${SHLIB_EXT} \
      -DLIBMINC_DIR:PATH=${CONDA_PREFIX}/lib/cmake \
      -DBICPL_DIR:PATH=${CONDA_PREFIX}/lib \
      -DBICGL_DIR:PATH=${CONDA_PREFIX}/lib \
      ${CMAKE_FLAGS} \
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
