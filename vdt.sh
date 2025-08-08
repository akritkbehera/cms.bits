package: vdt
version: "0.4.3"
build_requires:
- CMake
- Python
sources: 
- https://github.com/dpiparo/vdt/archive/v%(version)s.tar.gz
patches:
- vdt-integer-overflow.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < $SOURCEDIR/$PATCH0

[[ "$(uname -m)" == "x86_64" ]] && SSE=ON || SSE=OFF
cmake . \
    -DCMAKE_INSTALL_PREFIX=${INSTALLROOT:-/usr/local} \
    -DPYTHONLIBS_VERSION_STRING=${PYTHON_VERSION:-3.9} \
    -DPRELOAD:BOOL=ON \
    -DSSE:BOOL=$SSE \
    -DNEON:BOOL=OFF

make ${JOBS:+-j$JOBS} VERBOSE=1
make install