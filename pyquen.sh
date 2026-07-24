package: pyquen
version: 1.5.4
sources:
 - https://github.com/akritkbehera/pyquen/archive/refs/tags/v%(version)s.tar.gz
patches:
 - pyquen-gcc15.patch
build_requires:
 - CMake
 - gmake
requires:
 - gcc
 - pythia6
 - lhapdf
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"

cmake . -DCMAKE_INSTALL_PREFIX=$INSTALLROOT -DCMAKE_BUILD_TYPE=%(cms_build_type)s -DPYTHIA6_DIR=${PYTHIA6_ROOT} -DLHAPDF_ROOT_DIR=${LHAPDF_ROOT}
cmake --build . --clean-first -- ${JOBS:+-j $JOBS}
cmake --build . --target install --  ${JOBS:+-j $JOBS}
