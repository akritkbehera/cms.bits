package: geant4data
version: "11.0"
requires:
  - geant4-G4NDL
  - geant4-G4EMLOW
  - geant4-G4PhotonEvaporation
  - geant4-G4RadioactiveDecay
  - geant4-G4PARTICLEXS
  - geant4-G4SAIDDATA
  - geant4-G4ABLA
  - geant4-G4ENSDFSTATE
  - geant4-G4RealSurface
  - geant4-G4INCL
---
mkdir -p "$INSTALLROOT/etc/scram.d"

cat << EOF > "$INSTALLROOT/etc/scram.d/geant4data.xml"
<tool name="geant4data" version="$PKGVERSION" path="$INSTALLROOT" revision="2">
EOF

for tool in geant4-G4NDL geant4-G4EMLOW geant4-G4PhotonEvaporation geant4-G4RadioactiveDecay \
            geant4-G4PARTICLEXS geant4-G4SAIDDATA geant4-G4ABLA geant4-G4ENSDFSTATE \
            geant4-G4RealSurface geant4-G4INCL; do
  uctool=$(echo "$tool" | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  toolbase=$(eval echo "\${${uctool}_ROOT}")
  toolenv=$(eval echo "\${${uctool}_RUNTIME}")
  if [ -n "$toolbase" ] && [ -n "$toolenv" ] && [ -d "$toolbase/data" ]; then
    tooldata=$(ls -d "$toolbase/data/"* 2>/dev/null | tail -1)
    [ -n "$tooldata" ] && echo "  <runtime name=\"$toolenv\" value=\"$tooldata\" type=\"path\"/>" \
      >> "$INSTALLROOT/etc/scram.d/geant4data.xml"
  fi
done

echo "</tool>" >> "$INSTALLROOT/etc/scram.d/geant4data.xml"
chmod a+r "$INSTALLROOT/etc/scram.d/geant4data.xml"

mkdir -p "$INSTALLROOT/etc/profile.d"
echo "GEANT4DATA_ROOT='$INSTALLROOT'" > "$INSTALLROOT/etc/profile.d/init.sh"
echo "GEANT4DATA_VERSION='$PKGVERSION'" >> "$INSTALLROOT/etc/profile.d/init.sh"
