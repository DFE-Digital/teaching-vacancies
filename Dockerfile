FROM ruby:2.4.0

MAINTAINER dxw <rails@dxw.com>

RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev postgresql-client-9.4 --fix-missing --no-install-recommends

ENV INSTALL_PATH /srv/dfe-beta

RUN mkdir -p $INSTALL_PATH

# set context of where commands will be ran
WORKDIR $INSTALL_PATH

# set rails environment
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RACK_ENV=${RAILS_ENV:-production}

COPY Gemfile $INSTALL_PATH/Gemfile
COPY Gemfile.lock $INSTALL_PATH/Gemfile.lock

RUN bundle install --without development test
COPY . $INSTALL_PATH

# bundle ruby gems based on the current environment, default to production
RUN \
  if [ "$RAILS_ENV" = "production" ]; then \
    bundle install --without development test --retry 10; \
  else \
    bundle install --retry 10; \
  fi

EXPOSE 3000
CMD ["bundle", "exec", "rails s"]
