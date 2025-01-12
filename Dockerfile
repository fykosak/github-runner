FROM ubuntu:24.04

ARG RUNNER_VERSION="2.321.0"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN useradd -m runner --uid 987

# Install packages needed for runner
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl jq build-essential libssl-dev libffi-dev libicu-dev python3 python3-venv python3-dev python3-pip

# Install essential packages to be used in runs
RUN apt-get install -y --no-install-recommends \
	git sudo

# Add runner user to sudoers
RUN echo 'runner ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# Install runner
RUN cd /home/runner && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R runner ~runner && /home/runner/actions-runner/bin/installdependencies.sh

# Install additional packages and tools
RUN apt-get install -y --no-install-recommends \
	gettext mariadb-server mariadb-client

# Copy and make executable the starting script
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "runner" so all subsequent commands are run as the runner user
USER runner

# set correct utf-8 enconding, needed for correct insertions to mariadb tables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

ENTRYPOINT ["./entrypoint.sh"]
