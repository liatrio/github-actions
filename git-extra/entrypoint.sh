#!/bin/sh -l
set -e

git fetch --depth=1 origin +refs/tags/*:refs/tags/*
VERSION=$(git describe --tags --dirty)
echo "::set-output name=version::${VERSION}"
