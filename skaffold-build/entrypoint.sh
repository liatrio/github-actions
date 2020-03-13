#!/bin/sh -l
set -e

if [ $INPUT_PUSH != "true" ]
then
  skaffold config set --global local-cluster true 
fi

skaffold build
