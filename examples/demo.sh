#!/usr/bin/env bash
set -eE -o pipefail
source ustar.bash
ustar-dump -F -o mode=0644,mtime=now a/file "lorem ipsum" | tar -tvf -