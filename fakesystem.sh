package: fakesystem
version: "1.0"
---
mkdir -p "$INSTALLROOT"
cat << 'EOF' > "$INSTALLROOT/README"
This package provides fake Provides for a small set of things which
are technically required to satisfy dependencies of CMSSW. All of these
things are needed only by (for example) single shell or perl scripts,
used only for standalone work, and thus we do not want to add them to
the full required system seeds list.
EOF
