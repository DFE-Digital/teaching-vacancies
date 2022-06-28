ARG RUBY_VERSION=3.1.2
FROM ruby:${RUBY_VERSION}

ARG USERNAME=teaching-vacancies
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG NODEJS_MAJOR_VERSION=16

# Set up NodeSource repository for newer Node.JS
RUN apt update -yq \
   && apt install curl gnupg -yq \
   && curl -sL https://deb.nodesource.com/setup_$NODEJS_MAJOR_VERSION.x | bash

# Set up dependencies
RUN apt install -y nodejs postgresql-client redis-tools less vim sudo shared-mime-info man-db
RUN npm install -g yarn

# Set up unprivileged local user
RUN groupadd --gid $USER_GID $USERNAME \
    && groupadd bundler \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME --shell /bin/bash --groups bundler \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set unprivileged user as default user
USER $USERNAME

ENV DEVCONTAINER=true
