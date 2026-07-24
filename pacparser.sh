package: pacparser
version: 1.5.0
sources:
 - https://github.com/manugarg/pacparser/archive/refs/tags/v%(version)s.tar.gz
patches:
 - pacparser-pymod-install.patch
build_requires:
 - setuptools
requires:
 - Python
 - gcc
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -s -i "$SOURCEDIR/$PATCH0"

CFLAGS='-pthread' make -C src all pymod \
  PREFIX=$INSTALLROOT \
  PYTHON=$(which python3)

make -C src install install-pymod \
  PREFIX=$INSTALLROOT \
  PYTHON=$(which python3) \
  EXTRA_ARGS="--prefix=$INSTALLROOT"

find $INSTALLROOT/lib -type f | xargs chmod 0755
