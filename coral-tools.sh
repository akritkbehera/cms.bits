package: coral-tools
version: "1.0"
sources:
 - https://github.com/akritkbehera/scram-tools.file/archive/refs/tags/SCRAM/CMSSW_16_0_X/g14.tar.gz
variables:
  skipreqtools: jcompiler
  override_microarch: "-march=x86-64-v2"
requires:
 - compilation_flags_lto
 - compilation_flags
 - cuda-flags
 - microarch-flag
 - SCRAMV1
 - pcre
 - Python
 - gcc
 - expat
 - boost
 - frontier-client
 - sqlite
 - libuuid
 - zlib
 - bz2lib
 - xerces-c
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

source tool-conf-src.sh

