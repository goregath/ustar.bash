#!/bin/bash

export BATS_TEST_TIMEOUT=1

# shellcheck disable=SC2164
cd "${BATS_TEST_DIRNAME}/.."

source ./ustar.bash

dump2s() {
	# struct posix_header
	# {                      /* OFF */
	#   char name[100];      /*   0 */
	#   char mode[8];        /* 100 */
	#   char uid[8];         /* 108 */
	#   char gid[8];         /* 116 */
	#   char size[12];       /* 124 */
	#   char mtime[12];      /* 136 */
	#   char chksum[8];      /* 148 */
	#   char typeflag;       /* 156 */
	#   char linkname[100];  /* 157 */
	#   char magic[6];       /* 257 */
	#   char version[2];     /* 263 */
	#   char uname[32];      /* 265 */
	#   char gname[32];      /* 297 */
	#   char devmajor[8];    /* 329 */
	#   char devminor[8];    /* 337 */
	#   char prefix[155];    /* 345 */
	#                        /* 500 */
	# };
	ustar-dump "$@" | strings -td -n1 | awk '{ $1=sprintf("%03d",$1) } 1'
}