# define the ROCm compilation flags in a way that can be shared by SCRAM-based and regular tools
# build support for Instinct MI100 (gfx908), Instinct MI210/MI250X (gfx90a), Instinct MI300X (gfx942), Radeon Pro W6800 (gfx1030),
# Radeon Pro W7800/W7900 (gfx1100), and Radeon Pro W7600 (gfx1102)
rocm_archs="gfx90a:sramecc+ gfx942:sramecc+ gfx1100 gfx1102"
# LLVM/hipcc style for listing the supported ROCm compute architectures
hipcc_flags_rocm_archs="$(for arch in $rocm_archs; do echo -n '--offload-arch='$arch' ' ; done)"
# all ROCm flags
rocm_flags="$(echo $hipcc_flags_rocm_archs)"
