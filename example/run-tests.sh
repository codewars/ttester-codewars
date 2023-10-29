#!/usr/bin/env bash
# Copyright 2018-2023 nomennescio

example_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P)

cd "$example_dir"
gforth ../preamble.4th ../testest.4th ../protect.4th preloaded.4th solution.4th ../prepare.4th tests.4th -e bye
