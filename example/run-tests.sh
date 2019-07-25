#!/usr/bin/env bash

example_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P)

cd "$example_dir"
gforth preloaded.4th solution.4th ../ttester-codewars.4th tests.4th -e bye
