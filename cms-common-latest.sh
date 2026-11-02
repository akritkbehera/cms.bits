#!/bin/bash
set -euo pipefail
# A missing read store means this bootstrap uses only the pinned local package.
store=${BITS_REMOTE_STORE:-}
if [ -z "$store" ]; then
  exit 0
fi
store=${store%::rw}
case "$store" in
  b3://*|s3://*)
    bucket=${store#*://}
    if [[ ! "$bucket" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
      echo "cms-common: invalid S3 bucket in --remote-store: $store" >&2
      exit 1
    fi
    endpoint=${BITS_S3_ENDPOINT_URL:-https://s3.cern.ch}
    case "$endpoint" in
      http://*|https://*) base="${endpoint%/}/$bucket" ;;
      *) echo "cms-common: invalid S3 endpoint: $endpoint" >&2; exit 1 ;;
    esac
    ;;
  http://*|https://*)
    if [[ "$store" =~ ^(https?://[^/]+)/swift/v1/([A-Za-z0-9._-]+)$ ]]; then
      base="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    else
      base=${store%/}
    fi
    ;;
  *)
    echo "cms-common: public download requires an S3 or HTTP --remote-store: $store" >&2
    exit 1
    ;;
esac
index=MANIFESTS/rev-index/share/cms-common
listing=$(curl -fsSL --retry 3 --connect-timeout 10 --max-time 30 "$base?list-type=2&prefix=$index/vCMS-")
if [[ "$listing" == *'<IsTruncated>true</IsTruncated>'* ]]; then
  echo "cms-common: revision index listing is truncated" >&2
  exit 1
fi
pattern='<Key>MANIFESTS/rev-index/share/cms-common/vCMS-([0-9]+)</Key>'
latest=0
while [[ "$listing" =~ $pattern ]]; do
  revision=${BASH_REMATCH[1]}
  matched=${BASH_REMATCH[0]}
  if (( 10#$revision > latest )); then latest=$((10#$revision)); fi
  listing=${listing#*"$matched"}
done
if (( latest == 0 )); then
  echo "cms-common: no revisions in public index" >&2
  exit 1
fi
current=$(cat "$WORK_DIR/etc/cms-common/revision" 2>/dev/null || true)
if [[ ! "$current" =~ ^[0-9]+$ ]]; then current=0; fi
if (( current >= latest )) && [ -f "$WORK_DIR/cmsset_default.csh" ]; then
  exit 0
fi
hash=$(curl -fsSL --retry 3 --connect-timeout 10 --max-time 30 "$base/$index/vCMS-$latest" | tr -d '\r\n')
if [[ ! "$hash" =~ ^[0-9a-f]{40}$ ]]; then
  echo "cms-common: invalid hash in vCMS-$latest marker" >&2
  exit 1
fi
prefix=$(printf '%s' "$hash" | cut -c1-2)
archive="$base/TARS/share/store/$prefix/$hash/cms-common-vCMS-$latest.share.tar.gz"
mkdir -p "$WORK_DIR/TMP"
stage=$(mktemp -d "$WORK_DIR/TMP/cms-common.XXXXXX")
trap 'rm -rf "$stage"' EXIT
curl -fsSL --retry 3 --connect-timeout 10 --max-time 120 -o "$stage/archive.tar.gz" "$archive"
expected=$(curl -fsSI --retry 3 --connect-timeout 10 --max-time 30 "$archive" |
  tr -d '\r' | awk 'tolower($1)=="x-amz-meta-sha256:" {sub(/^sha256:/,"",$2); print $2}')
if [[ ! "$expected" =~ ^[0-9a-f]{64}$ ]]; then
  echo "cms-common: archive has no valid SHA-256 metadata" >&2
  exit 1
fi
printf '%s  %s\n' "$expected" "$stage/archive.tar.gz" | sha256sum -c -
while IFS= read -r entry; do
  case "$entry" in
    ./|./share/|./share/cms/|./share/cms/cms-common/|./share/cms/cms-common/vCMS-$latest/|./share/cms/cms-common/vCMS-$latest/*) ;;
    *) echo "cms-common: unexpected archive path $entry" >&2; exit 1 ;;
  esac
  case "$entry" in
    */../*|*/./*|/*) echo "cms-common: unsafe archive path $entry" >&2; exit 1 ;;
  esac
done < <(tar -tzf "$stage/archive.tar.gz")
tar -xzf "$stage/archive.tar.gz" --no-same-owner -C "$stage"
target="$WORK_DIR/share/cms/cms-common/vCMS-$latest"
if [ ! -e "$target" ]; then
  mkdir -p "$WORK_DIR/share/cms/cms-common"
  mv "$stage/share/cms/cms-common/vCMS-$latest" "$target"
fi
if ! grep -qx "PH=$hash" "$target/etc/profile.d/.bits-pkginfo"; then
  echo "cms-common: installed vCMS-$latest has the wrong package hash" >&2
  exit 1
fi
CMS_COMMON_REMOTE_UPGRADE_ACTIVE=1 WORK_DIR="$WORK_DIR" bash "$target/relocate-me.sh"
printf '%s\n' "$latest" > "$WORK_DIR/etc/cms-common/revision"
