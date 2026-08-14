package: aotriton-images
version: "0.13b"
sources:
  - https://github.com/ROCm/aotriton/releases/download/%(version)s/aotriton-%(version)s-images-amd-gfx942.tar.gz
  - https://github.com/ROCm/aotriton/releases/download/%(version)s/aotriton-%(version)s-images-amd-gfx90a.tar.gz
  - https://github.com/ROCm/aotriton/releases/download/%(version)s/aotriton-%(version)s-images-amd-gfx110x.tar.gz
requires:
  - gcc
---
#!include <rocm-flags.file>

# Port of cmsdist aotriton-images.spec: pick the prebuilt kernel-image tarball(s) matching
# $rocm_archs (from rocm-flags) and unpack whichever are actually needed.
#
# cmsdist's own arch-name extraction (`sed 's|:.*||'`) assumes every rocm_archs entry has a
# ':'-separated suffix; this tree's rocm_archs has entries of both shapes (gfx90a:ramecc+,
# gfx942sramecc+ with no colon at all), so re-use aotriton.sh's more robust stripping.
declare -A tarball_for_bucket=(
  [gfx942]="$SOURCEDIR/${SOURCE0}"
  [gfx90a]="$SOURCEDIR/${SOURCE1}"
  [gfx110x]="$SOURCEDIR/${SOURCE2}"
)
declare -A extracted

for a in $rocm_archs; do
  amd_gpu=$(echo "$a" | sed 's/:.*//; s/s\?ramecc+$//')
  case $amd_gpu in
    gfx1100|gfx1102) amd_gpu=gfx110x ;;
    *) ;;
  esac
  if [ -n "${extracted[$amd_gpu]:-}" ]; then
    continue
  fi
  tarball="${tarball_for_bucket[$amd_gpu]:-}"
  if [ -z "$tarball" ]; then
    echo "aotriton-images: no prebuilt image tarball for arch bucket '$amd_gpu' (from '$a')" >&2
    exit 1
  fi
  tar -xzf "$tarball" -C "$BUILDDIR"
  extracted[$amd_gpu]=1
done

mv "$BUILDDIR/aotriton/lib/aotriton.images" "$INSTALLROOT/aotriton.images"
