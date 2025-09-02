package: openmpi
version: "%(tag_basename)s"
tag: e6d2cb856f3fc649aa01bd5b688a003b3b33db7d
build_requires:
  - autotools
  - flex
requires:
 - gcc
 - libfabric
 - hwloc
 - rdma-core
 - xpmem
 - ucx
 - cuda
sources:
 - https://github.com/open-mpi/ompi/archive/%(tag_basename)s.tar.gz
env:
  OPAL_PREFIX: "$OPENMPI_ROOT"
prepend_path:
  LD_LIBRARY_PATH: $OPENMPI_ROOT/lib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

AUTOMAKE_JOBS=${JOBS:+-j$JOBS} ./autogen.pl
unset HWLOC_VERSION

CONFIGURE_OPTS="\
  --prefix=$INSTALLROOT \
  --disable-dependency-tracking \
  --enable-ipv6 \
  --enable-mpi-cxx \
  --enable-shared \
  --disable-static \
  --enable-cxx-exceptions \
  --disable-mpi-java \
  --enable-openib-rdmacm-ibaddr \
  --with-zlib=$ZLIB_ROOT \
  --with-hwloc=$HWLOC_ROOT \
  --with-ofi=$LIBFABRIC_ROOT \
  --without-portals4 \
  --without-psm \
  --without-psm2 \
  --with-verbs=$RDMA_CORE_ROOT \
  --without-mxm \
  --with-ucx=$UCX_ROOT \
  --with-cma \
  --without-knem \
  --with-xpmem=$XPMEM_ROOT \
  --without-x \
  --with-pic \
  --with-gnu-ld \
  --with-pmix=internal \
  "
[ -z "$without_cuda" ] && CONFIGURE_OPTS+=" --with-cuda=$CUDA_ROOT"

export LDFLAGS=-Wl,--enable-new-dtags
./configure $CONFIGURE_OPTS --with-wrapper-ldflags="-Wl,-rpath,\$ORIGIN/../lib -Wl,--enable-new-dtags"
make ${JOBS:+-j$JOBS}
make install

#sed -i \
#  -e 's|-Wl,-rpath -Wl,@{libdir}||g' \
#  -e 's|\(.*-Wl,-rpath,\$ORIGIN/../lib\).*--enable-new-dtags|\1 -Wl,--enable-new-dtags|' \
#  $INSTALLROOT/share/openmpi/*wrapper-data.txt
find $INSTALLROOT/lib/ -name '*.la' -delete 
