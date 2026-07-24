package: gmake
version: "4.3"
sources:
 - https://ftp.gnu.org/gnu/make/make-%(version)s.tar.gz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cd "$BUILDDIR"
./configure --prefix=$INSTALLROOT
make ${JOBS:+-j$JOBS}
make install
rm -rf $INSTALLROOT/{man,info}
cd $INSTALLROOT/bin
ln -sf make gmake
