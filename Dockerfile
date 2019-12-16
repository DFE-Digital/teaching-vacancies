FROM ruby:2.6.5-alpine as release
LABEL maintainer="teaching.vacancies@education.gov.uk"

ENV INSTALL_PATH /srv/dfe-tvs

RUN \
  mkdir -p $INSTALL_PATH \
  mkdir -p $INSTALL_PATH/log \
  mkdir -p $INSTALL_PATH/tmp

WORKDIR $INSTALL_PATH
COPY . $INSTALL_PATH

ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RACK_ENV=${RAILS_ENV:-production}

RUN \
  apk add --update --virtual build-dependencies \
  build-base \
  gcc \
  git \
  postgresql-dev && \
  apk add --update --no-cache \
  bash \
  libpq \
  npm \
  tzdata

RUN \
  if [ "$RAILS_ENV" = "development" ] || [ "$RAILS_ENV" = "test" ]; \
    then \
      bundle install --retry 10; \
    else \
      bundle install --without development test --retry 10; \
      RAILS_ENV=production bundle exec rake DATABASE_URL=postgresql:does_not_exist --quiet assets:precompile; \
    fi

RUN \
  npm install --only=production && \
  gem install bundler && \
  apk del build-dependencies

#ENV OPENSSL_CONF=/etc/ssl/
#ENV PHANTOM_JS="phantomjs-2.1.1-linux-x86_64"
#RUN curl -OLk https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2
#RUN tar xvjf $PHANTOM_JS.tar.bz2
#RUN mv $PHANTOM_JS/bin/phantomjs /usr/local/bin/phantomjs
#RUN rm -rf $PHANTOM_JS

EXPOSE 3000
CMD ["rails", "server"]
