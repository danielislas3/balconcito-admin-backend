#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /rails/tmp/pids/server.pid

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to start..."
until pg_isready -h $DATABASE_HOST -U $DATABASE_USERNAME; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done
echo "PostgreSQL is up and running!"

# Create database if it doesn't exist
echo "Creating database if it doesn't exist..."
bundle exec rails db:create 2>/dev/null || echo "Database already exists"

# Run migrations
echo "Running migrations..."
bundle exec rails db:migrate

# Check if database needs seeding
if [ "$RAILS_ENV" = "development" ]; then
  echo "Checking if database needs seeding..."
  bundle exec rails db:seed 2>/dev/null || echo "Seed data already exists or skipped"
fi

# Execute the main command
exec "$@"
