#!/bin/sh -l
set -e

VERSION=$(git describe --tags --dirty)
echo "::set-output name=version::${VERSION}"
