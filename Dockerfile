FROM ruby:2.6.6-alpine AS dev-build

ARG DEV_PACKAGES="gcc libc-dev make yarn postgresql-dev build-base libxml2-dev libxslt-dev"

WORKDIR /teacher-vacancy
COPY . .

RUN apk add --no-cache libxml2 libxslt libpq tzdata nodejs && \
        apk add --no-cache --virtual .gem-installdeps $DEV_PACKAGES && \
        gem install bundler:2.1.4 --no-document && \
        bundle -v && \
        bundle install --no-binstubs --retry=5 --jobs=4 --no-cache --without development test && \
        echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
        yarn install --check-files && \
        RAILS_ENV=staging bundle exec rake webpacker:compile

# this stage reduces the image size.
FROM ruby:2.6.6-alpine AS production
WORKDIR /teacher-vacancy

COPY --from=dev-build /teacher-vacancy /teacher-vacancy
COPY --from=dev-build /usr/local/bundle/ /usr/local/bundle/

RUN apk update && apk add --no-cache libxml2 libxslt libpq tzdata nodejs && \
        gem install bundler:2.1.4 --no-document && \
        echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
        rm -rf node_modules log tmp yarn.lock && \
        rm -rf /usr/local/bundle/cache && \
        rm -rf .env && touch .env && \
        find /usr/local/bundle/gems -name "*.c" -delete && \
        find /usr/local/bundle/gems -name "*.h" -delete && \
        find /usr/local/bundle/gems -name "*.o" -delete && \
        find /usr/local/bundle/gems -name "*.html" -delete

EXPOSE 3000
CMD bundle exec rails db:migrate && bundle exec rails s
