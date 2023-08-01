# ustar.bash

A pure bash library for generating uncompressed tarball chunks.

This implementation fully self-contained and does not rely on any external programs.

Tested with _bash 5.1_, striving for support from _4.3+_.

## Example

```bash
#!/usr/bin/env bash
set -euE -o pipefail
source ustar.bash

pack() {
	ustar-dump -D -o mtime=now a
	ustar-dump -F -o mtime=now a/file "lorem ipsum"
	ustar-dump -S -o mtime=now,target=file a/symlink
}

pack | tar -tvf -
```
```
drwxrwxr-x 0/0     0 2023-08-01 13:37 a/
-rw-r--r-- 0/0    11 2023-08-01 13:37 a/file
lrwxrwxrwx 0/0     0 2023-08-01 13:37 a/symlink -> file
```

## Requirements

At its current state, _GNU Bash 5.1+_ is required with array support enabled.