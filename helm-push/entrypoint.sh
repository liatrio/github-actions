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

if [ ! -z $INPUT_DEPENDENCIES ]
then
  echo "updating dependencies"
  ARGS="$ARGS --dependency-update"
  for config in $(echo $INPUT_DEPENDENCIES | jq -rc '.[]'); do
    name=$(echo ${config} | jq -r '.name')
    url=$(echo ${config} | jq -r '.url')
    helm repo add $name $url
  done;
fi

helm lint $INPUT_CHART
helm package $ARGS $INPUT_CHART

helm repo add liatrio s3://${INPUT_BUCKET}/charts
helm env
pwd
whoami
mkdir -p /root/.local/share/helm/repository/
ln -s /github/home/.config/helm/repositories.yaml /root/.local/share/helm/repository/repositories.yaml
helm s3 push --force --acl="public-read" $(basename $INPUT_CHART)-${INPUT_VERSION}.tgz liatrio
