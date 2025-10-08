package: demo
version: 6.4.0
requires:
 - Python
 - gcc
---
#. ${CMS_RECIPE_TOOLS_ROOT}/ScramRecipe
SRC_DIR="$BITS_WORK_DIR/$ARCHITECTURE"
DEST_DIR="$BITS_WORK_DIR/RPMS"

mkdir -p "$DEST_DIR"

echo "🔍 Looking for RPMs under: $SRC_DIR/*/*.rpm"
echo "📦 Destination: $DEST_DIR"

# Copy all RPMs exactly one level down
shopt -s nullglob
for rpm_file in "$SRC_DIR"/*/latest/*.rpm; do
    echo "Copying: $rpm_file"
    cp -v "$rpm_file" "$DEST_DIR/"
done

echo "✅ All RPM files copied successfully."

