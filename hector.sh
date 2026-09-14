package: hector
version: 1.3.4_patch1
variables:
  tag: 566e76718059fde2bf044579a2010a482b52a04a
sources:
  - https://github.com/cms-externals/hector/archive/%(tag)s.tar.gz
requires:
 - ROOT
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
mkdir -p obj lib

# Add CXX and CXXFLAGS to Makefile and increase output verbose level
sed -i.bak 's/@g++/$(CXX) $(CXXFLAGS)/g' Makefile
make
rsync -a . $INSTALLROOT
