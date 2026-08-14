package: aotriton
version: "0.13b"
sources:
  - git+https://github.com/ROCm/aotriton?obj=main/%(version)s&export=aotriton-%(version)s&submodules=1&output=/aotriton-%(version)s.tgz
patches:
  - aotriton-cms.patch
build_requires:
  - CMake
  - ninja
requires:
  - gcc
  - rocm-comgr
  - rocm-hip
  - rocr-runtime
  - xz
  - aotriton-images
  - py-triton
  - py-filelock
  - py-iniconfig
  - py-packaging
  - py-pluggy
  - py-numpy
  - setuptools
  - py-wheel
  - py-pybind11
  - py-pandas
  - py-PyYAML
---
#!include <rocm-flags.file>

# Port of cmsdist aotriton/spec. The upstream commit is pinned so the build does not try to
# read it out of a .git dir that the exported tarball does not carry.
aotriton_git_sha1=6e00ef3e335b45dfb49065259533b59c68995bfe

tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"
patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/$PATCH0"

export HIP_PLATFORM=amd

# aotriton's CMakeLists creates its own venv and pip-installs into it at configure time.
# Same two problems as rocblas: pip reads bits' PIP_ROOT as its --root (staging everything
# under $PIP_ROOT/<abs path>), and the venv has no setuptools of its own, so the isolated
# build environment cannot import the backend.
PIP_PKG_ROOT="$PIP_ROOT"
unset PIP_ROOT
export PYTHONPATH="${SETUPTOOLS_ROOT}/lib/python3.12/site-packages:${PIP_PKG_ROOT}/lib/python3.12/site-packages${PYTHONPATH:+:${PYTHONPATH}}"

# pip ignores PIP_NO_BUILD_ISOLATION, so the flag has to go on the command line.
sed -i 's|-m pip install |-m pip install --no-build-isolation |g' "$BUILDDIR/CMakeLists.txt"
grep -q -- '--no-build-isolation' "$BUILDDIR/CMakeLists.txt"

# cmsdist's rocm_gpus_cmake: bare gfx targets, ';'-separated. Strip both the ':sramecc+'
# suffix and a glued-on 'sramecc+' -- this tree's rocm_archs has entries of both shapes
# (gfx90a:ramecc+, gfx942sramecc+), so a plain ':'-split is not enough.
rocm_gpus_cmake=$(for a in $rocm_archs; do printf '%s;' "$(echo "$a" | sed 's/:.*//; s/s\?ramecc+$//')"; done | sed 's/;$//')

CMAKE_ARGS=(
  -S "$BUILDDIR" -B "$BUILDDIR/build"
  -G Ninja
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s
  -DCMAKE_INSTALL_PREFIX:STRING="$INSTALLROOT"
  -DAOTRITON_NOIMAGE_MODE=ON
  -DAOTRITON_TARGET_ARCH="$rocm_gpus_cmake"
  -DAOTRITON_NO_PYTHON=OFF
  -DAOTRITON_USE_TORCH=OFF
  -DAOTRITON_INHERIT_SYSTEM_SITE_TRITON=ON
  -DCMAKE_PREFIX_PATH="${GCC_ROOT};${ROCM_HIP_ROOT};${ROCM_COMGR_ROOT};${ROCR_RUNTIME_ROOT};${XZ_ROOT};${PY_PYBIND11_ROOT};${PY_TRITON_ROOT}"
  -DCMAKE_VERBOSE_MAKEFILE=TRUE
)
AOTRITON_CI_SUPPLIED_SHA1=$aotriton_git_sha1 \
AOTRITON_GIT_TREESHA1=$aotriton_git_sha1 \
  cmake "${CMAKE_ARGS[@]}"

ninja -v -C "$BUILDDIR/build" ${JOBS:+-j$JOBS}
ninja -v -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} install

ln -s "$AOTRITON_IMAGES_ROOT/aotriton.images" "$INSTALLROOT/lib/aotriton.images"
