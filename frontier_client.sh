package: frontier_client
version: 2.10.2
sources:
 - http://frontier.cern.ch/dist/frontier_client__%(version)s__src.tar.gz
patches:
 - frontier_client_py312.patch
requires:
 - gcc
 - expat
 - pacparser
 - zlib
prepend_path:
  PYTHON3PATH: "%(root_dir)s/python/lib"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"

export MAKE_ARGS="EXPAT_DIR=${EXPAT_ROOT} PACPARSER_DIR=${PACPARSER_ROOT} COMPILER_TAG=gcc_$(gcc -dumpfullversion) ZLIB_DIR=${ZLIB_ROOT}"

make $MAKE_ARGS CXXFLAGS="-ldl" CFLAGS=""

mkdir -p "$INSTALLROOT/lib"
mkdir -p "$INSTALLROOT/include"
make $MAKE_ARGS CXXFLAGS="-ldl" distdir="$INSTALLROOT" dist

cp -r python "$INSTALLROOT"

ln -sf "libfrontier_client.so.%(version)s" "$INSTALLROOT/lib/libfrontier_client.so"
ln -sf "libfrontier_client.so.%(version)s" "$INSTALLROOT/lib/libfrontier_client.so.$(echo %(version)s | cut -d. -f1)"
