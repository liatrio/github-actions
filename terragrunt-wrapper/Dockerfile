# syntax = docker/dockerfile:experimental
FROM golang:1.16 as builder

WORKDIR /workspace

COPY go.mod go.sum /workspace/
RUN go mod download

COPY main.go main.go
COPY comments/ comments/
COPY config/ config/
COPY terragrunt/ terragrunt/

RUN --mount=type=cache,target=/root/.cache/go-build CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o terragrunt-wrapper main.go

FROM amazonlinux:2 as deps

RUN yum update -y && \
    yum install -y unzip

ENV TERRAFORM_VERSION="1.0.8"
RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    ./terraform version

RUN curl -LO https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip && \
    unzip awscli-exe-linux-x86_64.zip && \
    ./aws/install --bin-dir /aws-cli-bin/ && \
    ./aws-cli-bin/aws --version

FROM amazonlinux:2

RUN yum install -y git

ENV TERRAFORM_PATH="/usr/bin/terraform"

COPY --from=deps /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=deps /aws-cli-bin/ /usr/local/bin/
COPY --from=deps /terraform ${TERRAFORM_PATH}

WORKDIR /
COPY --from=builder /workspace/terragrunt-wrapper .

ENTRYPOINT ["/terragrunt-wrapper"]
