package: common
version: "1"
variables:
 override_microarch_name: "x86-64-v2"
---
#!include <microarch-flags.file>
echo $selected_microarch
exit 1
