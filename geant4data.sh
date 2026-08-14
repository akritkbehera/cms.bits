package: geant4data
version: "11.0"
# cvmfs exposes geant4data as an aggregate over the geant4-G4* datasets. In this tree the
# datasets (and their G4*DATA env vars) live in the consolidated geant4-data package, whose
# env: chains through here — so geant4data is just a thin alias requiring it.
requires:
  - geant4-data
---
# Port of cmsdist geant4data.spec %install: it writes etc/scram.d/geant4data.xml with one
# <runtime> per geant4-G4* dataset, reading each subpackage's $<TOOL>_RUNTIME (the env var
# NAME, e.g. G4ABLADATA) and $<TOOL>_ROOT/data/* (the value). This tree consolidates the
# datasets into geant4-data, which already exports those same runtime env vars (chained in via
# its env:), each pointing at $GEANT4_DATA_ROOT/<Dataset><ver>. So we emit one runtime per var.
mkdir -p "$INSTALLROOT/etc/scram.d"
XML="$INSTALLROOT/etc/scram.d/geant4data.xml"

echo "<tool name=\"geant4data\" version=\"%(version)s\" path=\"$INSTALLROOT\" revision=\"2\">" > "$XML"

# Runtime env-var names in the cvmfs reference's order (sorted by source dataset package:
# G4ABLA, G4EMLOW, G4ENSDFSTATE, G4INCL, G4NDL, G4PARTICLEXS, G4PhotonEvaporation,
# G4RadioactiveDecay, G4RealSurface, G4SAIDDATA).
for name in G4ABLADATA G4LEDATA G4ENSDFSTATEDATA G4INCLDATA G4NEUTRONHPDATA \
            G4PARTICLEXSDATA G4LEVELGAMMADATA G4RADIOACTIVEDATA G4REALSURFACEDATA G4SAIDXSDATA; do
  val="${!name}"
  if [ -z "$val" ] || [ ! -d "$val" ]; then
    echo "WARNING: geant4data: \$$name unset or not a dir ('$val'); skipping" >&2
    continue
  fi
  echo "  <runtime name=\"$name\" value=\"$val\" type=\"path\"/>" >> "$XML"
done

echo "</tool>" >> "$XML"
chmod a+r "$XML"
