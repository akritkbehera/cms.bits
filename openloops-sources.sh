package: openloops-sources
version: 2.1.2
fetch_cache: true
variables:
  branch: cms/v%%(version)s
  github_user: cms-externals
  tag: 4247179369144b0134c7b8014a5d38a90dc9b6ba
  process_src: process_src.tgz
sources:
 - git+https://github.com/%(github_user)s/openloops.git?obj=%(branch)s/%(tag)s&export=openloops-%(version)s&output=/openloops-%(version)s-%(tag)s.tar.gz
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_20_1_X/master/openloops-user.coll.file
patches:
 - openloops-urlopen2curl.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    -C "$BUILDDIR"
cp $SOURCEDIR/$SOURCE1 .
cd openloops-2.1.2
patch -p1 -i "$SOURCEDIR/$PATCH0"
mkdir -p "$INSTALLROOT"
if [[ -n "${BITS_FETCH_CACHE:-}" && -s "$BITS_FETCH_CACHE/%(process_src)s" ]]; then
  cp "$BITS_FETCH_CACHE/%(process_src)s" "$INSTALLROOT/%(process_src)s"
else
  python3 pyol/bin/download_process.py $(cat "$BUILDDIR/openloops-user.coll.file" | tr '\n' ' ')
  tar -czf %(process_src)s process_src proclib
  if [[ -n "${BITS_FETCH_CACHE:-}" ]]; then
    mkdir -p "$BITS_FETCH_CACHE"
    cp %(process_src)s "$BITS_FETCH_CACHE/%(process_src)s"
  fi
  mv %(process_src)s "$INSTALLROOT/"
  rm -rf process_src proclib
fi
cp $BUILDDIR/openloops-user.coll.file $INSTALLROOT/
mkdir -p $INSTALLROOT/openloops_source/
rsync -a $BUILDDIR/openloops-2.1.2/ $INSTALLROOT/openloops_source/
