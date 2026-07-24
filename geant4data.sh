package: geant4data
version: "11.0"
# cvmfs exposes geant4data as an aggregate over the geant4-G4* datasets. In this tree the
# datasets (and their G4*DATA env vars) live in the consolidated geant4-data package, whose
# env: chains through here — so geant4data is just a thin alias requiring it.
requires:
  - geant4-data
---
mkdir -p "$INSTALLROOT"
