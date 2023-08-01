#!/bin/bash

export BATS_TEST_TIMEOUT=1

# shellcheck disable=SC2164
cd "${BATS_TEST_DIRNAME}/.."

source ./ustar.bash