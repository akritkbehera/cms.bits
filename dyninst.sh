package: dyninst
version: "13.0.0"
sources:
 - https://github.com/%(package)s/%(package)s/archive/refs/tags/v%(version)s.tar.gz
patches:
 - dyninst-pr1880.patch
build_requires:
 - CMake
 - gmake
 - libiberty
requires:
 - gcc
 - boost
 - TBB
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"

CMAKE_ARGS=(
  -S "$BUILDDIR" -B "$BUILDDIR/build"
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_PREFIX_PATH="${GCC_ROOT};${BOOST_ROOT};${TBB_ROOT};${LIBIBERTY_ROOT}"
  # Take elfutils from gcc, not gcc-prerequisites: gcc ships libdw/libelf and their
  # headers, but its libdw.pc/libelf.pc still carry the build-container prefix
  # (/container/bits/.../gcc-prerequisites), so anything resolving elfutils through
  # pkg-config gets a non-existent includedir. Setting ElfUtils_ROOT_DIR turns on
  # ElfUtils_NO_SYSTEM_PATHS, which makes FindLibELF/FindLibDW use find_path/find_library
  # against this root instead of pkg-config.
  -DElfUtils_ROOT_DIR="${GCC_ROOT}"
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi
cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install

# rocprofiler-systems links against an aggregate Dyninst::Dyninst target that upstream's
# DyninstConfig.cmake does not define; append it (as the spec does with its Source1).
test -f "$INSTALLROOT/lib/cmake/Dyninst/DyninstConfig.cmake"
cat >> "$INSTALLROOT/lib/cmake/Dyninst/DyninstConfig.cmake" <<'DYNINST_TARGET_EOF'
if(NOT TARGET Dyninst::Dyninst)
    add_library(Dyninst::Dyninst INTERFACE IMPORTED)
    message(STATUS "Adding additional target Dyninst::Dyninst")
    target_link_libraries(Dyninst::Dyninst
        INTERFACE
            Dyninst::dyninstAPI
            Dyninst::parseAPI
            Dyninst::instructionAPI
            Dyninst::symtabAPI)
endif()
DYNINST_TARGET_EOF
