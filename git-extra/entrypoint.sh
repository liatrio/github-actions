#!/bin/sh -l
set -e

mkdir -p ~/.ssh
ssh-keyscan -H github.com > ~/.ssh/known_hosts
git fetch --unshallow origin +refs/tags/*:refs/tags/* || echo "ok"
VERSION=$(git describe --tags --dirty)
echo "::set-output name=version::${VERSION}"
