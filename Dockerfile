FROM docker:20.10.24-alpine3.18

LABEL tools="docker-image, gitlab-aws, aws, helm, helm-charts, docker, gitlab-ci, kubectl, s3, aws-iam-authenticator, ecr, bash, envsubst, alpine, curl, python3, pip3, git"
LABEL version="1.0.0"
LABEL description="An Alpine based docker image contains a good combination of commonly used tools to build, package as docker image, login and push to AWS ECR, AWS authentication and all Kubernetes staff. tools included: Docker, AWS-CLI, Kubectl, Helm, Curl, Python, Envsubst, Python, Pip, Git, Bash, AWS-IAM-Auth."
LABEL maintainer="nanimanjala@gmail.com"

ENV AWS_CLI_VERSION 2.13.2 

# Install base dependencies and Python
RUN apk add --no-cache python3 py3-pip bash curl jq git openssl ca-certificates

# Upgrade pip and install setuptools
RUN python3 -m ensurepip && \
    pip3 install --upgrade pip setuptools

# Install AWS CLI in a virtual environment
RUN python3 -m venv /opt/venv && \
    source /opt/venv/bin/activate && \
    /opt/venv/bin/pip install "awscli==$AWS_CLI_VERSION"

# Add more tools
RUN apk add --no-cache \
    make \
    groff \
    less \
    docker-compose \
    wget

# Install envsubst
RUN curl -L -o /usr/local/bin/envsubst https://github.com/a8m/envsubst/releases/download/v1.18.0/envsubst-Linux-x86_64 && \
    chmod +x /usr/local/bin/envsubst

# Install aws-iam-authenticator
RUN curl -LO "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64" && \
    chmod +x aws-iam-authenticator_0.5.9_linux_amd64 && \
    mv aws-iam-authenticator_0.5.9_linux_amd64 /usr/local/bin/aws-iam-authenticator

# Install kubectl
RUN K8S_VERSION="v1.28.7" && \
    curl -LO "https://dl.k8s.io/release/$K8S_VERSION/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Helm (v3)
RUN HELM_VERSION="v3.14.0" && \
    curl -LO "https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz" && \
    tar -zxvf "helm-$HELM_VERSION-linux-amd64.tar.gz" && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf "helm-$HELM_VERSION-linux-amd64.tar.gz"

# Cleanup
RUN rm -rf /var/cache/apk/*

WORKDIR /data
