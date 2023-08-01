#!/usr/bin/env bash
set -euE -o pipefail
source ustar.bash

USTAR_OPTIONS=user+group=root,mtime=now

pack() {
	ustar-dump -D a
	ustar-dump -F a/file "lorem ipsum"
	ustar-dump -Lo target=file a/symlink
}

pack | tar -tvf -
