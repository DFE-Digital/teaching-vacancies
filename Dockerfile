FROM ruby:2.4.0

MAINTAINER DXW <support@dxw.com>


RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev postgresql-client-9.4 --fix-missing --no-install-recommends

ENV INSTALL_PATH /srv/dfe-beta

RUN mkdir -p $INSTALL_PATH

# set context of where commands will be ran
WORKDIR $INSTALL_PATH

COPY Gemfile $INSTALL_PATH/Gemfile
COPY Gemfile.lock $INSTALL_PATH/Gemfile.lock

RUN bundle install
COPY . $INSTALL_PATH

EXPOSE 3000
CMD ["bundle", "exec", "rails s -b0"]
