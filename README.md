# ustar.bash

A pure bash library for generating uncompressed tarball chunks.

This implementation is fully self-contained and does not rely on any external programs.

Tested with _GNU Bash 5.1_, _4.4_ and _4.3_, striving for full support from _4.3+_.

## Usage

```plain
USAGE: ustar-dump [-hBCDFHLP] [-o OPTION] [--] PATH [PAYLOAD]

  -h         Display this text and exit.
  -B         Set to block device,     alias for `-o type=blk,mode=0666`.
  -C         Set to character device, alias for `-o type=chr,mode=0666`.
  -D         Set to directory,        alias for `-o type=dir,mode=0775`.
  -F         Set to regular file,     alias for `-o type=reg,mode=0644`.
  -H         Set to hard link,        alias for `-o type=lnk,mode=0644`.
  -L         Set to symbolic link,    alias for `-o type=sym,mode=0777`.
  -P         Set to named pipe,       alias for `-o type=fifo,mode=0644`.
  -o OPTION  Configure fields of header.
```
### Setting fields

Use the `-o OPTION` to change specific fields of a header. The `OPTION` argument is defined as follows:
```
OPTION := FIELD[+FIELD..]=[VALUE][,OPTION..]
```
Where `FIELD` can be one of:

| field    | type            | alias                     |
|----------|-----------------|---------------------------|
| `name`   | `string`        | `n`                       |
| `mode`   | `number`        | `m`                       |
| `uid`    | `number`        | `u`                       |
| `gid`    | `number`        | `g`                       |
| `size`   | `number`        | `s`, `sz`                 |
| `mtime`  | `number`        | `t`, `time`, `date`       |
| `type`   | `number`,`char` | `T`                       |
| `link`   | `string`        | `l`, `target`, `linkname` |
| `user`   | `string`        | `U`, `uname`              |
| `group`  | `string`        | `G`, `gname`              |
| `major`  | `string`        | `D`, `devmajor`           |
| `minor`  | `string`        | `d`, `devminor`           |
| `prefix` | `string`        | `p`                       |
| `path`\* | `string`        | `P`                       |

Setting `path` will affect the fields `name` and `prefix` by balancing the path components betwen those two, e.g. a value of `"a/file"` will set `prefix` to `"a"` and `name` to `"file"`.

It is also possible to specify multiple fields by concatenating them by `+`, e.g. `user+group`, thus the value is applied to all fields enumerated.

The assignment of `VALUE` can either be a string or numeric constant. Please take note, that an assignment is terminated by `,` (comma) or `\n` (newline). Literals like `,` or `\n` should be escaped properly, e.g. `lorem ispum\, dolor`.

Multiple options can be specified either by concatenation `,` (comma), or by specifying multiple `-o` options at command line. Its values are applied in order appearance.

There is also a special variable `USTAR_OPTIONS` whose content is applied before command line arguments are evaluated.

## Example

```bash
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
```
```plain
drwxrwxr-x root/root         0 2023-07-31 13:37 a/
-rw-r--r-- root/root        11 2023-07-31 13:37 a/file
lrwxrwxrwx root/root         0 2023-07-31 13:37 a/symlink -> file
```

## Requirements

Only _GNU Bash 4.3+_ is required with array support enabled.
