package: patchelf-bootstrap
version: "0.13"
variables:
 git_branch: master
sources: 
 - git://github.com/NixOS/patchelf.git?obj=%(git_branch)s/%(version)s&export=patchelf-%(version)s&output=/patchelf-%(version)s.tgz
build_requires:
 - autotools
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./bootstrap.sh
./configure --prefix=$INSTALLROOT

make ${JOBS:+-j$JOBS}
make install
