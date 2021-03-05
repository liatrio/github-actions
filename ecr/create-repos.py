#!/usr/bin/env python3
import yaml
import json
import boto3
from botocore.exceptions import ClientError

def ecr_policy():
  policy = {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:ListImages"
        ]
      }
    ]
  }

  return policy


def main():
  client = boto3.client('ecr')
  with open(r'skaffold.yaml') as file:
    skaffold = yaml.load(file, Loader=yaml.FullLoader)
    for artifact in skaffold['build']['artifacts']: 
      repo = artifact['image']
      try:
        client.create_repository(
          repositoryName=repo
        )
        print("Created new repository '{}'".format(repo))
      except ClientError as e:
        if e.response['Error']['Code'] == 'RepositoryAlreadyExistsException':
          print("Repository '{}' already existed.".format(repo))
          pass
        else:
          raise(e)

      client.set_repository_policy(
        repositoryName=artifact['image'],
        policyText=json.dumps(ecr_policy())
      )

if __name__ == "__main__":
  main()
