#!/bin/sh -l
set -e

git fetch --unshallow origin +refs/tags/*:refs/tags/*
VERSION=$(git describe --tags --dirty)
echo "::set-output name=version::${VERSION}"
