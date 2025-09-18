package: java
version: "17_21"
env:
  JAVA_HOME: /usr/lib/java
prefer_system: "(?!.*)"
prefer_system_check: |
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    EL_MAJOR=${VERSION_ID%%.*}
  else
    echo "Cannot determine EL version"
    exit 1
  fi
  JAVA_MAJOR=$(java -version 2>&1 | head -1 | cut -d\" -f2 | sed 's/^1\.//' | cut -d. -f1)
  EXPECTED=$([ "$EL_MAJOR" -ge 11 ] && echo 21 || echo 17)
  [ "$JAVA_MAJOR" -eq "$EXPECTED" ] || { echo "EL $EL_MAJOR needs Java $EXPECTED, found $JAVA_MAJOR"; exit 1; }
prefer_system_replacement_specs:
  "java.*":
     recipe: |
       export JAVA_HOME=/usr/lib/jvm
       echo HELLO
---
# If replacement is selected, this must NOT run
echo "RUNNING RECIPE"
exit 1
