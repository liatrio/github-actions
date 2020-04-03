#!/bin/sh -l
set -e

if [ -z $INPUT_DEFAULT_REPO ]
then
  skaffold config set --global local-cluster true 
else
  export SKAFFOLD_DEFAULT_REPO=$INPUT_DEFAULT_REPO
fi

if [ -z $INPUT_SKAFFOLD_FILE_PATH ]
then
  skaffold build
else
  skaffold build -f $INPUT_SKAFFOLD_FILE_PATH
fi
