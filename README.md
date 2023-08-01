# ustar.bash

A pure bash library for generating uncompressed tarball chunks.

This implementation is fully self-contained and does not rely on any external programs.

Tested with _GNU Bash 5.1_, _4.4_ and _4.3_, striving for full support from _4.3+_.

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

Only _GNU Bash 4.3+_ is required with array support enabled.
