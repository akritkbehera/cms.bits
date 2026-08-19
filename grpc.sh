package: grpc
version: "1.48.4"
sources:
 - git+https://github.com/grpc/grpc.git?obj=master/v%(version)s&export=%(package)s-%(version)s&submodules=1&output=/%(package)s-%(version)s.tgz
build_requires:
 - CMake
 - ninja
 - go
requires:
 - gcc
 - protobuf
 - zlib
 - pcre
 - c-ares
 - abseil-cpp
 - re2
patches:
 - grpc-mno-outline-atomics.patch
 - grpc-openssl-no-engine.patch
 - grpc-fix-aligned_storage.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"
patch -p1 < "$SOURCEDIR/$PATCH2"

CMAKE_ARGS=(
    -G Ninja
    -S "$BUILDDIR"
    -B "$BUILDROOT/$PKGNAME.build"
    -DgRPC_INSTALL=ON
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s
    -DBUILD_SHARED_LIBS=ON
    -DCMAKE_INSTALL_LIBDIR=lib
    -DgRPC_ABSL_PROVIDER=package
    -DgRPC_CARES_PROVIDER=package
    -DgRPC_PROTOBUF_PROVIDER=package
    -DgRPC_SSL_PROVIDER=package
    -DgRPC_ZLIB_PROVIDER=package
    -DgRPC_RE2_PROVIDER=package
    -DZLIB_ROOT="${ZLIB_ROOT}"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_PREFIX_PATH="${PCRE_ROOT};${PROTOBUF_ROOT};${ZLIB_ROOT};${C_ARES_ROOT};${ABSEIL_CPP_ROOT};${RE2_ROOT}"
)

cmake "${CMAKE_ARGS[@]}"

ninja -C "$BUILDROOT/$PKGNAME.build" -v ${JOBS:+-j$JOBS}
ninja -C "$BUILDROOT/$PKGNAME.build" -v ${JOBS:+-j$JOBS} install
rm -rf "$INSTALLROOT/include/absl"
cp -rL "$ABSEIL_CPP_ROOT/include/absl" "$INSTALLROOT/include/absl"
