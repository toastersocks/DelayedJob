#!/usr/bin/env bash

### This can be run from non-Linux platforms to run tests on a dockerized ARM Linux install

command -v docker >/dev/null 2>&1 || { echo >&2 "Docker not found. Docker is needed to run tests on Linux from a non-Linux environment. Visit https://hub.docker.com for more info. Aborting."; exit 1; }

swift test --generate-linuxmain # Requires the Objective-C runtime to do anything useful. Otherwise it silently fails. If you add tests from a non-Darwin platform, you have to update the test list manually or your new tests wont be found and run.

# arm7-32bit - Raspberry Pies except for Raspi Zero
echo "Running arm7-32bit Linux tests...."
docker run --rm \
    --volume "$(pwd):/package" \
    --workdir "/package" \
    wlisac/raspberrypi3-swift:5.0.1-build \
    /bin/bash -c \
    "swift package resolve && swift test --build-path ./.build/linux"
echo "Done!"