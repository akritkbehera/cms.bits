package: cpu_features
version: 0.9.0
sources:
 - https://github.com/google/cpu_features/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - gmake
 - CMake
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake -S. -Bbuild \
    -DBUILD_TESTING=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX:STRING=$INSTALLROOT

cd build
make install
