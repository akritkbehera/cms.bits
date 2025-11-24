package: patchelf-bootstrap
version: "0.13"
variables:
 git_branch: master
sources:
 - https://github.com/NixOS/patchelf/releases/download/%(version)s/patchelf-%(version)s.tar.bz2
build_requires:
 - autotools
requires:
 - autotools
---
tar -xjf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./bootstrap.sh
./configure --prefix=$INSTALLROOT

make ${JOBS:+-j$JOBS}
make install
