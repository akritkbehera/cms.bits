package: rdma-core
version: "%(tag_basename)s"
tag: v57.0
source: https://github.com/linux-rdma/rdma-core
patches:
 - rdma-core-VERBS_CONFIG_DIR.patch
build_requires:
 - CMake
 - ninja
requires:
 - gcc
prepend_path:
  LD_LIBRARY_PATH: $RDMA_CORE_ROOT/lib64
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

patch -p1 < "$SOURCEDIR/$PATCH0"

# currently there is no way to use a custom location for libnl3, so disable neighbours resolution
cmake \
  -G Ninja \
  -S "$BUILDDIR" \
  -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_INSTALL_RUNDIR=/var/run \
  -DENABLE_RESOLVE_NEIGH=FALSE \
  -DENABLE_STATIC=FALSE \
  -DNO_MAN_PAGES=TRUE

cmake -L "$BUILDDIR/build"

ninja -C "$BUILDDIR/build" -v ${JOBS:+-j$JOBS}
ninja -C "$BUILDDIR/build" -v ${JOBS:+-j$JOBS} install

# remove pkg-config to avoid rpm-generated dependency on /usr/bin/pkg-config
rm -rf $INSTALLROOT/lib64/pkgconfig

# keep only the user binaries, libibverbs configuration, libraries and include files
rm -rf $INSTALLROOT/etc/infiniband-diags
rm -rf $INSTALLROOT/etc/init.d
rm -rf $INSTALLROOT/etc/modprobe.d
rm -rf $INSTALLROOT/etc/rdma
rm -rf $INSTALLROOT/lib
rm -rf $INSTALLROOT/libexec
rm -rf $INSTALLROOT/sbin
rm -rf $INSTALLROOT/share/perl5

# update the libibverbs plugins with the full path
sed -e's#driver \(\w\+\)#driver $INSTALLROOT/lib64/libibverbs/lib\1#' -i $INSTALLROOT/etc/libibverbs.d/*
