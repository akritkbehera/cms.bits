package: hector
version: 1.3.4_patch1
tag: 566e76718059fde2bf044579a2010a482b52a04a
source: https://github.com/cms-externals/hector
requires:
 - ROOT
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
mkdir -p obj lib

# Add CXX and CXXFLAGS to Makefile and increase output verbose level
sed -i.bak 's/@g++/$(CXX) $(CXXFLAGS)/g' Makefile
make
rsync -a . $INSTALLROOT
