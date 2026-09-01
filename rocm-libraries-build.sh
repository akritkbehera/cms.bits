# Shared build recipe for packages built from the ROCm/rocm-libraries monorepo.
# Include with `#!include <rocm-libraries-build.sh>` as the LAST line of the
# build-script body, after exporting whichever of the following the package needs:
#
#   ROCM_PROJECT           subdirectory under rocm-libraries/$ROCM_LIBRARIES_DIR/ to build
#                           (defaults to $PKGNAME)
#   ROCM_LIBRARIES_DIR      tree the project lives in: `projects` (default) or `shared`
#   ROCM_CMAKE_EXTRA_ARGS   extra -D... cmake flags, appended to the base set
#   ROCM_PRE_BUILD_HOOK     bash snippet, eval'd after extraction, before cmake
#   ROCM_POST_CMAKE_HOOK    bash snippet, eval'd after cmake configure, before make
#   ROCM_POST_INSTALL_HOOK  bash snippet, eval'd after `make install`
#
# The monorepo tarball comes from the `rocm-sources` package, which clones it once for
# the whole stack; declare `rocm-sources` in build_requires.
: "${ROCM_PROJECT:=$PKGNAME}"
: "${ROCM_LIBRARIES_DIR:=projects}"

ROCM_DEVICE_LIB_FLAG="--rocm-device-lib-path=$ROCM_LLVM_ROOT/amdgcn/bitcode -Wno-unused-command-line-argument"

# Some upstream CMakeLists (e.g. MIOpen's ClangToolChain.cmake) auto-detect the
# ROCm install via `hipconfig --rocmpath`, which echoes back a stale ROCM_PATH
# if one happens to be set in the environment (or otherwise mis-detects). Force
# it explicitly instead of leaving it unset: some packages (e.g. rocblas's
# Tensile) shell out to amdclang++ directly, bypassing CMAKE_CXX_FLAGS, and
# rely on $ROCM_PATH alone to find the HIP runtime headers -- which live in
# the separate rocm-hip package, not rocm-llvm.
export ROCM_PATH="$ROCM_HIP_ROOT"
export ROCM_CMAKE_PATH="$ROCM_LLVM_ROOT"
export HIP_DEVICE_LIB_PATH="$ROCM_LLVM_ROOT/amdgcn/bitcode"

tar -xzf "$ROCM_SOURCES_ROOT/rocm_libraries.tar.gz" -C "$BUILDDIR"

ROCM_PROJECT_DIR="$BUILDDIR/rocm-libraries/$ROCM_LIBRARIES_DIR/$ROCM_PROJECT"

if [ -n "${ROCM_PRE_BUILD_HOOK:-}" ]; then
  eval "$ROCM_PRE_BUILD_HOOK"
fi

CMAKE_ARGS=(
  -B "$BUILDDIR/build"
  -S "$ROCM_PROJECT_DIR"
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_C_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang"
  -DCMAKE_CXX_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang++"
  -DCMAKE_PREFIX_PATH="$ROCM_HIP_ROOT;$ROCM_CORE_ROOT;$ROCM_LLVM_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_COMGR_ROOT;$ROCM_CMAKE_ROOT"
  -DBUILD_CLIENTS_TESTS=off
  -DHIP_ROOT=$ROCM_HIP_ROOT
  -DGPU_TARGETS="gfx90a;gfx942;gfx1100;gfx1102"
  -DCMAKE_C_FLAGS="$ROCM_DEVICE_LIB_FLAG"
  -DCMAKE_CXX_FLAGS="$ROCM_DEVICE_LIB_FLAG"
)
if [ -n "${ROCM_CMAKE_EXTRA_ARGS:-}" ]; then
  eval "CMAKE_ARGS+=($ROCM_CMAKE_EXTRA_ARGS)"
fi
cmake "${CMAKE_ARGS[@]}"

if [ -n "${ROCM_POST_CMAKE_HOOK:-}" ]; then
  eval "$ROCM_POST_CMAKE_HOOK"
fi

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1

if [ -n "${ROCM_POST_INSTALL_HOOK:-}" ]; then
  eval "$ROCM_POST_INSTALL_HOOK"
fi
