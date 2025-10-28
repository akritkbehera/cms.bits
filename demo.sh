package: demo
version: "v1"
requires:
 - Python
---
echo %(python_major_minor)s
exit 1
