package: demo1
version: vCMS
sources:
 - file://xz.xml
requires:
 - xz
---
cp $SOURCEDIR/xz.xml $BUILDDIR/
cat xz.xml
python3 /home/akbehera/Desktop/bitsorg/scram/tools.py xz.xml 
cat xz.xml
exit 1
