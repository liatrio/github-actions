#!/bin/sh -l
set -e

if [ "$INPUT_LOGIN" = "true" ]
then
  $(aws ecr get-login --no-include-email)
fi

if [ "$INPUT_CREATE_REPOS" = "true" ]
then
  /create-repos.py
fi

REGISTRY=$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com
echo "::set-output name=registry::${REGISTRY}"
