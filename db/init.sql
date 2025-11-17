-- Initialization script for PostgreSQL Docker container
-- This script runs when the container is first created

-- Create additional databases if needed
-- CREATE DATABASE balconcito_api_test;

-- Grant privileges
-- GRANT ALL PRIVILEGES ON DATABASE balconcito_api_development TO balconcito;
-- GRANT ALL PRIVILEGES ON DATABASE balconcito_api_test TO balconcito;

-- Enable extensions if needed
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Log initialization
SELECT 'PostgreSQL initialized successfully!' as status;
