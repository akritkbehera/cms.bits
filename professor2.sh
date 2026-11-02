package: professor2
version: 2.4.2
sources:
  - git+https://gitlab.com/hepcedar/professor.git?obj=main/professor-%(version)s&export=professor-%(version)s&output=/professor-%(version)s.tgz
patches:
  - professor2-ppc64-flag-change.patch
requires:
  - py-matplotlib
  - ROOT
  - yoda
  - eigen
  - py-iminuit
  - setuptools
  - gcc
build_requires:
  - py-cython
  - pip
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

ARCH=$(uname -m)

if [[ "$ARCH" == "ppc64le" ]]; then
    patch -p1 < "$SOURCEDIR/$PATCH0"
fi

if [[ "$ARCH" == "riscv64" ]]; then
    sed -i -e 's|-march=native||' Makefile
fi

grep -q 'std=c[+][+]11' pyext/setup.py
sed -i -e "s|-std=c[+][+]11|-std=c++$CXXSTD|" pyext/setup.py
grep -q 'CXXSTD := c[+][+]11' Makefile
sed -i -e "s|CXXSTD := c[+][+]11|CXXSTD := c++$CXXSTD|" Makefile
sed -i -e "s|pip install -vv|pip install --no-build-isolation --target ../${PYTHON3_LIB_SITE_PACKAGES} -vv|" Makefile

for i in `ls bin`
do
   echo "bin/${i}"
   sed -i -e 's|/usr/bin/env python|/usr/bin/env python3|' "bin/${i}"
done

export build_flags="CPPFLAGS=-I${EIGEN_ROOT}/include/eigen3 PYTHON=$(which python3) PROF_VERSION=$PKG_VERSION PYTHONPATH=./${PYTHON3_LIB_SITE_PACKAGES}:./pyext/professor2:${PYTHON3PATH}"

# PIP_ROOT names the BITS dependency but pip treats it as --root.
unset PIP_ROOT
make PREFIX="$INSTALLROOT" $build_flags
make install PREFIX="$INSTALLROOT" $build_flags

# Install the Python extension explicitly: the upstream make install path can
# copy the Python sources without the wheel-built core extension.
CPPFLAGS="-I${EIGEN_ROOT}/include/eigen3 ${CPPFLAGS:-}" \
PROF_ROOT="$BUILDDIR" PROF_VERSION="$PKGVERSION" python3 -m pip install \
  --no-deps --no-index --no-build-isolation --upgrade \
  --target "$INSTALLROOT/$PYTHON3_LIB_SITE_PACKAGES" "$BUILDDIR/pyext"
PYTHONPATH="$INSTALLROOT/$PYTHON3_LIB_SITE_PACKAGES${PYTHONPATH:+:$PYTHONPATH}" \
LD_LIBRARY_PATH="$INSTALLROOT/lib:$INSTALLROOT/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
  python3 -c 'import professor2.core'

#mv $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/$PKGNAME-$PKG_VERSION*.dist* $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/$PKGNAME
rm -f $INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/*.pth
