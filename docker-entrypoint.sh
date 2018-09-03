#!/bin/bash
set -e

echo "ENTRYPOINT: Starting docker entrypoint…"

setup_database()
{
  echo "ENTRYPOINT: Checking database setup is up to date…"
  # Rails will throw an error if no database exists"
  #   PG::ConnectionBad: FATAL:  database "tvs_development" does not exist
  if rake db:migrate:status &> /dev/null; then
    echo "ENTRYPOINT: Database found, running db:migrate…"
    rake db:migrate
  else
    echo "ENTRYPOINT: No database found…"

    if [ "$RAILS_ENV" == "production" ]; then
      echo "ENTRYPOINT: Environment is production, doing nothing."
    else
      echo "ENTRYPOINT: Environment is in non-production, attempting to automatically create the database…"
      echo "ENTRYPOINT: Running db:create db:schema:load…"
      rake db:create db:schema:load
    fi
  fi
  echo "ENTRYPOINT: Finished database setup."
}

if [ -z ${DATABASE_URL+x} ]; then echo "ENTRYPOINT: Skipping database setup due to missing DATABASE_URL"; else setup_database; fi

echo "ENTRYPOINT: Finished docker entrypoint."
exec "$@"
