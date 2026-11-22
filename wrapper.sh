export $DEFAULT_MICROARCH=echo "%(default_microarch)s" | tr '-' '_' | tr '[:lower:]' '[:upper:]'
export $(PKGNAME)_ROOT=$(PKGNAME)_$(DEFAULT_MICROARCH)_ROOT
export $(PKGNAME)_VERSION=..
export $(PKGNAME)_REVISION=..
export $(PKGNAME)_HASH=..
