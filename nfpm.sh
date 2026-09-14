package: nfpm
version: 2.41.3
variables:
  tag: v2.41.3
sources:
  - https://github.com/goreleaser/nfpm/archive/%(tag)s.tar.gz
requires:
- go
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
go mod tidy
go build -o $INSTALLROOT ./cmd/nfpm
$INSTALLROOT/nfpm
