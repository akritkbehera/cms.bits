package: cmsswdata
version: vCMS
requires:
  - data-RecoTracker-LSTCore
  - data-L1Trigger-L1TMuon
  - data-RecoMuon-TrackerSeedGenerator
  - data-DQM-Integration
  - data-Geometry-HGCalMapping
  - data-RecoTracker-MkFit
  - data-RecoBTag-Combined
  - data-RecoEgamma-PhotonIdentification
  - data-PhysicsTools-NanoAOD
  - data-Validation-HGCalValidation
  - data-L1Trigger-L1TMuonEndCapPhase2
  - data-L1Trigger-L1TTrackMatch
  - data-L1Trigger-VertexFinder
  - data-DataFormats-L1ScoutingRawData
  - data-DataFormats-L1Scouting
  - data-L1Trigger-L1CaloTrigger
  - data-L1Trigger-Phase2L1ParticleFlow
  - data-GeneratorInterface-EvtGenInterface
  - data-DataFormats-Scouting
  - data-RecoTauTag-TrainingFiles
  - data-RecoEgamma-EgammaPhotonProducers
  - data-RecoMET-METPUSubtraction
  - data-RecoEcal-EgammaClusterProducers
  - data-HeterogeneousCore-SonicTriton
  - data-RecoMuon-MuonIdentification
  - data-RecoEgamma-ElectronIdentification
  - data-SimCalorimetry-EcalEBTrigPrimProducers
  - data-Configuration-Generator
  - data-L1Trigger-DTTriggerPhase2
  - data-RecoTracker-FinalTrackSelectors
  - data-IOPool-Input
  - data-DataFormats-DetId
  - data-RecoTracker-TkSeedGenerator
  - data-DataFormats-SiStripCluster
  - data-L1Trigger-L1THGCal
  - data-L1Trigger-L1TCalorimeter
  - data-L1Trigger-TrackTrigger
  - data-Geometry-TestReference
  - data-DQM-HcalTasks
  - data-DataFormats-HLTReco
  - data-RecoPPS-Local
  - data-DataFormats-L1TGlobal
  - data-DataFormats-FEDRawData
  - data-DataFormats-Common
  - data-DQM-EcalMonitorClient
  - data-CondTools-Hcal
  - data-RecoTracker-DisplacedRegionalTracking
  - data-CalibTracker-SiStripDCS
  - data-L1Trigger-TrackFindingTracklet
  - data-Alignment-OfflineValidation
  - data-L1Trigger-L1TGlobal
  - data-CalibTracker-SiPixelESProducers
  - data-RecoHGCal-TICL
  - data-L1Trigger-CSCTriggerPrimitives
  - data-MagneticField-Interpolation
  - data-L1TriggerConfig-L1TConfigProducers
  - data-CondTools-SiStrip
  - data-RecoParticleFlow-PFProducer
  - data-CondTools-SiPhase2Tracker
  - data-CalibCalorimetry-CaloMiscalibTools
  - data-FastSimulation-MaterialEffects
  - data-L1Trigger-RPCTrigger
  - data-RecoParticleFlow-PFBlockProducer
  - data-SimG4CMS-Calo
  - data-Validation-Geometry
  - data-CalibPPS-ESProducers
  - data-DataFormats-PatCandidates
  - data-DetectorDescription-Schema
  - data-PhysicsTools-PatUtils
  - data-RecoJets-JetProducers
  - data-EgammaAnalysis-ElectronTools
  - data-Geometry-DTGeometryBuilder
  - data-L1Trigger-TrackFindingTMTT
  - data-SimTransport-PPSProtonTransport
  - data-DQM-SiStripMonitorClient
  - data-RecoMTD-TimingIDTools
  - data-MagneticField-Engine
  - data-SimTracker-SiStripDigitizer
  - data-SimPPS-PPSPixelDigiProducer
  - data-CalibCalorimetry-EcalTrivialCondModules
  - data-RecoLocalCalo-EcalDeadChannelRecoveryAlgos
  - data-FWCore-Modules
  - data-RecoCTPPS-TotemRPLocal
  - data-SLHCUpgradeSimulations-Geometry
  - data-SimTransport-TotemRPProtonTransportParametrization
  - data-SimG4CMS-HGCalTestBeam
  - data-Fireworks-Geometry
  - data-SimG4CMS-Forward
  - data-GeneratorInterface-ReggeGribovPartonMCInterface
  - data-Calibration-Tools
  - data-CondFormats-JetMETObjects
  - data-DQM-DTMonitorClient
  - data-DQM-PhysicsHWW
  - data-EventFilter-L1TRawToDigi
  - data-FastSimulation-TrackingRecHitProducer
  - data-HLTrigger-JetMET
  - data-RecoBTag-CTagging
  - data-RecoBTag-SecondaryVertex
  - data-RecoBTag-SoftLepton
  - data-RecoHI-HiJetAlgos
  - data-RecoParticleFlow-PFTracking
  - data-SimTransport-HectorProducer
  - data-RecoTracker-PixelLowPtUtilities
  - data-L1Trigger-Phase2L1GMT
  - data-L1TriggerScouting-OnlineProcessing
  - data-HLTrigger-HLTfilters
  - data-PhysicsTools-PyTorch
  - data-PhysicsTools-PyTorchAlpaka
  - data-PhysicsTools-PyTorchAlpakaTest
  - data-RecoLocalCalo-HGCalRecProducers
