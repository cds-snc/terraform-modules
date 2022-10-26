FROM mcr.microsoft.com/vscode/devcontainers/base:buster@sha256:6ebc901996e7a222d3e2ae7c2ed1710381fdb348cb2f43f6116ed5bd69ee268d

ARG USERNAME=vscode

# Set these in devcontainer.json
ARG GO_VERSION
ARG GO_CHECKSUM
ARG SHELLCHECK_VERSION
ARG SHELLCHECK_CHECKSUM
ARG TERRAFORM_VERSION
ARG TERRAFORM_CHECKSUM
ARG TERRAFORM_DOCS_VERSION
ARG TERRAFORM_DOCS_VERSION_CHECKSUM

# Install packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends awscli build-essential ca-certificates curl git gnupg2 jq libssl-dev libffi-dev make openssh-client python3-dev python3-pip vim xz-utils zsh \
    && apt-get autoremove -y && apt-get clean -y 

# Install Terraform
RUN curl -Lo terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && echo "${TERRAFORM_CHECKSUM} terraform.zip" | sha256sum --check \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# Install Terraform-docs
RUN curl -Lo terraform-docs.tar.gz "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz" \
    && echo "${TERRAFORM_DOCS_VERSION_CHECKSUM} terraform-docs.tar.gz" | sha256sum --check \ 
    && tar -xzf terraform-docs.tar.gz \
    && chmod +x terraform-docs \
    && mv terraform-docs /usr/local/bin/ \
    && rm terraform-docs.tar.gz

# Install ShellCheck
RUN curl -Lo shellcheck.tar.xz "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" \ 
    && echo "${SHELLCHECK_CHECKSUM} shellcheck.tar.xz" | sha256sum --check \
    && tar -xf shellcheck.tar.xz \
    && mv "shellcheck-v${SHELLCHECK_VERSION}/shellcheck" /usr/local/bin/ \
    && rm -r shellcheck*

# Install Checkov
RUN pip3 install --upgrade requests setuptools \
    && pip3 install --upgrade botocore checkov==2.1.242

# Install Go
RUN curl -Lo go.tar.gz "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    && echo "${GO_CHECKSUM} go.tar.gz" | sha256sum --check \
    && tar -C /usr/local -xf go.tar.gz \
    && rm go.tar.gz

ARG CONFTEST_VERSION
RUN wget "https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz" \
    && wget "https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/checksums.txt" \
    && grep 'Linux_x86_64.tar.gz' < checksums.txt | sha256sum --check  --status \
    && tar -zxvf "conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz" conftest \
    && mv conftest /usr/local/bin \
    && rm "conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz" checksums.txt

# Setup aliases and autocomplete
RUN echo "\n\
complete -C /usr/bin/aws_completer aws\n\
complete -C /usr/local/bin/terraform terraform\n\
alias tf='terraform'\n\
alias ll='la -la'" >> /home/"${USERNAME}"/.zshrc