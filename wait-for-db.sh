#!/bin/sh

DB_HOST=${DB_HOST:-aws-0-us-west-1.pooler.supabase.com}
DB_PORT=${DB_PORT:-5432}

echo "Waiting for database to be ready at $DB_HOST:$DB_PORT..."
while ! nc -z $DB_HOST $DB_PORT; do
  sleep 1
done

echo "Database is ready!"
