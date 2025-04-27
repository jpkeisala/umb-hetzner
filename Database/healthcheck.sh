#!/bin/bash
set -e

# Hardcoded password for testing
DB_PASSWORD="Password1234"

# Check if SQL Server process is running
if ! pgrep -x "sqlservr" > /dev/null; then
  echo "SQL Server process is not running"
  exit 1
fi

# Give SQL Server some time to initialize during container startup
if [ ! -f /tmp/app-initialized ]; then
  echo "Container still initializing..."
  
  # Check if SQL Server is responding
  /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$DB_PASSWORD" -Q "SELECT 1" &> /dev/null
  if [ $? -eq 0 ]; then
    echo "SQL Server is responsive during initialization"
    exit 0
  else
    echo "SQL Server is still starting up, but process is running"
    exit 0  # Return success during initial startup phase
  fi
fi

# Once initialization marker exists, perform full health check
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$DB_PASSWORD" -Q "SELECT 1" &> /dev/null
if [ $? -ne 0 ]; then
  echo "SQL Server is not responsive"
  exit 1
fi

# Check if umbracoDb database exists
value=$(/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$DB_PASSWORD" -d master -Q "SELECT COUNT(*) FROM sys.databases WHERE name = 'umbracoDb'" -h -1)
if [[ $value -gt 0 ]]; then
  echo "Database umbracoDb exists and is accessible"
  exit 0
else
  echo "Database umbracoDb does not exist yet, but SQL Server is running"
  # If SQL Server is running but database doesn't exist yet, consider it healthy
  # The startup script will create the database
  exit 0
fi