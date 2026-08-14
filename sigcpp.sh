package: sigcpp
version: "3.2.0"
sources:
 - https://github.com/libsigcplusplus/libsigcplusplus/archive/refs/tags/%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
	-DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS}
make -C "$BUILDDIR/build" install
rm -rf $INSTALLROOT/lib/pkgconfig
cp $INSTALLROOT/lib/sigc++-3.0/include/sigc++config.h $INSTALLROOT/include/sigc++-3.0/
