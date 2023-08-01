#!/usr/bin/env bash

# shellcheck shell=bats
# shellcheck disable=SC1091,SC2093,SC2164

if [[ -z "$BATS_TEST_DIRNAME" ]]; then
	exec "${0%/*}"/bats/bats-core/bin/bats --tap "$0" "$@"
fi

source "$BATS_TEST_DIRNAME"/bats/commons.bash

setup() {
	load 'bats/bats-support/load'
	load 'bats/bats-assert/load'
	load 'bats/bats-file/load'
	TEST_TEMP_DIR="$(temp_make)"
}

teardown() {
	temp_del "$TEST_TEMP_DIR"
}

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

dump() {
	ustar-dump "$@" | strings -td -n1 | sed -e 's/^[ \t]*//'
}

@test "unicode" {
	:
}

@test "path" {
	run dump dir/file
	assert_output --partial '0 file'
	assert_output --partial '345 dir'
}

@test "name" {
	run dump -o name=dir/file -
	assert_output --partial '0 dir/file'
}

@test "prefix" {
	run dump -o prefix=dir/file -
	assert_output --partial '345 dir/file'
}

@test "prefix,name" {
	run dump -o prefix=dir,name=file -
	assert_output --partial '0 file'
	assert_output --partial '345 dir'
}