package: intel-vtune
version: "2025.0"
env:
  INTEL_VTUNE_INSTALLDIR: /cvmfs/projects.cern.ch/intelsw/oneAPI/linux/x86_64/2025/vtune/%(version)s
---
mkdir -p "$INSTALLROOT"
