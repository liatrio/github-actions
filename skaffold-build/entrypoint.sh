#!/bin/sh -l
set -e
if [ -z "$1" ]
then
  skaffold config set --global local-cluster true
else
  export SKAFFOLD_DEFAULT_REPO=$1
fi

if [ $INPUT_CREATE = "true" ]
then
  /create-repos.py
fi

skaffold build
