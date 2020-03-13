#!/bin/sh -l
set -e

git fetch origin +refs/tags/*:refs/tags/*
VERSION=$(git describe --tags --dirty)
echo "::set-output name=version::${VERSION}"
