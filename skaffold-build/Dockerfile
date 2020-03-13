# Container image that runs your code
FROM gcr.io/k8s-skaffold/skaffold:v1.5.0

RUN apt-get update \
    && apt install -y python3-pip

RUN pip3 install pyyaml \
    && pip3 install boto3 \
    && pip3 install awscli 

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY create-repos.py /create-repos.py
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
