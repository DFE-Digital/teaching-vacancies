 # Some packages are defined here with a hardcoded version to resolve vulnerabilities in the packages coming with 
 # Alpine v3.18.
 # TODO: Regularly check in the alpine ruby "3.3.0-alpine3.18" images for its latest upgraded packages so we can remove
 # the hardcoded versions below when they have been updated in the alpine ruby image.
ARG PROD_PACKAGES="imagemagick libxml2=2.11.7-r0 libxslt libpq tzdata shared-mime-info postgresql15=15.6-r0 gnutls=3.8.4-r0"

FROM ruby:3.3.0-alpine3.18 AS builder

WORKDIR /app

ARG PROD_PACKAGES
ENV DEV_PACKAGES="gcc libc-dev make yarn postgresql15-dev build-base git"
RUN apk add --no-cache $PROD_PACKAGES $DEV_PACKAGES
RUN echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime
RUN gem install bundler:2.3.5 --no-document


COPY Gemfile* ./
RUN bundle config set --local without 'development test'
RUN bundle install --no-binstubs --retry=5 --jobs=4 --no-cache

COPY package.json yarn.lock ./
RUN yarn install --check-files

COPY . .

# TODO: Replace fix below with something more elegant or appropriate.
# Due to how we've configured ActiveStorage, particularly by specifying the service to use for attachments in the
# model, an error is thrown when bundle exec rake assets:precompile is executed below. This rake command seems to load models.
# When it hits a line where an attachment is defined and we specify a servicem, ActiveStorage attempts to set up that service,
# configuring it using the ENV variables we provide in storage.yml. However, at this point, these ENV vars have not been loaded,
# causing the error. Below we define two throaway ENV vars to prevent the error from being thrown. These are then later overwritten,
# when all of the ENV vars are loaded.

ENV DOCUMENTS_S3_BUCKET=throwaway_value
ENV SCHOOLS_IMAGES_LOGOS_S3_BUCKET=throwaway_value

RUN RAILS_ENV=production SECRET_KEY_BASE=required-to-run-but-not-used RAILS_SERVE_STATIC_FILES=1 bundle exec rake assets:precompile

RUN rm -rf node_modules log tmp yarn.lock && \
      rm -rf /usr/local/bundle/cache && \
      rm -rf .env && touch .env && \
      find /usr/local/bundle/gems -name "*.c" -delete && \
      find /usr/local/bundle/gems -name "*.h" -delete && \
      find /usr/local/bundle/gems -name "*.o" -delete && \
      find /usr/local/bundle/gems -name "*.html" -delete


# this stage reduces the image size.
FROM ruby:3.3.0-alpine3.18 AS production

WORKDIR /app

ARG PROD_PACKAGES
RUN apk -U upgrade && apk add --no-cache $PROD_PACKAGES
RUN echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime
RUN gem install bundler:2.3.5 --no-document

COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
RUN echo export PATH=/usr/local/bundle/:/usr/local/bin/:$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA

EXPOSE 3000
CMD bundle exec rails db:migrate:ignore_concurrent_migration_exceptions && bundle exec rails s
