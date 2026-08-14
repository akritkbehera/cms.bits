package: openmpi
version: "5.0.10"
variables:
 branch: v5.0.x
 tag: v%(version)s
 HFI_NO_BACKTRACE: "1"
 IPATH_NO_BACKTRACE: "1"
build_requires:
 - autotools
 - flex
 - Python
requires:
 - gcc
 - libfabric
 - hwloc
 - rdma-core
 - xpmem
 - ucx
 - cuda
 - rocm-hip
 - zlib
sources:
 - git://github.com/open-mpi/ompi.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&submodules=1&output=/%(package)s-%(version)s.tgz
patches:
 - openmpi-setenv-fix.patch
env:
  OPAL_PREFIX: "$OPENMPI_ROOT"
  PMIX_PREFIX: "$OPENMPI_ROOT"
prepend_path:
  LD_LIBRARY_PATH: $OPENMPI_ROOT/lib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
patch -p1 -i "$SOURCEDIR/$PATCH0"

# Make sure IPATH_NO_BACKTRACE and HFI_NO_BACKTRACE default values match what we expect
grep ' opal_setenv("IPATH_NO_BACKTRACE", "%(IPATH_NO_BACKTRACE)s", true, &environ)' opal/runtime/opal_init.c
grep ' opal_setenv("HFI_NO_BACKTRACE", "%(HFI_NO_BACKTRACE)s", true, &environ)' opal/runtime/opal_init.c

AUTOMAKE_JOBS=${JOBS:-1} ./autogen.pl
unset HWLOC_VERSION

CONFIGURE_OPTS="\
  --prefix=$INSTALLROOT \
  --disable-dependency-tracking \
  --enable-ipv6 \
  --enable-shared \
  --disable-static \
  --disable-mpi-java \
  --with-zlib=$ZLIB_ROOT \
  --with-hwloc=$HWLOC_ROOT \
  --with-ofi=$LIBFABRIC_ROOT \
  --without-portals4 \
  --without-psm2 \
  --with-ucx=$UCX_ROOT \
  --with-cma \
  --without-knem \
  --with-xpmem=$XPMEM_ROOT \
  --with-pic \
  --disable-io-romio \
  --with-gnu-ld \
  --with-pmix=internal \
  "
[ -n "$CUDA_ROOT" ] && CONFIGURE_OPTS+=" --with-cuda=$CUDA_ROOT --with-cuda-libdir=$CUDA_ROOT/lib64/stubs"
[ -n "$ROCM_ROOT" ] && CONFIGURE_OPTS+=" --with-rocm=$ROCM_ROOT"

./configure $CONFIGURE_OPTS
make ${JOBS:+-j$JOBS}
make install

# remove the libtool library files
find $INSTALLROOT/lib/ -name '*.la' -delete
