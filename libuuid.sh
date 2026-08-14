package: libuuid
version: "2.40"
sources:
- http://www.kernel.org/pub/linux/utils/util-linux/v%(version)s/util-linux-%(version)s.tar.gz
patches:
- libuuid-2.40-disable-get_uuid_via_daemon.patch
build_requires:
  - gmake
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"

CMS_BITS_MARCH=$(gcc -dumpmachine)

./configure \
    --libdir=$INSTALLROOT/lib64 \
    --prefix=$INSTALLROOT \
    --build="$CMS_BITS_MARCH" \
    --host="$CMS_BITS_MARCH" \
    --disable-silent-rules \
    --disable-tls \
    --disable-rpath \
    --disable-libblkid \
    --disable-libmount \
    --disable-mount \
    --disable-losetup \
    --disable-fsck \
    --disable-partx \
    --disable-mountpoint \
    --disable-fallocate \
    --disable-unshare \
    --disable-eject \
    --disable-agetty \
    --disable-cramfs \
    --disable-wdctl \
    --disable-switch_root \
    --disable-pivot_root \
    --disable-kill \
    --disable-utmpdump \
    --disable-rename \
    --disable-liblastlog2 \
    --disable-login \
    --disable-sulogin \
    --disable-su \
    --disable-schedutils \
    --disable-wall \
    --disable-makeinstall-setuid \
    --without-ncurses \
    --enable-libuuid

make ${JOBS:+-j$JOBS} uuidd

# There is no make install action for the libuuid libraries only
mkdir -p $INSTALLROOT/lib64
cp -p $BUILDDIR/.libs/libuuid.a* $INSTALLROOT/lib64
cp -p $BUILDDIR/.libs/libuuid.so* $INSTALLROOT/lib64

mkdir -p $INSTALLROOT/include
make install-uuidincHEADERS
