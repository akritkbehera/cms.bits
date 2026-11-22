package: ittnotify
version: 3.28.4
sources:
 - https://github.com/intel/ittapi/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake -S "$BUILDDIR" -B "$BUILDDIR/build" -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
cmake --build "$BUILDDIR/build" --parallel "${JOBS:-1}"
cmake --install "$BUILDDIR/build"
