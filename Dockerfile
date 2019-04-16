FROM openjdk:8-jdk

ARG AWSCLI_VER="1.16.118"

# Set up directories
RUN mkdir -p ~/.local/bin

# Install Docker
RUN apt-get update -y && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/debian \
        $(lsb_release -cs) \
        stable" && \
    apt-get update -y && \
    apt-get install -y docker-ce-cli

# Install AWS CLI
RUN apt-get install -y python-pip && \
    pip install awscli==${AWSCLI_VER} --upgrade --user

# Install gcloud
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh --quiet

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin:$HOME/.local/bin

# Install Helm
RUN export PATH=$PATH:$HOME/.local/bin/ \
  && cd /tmp \
  && curl -O -L https://storage.googleapis.com/kubernetes-helm/helm-v2.12.1-linux-amd64.tar.gz \
  && tar xvf helm-v2.12.1-linux-amd64.tar.gz \
  && cd $HOME/.local/bin \
  && mv /tmp/linux-amd64/helm . \
  && chmod u+x helm \
  && helm init --client-only \
  && helm plugin install https://github.com/databus23/helm-diff --version "v2.11.0+2"

# Install Helmfile
RUN cd $HOME/.local/bin \
  && curl -O -L https://github.com/roboll/helmfile/releases/download/v0.41.0/helmfile_linux_amd64 \
  && mv helmfile_linux_amd64 helmfile \
  && chmod u+x helmfile
