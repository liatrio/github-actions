FROM docker:18.09

RUN apk update && \
apk -Uuv add python3 py3-pip && \
pip3 install awscli boto3

COPY create-repos.py /create-repos.py
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
