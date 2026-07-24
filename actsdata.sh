package: actsdata
version: v10
# Traccc test data. cmsdist uses install-time unpacking (shared-data-package macros); bits
# has no such machinery, so we unpack into the install tree at build time (data dirs land at
# the top level, matching TRACCC_TEST_DATA_DIR = tool base).
sources:
  - https://acts.web.cern.ch/traccc/data/traccc-data-%(version)s.tar.gz
env:
  TRACCC_TEST_DATA_DIR: "$ACTSDATA_ROOT"
---
mkdir -p "$INSTALLROOT"
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$INSTALLROOT"
