package: dablooms
version: 0.9.1
sources:
 - https://github.com/bitly/dablooms/archive/v%(version).tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

