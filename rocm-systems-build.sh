# Shared build recipe for packages built from the ROCm/rocm-systems monorepo.
# Include with `#!include <rocm-systems-build.sh>` as the LAST line of the
# build-script body, after exporting whichever of the following the package needs:
#
#   ROCM_PROJECT           subdirectory under rocm-systems/projects/ to build
#                           (defaults to $PKGNAME)
#   ROCM_CMAKE_EXTRA_ARGS   extra -D... cmake flags, appended to the base set
#   ROCM_PRE_BUILD_HOOK     bash snippet, eval'd after extraction, before cmake
#   ROCM_POST_INSTALL_HOOK  bash snippet, eval'd after `make install`
: "${ROCM_PROJECT:=$PKGNAME}"

tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"

if [ -n "${ROCM_PRE_BUILD_HOOK:-}" ]; then
  eval "$ROCM_PRE_BUILD_HOOK"
fi

CMAKE_ARGS=(
  -S "$BUILDDIR/rocm-systems/projects/$ROCM_PROJECT"
  -B "$BUILDDIR/build"
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_LLVM_ROOT;$ROCM_HIP_ROOT;$ROCM_COMGR_ROOT"
)
if [ -n "${ROCM_CMAKE_EXTRA_ARGS:-}" ]; then
  eval "CMAKE_ARGS+=($ROCM_CMAKE_EXTRA_ARGS)"
fi
cmake "${CMAKE_ARGS[@]}"
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1

if [ -n "${ROCM_POST_INSTALL_HOOK:-}" ]; then
  eval "$ROCM_POST_INSTALL_HOOK"
fi
