package: boost
version: "1.80.0"
tag: 66e4a726b4ac46155ef33553b65172900660dde5
variables:
 github_user: "cms-externals"
 branch: "cms/v%%(version)s"
sources:
- git+https://github.com/%(github_user)s/boost.git?obj=%(branch)s/%(tag_basename)s&export=boost-%(version)s&output=/boost-%(version)s.tgz
requires:
- Python
- bz2lib
- zlib
- openmpi
- xz
- zstd
- gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

if [[ "$(uname)" == "Darwin" ]]; then
  TOOLSET=darwin
else
  TOOLSET=gcc
fi

#%if "%{?arch_build_flags}"
#echo 'using gcc : : : <cxxflags>"%{arch_build_flags}" <cflags>"%{arch_build_flags}" ;' > user-config.jam
#%endif

pushd tools/build
  sh bootstrap.sh ${TOOLSET}
  mkdir ./tmp-boost-build
  ./b2 install --prefix=./tmp-boost-build
  export PATH=${PWD}/tmp-boost-build/bin:${PATH}
popd

PYTHONV=$(echo $PYTHON_VERSION | sed 's/^v//' | cut -f1,2 -d.)

echo "using mpi ;" >> user-config.jam
echo "using python : ${PYTHONV} : ${PYTHON_ROOT}/bin/python3 : ${PYTHON_ROOT}/include/python${PYTHONV} : ${PYTHON_ROOT}/lib ;" >> user-config.jam

b2 -q \
   -d2 \
   define=BOOST_FILESYSTEM_DISABLE_STATX \
   ${JOBS+-j $JOBS} \
   --build-dir=build-boost \
   --disable-icu \
   --without-atomic \
   --without-container \
   --without-context \
   --without-coroutine \
   --without-exception \
   --without-graph \
   --without-graph_parallel \
   --without-locale \
   --without-log \
   --without-math \
   --without-random \
   --without-wave \
   --user-config=${BUILDDIR}/user-config.jam \
   toolset=${TOOLSET} \
   link=shared \
   threading=multi \
   variant=release \
   python=${PYTHONV} \
   -sBZIP2_INCLUDE=${BZ2LIB_ROOT}/include \
   -sBZIP2_LIBPATH=${BZ2LIB_ROOT}/lib \
   -sZLIB_INCLUDE=${ZLIB_ROOT}/include \
   -sZLIB_LIBPATH=${ZLIB_ROOT}/lib \
   -sLZMA_INCLUDE=${XZ_ROOT}/include \
   -sLZMA_LIBPATH=${XZ_ROOT}/lib \
   -sZSTD_INCLUDE=${ZSTD_ROOT}/include \
   -sZSTD_LIBPATH=${ZSTD_ROOT}/lib \
   stage

mkdir -p $INSTALLROOT/lib $INSTALLROOT/include

pushd stage/lib
  find . -name "*.so*" -type f | tar cf - -T - | (cd $INSTALLROOT/lib; tar xfp -)
  find . -name "*.cmake" -type f | tar cf - -T - | (cd $INSTALLROOT//lib; tar xfp -)
popd
find boost -name '*.[hi]*' | tar cf - -T - | ( cd $INSTALLROOT//include; tar xfp -)

# Fix paths inside CMake files
find "$INSTALLROOT/lib/cmake" -name '*.cmake' -exec \
  sed -i \
  -e "s#$BUILDDIR/stage#$INSTALLROOT/#g" \
  -e 's#_BOOST_INCLUDEDIR "${_BOOST_CMAKEDIR}/../../../"#_BOOST_INCLUDEDIR "${_BOOST_CMAKEDIR}/../../include/"#g' {} +

# Fix library symlinks (.so → .so.<version>)
find "$INSTALLROOT/lib" -name "*.so.*" | while read -r l; do
  dir=$(dirname "$l")
  base=$(basename "$l")
  sofile=$(echo "$base" | sed -e 's|\.so\..*|.so|')
  (cd "$dir" && ln -sf "$base" "$sofile")
done
