package: yoda
version: "v2.1.0"
tag: "yoda-2.1.0"
requires:
- Python
- ROOT
- hdf5
- highfive
build_requires:
- py-cython
- autotools
source: https://gitlab.com/hepcedar/yoda.git
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
autoreconf -fiv
export PYTHONHOME=$PYTHON_ROOT
PYTHON=$(which python3) ./configure --prefix=$INSTALLROOT --enable-root --with-highfive=${HIGHFIVE_ROOT} CXX="mpicxx"
make ${JOBS:+-j$JOBS}
make install
