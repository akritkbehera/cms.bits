package: jemalloc
version: 5.3.0
variables:
  github_user: cms-externals
  branch: cms/%%(version)s
  tag: 54eaed1d8b56b1aa528be3bdd1877e59c56fa90c
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
