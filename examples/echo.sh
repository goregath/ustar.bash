#!/usr/bin/env bash

# A simple program that packs itself into a tar archive.

set -euE -o pipefail

# shellcheck source=/dev/null
source ustar.bash

pack() {
  ustar-dump -Fo mode=0755,mtime=now,size="$(stat -Lc %s "$1")" "$(basename "$1")"
  dd if="$0" ibs=512 conv=sync status=none
}

pack "$0"
