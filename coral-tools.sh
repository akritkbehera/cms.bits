package: coral-tools
version: "v1"
tag: cb06ad14f7ba04453ee45667de5648bd5fd38eaa
source: https://github.com/akritkbehera/scram-tools.file.git
variables:
  skipreqtools: jcompiler
  override_microarch: "-march=x86-64-v2"
  package_vectorization: ""
  vectorized_packages: ""
  gpu_backend_specific_packages: ""
  gpu_types: ""
  default_microarch: "-march=x86-64-v2"
  cuda_gcc_support: "true"
  override_microarch_name: ""
  min_microarch_name: "-march=x86-64-v2"
  use_system_gcc: "0"
requires:
  # Core build toolchain
  - gcc
  # Python and its dependencies
  - Python
  - zlib
  - bz2lib
  - expat
  - xz
  - db6
  - libuuid
  - gdbm
  - libffi
  - sqlite
  - curl
  # HPC and parallel computing libraries
  - numactl
  - fmt
  - zstd
  # GPU support (NVIDIA and AMD)
  - cuda
  - rocm
  # High-performance networking and communication
  - xpmem
  - gdrcopy
  - rdma-core
  - libpciaccess
  - libxml2
  - hwloc
  - libfabric
  - ucx
  # MPI and network utilities
  - pacparser
  - openmpi
  # XML processing and testing
  - xerces-c
  - cppunit
  - pcre
  # CMS-specific dependencies
  - frontier_client
  - boost
  - oracle
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
chmod +x "$BUILDDIR/bin/get_tools"
chmod +x "$BUILDDIR/bin/fix_tool_variables"
[ -f "$BUILDDIR/bin/get_vectorized_tools" ] && chmod +x "$BUILDDIR/bin/get_vectorized_tools"
#!include  <microarch-flag.sh>
#!include  <tool-conf-src.file>
mkdir -p touch $INSTALLROOT/etc/profile.d
touch $INSTALLROOT/etc/profile.d/post-relocate.sh
cat >"$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF
  cp $INSTALLROOT/tools/selected.tmpl \$WORK_DIR/$PKGNAME.selected.tmpl
  cp $INSTALLROOT/tools/available.tmpl \$WORK_DIR/$PKGNAME.available.tmpl
EoF
