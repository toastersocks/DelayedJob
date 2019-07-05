#!/usr/bin/env bash

### This enables telling Xcode to run custom commands on run in order to enable remote debugging (e.g. for remote debugging on Raspberry Pi)

defaults write com.apple.dt.Xcode IDEDebuggerFeatureSetting 12

echo "Restart Xcode to see the change."

