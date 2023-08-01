#!/usr/bin/env bash
set -euE -o pipefail
source ustar.bash

pack() {
	ustar-dump -D -o mtime=now a
	ustar-dump -F -o mtime=now a/file "lorem ipsum"
	ustar-dump -S -o mtime=now,target=file a/symlink
}

pack | tar -tvf -
