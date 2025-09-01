package: python-python3
version: "v1"
requires:
 - Python
---
mkdir $INSTALLROOT/bin/
ln -s ../../../../$BITS_ARCH_PREFIX/Python/$PYTHON_VERSION-$PYTHON_REVISION/bin/python3 $INSTALLROOT/bin/python3