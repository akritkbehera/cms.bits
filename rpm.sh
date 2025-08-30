package: rpm
version: "%(tag_basename)s"
tag: "cms/rpm-4.18.0-release"
source: https://github.com/cms-externals/rpm-upstream
build_requires:
    - autotools
    - gcc
    - bootstrap-bundle
    - patchelf-bootstrap
env:
    RPM_CONFIGDIR: "%(root_dir)s/libx/rpm"
    RPM_POPTEXEC_PATH: "%(root_dir)s/bin"
    MAGIC: "%(root_dir)s/share/misc/magic.mgc"
---
CMS_BITS_MARCH=$(gcc -dumpmachine)

rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

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

./configure \
  --prefix="$INSTALLROOT" \
  --build="$CMS_BITS_MARCH" \
  --host="$CMS_BITS_MARCH" \
  --disable-python \
  --disable-nls \
  --with-archive \
  --disable-rpath \
  --with-crypto=openssl \
  --enable-zstd \
  --enable-ndb=yes \
  --enable-sqlite=yes \
  --localstatedir="$INSTALLROOT/var" \
  --with-lua-lib="$BOOTSTRAP_BUNDLE_ROOT/lib" \
  CXXFLAGS="$USER_CXXFLAGS $OS_CXXFLAGS" \
  CFLAGS="$CFLAGS_PLATF $USER_CFLAGS -I$BOOTSTRAP_BUNDLE_ROOT/include \
          $OS_CFLAGS -I/usr/include/nspr4 -I/usr/include/nss3" \
  LDFLAGS="-L$BOOTSTRAP_BUNDLE_ROOT/lib $OS_LDFLAGS" \
  CPPFLAGS="-I$BOOTSTRAP_BUNDLE_ROOT/include \
            $OS_CPPFLAGS -I/usr/include/nspr4 -I/usr/include/nss3" \
  LIBS="-lnspr4 -lnss3 -lnssutil3 -lplds4 -lbz2 -lplc4 -lz -lpopt \
        -llzma -lsqlite3 -llua -larchive $LIBS_PLATF" \
  ZSTD_CFLAGS="-I$BOOTSTRAP_BUNDLE_ROOT/include" \
  ZSTD_LIBS="-lzstd"

make install