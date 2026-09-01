package: rocm-sources
version: "7.14"
# Single source of truth for the two ROCm monorepos (port of cmsdist's rocm/rocm-sources.spec).
#
# This package does nothing but clone the two repos and park the tarballs in its install
# root. Every other ROCm package build-requires it and untars from $ROCM_SOURCES_ROOT
# instead of cloning for itself, so the stack costs one clone of each monorepo instead of
# ~17 apiece. Changing the ROCm source ref is a one-line edit here.
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
  - git+https://github.com/ROCm/rocm-libraries.git?obj=release/therock-%(version)s/HEAD&export=rocm-libraries&submodules=1&output=/rocm-libraries.tar.gz
---
mkdir -p "$INSTALLROOT"
cp "$SOURCEDIR/${SOURCE0}" "$INSTALLROOT/rocm_systems.tar.gz"
cp "$SOURCEDIR/${SOURCE1}" "$INSTALLROOT/rocm_libraries.tar.gz"
