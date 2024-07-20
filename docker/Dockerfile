# Use Fedora 40 as the base image
FROM fedora:40

ARG SOPS_VERSION=v3.8.1
ARG KUBECTL_VERSION=v1.30.0

# Install necessary packages to download and install binaries
RUN dnf update -y && \
    dnf install -y curl gnupg yq && \
    dnf clean all

# Install sops binary
RUN curl -LO https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64 && \
    mv sops-${SOPS_VERSION}.linux.amd64 /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# Install kubectl binary
RUN curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/


COPY decrypt-sops.sh /usr/local/bin/decrypt-sops.sh

# Create necessary directories and set permissions
RUN mkdir -p /decrypted-secrets && \
    mkdir -p /tmp/gnupg && \
    chmod 700 /tmp/gnupg


# Make the script executable
RUN chmod +x /usr/local/bin/decrypt-sops.sh

# Set the entry point to bash
ENTRYPOINT ["/bin/bash"]
