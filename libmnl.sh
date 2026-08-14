package: libmnl
version: "1.0.5"
sources:
 - https://netfilter.org/projects/libmnl/files/libmnl-%(version)s.tar.bz2
build_requires:
 - gmake
requires:
 - gcc
---
tar -xjf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cd "$BUILDDIR"
./configure --prefix="$INSTALLROOT" --disable-static
make ${JOBS:+-j$JOBS}
make install
