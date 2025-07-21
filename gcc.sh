package: gcc
version: "14.3.1"
tag: e02b12e7248f8209ebad35d6df214d3421ed8020
variables:
 gccTag: "e02b12e7248f8209ebad35d6df214d3421ed8020"
 gccBranch: "releases/gcc-14"
sources: 
 - https://github.com/gcc-mirror/gcc/archive/%(gccTag)s.tar.gz 
 - https://github.com/gcc-mirror/gcc/commit/0a1d2ea57722c248777e1130de076e28c443ff8b.diff
 - https://github.com/gcc-mirror/gcc/commit/77d01927bd7c989d431035251a5c196fe39bcec9.diff
patches:
 - 0a1d2ea57722c248777e1130de076e28c443ff8b.diff
 - 77d01927bd7c989d431035251a5c196fe39bcec9.diff
requires:
 - gcc-prerequisites
---
for f in "$SOURCEDIR"/*; do
    case "$f" in
        *.diff|*.patch) cp -- "$f" "$BUILDDIR";;
        *.tar.gz|*.tgz) tar -xzf "$f" -C "$BUILDDIR";;
        *.tar.bz2) tar -xjf "$f" -C "$BUILDDIR";;
        *.tar.xz) tar -xJf "$f" -C "$BUILDDIR";;
        *.tar) tar -xf "$f" -C "$BUILDDIR";;
    esac
done

cp $PATCH0 $PATCH1 gcc-*/
cd gcc-*
patch -p1 < $PATCH0
patch -p1 < $PATCH1
cd $BUILDDIR
<<'DISABLE'
cat << \EOF > ${PKGNAME}-req
#!/bin/sh
%{__find_requires} $* | \
sed -e '/GLIBC_PRIVATE/d'
EOF
%global __find_requires %{_builddir}/%{moduleName}/%{name}-req
chmod +x %{__find_requires}
DISABLE
OS="$(uname)"
ARCH="$(uname -m)"

patch_gcc_cms() {
  cd gcc-*
  # Only on 64-bit Linux
  if [[ "$OS" == "Linux" ]] && [[ "$ARCH" == "x86_64" ]]; then
    cat <<\EOF_CONFIG_GCC >> gcc/config.gcc
# CMS patch to include gcc/config/i386/cms.h when building gcc
tm_file="$tm_file i386/cms.h"
EOF_CONFIG_GCC

    cat <<\EOF_CMS_H > gcc/config/i386/cms.h
#undef LINK_SPEC
#define LINK_SPEC "%{" SPEC_64 ":-m elf_x86_64} %{" SPEC_32 ":-m elf_i386} \
 %{shared:-shared} \
 %{!shared: \
   %{!static: \
     %{rdynamic:-export-dynamic} \
     %{" SPEC_32 ":%{!dynamic-linker:-dynamic-linker " GNU_USER_DYNAMIC_LINKER32 "}} \
     %{" SPEC_64 ":%{!dynamic-linker:-dynamic-linker " GNU_USER_DYNAMIC_LINKER64 "}}} \
   %{static:-static}} -z common-page-size=4096 -z max-page-size=4096"
EOF_CMS_H
  fi

  # Always include the general CMS header
  cat <<\EOF_CONFIG_GCC >> gcc/config.gcc
# CMS patch to include gcc/config/general-cms.h when building gcc
tm_file="$tm_file general-cms.h"
EOF_CONFIG_GCC

  cat <<\EOF_CMS_H > gcc/config/general-cms.h
#undef CC1PLUS_SPEC
#define CC1PLUS_SPEC "-fabi-version=0"
EOF_CMS_H
cd ..
}

if [ "$OS" = "Darwin"]; then
  export CC="clang"
  export CXX="clang++"
  export CPP="clang -E"
  export CXXCPP="clang++ -E"
  export ADDITIONAL_LANGUAGES=",objc,obj-c++"
  export CONF_GCC_OS_SPEC=""
else
  export CC="gcc"
  export CXX="c++"
  export CPP="cpp"
  export CXXCPP="c++ -E"
  export CONF_GCC_OS_SPEC=""
