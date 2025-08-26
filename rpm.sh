package: rpm
version: 4.18.0
tag: 10c1f38c4c5e4c62a879801e34a0aa042207cd53
variables:
    github_user: cms-externals
    github_repo: rpm-upstream
    branch: cms/rpm-%(version)s-release
sources:
    - git+https://github.com/%(github_user)s/%(github_repo)s.git?branch=%(branch)s/%(tag_basename)s}&export=rpm-%(version)s&output=/rpm-%(version)s.tgz
build_requires:
    - autotools
    - gcc
    - bootstrap-bundle
    - lua-bootstrap
env:
    RPM_CONFIGDIR: "%(root_dir)s/libx/rpm"
    RPM_POPTEXEC_PATH: "%(root_dir)s/bin"
    MAGIC: "%(root_dir)s/share/misc/magic.mgc"
---
CMS_BITS_MARCH=$(gcc -dumpmachine)bi
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

autoreconf -fiv

CFLAGS_PLATF="-fPIC"
if [[ "$OSTYPE" == "darwin"* ]]; then
    CFLAGS_PLATF="-arch x86_64 -fPIC -D_FORTIFY_SOURCE=0"
    export LIBS_PLATF="-liconv"
else
    case "$(uname -m)" in
        aarch64)
            LIBS_PLATF="-ldl -lrt -pthread"
            ;;
        x86_64)
            LIBS_PLATF="-ldl"
            ;;
    esac
fi

USER_CFLAGS="-ggdb -O0"
USER_CXXFLAGS="-ggdb -O0"

if [[ -z "${use_system_gcc:-}" && "$OSTYPE" == "linux-gnu" ]]; then
    OS_CFLAGS="-I$GCC_ROOT/include"
    OS_CXXFLAGS="-I$GCC_ROOT/include"
    OS_CPPFLAGS="-I$GCC_ROOT/include"
    OS_LDFLAGS="-L$GCC_ROOT/lib"
fi


perl -p -i -e's|-O2|-O0|' ./configure
./configure --prefix $INSTALLROOT --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
    --with-external-db --disable-python --disable-nls --with-archive \
    --disable-rpath --with-lua --localstatedir=$INSTALLROOT/var --with-lua-lib=$BOOTSTRAP_BUNDLE_ROOT/lib \
    CXXFLAGS="$USER_CXXFLAGS $OS_CXXFLAGS" \
    CFLAGS="$CFLAGS_PLATF $USER_CFLAGS -I$BOOTSTRAP_BUNDLE_ROOT/include \
            $OS_CFLAGS -I/usr/include/nspr4 -I/usr/include/nss3" \
    LDFLAGS="-L$BOOTSTRAP_BUNDLE_ROOT/lib $OS_LDFLAGS" \
    CPPFLAGS="-I$BOOTSTRAP_BUNDLE_ROOT/include \
              $OS_CPPFLAGS -I/usr/include/nspr4 -I/usr/include/nss3" \
    LIBS="-lnspr4 -lnss3 -lnssutil3 -lplds4 -lbz2 -lplc4 -lz -lpopt -llzma \
          -ldb -llua -larchive $LIBS_PLATF"


perl -p -i -e "s|#\!.*perl(.*)|#!/usr/bin/env perl$1|"     $(grep -R '#! */usr/bin/perl' . | sed 's|:.*||' | sort | uniq)
perl -p -i -e "s|#\!.*python(.*)|#!/usr/bin/env python$1|" $(grep -R '#! */usr/bin/python' . | sed 's|:.*||' | sort | uniq)

make install