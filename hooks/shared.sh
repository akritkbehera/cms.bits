# Define the destination once to avoid "path drift"
if [[ $revision == "None" ]]; then
    DEST_DIR="$WORK_DIR/${arch:-SHARED}/$PKGNAME/$PKGVERSION"
else
    DEST_DIR="$WORK_DIR/${arch:-SHARED}/$PKGNAME/$PKGVERSION-${revision:-$PKGREVISION}"
fi
echo "Shared archive detected. Copying to $DEST_DIR"
mkdir -p "$DEST_DIR"
rsync -a "$WORK_DIR/INSTALLROOT/$PKGHASH/$ARCHITECTURE/$PKGNAME/$PKGVERSION-$PKGREVISION/" "$DEST_DIR/"
bash "$DEST_DIR/relocate-me.sh"
