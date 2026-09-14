package: jemalloc
version: 5.3.1
variables:
  github_user: cms-externals
  branch: cms/%%(version)s
  tag: fc5eb3f3a066cf57492e316f2d6e1ab4824ba72b
sources: 
 - git+https://github.com/%(github_user)s/jemalloc.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
build_requires:
 - autotools
 - gmake
 - patchelf-bootstrap
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

args=(
  --prefix="$INSTALLROOT"
  --disable-doc
  --enable-shared
  --disable-static
  --enable-stats
)
if [[ "$(uname -m)" == "aarch64" ]]; then
  args+=(--with-lg-page=16)
  args+=(--with-lg-hugepage=24)
fi
$BUILDDIR/autogen.sh "${args[@]}"

make ${JOBS:+-j$JOBS}
make install
