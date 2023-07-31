#!/usr/bin/env bash

set -eE -o pipefail
shopt -s globstar

source ustar.bash

USTAR_OPTS="uid+gid=${UID},user+group=${USER},time=now"

ustar-dump -D dir
ustar-dump -D subdir
ustar-dump -F subdir/hello -- "lorem ipsum"
ustar-dump -S -otarget=hello subdir/index
