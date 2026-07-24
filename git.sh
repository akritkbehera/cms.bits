package: git
version: "2.54.0"
build_requires:
 - autotools
requires:
 - curl
 - expat
 - zlib
 - pcre2
 - Python
 - gcc
sources:
 - https://github.com/git/git/archive/v%(version)s.tar.gz
patches:
 - git-2.19.0-runtime.patch
prepend_path:
  PATH: "%(root_dir)s/libexec/git-core"
env:
  GIT_TEMPLATE_DIR: "$GIT_ROOT/share/git-core/templates"
  GIT_EXEC_PATH: "$GIT_ROOT/libexec/git-core"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -s -i "$SOURCEDIR/$PATCH0"
sed -i -e 's|$(sysconfdir)/git|etc/git|' Makefile

export LDFLAGS=""
export NO_LIBPCRE1_JIT=1

make ${JOBS:+-j$JOBS} configure
./configure prefix=$INSTALLROOT \
	--with-curl=${CURL_ROOT} \
        --with-expat=${EXPAT_ROOT} \
        --with-libpcre=${PCRE2_ROOT} \
        --with-python=$(which python3) \
        --with-zlib=${ZLIB_ROOT}

make ${JOBS:+-j$JOBS} \
  NO_GETTEXT=1 \
  NO_R_TO_GCC_LINKER=1 \
  RUNTIME_PREFIX=1 \
  V=1 \
  NO_CROSS_DIRECTORY_HARDLINK=1 \
  NO_INSTALL_HARDLINKS=1 \
  all

export NO_LIBPCRE1_JIT=1
make ${JOBS:+-j$JOBS} \
  V=1 \
  NO_CROSS_DIRECTORY_HARDLINK=1 \
  NO_INSTALL_HARDLINKS=1 \
  install

perl -p -i -e "s|^#!.*python.*|#!/usr/bin/env python3|" $INSTALLROOT/libexec/git-core/git-p4
