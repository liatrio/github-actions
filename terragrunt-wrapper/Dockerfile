# syntax = docker/dockerfile:experimental
FROM golang:1.17 as builder

WORKDIR /workspace

RUN apt update && \
    apt install unzip

ENV TERRAFORM_VERSION="1.0.8"

RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

COPY go.mod go.sum /workspace/
RUN go mod download

COPY main.go main.go
COPY comments/ comments/
COPY config/ config/
COPY terragrunt/ terragrunt/

RUN --mount=type=cache,target=/root/.cache/go-build CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o terragrunt-wrapper main.go


FROM alpine:3.14.2

RUN apk add --no-cache git

WORKDIR /
COPY --from=builder /workspace/terragrunt-wrapper .
COPY --from=builder /workspace/terraform /bin/terraform
ENV TERRAFORM_PATH="/bin/terraform"

ENTRYPOINT ["/terragrunt-wrapper"]
