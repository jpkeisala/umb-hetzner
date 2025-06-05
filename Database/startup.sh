#!/bin/bash
set -e
set -x  # Enable debug output

# Taken from: https://github.com/CarlSargunar/Umbraco-Docker-Workshop
if [ "$1" = '/opt/mssql/bin/sqlservr' ]; then
  echo "Starting SQL Server"
  
  # If this is the container's first run, initialize the application database
  if [ ! -f /tmp/app-initialized ]; then
    echo "First container run - initializing database"
    
    # Initialize the application database asynchronously in a background process
    function initialize_app_database() {
      echo "Waiting for SQL Server to start..."
      # More robust SQL Server startup detection
      ready=0
      for i in {1..60}; do
        if [ $ready -eq 0 ]; then
          # Check if SQL Server process is running
          if pgrep -x "sqlservr" > /dev/null; then
            echo "SQL Server process found, checking connectivity..."
            
            # Try to connect to SQL Server
            /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -Q "SELECT 1" &> /dev/null
            if [ $? -eq 0 ]; then
              echo "SQL Server is ready, running setup script..."
              ready=1
            else
              echo "SQL Server process is running but not yet accepting connections (attempt $i/60)..."
            fi
          else
            echo "SQL Server process not found yet (attempt $i/60)..."
          fi
        fi
        
        if [ $ready -eq 0 ]; then
          sleep 2
        else
          break
        fi
      done
      
      if [ $ready -eq 0 ]; then
        echo "SQL Server did not become ready in the allocated time"
        exit 1
      fi

      echo "Running setup script..."
      /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -d master -i setup.sql > /tmp/setup.log 2>&1
      
      if [ $? -eq 0 ]; then
        echo "Database setup completed successfully"
        # Create a file to indicate setup has completed
        touch /tmp/app-initialized
        echo "Container initialization complete"
      else
        echo "Database setup failed. Dumping setup.log:"
        cat /tmp/setup.log
        exit 1
      fi
    }
    
    # Start initialization in the background
    initialize_app_database 
  else
    echo "Container already initialized"
  fi
fi

echo "Executing command: $@"
exec "$@"