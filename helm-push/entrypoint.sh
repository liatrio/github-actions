#!/bin/sh -l
set -e

ARGS=""
if [ ! -z $INPUT_VERSION ]
then
  echo "setting version=${INPUT_VERSION}"
  ARGS="$ARGS --version ${INPUT_VERSION}" 
fi

if [ ! -z $INPUT_APPVERSION ]
then
  echo "setting app version=${INPUT_APPVERSION}"
  ARGS="$ARGS --app-version ${INPUT_APPVERSION}"
fi

helm lint $INPUT_CHART
helm package $ARGS $INPUT_CHART

helm repo add liatrio s3://${INPUT_BUCKET}/charts
helm s3 push --acl="public-read" $(basename $INPUT_CHART)-${INPUT_VERSION}.tgz liatrio
