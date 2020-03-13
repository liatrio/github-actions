#!/usr/bin/env python3
import yaml
import boto3
from botocore.exceptions import ClientError

def main():
  client = boto3.client('ecr')
  with open(r'skaffold.yaml') as file:
    skaffold = yaml.load(file)
    for artifact in skaffold['build']['artifacts']: 
      try:
        client.create_repository(
          repositoryName=artifact['image']
        )
      except ClientError as e:
        if e.response['Error']['Code'] == 'RepositoryAlreadyExists':
          pass
        else:
          print(e.response['Error']['Code'])
          raise(e)

if __name__ == "__main__":
  main()
