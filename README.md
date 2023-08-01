# ustar.bash

A pure bash library for generating uncompressed tarball chunks.

This implementation is fully self-contained and does not rely on any external programs.

Tested with _GNU Bash 5.1_, _4.4_ and _4.3_, striving for full support from _4.3+_.

## Usage

```plain
Usage: ustar-dump [-hBCDFLPS] [-o OPT] [--] [PATH] [PAYLOAD]
  -B      Same as `-o type=blk,mode=0666`.
  -C      Same as `-o type=chr,mode=0666`.
  -D      Same as `-o type=dir,mode=0775`.
  -F      Same as `-o type=reg,mode=0644`.
  -L      Same as `-o type=lnk,mode=0644`.
  -P      Same as `-o type=pipe,mode=0644`.
  -S      Same as `-o type=sym,mode=0777`.
  -h      Display this text and exit.
  -o OPT  Configure fields of header.
```

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
```plain
drwxrwxr-x 0/0     0 2023-08-01 13:37 a/
-rw-r--r-- 0/0    11 2023-08-01 13:37 a/file
lrwxrwxrwx 0/0     0 2023-08-01 13:37 a/symlink -> file
```

## Requirements

Only _GNU Bash 4.3+_ is required with array support enabled.
