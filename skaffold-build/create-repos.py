#!/usr/bin/env python3
import yaml
import boto3

def main():
  client = boto3.client('ecr')
  with open(r'skaffold.yaml') as file:
    skaffold = yaml.load(file, Loader=yaml.FullLoader)
    for artifact in skaffold['build']['artifacts']: 
      try:
        client.create_repository(
          repositoryName=artifact['image']
        )
      except client.exceptions.RepositoryAlreadyExistsException:
        pass

if __name__ == "__main__":
  main()
