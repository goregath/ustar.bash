[![CI](https://github.com/goregath/ustar.bash/actions/workflows/tests.yml/badge.svg)](https://github.com/goregath/ustar.bash/actions/workflows/tests.yml)

# ustar.bash

A pure bash library for generating uncompressed tarball chunks.

This implementation is fully self-contained and does not rely on any external programs.

Tested with _GNU Bash 5.1_, _4.4_ and _4.3_, striving for full support from _4.3+_.

## Usage

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


### Setting fields

Use the `-o OPTION` to change specific fields of a header. The `OPTION` argument is defined as follows:

    OPTION := FIELD[+FIELD..]=[VALUE][,OPTION..]

The assignment of `VALUE` can either be a string or numeric constant. The latter supports integers with different base
notations like `0x400`, `0755`. If a field is not defined it either defaults to the empty string `""` or `0` for strings
or numbers respectively. Please take note, that an assignment is terminated by `,` (comma) or `\n` (newline). Literals
like `,` or `\n` should be escaped properly, e.g. `lorem ispum\, dolor`.

It is also possible to specify multiple fields by concatenating them by `+`, e.g. `user+group`, thus the value is
applied to all fields enumerated.

Multiple options can be specified either by concatenation `,` (comma), or by specifying multiple `-o` options at command
line. Its values are applied in order appearance.

There is also a special variable `USTAR_OPTIONS` whose content is applied before command line arguments are evaluated.
Please take a look at the [Examples](#examples) section for how it can be used.

Where `FIELD` can be one of:

| field    | type              | alias                     | example            |
|----------|-------------------|---------------------------|--------------------|
| `name`   | `string`          | `n`                       |                    |
| `mode`   | `number`          | `m`                       | `420`, `0644`      |
| `uid`    | `number`          | `u`                       |                    |
| `gid`    | `number`          | `g`                       |                    |
| `size`   | `number`          | `s`, `sz`                 |                    |
| `mtime`  | `number`,`string` | `t`, `time`, `date`       | `now`, `283996800` |
| `type`   | `number`,`string` | `T`                       | `0`, `-`, `reg`    |
| `link`   | `string`          | `l`, `target`, `linkname` |                    |
| `user`   | `string`          | `U`, `uname`              |                    |
| `group`  | `string`          | `G`, `gname`              |                    |
| `major`  | `number`          | `D`, `devmajor`           |                    |
| `minor`  | `number`          | `d`, `devminor`           |                    |
| `prefix` | `string`          | `p`                       |                    |
| `path`\* | `string`          | `P`                       |                    |

The fields `prefix` and `name` are used to specify the file name of the chunk. A `prefix` of `"sub/dir"` and a `name` of
`"file"` is interpreted by the tar specification as `"sub/dir/file"`.

The `path` field has a special meaning, setting it will affect the fields `name` and `prefix` by balancing the path
components between those two, e.g. a value of `"a/file"` will set `prefix` to `"a"` and `name` to `"file"`. The `path`
value can either be specified as an option or via command line argument (see [Usage](#usage)). The latter form is for
convenience and offers some auto-magic like appending a trailing `/` if the `type` has been previously set to directory.
Please take note that this form is only applied if neither `prefix` nor `name` has been previously set.

File permissions can be set by `mode` but only numeric constants are allowed, octal notations like `0755` are supported.
File ownership can either be set with `uid` (user id) and `gid` (group id) or with `user` or `group` or both.

File modification time is set by `mtime` in seconds since epoch ([Unix time][wiki-unixtime]). If the special value
`"now"`is supplied, `mtime` is set to the current time [UTC][wiki-utc].

The file type can be set with `type` using either a single character or an alias string as you can see in the table
below: 

| type             | number | symbolic | alias                        |
|------------------|--------|----------|------------------------------|
| regular file     | `0`    | `-`      | `reg`, `file`, `regular`     | 
| hard link        | `1`    | `h`      | `lnk`, `link`, `hardlink`    |
| symbolic link    | `2`    | `l`      | `sym`, `softlink`, `symlink` |
| character device | `3`    | `c`      | `chr`, `char`                |
| block device     | `4`    | `b`      | `blk`, `block`               |
| directory        | `5`    | `d`      | `dir`, `directory`           |
| named pipe       | `7`    | `p`      | `fifo`, `pipe`               |

The field `link` is only of relevance if the `type` is set to either `h` (hard link) or `l` (symbolic link).

Device numbers, `major` and `minor`, are only of relevance if the `type` is set to either `c` (character device) or `b`
(block device).

## USTAR Format

This implementation follows the *USTAR* (*Unix Standard TAR*) specification for portable *tar* archives as defined by
POSIX.1-1988 and POSIX.1-2001. 

It does not have support for extended header capabilities, later enhancements to overcome the fixed field size
limitations and the inability to store additional fields like [Extended Attributes][xattr(7)]. 

Some restrictions are resumed in the [GNU Manual][gnu-manual-tar-format]:

> * File names can contain at most 255 bytes.
> * File names longer than 100 bytes must be split at a directory separator in two parts, the first being at most 155
>   bytes long. So, in most cases file names must be a bit shorter than 255 bytes.
> * Symbolic links can contain at most 100 bytes.
> * Files can contain at most 8 GiB (2^33 bytes = 8,589,934,592 bytes).
> * UIDs, GIDs, device major numbers, and device minor numbers must be less than 2^21 (2,097,152). 

## Examples

### Demo

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

pack
```

```plain
$ examples/demo.sh | tar -tvf -
drwxrwxr-x root/root         0 2023-07-31 13:37 a/
-rw-r--r-- root/root        11 2023-07-31 13:37 a/file
lrwxrwxrwx root/root         0 2023-07-31 13:37 a/symlink -> file
```

### Archive file from disk

```bash
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
```

```plain
$ examples/echo.sh | tar -tvf -
-rwxr-xr-x 0/0             298 2023-07-31 13:37 echo.sh
```

### GNU Make

For a full listing please see [examples/demo.mk](examples/demo.mk).

```plain
$ make -f examples/demo.mk clean all
mkdir -p tmp/ustar/
./ustar.bash -o group=root -o mode=0644 -o mtime=1697399708 -o name=README -o prefix=ustar.bash-7c92690 -o size=0 -o type=file -o user=root -- "" "A demo archive with ustar.bash and make" > tmp/ustar/README
./ustar.bash -o group=root -o mode=0755 -o mtime=1697399708 -o name=lib/ustar.bash -o prefix=ustar.bash-7c92690 -o size=7450 -o type=file -o user=root -- "" "" > tmp/ustar/lib-ustar
./ustar.bash -o group=root -o link=../lib/ustar.bash -o mode=0777 -o mtime=1697399708 -o name=bin/ustar-dump -o prefix=ustar.bash-7c92690 -o size=0 -o type=symlink -o user=root -- "" "" > tmp/ustar/bin-ustar
dd if=tmp/ustar/README of=demo.tar ibs=512 conv=sync,notrunc oflag=append status=none 
dd if=tmp/ustar/lib-ustar of=demo.tar ibs=512 conv=sync,notrunc oflag=append status=none 
dd if=ustar.bash of=demo.tar ibs=512 conv=sync,notrunc oflag=append status=none 
dd if=tmp/ustar/bin-ustar of=demo.tar ibs=512 conv=sync,notrunc oflag=append status=none 
tar -tvf demo.tar
-rw-r--r-- root/root        39 2023-10-15 21:55 ustar.bash-7c92690/README
-rwxr-xr-x root/root      7450 2023-10-15 21:55 ustar.bash-7c92690/lib/ustar.bash
lrwxrwxrwx root/root         0 2023-10-15 21:55 ustar.bash-7c92690/bin/ustar-dump -> ../lib/ustar.bash
gzip -kf demo.tar
```

## Requirements

Only _GNU Bash 4.3+_ is required with array support enabled.

[wiki-unixtime]: https://en.wikipedia.org/wiki/Unix_time "Wikipedia: Unix Time"
[wiki-utc]: https://en.wikipedia.org/wiki/Coordinated_Universal_Time "Wikipedia: Coordinated Universal Time"
[gnu-manual-tar-format]: https://www.gnu.org/software/tar/manual/tar.html#Formats "GNU Tar Manual: Formats"
[gnu-manual-tar-standard]: https://www.gnu.org/software/tar/manual/tar.html#Standard "GNU Tar Manual: Standard"
[xattr(7)]: http://www.kernel.org/doc/man-pages/online/pages/man7/xattr.7.html "Manpage of xattr(7)" 
