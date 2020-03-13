FROM docker:18.09

RUN apk update && \
apk -Uuv add python py-pip && \
pip install awscli boto3

COPY create-repos.py /create-repos.py
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
