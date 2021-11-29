ARG RUBY_VERSION=3.0.3
FROM ruby:${RUBY_VERSION}

ARG USERNAME=teaching-vacancies
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Set up dependencies
RUN apt update && apt install -y nodejs yarnpkg postgresql-client redis-tools \
      less vim sudo shared-mime-info man-db

# Set up unprivileged local user
RUN groupadd --gid $USER_GID $USERNAME \
    && groupadd bundler \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME --shell /bin/bash --groups bundler \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Debian has Yarn as `yarnpkg`, so symlink it to a more expected `yarn` command
# TODO: Replace with `bin/yarn`
RUN ln -s /usr/bin/yarnpkg /usr/local/bin/yarn

# Set unprivileged user as default user
USER $USERNAME

ENV DEVCONTAINER=true
