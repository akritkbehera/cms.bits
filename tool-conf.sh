package: tool-conf
version: v1
variables:
  tag: bd299a84cde9e2efed17b220969b6daf2ca3447e
sources:
  - https://github.com/akritkbehera/scram-tools.file/archive/%(tag)s.tar.gz
requires:
  - gcc
  - zlib
  - bz2lib
  - expat
  - xz
  - db6
  - libuuid
  - gdbm
  - libffi
  - sqlite
  - Python
  - curl
  - numactl
  - fmt
  - zstd
  - cuda
  - rocm
  - xpmem
  - gdrcopy
  - rdma-core
  - libpciaccess
  - libxml2
  - hwloc
  - libfabric
  - ucx
  - pacparser
  - openmpi
  - xerces-c
  - cppunit
  - pcre
  - frontier_client
  - boost
  - oracle
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$INSTALLROOT"
export SCRAM_TOOLS_BIN_DIR=$BUILDDIR/bin
python3 /home/akbehera/Desktop/bitsorg/scram/tools.py