---
# Port of cmsdist cmsswdata.spec -> ## INCLUDE cmsswdata (cmsdist/cmsswdata.file).
# That %install writes etc/scram.d/cmsswdata.xml by walking %pkgreqs (the resolved
# cms/data-*/<version> paths). bits has no %pkgreqs, but it exports a <PKG>_ROOT for every
# dependency (name upper-cased, '-'->'_'), so we enumerate the DATA_*_ROOT vars and read each
# package's real on-disk path from them. pack (Sub/Pkg) and version come straight from the
# install dir, so casing and the local build suffix are exact -- same shape cmsdist produces.
mkdir -p "$INSTALLROOT/etc/scram.d"
XML="$INSTALLROOT/etc/scram.d/cmsswdata.xml"

# Header + <client> open + the CMSSW_DATA_PATH environment (mirrors cmsswdata.file).
{
  echo "<tool name=\"cmsswdata\" version=\"%(version)s\" path=\"$INSTALLROOT\" revision=\"2\">"
  echo "  <client>"
  echo "    <environment name=\"CMSSW_DATA_PATH\" default=\"\$TOOL_BASE\"/>"
} > "$XML"

# Collect one CMSSW_DATA_PACKAGE flag (inside <client>) and one CMSSW_SEARCH_PATH runtime
# (after </client>) per required data package. Sorted by package to match the cvmfs reference.
flags="$(mktemp)"; paths="$(mktemp)"
for var in $(compgen -v | grep -E '^DATA_.*_ROOT$'); do
  root="${!var}"
  case "$root" in */cms/data-*) ;; *) continue ;; esac
  [ -d "$root" ] || continue
  ver="$(basename "$root")"                               # e.g. V00-03-00-local1
  pkgdir="$(basename "$(dirname "$root")")"               # e.g. data-Alignment-OfflineValidation
  pack="$(echo "$pkgdir" | sed 's|^data-||;s|-|/|')"      # e.g. Alignment/OfflineValidation
  printf '    <flags CMSSW_DATA_PACKAGE="%s=%s"/>\n' "$pack" "$ver" >> "$flags"
  printf '  <runtime name="CMSSW_SEARCH_PATH" default="%s" type="path"/>\n' "$root" >> "$paths"
done

sort "$flags" >> "$XML"
# Close <client>, then the aggregate CMSSW_DATA_PATH runtime, then the per-package search paths.
{
  echo "  </client>"
  echo "  <runtime name=\"CMSSW_DATA_PATH\" value=\"\$TOOL_BASE\" type=\"path\"/>"
} >> "$XML"
sort "$paths" >> "$XML"
echo "</tool>" >> "$XML"

rm -f "$flags" "$paths"
chmod a+r "$XML"
