package: geant4-data
version: "11.0"
variables:
  G4NDL: "4.7.1"
  G4EMLOW: "8.8"
  G4PhotonEvaporation: "6.1.2"
  G4RadioactiveDecay: "6.1.2"
  G4PARTICLEXS: "4.2"
  G4SAIDDATA: "2.0"
  G4ABLA: "3.3"
  G4ENSDFSTATE: "3.0"
  G4RealSurface: "2.2"
  G4INCL: "1.3"
# Datasets unpack at the top level as G4<Name><Version>; export the env vars Geant4 uses to
# locate each (the cmsdist geant4-G4* subpackages set these individually — here they live with
# the consolidated data package and chain through to geant4 / geant4data).
env:
  G4NEUTRONHPDATA:   "$GEANT4_DATA_ROOT/G4NDL%(G4NDL)s"
  G4LEDATA:          "$GEANT4_DATA_ROOT/G4EMLOW%(G4EMLOW)s"
  # NOTE: PhotonEvaporation, RadioactiveDecay and RealSurface tarballs extract WITHOUT the
  # "G4" prefix (Geant4 quirk), unlike the others — so their dir names omit it.
  G4LEVELGAMMADATA:  "$GEANT4_DATA_ROOT/PhotonEvaporation%(G4PhotonEvaporation)s"
  G4RADIOACTIVEDATA: "$GEANT4_DATA_ROOT/RadioactiveDecay%(G4RadioactiveDecay)s"
  G4PARTICLEXSDATA:  "$GEANT4_DATA_ROOT/G4PARTICLEXS%(G4PARTICLEXS)s"
  G4SAIDXSDATA:      "$GEANT4_DATA_ROOT/G4SAIDDATA%(G4SAIDDATA)s"
  G4ABLADATA:        "$GEANT4_DATA_ROOT/G4ABLA%(G4ABLA)s"
  G4ENSDFSTATEDATA:  "$GEANT4_DATA_ROOT/G4ENSDFSTATE%(G4ENSDFSTATE)s"
  G4REALSURFACEDATA: "$GEANT4_DATA_ROOT/RealSurface%(G4RealSurface)s"
  G4INCLDATA:        "$GEANT4_DATA_ROOT/G4INCL%(G4INCL)s"
sources:
- https://cern.ch/geant4-data/datasets/G4NDL.%(G4NDL)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4EMLOW.%(G4EMLOW)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4PhotonEvaporation.%(G4PhotonEvaporation)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4RadioactiveDecay.%(G4RadioactiveDecay)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4PARTICLEXS.%(G4PARTICLEXS)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4SAIDDATA.%(G4SAIDDATA)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4ABLA.%(G4ABLA)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4ENSDFSTATE.%(G4ENSDFSTATE)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4RealSurface.%(G4RealSurface)s.tar.gz
- https://cern.ch/geant4-data/datasets/G4INCL.%(G4INCL)s.tar.gz
---
for i in $(seq 0 9); do
  src_var="SOURCE$i"
  src_file="${!src_var}"
  if [ -n "$src_file" ]; then
    tar -xzf "$SOURCEDIR/$src_file" -C "$INSTALLROOT"
  fi
done