fi

CXXFLAGS="-O2"
CFLAGS="-O2"
CC="$CC -fPIC"
CXX="$CXX -fPIC"
OLD="$(sed 's|.*/sw/||' <<< "$GCC_PREREQUISITES_ROOT")"
NEW="$(sed 's|.*/INSTALLROOT/[^/]*/||' <<< "$INSTALLROOT")"
rsync -a ${GCC_PREREQUISITES_ROOT}/ ${INSTALLROOT}/
rm -rf ${INSTALLROOT}/etc/profile.d/dependencies-setup.*sh ${INSTALLROOT}/etc/profile.d/init.*sh

sed -i -e "s|${OLD}|${NEW}|g" \
  ${INSTALLROOT}/etc/profile.d/debuginfod.*sh \
  ${INSTALLROOT}/share/fish/vendor_conf.d/debuginfod.fish \
  ${INSTALLROOT}/bin/eu-make-debug-archive

find "${INSTALLROOT}"/*/lib/ldscripts -type f -exec \
  sed -i -e "s|${OLD}|${NEW}|g" {} +

export PATH="${INSTALLROOT}/tmp/sw/bin:${PATH}"

CONF_GCC_ARCH_SPEC="--enable-frame-pointer"

if [ "$ARCH" = "x86_64" ]; then
    if [ $(grep -oE '[0-9]+' /etc/redhat-release 2>/dev/null | head -1 || echo 0) -gt 9 ]; then
        CONF_GCC_ARCH_SPEC="$CONF_GCC_ARCH_SPEC --with-arch=x86-64-v3"
    fi
fi

if [ "$ARCH" = "aarch64" ]; then
    CONF_GCC_ARCH_SPEC="$CONF_GCC_ARCH_SPEC \
                        --enable-threads=posix --enable-initfini-array --disable-libmpx"
fi

if [ "$ARCH" = "ppc64le" ]; then
    CONF_GCC_ARCH_SPEC="$CONF_GCC_ARCH_SPEC \
                        --enable-threads=posix --enable-initfini-array \
                        --enable-targets=powerpcle-linux --enable-secureplt --with-long-double-128 \
                        --with-cpu=power8 --with-tune=power8 --disable-libmpx"
fi

ls -l

cd gcc-*
rm gcc/DEV-PHASE
touch gcc/DEV-PHASE
mkdir -p obj
cd obj

export LD_LIBRARY_PATH=$INSTALLROOT/lib64:$INSTALLROOT/lib:$LD_LIBRARY_PATH

../configure --prefix=$INSTALLROOT --disable-multilib --disable-nls --disable-dssi \
             --enable-languages=c,c++,fortran$ADDITIONAL_LANGUAGES --enable-gnu-indirect-function \
             --enable-__cxa_atexit --disable-libunwind-exceptions --enable-gnu-unique-object \
             --enable-plugin --with-linker-hash-style=gnu --enable-linker-build-id \
             $CONF_GCC_OS_SPEC $CONF_GCC_WITH_LTO --with-gmp=$INSTALLROOT --with-mpfr=$INSTALLROOT --enable-bootstrap \
             --with-mpc=$INSTALLROOT --with-isl=$INSTALLROOT --enable-checking=release \
              --build="$MARCH" --host="$MARCH" $CONF_GCC_ARCH_SPEC \
             --enable-shared --disable-libgcj \
             --with-zstd=$INSTALLROOT/tmp/sw \
             CC="$CC" CXX="$CXX" CPP="$CPP" CXXCPP="$CXXCPP" \
             CFLAGS="-I$INSTALLROOT/tmp/sw/include" CXXFLAGS="-I$INSTALLROOT/tmp/sw/include" LDFLAGS="-L$INSTALLROOT/tmp/sw/lib"

make ${JOBS:+-j "$JOBS"} profiledbootstrap

cd $BUILDDIR/gcc-*/obj && make install
ln -s gcc $INSTALLROOT/bin/cc
find $INSTALLROOT/lib $INSTALLROOT/lib64 -name '*.la' -exec rm -f {} \; || true
