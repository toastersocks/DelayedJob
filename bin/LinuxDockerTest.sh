#!/usr/bin/env bash

### This can be run from non-Linux platforms to run tests on a dockerized Linux install

command -v docker >/dev/null 2>&1 || { echo >&2 "Docker not found. Docker is needed to run tests on Linux from a non-Linux environment. Visit https://hub.docker.com for more info. Aborting."; exit 1; }

swift test --generate-linuxmain # Requires the Objective-C runtime to do anything useful. Otherwise it silently fails. If you add tests from a non-Darwin platform, you have to update the test list manually or your new tests wont be found and run.

echo "Running Linux tests...."

docker run --rm \
    --volume "$(pwd):/package" \
    --workdir "/package" \
    swift \
    /bin/bash -c \
    "swift package resolve && swift test --build-path ./.build/linux"

echo "Done!"