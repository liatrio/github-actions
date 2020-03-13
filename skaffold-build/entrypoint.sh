#!/bin/sh -l
set -e

if [ -z $INPUT_DEFAULT_REPO ]
then
  skaffold config set --global local-cluster true 
else
  export SKAFFOLD_DEFAULT_REPO=$INPUT_DEFAULT_REPO
fi

skaffold build
