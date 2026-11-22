package: geant4-G4EMLOW
version: "8.8"
sources:
 - https://cern.ch/geant4-data/datasets/G4EMLOW.%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$INSTALLROOT"
