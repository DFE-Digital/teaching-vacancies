FROM ruby:2.7.1-alpine AS builder

ARG DEV_PACKAGES="gcc libc-dev make yarn postgresql-dev build-base libxml2-dev libxslt-dev"

WORKDIR /teacher-vacancy

RUN apk add --no-cache libxml2 libxslt libpq tzdata nodejs $DEV_PACKAGES
RUN echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime
RUN gem install bundler:2.1.4 --no-document

COPY Gemfile* ./
RUN bundle install --no-binstubs --retry=5 --jobs=4 --no-cache --without development test

COPY package.json yarn.lock ./
RUN yarn install --check-files

COPY . .

RUN RAILS_ENV=staging bundle exec rake webpacker:compile

RUN rm -rf node_modules log tmp yarn.lock && \
      rm -rf /usr/local/bundle/cache && \
      rm -rf .env && touch .env && \
      find /usr/local/bundle/gems -name "*.c" -delete && \
      find /usr/local/bundle/gems -name "*.h" -delete && \
      find /usr/local/bundle/gems -name "*.o" -delete && \
      find /usr/local/bundle/gems -name "*.html" -delete


# this stage reduces the image size.
FROM ruby:2.7.1-alpine AS production
WORKDIR /teacher-vacancy

RUN apk update && apk add --no-cache libxml2 libxslt libpq tzdata nodejs
RUN echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime
RUN gem install bundler:2.1.4 --no-document

COPY --from=builder /teacher-vacancy /teacher-vacancy
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

EXPOSE 3000
CMD bundle exec rails db:migrate && bundle exec rails s
