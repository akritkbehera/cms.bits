package: icx
version: "2025.0"
---
YEAR=$(echo "$PKGVERSION" | cut -d. -f1)
mkdir -p "$INSTALLROOT"
ln -s /cvmfs/projects.cern.ch/intelsw/oneAPI/linux/x86_64/${YEAR}/compiler/${PKGVERSION} \
    "$INSTALLROOT/installation"
