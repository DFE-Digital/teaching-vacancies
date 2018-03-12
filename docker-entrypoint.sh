#!/bin/bash
set -e

echo "Starting docker entrypoint…"

setup_database()
{
  echo "Checking database setup is up-to-date…"
  # Rails will throw an error if no database exists"
  #   PG::ConnectionBad: FATAL:  database "tvs_development" does not exist
  if rake db:migrate:status &> /dev/null; then
    echo "Database found, running db:migrate…"
    rake db:migrate
  else
    echo "No database found, running db:create db:schema:load…"
    rake db:create db:schema:load
  fi
  echo "Finished database setup"
}

if [ -z ${DATABASE_URL+x} ]; then echo "Skipping database setup"; else setup_database; fi

echo "Finished docker entrypoint."
exec "$@"
