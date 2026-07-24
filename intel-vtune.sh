package: intel-vtune
version: "2026.0"
env:
 INTEL_VTUNE_INSTALLDIR: /cvmfs/projects.cern.ch/intelsw/oneAPI/linux/x86_64/2026/vtune/$PKGVERSION
---
export year=$(echo $PKGVERSION | cut -d. -f1)
