package: perfetto
version: "56.1"
sources:
  - https://github.com/google/perfetto/releases/download/v%(version)s/perfetto-cpp-sdk-src.zip
requires:
  - gcc
---
# The Perfetto C++ tracing SDK ships as a self-contained amalgamation (perfetto.h +
# perfetto.cc), no dependencies beyond libstdc++ and pthread. The zip has no top-level
# directory, so unpack it into the build dir directly.
unzip -q -o "$SOURCEDIR/${SOURCE0}" -d "$BUILDDIR"

mkdir -p "$INSTALLROOT/lib" "$INSTALLROOT/include"

# Compile the amalgamation into a single shared library.
g++ -std=c++%(cms_cxx_std)s -O2 -fPIC -pthread -DNDEBUG -Wno-redundant-move \
    -shared -Wl,-soname,libperfetto.so \
    -o "$INSTALLROOT/lib/libperfetto.so" "$BUILDDIR/perfetto.cc" -lpthread

cp -p "$BUILDDIR/perfetto.h" "$INSTALLROOT/include/perfetto.h"
