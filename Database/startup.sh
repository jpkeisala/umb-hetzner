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
      # Instead of a fixed sleep, actively check if SQL Server is accepting connections
      for i in {1..30}; do
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -Q "SELECT 1" &> /dev/null
        if [ $? -eq 0 ]; then
          echo "SQL Server is ready, running setup script..."
          break
        fi
        echo "Waiting for SQL Server to start (attempt $i/30)..."
        sleep 2
      done

      echo "Running setup script..."
      /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -d master -i setup.sql
      
      if [ $? -eq 0 ]; then
        echo "Database setup completed successfully"
        # Create a file to indicate setup has completed
        touch /tmp/app-initialized
        echo "Container initialization complete"
      else
        echo "Database setup failed"
      fi
    }
    initialize_app_database &
  else
    echo "Container already initialized"
  fi
fi

echo "Executing command: $@"
exec "$@"