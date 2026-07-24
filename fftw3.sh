package: FFTW3
version: "3.3.8"
sources:
 - http://www.fftw.org/fftw-%(version)s.tar.gz
build_requires:
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMS_BITS_MARCH=$(gcc -dumpmachine)

CONFIG_ARGS="--with-pic --enable-shared --enable-threads --disable-fortran
             --disable-dependency-tracking --disable-mpi --disable-openmp
             --prefix=${INSTALLROOT} --build=${CMS_BITS_MARCH} --host=${CMS_BITS_MARCH}"

if [ "$(uname -m)" = "x86_64" ]; then
  CONFIG_ARGS="${CONFIG_ARGS} --enable-sse2"
fi

cd "$BUILDDIR"
./configure ${CONFIG_ARGS}
make ${JOBS:+-j$JOBS}
make install
