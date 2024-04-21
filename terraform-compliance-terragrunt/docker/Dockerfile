ARG TERRAFORM_COMPLIANCE_VERSION=latest

ARG TERRAGRUNT_IMAGE_VERSION=latest
FROM alpine/terragrunt:$TERRAGRUNT_IMAGE_VERSION as builder
RUN which terragrunt >> /tmp/alpine_terragrunt_binaries && \
    which terraform >> /tmp/alpine_terragrunt_binaries && \
    mkdir -p /custom && \
    for file in $(echo $(cat /tmp/alpine_terragrunt_binaries)); \
    do \
      mv $file /custom/; \
    done

FROM eerkunt/terraform-compliance:$TERRAFORM_COMPLIANCE_VERSION
COPY --from=builder /custom/* /opt/bin/
ENV PATH="/opt/bin:${PATH}"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]