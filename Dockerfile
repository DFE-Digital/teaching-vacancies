# Install dependencies into a seperate and isolated Docker stage
# that is thrown away apart from any subsequent COPY commands
FROM mkenney/npm:latest AS dependencies
ENV INSTALL_PATH /deps
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH
COPY package.json ./package.json
COPY package-lock.json ./package-lock.json
RUN npm set progress=false && npm config set depth 0
RUN npm install --only=production

FROM ruby:2.6.5 as release
LABEL maintainer="teaching.vacancies@education.gov.uk"
RUN apt-get update && apt-get install -qq -y \
  build-essential \
  nodejs \
  libpq-dev \
  --fix-missing --no-install-recommends

ENV OPENSSL_CONF=/etc/ssl/
ENV PHANTOM_JS="phantomjs-2.1.1-linux-x86_64"
RUN curl -OLk https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2
RUN tar xvjf $PHANTOM_JS.tar.bz2
RUN mv $PHANTOM_JS/bin/phantomjs /usr/local/bin/phantomjs
RUN rm -rf $PHANTOM_JS

ENV INSTALL_PATH /srv/dfe-tvs
RUN mkdir -p $INSTALL_PATH

# This must be ordered before rake assets:precompile
COPY --from=dependencies ./deps/node_modules $INSTALL_PATH/node_modules
COPY --from=dependencies ./deps/node_modules/govuk-frontend/govuk/assets $INSTALL_PATH/app/assets

WORKDIR $INSTALL_PATH

# set rails environment
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RACK_ENV=${RAILS_ENV:-production}

COPY Gemfile $INSTALL_PATH/Gemfile
COPY Gemfile.lock $INSTALL_PATH/Gemfile.lock

RUN gem install bundler

# bundle ruby gems based on the current environment, default to production
RUN echo $RAILS_ENV
RUN \
  if [ "$RAILS_ENV" = "development" ] || [ "$RAILS_ENV" = "test" ]; then \
    bundle install --retry 10; \
  else \
    bundle install --without development test --retry 10; \
  fi

RUN mkdir -p $INSTALL_PATH/log
RUN mkdir -p $INSTALL_PATH/tmp

COPY .rspec $INSTALL_PATH/.rspec
COPY .rubocop.yml $INSTALL_PATH/.rubocop.yml
COPY config.ru $INSTALL_PATH/config.ru
COPY Rakefile $INSTALL_PATH/Rakefile

COPY public $INSTALL_PATH/public
COPY vendor $INSTALL_PATH/vendor
COPY lib $INSTALL_PATH/lib
COPY bin $INSTALL_PATH/bin
COPY config $INSTALL_PATH/config
COPY db $INSTALL_PATH/db
COPY spec $INSTALL_PATH/spec
COPY app $INSTALL_PATH/app

RUN \
  if [ ! "$RAILS_ENV" = "development" ] && [ ! "$RAILS_ENV" = "test" ]; then \
    RAILS_ENV=production bundle exec rake DATABASE_URL=postgresql:does_not_exist --quiet assets:precompile; \
  fi

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 3000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["rails", "server"]
