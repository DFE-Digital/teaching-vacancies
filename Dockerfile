ARG PROD_PACKAGES="libxml2 libxslt libpq tzdata nodejs shared-mime-info"

FROM ruby:3.0.2-alpine AS builder

ARG DEV_PACKAGES="gcc libc-dev make yarn postgresql-dev build-base libxml2-dev libxslt-dev"
ARG PROD_PACKAGES

WORKDIR /app

RUN apk add --no-cache $PROD_PACKAGES $DEV_PACKAGES
RUN echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime
RUN gem install bundler:2.2.22 --no-document

COPY Gemfile* ./
RUN bundle install --no-binstubs --retry=5 --jobs=4 --no-cache --without development test

COPY package.json yarn.lock ./
RUN yarn install --check-files

COPY . .

RUN RAILS_ENV=production SECRET_KEY_BASE=required-to-run-but-not-used bundle exec rake webpacker:compile

RUN rm -rf node_modules log tmp yarn.lock && \
      rm -rf /usr/local/bundle/cache && \
      rm -rf .env && touch .env && \
      find /usr/local/bundle/gems -name "*.c" -delete && \
      find /usr/local/bundle/gems -name "*.h" -delete && \
      find /usr/local/bundle/gems -name "*.o" -delete && \
      find /usr/local/bundle/gems -name "*.html" -delete


# this stage reduces the image size.
FROM ruby:3.0.2-alpine AS production

ARG PROD_PACKAGES
ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA

WORKDIR /app

RUN apk update && apk add --no-cache $PROD_PACKAGES
RUN echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime
RUN gem install bundler:2.2.22 --no-document

COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
RUN echo export PATH=/usr/local/bundle/:/usr/local/bin/:$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

EXPOSE 3000
CMD bundle exec rails db:migrate && bundle exec rails s
