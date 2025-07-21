package: bz2lib
version: "%(tag_basename)s"
tag: bzip2-1.0.6
build_requires:
 - alibuild-recipe-tools
requires:
 - gcc
source: https://github.com/libarchive/bzip2
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/
if [[ ${ARCHITECTURE:0:3} == "osx" ]]; then
  sed -e 's/ -shared/ -dynamiclib/' \
      -e 's/ -Wl,-soname -Wl,[^ ]*//' \
      -e 's/libbz2\.so/libbz2.dylib/g' \
      < Makefile-libbz2_so > Makefile-libbz2_dylib
  MAKEFILE="Makefile-libbz2_dylib"
  soname="dylib"
else
  MAKEFILE="Makefile-libbz2_so"
  soname="so"
fi

make -j"${MAKEJOBS:-1}" -f "$MAKEFILE"

ls -l | grep libbz2 || :

version=$(echo $PKG_VERSION | cut -d'-' -f2)

mkdir -p "$INSTALLROOT"/{bin,lib,include}

if [[ -f "libbz2.${soname}.${version}" ]]; then
    cp "libbz2.${soname}.${version}" "${INSTALLROOT}/lib/"
else
    ls -la libbz2.* || :
    exit 1
fi

cd "${INSTALLROOT}/lib"
ln -sf "libbz2.${soname}.${version}" "libbz2.${soname}"
two_digit_version=$(echo "${version}" | cut -d. -f1,2)
ln -sf "libbz2.${soname}.${version}" "libbz2.${soname}.${two_digit_version}"
one_digit_version=$(echo "${version}" | cut -d. -f1)
ln -sf "libbz2.${soname}.${version}" "libbz2.${soname}.${one_digit_version}"
cd "$BUILDDIR"

if [[ -f "bzlib.h" ]]; then
    cp bzlib.h "${INSTALLROOT}/include/"
else
    exit 1
fi

for binary in bzip2 bunzip2 bzcat bzdiff bzgrep bzmore; do
    if [[ -f "$binary" ]]; then
        cp "$binary" "${INSTALLROOT}/bin/"
    fi
done
cd "${INSTALLROOT}/bin"
[[ -f "bzdiff" ]] && ln -sf bzdiff bzcmp
[[ -f "bzgrep" ]] && ln -sf bzgrep bzegrep
[[ -f "bzgrep" ]] && ln -sf bzgrep bzfgrep
[[ -f "bzmore" ]] && ln -sf bzmore bzless
cd "$BUILDDIR"
