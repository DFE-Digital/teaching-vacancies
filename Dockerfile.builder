FROM ruby:2.7.1-alpine

WORKDIR /app

RUN set -eux; \
	\
        apk update && \
        apk add --no-cache \
                build-base \
                gcc \
                libc-dev \
                libpq \
                libxml2 \
                libxml2-dev \
                libxslt \
                libxslt \
                make \
                nodejs \
                postgresql-dev \
                tzdata \
                yarn

RUN echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime

# skip installing gem documentation
RUN set -eux; \
	mkdir -p /usr/local/etc; \
	{ \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc

# Install the version of bundler which generated Gemfile.lock
RUN gem install bundler:2.1.4

# Install standard Node modules
COPY package.json yarn.lock /app/
RUN yarn install --frozen-lockfile

# Install standard gems
COPY Gemfile* /app/
RUN bundle config --local frozen 1 && \
    bundle install --no-binstubs --retry=5 --jobs=4

#### ONBUILD: Add triggers to the image, executed later while building a child image

# Install Ruby gems (for production only)
ONBUILD COPY Gemfile* /app/
ONBUILD RUN bundle config --local without 'development test' && \
            bundle --no-binstubs --retry=5 --jobs=4 && \
            # Remove unneeded gems
            bundle clean --force && \
            # Remove unneeded files from installed gems (cached *.gem, *.o, *.c)
            rm -rf /usr/local/bundle/cache/*.gem && \
            find /usr/local/bundle/gems/ -name "*.c" -delete && \
            find /usr/local/bundle/gems/ -name "*.h" -delete && \
            find /usr/local/bundle/gems/ -name "*.o" -delete && \
            find /usr/local/bundle/gems/ -name "*.html"

# Copy the whole application folder into the image
ONBUILD COPY . /app

# Compile assets with Webpacker or Sprockets
#
# Notes:
#   1. Executing "assets:precompile" runs "yarn:install" prior
#   2. Executing "assets:precompile" runs "webpacker:compile", too
#
ONBUILD RUN RAILS_ENV=staging \
            bundle exec rails assets:precompile

# Remove folders not needed in resulting image
ONBUILD RUN rm -rf log node_modules spec test tmp vendor/bundle yarn.lock && \
            rm -rf .env && touch .env
