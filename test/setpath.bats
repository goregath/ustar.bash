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

@test "path" {
	:
}
