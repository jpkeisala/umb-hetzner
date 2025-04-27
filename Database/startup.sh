#!/bin/bash
set -e

# Taken from: https://github.com/CarlSargunar/Umbraco-Docker-Workshop
if [ "$1" = '/opt/mssql/bin/sqlservr' ]; then
  echo "Starting SQL Server"
  
  # If this is the container's first run, initialize the application database
  if [ ! -f /tmp/app-initialized ]; then
    echo "First container run - initializing database"
    
    # Initialize the application database asynchronously in a background process
    function initialize_app_database() {
      echo "Waiting for SQL Server to start..."
      sleep 20s  # Increased wait time to ensure SQL Server is fully started

      echo "Running setup script..."
      /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -d master -i setup.sql
      
      if [ $? -eq 0 ]; then
        echo "Database setup completed successfully"
      else
        echo "Database setup failed"
      fi

      # Note that the container has been initialized
      touch /tmp/app-initialized
      echo "Container initialization complete"
    }
    initialize_app_database &
  else
    echo "Container already initialized"
  fi
fi

echo "Executing command: $@"
exec "$@"