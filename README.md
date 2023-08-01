# ustar.bash
A library for generating tarball chunks written in pure bash.

```bash
#!/usr/bin/env bash
source ustar.bash
ustar-dump -F -o mode=0644,mtime=now a/file "lorem ipsum" | tar -tvf -
```
```
-rw-r--r-- 0/0    11 2023-08-01 13:37 a/file
```
