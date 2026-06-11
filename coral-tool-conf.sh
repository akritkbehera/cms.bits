package: coral-tool-conf
version: vCMS
requires:
 - coral-tools
variables:
  skipreqtools: jcompiler
  override_microarch: "-march=x86-64-v2"
  package_vectorization: ""
  vectorized_packages: ""
  gpu_backend_specific_packages: ""
  gpu_types: ""
  default_microarch: "-march=x86-64-v2"
  cuda_gcc_support: "false"
  min_microarch_name: "-march=x86-64-v2"
  use_system_gcc: "0"
  enable_frame_pointer: "1"
  use_cuda: "1"
  use_rocm: "1"
  HFI_NO_BACKTRACE: "1"
  IPATH_NO_BACKTRACE: "1"
---
# =============================================================================
# coral-tool-conf: Deploys tool configuration files from coral-tools templates
# =============================================================================

# Create the directory structure for tool configurations
mkdir -p $INSTALLROOT/tools/{available,selected}

export PKGINSTROOT=$INSTALLROOT

bash $CORAL_TOOLS_ROOT/tools/selected.tmpl

# Create python3.xml as alias to python.xml (boost_python uses python3)
if [ -f "$INSTALLROOT/tools/selected/python.xml" ] && [ ! -f "$INSTALLROOT/tools/selected/python3.xml" ]; then
  sed 's/name="python"/name="python3"/' "$INSTALLROOT/tools/selected/python.xml" > "$INSTALLROOT/tools/selected/python3.xml"
fi
