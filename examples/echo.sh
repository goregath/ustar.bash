#!/usr/bin/env bash

# A simple program that packs itself into a tar archive.

set -euE -o pipefail

# shellcheck source=/dev/null
source ustar.bash

pack() {
  ustar-dump -Fo"$(stat -Lc mode=%04a,mtime=%Y,size=%s -- "$1")" "$(basename "$1")"
  dd if="$1" ibs=512 conv=sync status=none
}

pack "$0"
