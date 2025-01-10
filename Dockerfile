FROM ubuntu:24.04

ARG RUNNER_VERSION="2.321.0"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN useradd -m docker --uid 987

# Install packages needed for runner
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl jq build-essential libssl-dev libffi-dev libicu-dev python3 python3-venv python3-dev python3-pip

# Install runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# Install additional packages to be used in runs
RUN apt-get update -y && apt-get install -y --no-install-recommends \
	git sudo

# Add docker user to sudoers
RUN echo 'docker ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# Copy and make executable the starting script
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

ENTRYPOINT ["./entrypoint.sh"]
