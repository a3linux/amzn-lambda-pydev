FROM public.ecr.aws/lambda/python:3.9

RUN yum install -y yum-utils curl wget which gcc-c++ make jq amazon-linux-extras shadow-utils

# NodeJs 16.x
RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash -
RUN yum install -y nodejs
# terraform: 1.1.2
RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
RUN yum -y install terraform
# Vault
RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
RUN yum -y install vault
# terragrunt: 0.35.16
ENV TERRAGRUNT_VERSION=v0.35.16
ENV TERRAGRUNT_SHA256SUM=0404f0dfd2ab3b642dcf2c1c038d0bcbee256ee14a92d731a9ea0514f6cf47f4
RUN curl -sL https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 > \
    terragrunt_${TERRAGRUNT_VERSION} && \
    echo "${TERRAGRUNT_SHA256SUM}  terragrunt_${TERRAGRUNT_VERSION}" > terragrunt_${TERRAGRUNT_VERSION}_SHA256SUMS && \
    sha256sum -c --status terragrunt_${TERRAGRUNT_VERSION}_SHA256SUMS && \
    mv terragrunt_${TERRAGRUNT_VERSION} /bin/terragrunt && \
    chmod +x /bin/terragrunt
# serverless
RUN npm install -g serverless fx yarn

# awscli
RUN pip3 install awscli

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set image for Jenkins environment
ARG user=iacuser
ARG group=iacuser
ARG uid=1001
ARG gid=1001

ENV IACUSER_HOME /home/iacuser
RUN /usr/sbin/groupadd -g ${gid} ${group} && /usr/sbin/useradd -u ${uid} -g ${group} -d ${IACUSER_HOME} -s /bin/bash ${user}

COPY ./scripts/dotbash_functions ${IACUSER_HOME}/.bash_functions
COPY ./scripts/dotbash_profile ${IACUSER_HOME}/.bash_profile
COPY .yarnrc ${IACUSER_HOME}/.yarnrc
COPY .npmrc ${IACUSER_HOME}/.npmrc
RUN chown -R ${user}:${group} ${IACUSER_HOME}

USER iacuser
WORKDIR ${IACUSER_HOME}

ENV PATH /var/lang/bin:/usr/local/bin:/usr/bin/:/bin:/opt/bin
ENTRYPOINT []
#ENTRYPOINT ["/lambda-entrypoint.sh"]
CMD ["bash", "-l"]
