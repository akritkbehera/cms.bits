package: OpenBLAS
version: 0.3.27
variables:
  tag: v%(version)s
sources:
  - https://github.com/OpenMathLib/OpenBLAS/archive/%(tag)s.tar.gz
requires:
 - gcc
---
#!include <microarch-flags.file>
#!include <compilation-flags.file>

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

ARCH="$(uname -m)"

if [ "$ARCH" = "x86_64" ]; then
    XTARGETS="sse3=CORE2"
fi

for t in nehalem sandybridge haswell ; do
    XTARGETS="${XTARGETS} $t=$(echo $t | tr 'a-z' 'A-Z')"
done

XTARGETS="${XTARGETS} skylake-avx512=SKYLAKEX"
XTARGETS="${XTARGETS} x86-64-v2=NEHALEM"
XTARGETS="${XTARGETS} x86-64-v3=HASWELL"
XTARGETS="${XTARGETS} x86-64-v4=SKYLAKEX"

if [ "$ARCH" = "x86_64" ]; then
    STARGET=$(echo "$selected_microarch_name" | sed 's|^-m||;s|^arch=||')
    TARGET_ARCH=$(echo ${XTARGETS} | tr ' ' '\n' | grep "^${STARGET}=" | sed "s|^${STARGET}=||")

    if [ "${TARGET_ARCH}" = "" ] ; then
        echo "ERROR: Unable to match OpenBlas build target '${STARGET}'. Available build targets are"
        echo "${XTARGETS}" | tr ' ' '\n' | sed 's|=.*||'
        echo "Please use one of the supported targets or add support for ${STARGET}"
        exit 1
    fi

    make FC=gfortran BINARY=64 NUM_THREADS=256 DYNAMIC_ARCH=0 ${JOBS:+MAKE_NB_JOBS=$JOBS} TARGET=${TARGET_ARCH}
fi

if [ "$ARCH" = "aarch64" ]; then
    make FC=gfortran BINARY=64 NUM_THREADS=256 DYNAMIC_ARCH=0 ${JOBS:+MAKE_NB_JOBS=$JOBS} TARGET=ARMV8 CFLAGS="-march=armv8-a -mno-outline-atomics"
fi

if [ "$ARCH" = "ppc64le" ]; then
    make FC=gfortran BINARY=64 NUM_THREADS=256 DYNAMIC_ARCH=0 ${JOBS:+MAKE_NB_JOBS=$JOBS} CFLAGS="$arch_build_flags"
fi

if [ "$ARCH" = "riscv64" ]; then
    make FC=gfortran BINARY=64 NUM_THREADS=256 DYNAMIC_ARCH=0 ${JOBS:+MAKE_NB_JOBS=$JOBS} TARGET=RISCV64_GENERIC shared
fi

make PREFIX=$INSTALLROOT install MAKE_NB_JOBS=$JOBS

# Mirror CMSBUILD default archive cleanup for this recipe.
rm -f "$INSTALLROOT"/lib/*.a "$INSTALLROOT"/lib/*.la
