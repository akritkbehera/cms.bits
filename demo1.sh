package: demo1
version: vCMS
variables:
 apple: "bear"
requires:
 - demo2
---
cat $INSTALLROOT/.meta.json
resolve_meta.py $WORK_DIR/xz.xml
echo $WORK_DIR/xz.xml
exit 1
echo $BITS_SCRIPT_DIR
