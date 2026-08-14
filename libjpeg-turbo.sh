package: libjpeg-turbo
version: "3.0.4"
sources:
 - https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/%(version)s.tar.gz
build_requires:
 - nasm
 - autotools
 - gmake
 - CMake
requires:
 - gcc
prepend_path:
  LD_LIBRARY_PATH: $LIBJPEG_TURBO_ROOT/lib64
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

# Update to get AArch64
CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
rm -f "$BUILDDIR"/config.{sub,guess}
curl -L -k -s -o "$BUILDDIR"/config.guess "$CONFIG_BASE_URL/config.guess"
curl -L -k -s -o "$BUILDDIR"/config.sub "$CONFIG_BASE_URL/config.sub"
chmod +x "$BUILDDIR"/config.{sub,guess}

CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_ASM_NASM_COMPILER="${NASM_ROOT}/bin/nasm"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DENABLE_SHARED=TRUE
    -DENABLE_STATIC=FALSE
    -DWITH_JPEG8=TRUE
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS}
make -C "$BUILDDIR/build" install
