package: bazel
version: "5.3.0"
sources:
 - https://github.com/bazelbuild/bazel/releases/download/%(version)s/bazel-%(version)s-dist.zip
build_requires:
 - java-env
 - Python
 - python-python3
requires:
 - gcc
patches:
 - bazel-3.7.0-patches.patch
 - bazel-absl.patch
 - bazel-gcc14.patch
---
unzip -q "$SOURCEDIR/${SOURCE0}" -d "$BUILDDIR"

patch -p1 -s -i "$SOURCEDIR/$PATCH0"
patch -p1 -s -i "$SOURCEDIR/$PATCH1"
patch -p1 -s -i "$SOURCEDIR/$PATCH2"

export EXTRA_BAZEL_ARGS="--define=ABSOLUTE_JAVABASE=${JAVA_HOME} --jobs 8"
export BAZEL_CXXOPTS="-std=c++$CXXSTD"
if [ $(${JAVA_HOME}/bin/java -version 2>&1 | grep -i 'openjdk version' | sed -E 's/.*"([0-9]+)\..*/\1/') -ge 17 ] ; then
  export JNI_FLAGS="--add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED"
fi
bash ./compile.sh

mkdir $INSTALLROOT/bin
cp output/bazel $INSTALLROOT/bin/.
