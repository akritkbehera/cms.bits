package: catch2
version: 2.13.6
sources:
 - https://raw.githubusercontent.com/catchorg/Catch2/v%(version)s/single_include/catch2/catch.hpp
---
mkdir $INSTALLROOT/include
cp $SOURCEDIR/catch.hpp $INSTALLROOT/include/
