package: openloops
version: "2.1.2"
variables:
  branch: cms/v%%(version)s
  github_user: cms-externals
  tag: 4247179369144b0134c7b8014a5d38a90dc9b6ba
patches:
 - openloops-py3.patch
build_requires:
 - py-scons
 - openloops-sources
 - openloops-process
requires:
 - "gcc:(?gcc)"
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$OPENLOOPS_SOURCES_ROOT/openloops_source/" "$BUILDDIR"/

patch -p1 < "$SOURCEDIR/$PATCH0"

if [ "$(uname -m)" = "aarch64" ]; then
    drop_process="pplljj_ew"
    sed -i -e 's|^ *cmodel *=.*|cmodel = small|' pyol/config/default.cfg
else
    drop_process=""
fi

gcc10_extra_flag=""
if [[ $(gcc --version | head -1 | cut -d' ' -f3 | cut -d. -f1,2,3 | tr -d .) -gt 1000 ]]; then
  gcc10_extra_flag="-fallow-invalid-boz"
fi

cat <<EOF > openloops.cfg
[OpenLoops]
fortran_compiler = gfortran
gfortran_f90_flags = -ffixed-line-length-0 -ffree-line-length-0 $gcc10_extra_flag
generic_optimisation = -O2
born_optimisation = -O2
loop_optimisation = -O0
link_optimisation = -O2
EOF

export SCONSFLAGS="-j${JOBS:-1}"
cp "$OPENLOOPS_SOURCES_ROOT/openloops-user.coll.file" openloops-user.coll
./openloops update --processes generator=0

rm -rf process_src
tar -xzf "$OPENLOOPS_PROCESS_ROOT/process_src.tgz"

for xproc in $drop_process; do
  sed -i -e "/^${xproc}\$/d" openloops-user.coll
  sed -i -e "/^${xproc} .*/d" process_src/downloaded.dat
  rm -rf "process_src/${xproc}"
done

./openloops libinstall openloops-user.coll

mkdir -p "$INSTALLROOT/lib" "$INSTALLROOT/proclib"
cp lib/*.so "$INSTALLROOT/lib/"
cp proclib/*.so "$INSTALLROOT/proclib/"
cp proclib/*.info "$INSTALLROOT/proclib/"
