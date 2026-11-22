package: geant4-G4PhotonEvaporation
version: "6.1.2"
sources:
 - https://cern.ch/geant4-data/datasets/G4PhotonEvaporation.%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$INSTALLROOT"
