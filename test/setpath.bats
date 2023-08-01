#!/usr/bin/env bash

# shellcheck shell=bats
# shellcheck disable=SC1091

if [[ -z "$BATS_TEST_DIRNAME" ]]; then
	exec "${0%/*}"/bats/bats-core/bin/bats --tap "$0" "$@"
fi

source "$BATS_TEST_DIRNAME"/bats/commons.bash

setup() {
	load 'bats/bats-support/load'
	load 'bats/bats-assert/load'
}

@test "unicode support" {
	skip
}

@test "set path implicitely sets name and prefix" {
	run dump2s dir/file
	assert_output -p '0 file'
	assert_output -p '345 dir'
}

@test "set name" {
	run dump2s -o name=dir/file -
	assert_output -p '0 dir/file'
}

@test "set prefix" {
	run dump2s -o prefix=dir/file -
	assert_output -p '345 dir/file'
}

@test "set prefix,name" {
	run dump2s -o prefix=dir,name=file -
	assert_output -p '0 file'
	assert_output -p '345 dir'
}