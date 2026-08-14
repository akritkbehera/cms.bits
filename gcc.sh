package: gcc
version: "14.3.1"
tag: e02b12e7248f8209ebad35d6df214d3421ed8020
variables:
 gccTag: "e02b12e7248f8209ebad35d6df214d3421ed8020"
 gccBranch: "releases/gcc-14"
sources:
 - https://github.com/gcc-mirror/gcc/archive/%(gccTag)s.tar.gz
patches:
 - 0a1d2ea57722c248777e1130de076e28c443ff8b.diff
 - 77d01927bd7c989d431035251a5c196fe39bcec9.diff
build_requires:
 - gcc-prerequisites
prepend_path:
 LD_LIBRARY_PATH: $GCC_ROOT/lib64
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"

# x86_64: align sections to 4096 bytes rather than 2MB to reduce the address
# space wasted relocating many libraries (CMS linker spec patch).
if [ "$(uname -m)" = "x86_64" ]; then
  cat <<'EOF_CONFIG_GCC' >> "$BUILDDIR/gcc/config.gcc"
# CMS patch to include gcc/config/i386/cms.h when building gcc
tm_file="$tm_file i386/cms.h"
EOF_CONFIG_GCC
  cat <<'EOF_CMS_H' > "$BUILDDIR/gcc/config/i386/cms.h"
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

# Set C++ ABI version to the newest (0)
cat <<'EOF_CONFIG_GCC' >> "$BUILDDIR/gcc/config.gcc"
# CMS patch to include gcc/config/general-cms.h when building gcc
tm_file="$tm_file general-cms.h"
EOF_CONFIG_GCC

cat <<'EOF_CMS_H' > "$BUILDDIR/gcc/config/general-cms.h"
#undef CC1PLUS_SPEC
#define CC1PLUS_SPEC "-fabi-version=0"
EOF_CMS_H

# Bootstrap with the system compiler (Linux)
CC="gcc"
CXX="c++"
CPP="cpp"
CXXCPP="c++ -E"
CONF_GCC_OS_SPEC=""

CC="$CC -fPIC"
CXX="$CXX -fPIC"

MARCH="$(gcc -dumpmachine)"

# Stage gcc-prerequisites into the install tree, then rewrite the embedded
# prerequisites path to the gcc install path in the relocated config files.
mkdir -p "${INSTALLROOT}"
rsync -a "${GCC_PREREQUISITES_ROOT}/" "${INSTALLROOT}/"
rm -rf "${INSTALLROOT}"/etc/profile.d/dependencies-setup.*sh "${INSTALLROOT}"/etc/profile.d/init.*sh

OLD="$(sed 's|.*/sw/||' <<< "$GCC_PREREQUISITES_ROOT")"
NEW="$(sed 's|.*/INSTALLROOT/[^/]*/||' <<< "$INSTALLROOT")"
sed -i -e "s|${OLD}|${NEW}|g" \
  "${INSTALLROOT}"/etc/profile.d/debuginfod.*sh \
  "${INSTALLROOT}"/share/fish/vendor_conf.d/debuginfod.fish \
  "${INSTALLROOT}"/bin/eu-make-debug-archive

find "${INSTALLROOT}"/*/lib/ldscripts -type f -exec \
  sed -i -e "s|${OLD}|${NEW}|g" {} +

export PATH="${INSTALLROOT}/tmp/sw/bin:${PATH}"

# Link-time optimization / gold linker (matches the binutils built in gcc-prerequisites)
CONF_GCC_WITH_LTO="--enable-ld=default --enable-lto --enable-gold=yes"

# Architecture-specific configure options
CONF_GCC_ARCH_SPEC="--enable-frame-pointer"
if [ "$(uname -m)" = "x86_64" ]; then
    CONF_GCC_ARCH_SPEC="$CONF_GCC_ARCH_SPEC --with-arch=x86-64-v3"
fi
if [ "$(uname -m)" = "aarch64" ]; then
    CONF_GCC_ARCH_SPEC="$CONF_GCC_ARCH_SPEC --enable-threads=posix --enable-initfini-array --disable-libmpx"
fi
if [ "$(uname -m)" = "ppc64le" ]; then
    CONF_GCC_ARCH_SPEC="$CONF_GCC_ARCH_SPEC --enable-threads=posix --enable-initfini-array --enable-targets=powerpcle-linux --enable-secureplt --with-long-double-128 --with-cpu=power8 --with-tune=power8 --disable-libmpx"
fi

# Mark this as a release build
rm "$BUILDDIR/gcc/DEV-PHASE"
touch "$BUILDDIR/gcc/DEV-PHASE"
mkdir -p "$BUILDDIR/obj"
cd "$BUILDDIR/obj"

export LD_LIBRARY_PATH="$INSTALLROOT/lib64:$INSTALLROOT/lib:$LD_LIBRARY_PATH"

config_args=(
  --prefix="$INSTALLROOT"
  --disable-multilib
  --disable-nls
  --disable-dssi
  --enable-languages="c,c++,fortran"
  --enable-gnu-indirect-function
  --enable-__cxa_atexit
  --disable-libunwind-exceptions
  --enable-gnu-unique-object
  --enable-plugin
  --with-linker-hash-style=gnu
  --enable-linker-build-id
  $CONF_GCC_OS_SPEC
  $CONF_GCC_WITH_LTO
  --with-gmp="$INSTALLROOT"
  --with-mpfr="$INSTALLROOT"
  --enable-bootstrap
  --with-mpc="$INSTALLROOT"
  --with-isl="$INSTALLROOT"
  --enable-checking=release
  --build="$MARCH"
  --host="$MARCH"
  --enable-libstdcxx-time=rt
  $CONF_GCC_ARCH_SPEC
  --enable-shared
  --disable-libgcj
  --with-zstd="$INSTALLROOT/tmp/sw"
  CC="$CC"
  CXX="$CXX"
  CPP="$CPP"
  CXXCPP="$CXXCPP"
  CFLAGS="-I$INSTALLROOT/tmp/sw/include"
  CXXFLAGS="-I$INSTALLROOT/tmp/sw/include"
  LDFLAGS="-L$INSTALLROOT/tmp/sw/lib"
)

"$BUILDDIR/configure" "${config_args[@]}"

# profiledbootstrap: 3-stage build using profile-guided optimization
make ${JOBS:+-j$JOBS} profiledbootstrap
make install

ln -s gcc "$INSTALLROOT/bin/cc"

# Drop docs, temp build tools and static C++ libs
rm -rf "$INSTALLROOT"/share/{man,info,doc,locale}
rm -rf "$INSTALLROOT/tmp"
rm -f "$INSTALLROOT"/lib*/libstdc++.a "$INSTALLROOT"/lib*/libsupc++.a
find "$INSTALLROOT/lib" "$INSTALLROOT/lib64" -name '*.la' -exec rm -f {} \; || true
rm -rf "$INSTALLROOT/lib/pkg-config"
