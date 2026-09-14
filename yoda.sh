package: yoda
version: "2.1.2"
variables:
  tag: "yoda-2.1.2"
requires:
 - Python
 - gcc
 - ROOT
 - hdf5
 - highfive
 - zlib
 - openmpi
build_requires:
 - py-cython
 - autotools
sources:
  - https://gitlab.com/hepcedar/yoda/-/archive/%(tag)s/yoda-%(tag)s.tar.gz
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
autoreconf -fiv
sed -i 's|/usr/bin/env python|/usr/bin/env python3|g' $(grep -rl '/usr/bin/env python' .)
PYTHON=$(which python3) ./configure --prefix=$INSTALLROOT --enable-root --with-highfive=${HIGHFIVE_ROOT} CXX="mpicxx"
make ${JOBS:+-j$JOBS}
make install
