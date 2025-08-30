package: bazel
version: "5.3.0"
sources:
 - https://github.com/bazelbuild/bazel/archive/refs/tags/%(version)s.tar.gz
build_requires:
 - Python
patches:
 - bazel-3.7.0-patches.patch
 - bazel-absl.patch
 - bazel-gcc14.patch
---
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-17.0.16.0.8-2.el9.x86_64
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -i $SOURCEDIR/$PATCH0
patch -p1 -i $SOURCEDIR/$PATCH1
patch -p1 -i $SOURCEDIR/$PATCH2

export EXTRA_BAZEL_ARGS="--define=ABSOLUTE_JAVABASE=${JAVA_HOME} --jobs ${JOBS:+-j$JOBS}"
export BAZEL_CXXOPTS="-std=c++$CXXSTD"
if [ $(${JAVA_HOME}/bin/java -version 2>&1 | grep -E -i 'openjdk version "[1-9]' | sed -E 's|.* "([0-9]+)[.].*|\1|') -ge 17 ] ; then
  export JNI_FLAGS="--add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED"
fi
bash ./compile.sh

mkdir $INSTALLROOT/bin
cp output/bazel $INSTALLROOT/bin/.
