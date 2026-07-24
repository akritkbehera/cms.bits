if [ "$(uname -m)" = "x86_64" ]; then
    export default_microarch_name="x86-64-v3"
    export default_microarch="-march=${default_microarch_name}"
fi

selected_microarch_name="${default_microarch_name}"
selected_microarch="${default_microarch}"

export CMS_CXX_STANDARD=$CXXSTD
export LTO_FLAGS="-flto=auto -fipa-icf -flto-odr-type-merging -fno-fat-lto-objects -Wodr"
export ROOT_CXXMODULES="0"
export CMSDIST_DIR=$BITS_CONFIG_DIR
export COMPILER_CXXFLAGS=$selected_microarch
