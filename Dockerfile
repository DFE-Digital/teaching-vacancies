 # Some packages are defined here with a hardcoded version to resolve vulnerabilities in the packages coming with
 # Alpine v3.23
 # TODO: Regularly check in the alpine ruby "4.0.1-alpine3.23" images for its latest upgraded packages so we can remove
 # the hardcoded versions below when they have been updated in the alpine ruby image.
 # To find the current version of each package in the alpine image, search here:
 # https://pkgs.alpinelinux.org/packages?name=&branch=v3.23
# These are packages we need over-and-beyond the base image
ARG EXTRA_PACKAGES="imagemagick libpng libjpeg libxml2 libxslt tzdata shared-mime-info vips-poppler vips-magick proj-dev libpq=18.4-r0 postgresql18=18.4-r0"
# These are security patches to the base image
ARG PROD_PACKAGES="zlib=1.3.2-r0 expat=2.8.2-r0 curl=8.19.0-r0 libcurl=8.19.0-r0 curl-dev=8.19.0-r0 lcms2=2.19-r0 openssl=3.5.7-r0"

FROM ruby:4.0.1-alpine3.23 AS builder

WORKDIR /app

ARG EXTRA_PACKAGES
ARG PROD_PACKAGES
ENV DEV_PACKAGES="gcc libc-dev make yaml-dev nodejs npm postgresql18-dev build-base git"
RUN apk add --no-cache $EXTRA_PACKAGES $PROD_PACKAGES $DEV_PACKAGES
RUN echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime
RUN gem install bundler:4.0.14 --no-document


COPY Gemfile* ./
RUN bundle config set --local without 'development test'
RUN bundle install --no-binstubs --retry=5 --jobs=4 --no-cache

COPY package.json yarn.lock .yarnrc.yml ./
RUN npm install -g corepack && corepack enable && yarn install

COPY . .

# TODO: Replace fix below with something more elegant or appropriate.
# Due to how we've configured ActiveStorage, particularly by specifying the service to use for attachments in the
# model, an error is thrown when bundle exec rake assets:precompile is executed below. This rake command seems to load models.
# When it hits a line where an attachment is defined and we specify a servicem, ActiveStorage attempts to set up that service,
# configuring it using the ENV variables we provide in storage.yml. However, at this point, these ENV vars have not been loaded,
# causing the error. Below we define two throaway ENV vars to prevent the error from being thrown. These are then later overwritten,
# when all of the ENV vars are loaded.
ENV DOCUMENTS_AZURE_STORAGE_ACCESS_KEY=throwaway_value
ENV IMAGES_LOGOS_AZURE_STORAGE_ACCESS_KEY=throwaway_value

RUN --mount=type=secret,id=master_key,env=RAILS_MASTER_KEY RAILS_ENV=production SECRET_KEY_BASE=required-to-run-but-not-used RAILS_SERVE_STATIC_FILES=1 bundle exec rake assets:precompile

RUN rm -rf node_modules log tmp yarn.lock && \
      rm -rf /usr/local/bundle/cache && \
      rm -rf .env && touch .env && \
      find /usr/local/bundle/gems -name "*.c" -delete && \
      find /usr/local/bundle/gems -name "*.h" -delete && \
      find /usr/local/bundle/gems -name "*.o" -delete && \
      find /usr/local/bundle/gems -name "*.html" -delete


# this stage reduces the image size.
FROM ruby:4.0.1-alpine3.23 AS production

RUN addgroup -S appgroup -g 20001 && adduser -S appuser -G appgroup -u 10001
WORKDIR /app

ARG PROD_PACKAGES
ARG EXTRA_PACKAGES

RUN apk -U upgrade && apk add --no-cache $PROD_PACKAGES $EXTRA_PACKAGES
RUN echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime
RUN gem install bundler:4.0.14 --no-document

COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
RUN echo export PATH=/usr/local/bundle/:/usr/local/bin/:$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA

RUN mkdir -p /app/tmp /app/log
RUN chown -hR appuser:appgroup /app/tmp /app/log
USER 10001
EXPOSE 3000
CMD bundle exec rails db:prepare:ignore_concurrent_migration_exceptions && bundle exec rails s
