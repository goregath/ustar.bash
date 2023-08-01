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

@test "manual set size" {
	run dump2s -osize=8 -
	assert_output -p '124 10'
}

@test "implicit set size for non-empty payload" {
	run dump2s - "abc"
	assert_output -p '124 3'
}

@test "implicit set size overrides manual one for non-empty payload" {
	run dump2s -osize=8 - "abc"
	assert_output -p '124 3'
}

@test "manual set size overrides implicit one for empty payload" {
	run dump2s -osize=8 - ""
	assert_output -p '124 10'
}