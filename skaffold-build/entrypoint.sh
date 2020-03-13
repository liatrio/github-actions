#!/bin/sh -l
set -e

if [ $INPUT_LOGIN_ECR = "true" ]
then
  $(aws ecr get-login --no-include-email)
  export SKAFFOLD_DEFAULT_REPO=$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com
fi

if [ $INPUT_PUSH != "true" ]
then
  skaffold config set --global local-cluster true 
fi

if [ $INPUT_CREATE_ECR = "true" ]
then
  /create-repos.py
fi

skaffold build
