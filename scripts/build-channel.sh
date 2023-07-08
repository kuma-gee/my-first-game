#!/bin/bash

CHANNEL=${CHANNEL:-$1}

mkdir -v -p build/$CHANNEL
godot --headless --export-release $CHANNEL