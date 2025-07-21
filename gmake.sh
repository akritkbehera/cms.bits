package: gmake
version: "%(tag_basename)s"
tag: "4.3"
sources:
 - ftp://ftp.gnu.org/gnu/make/make-%(tag_basename)s.tar.gz
---
tar -xzf "$SOURCEDIR"/*.tar.gz -C "$BUILDDIR"
cd $BUILDDIR/make-*
./configure --prefix=$INSTALLROOT
make ${JOBS+-j $JOBS}
make install
rm -rf $INSTALLROOT/{man,info}
cd $INSTALLROOT/bin
ln -sf make gmake
