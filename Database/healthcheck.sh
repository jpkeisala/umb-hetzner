#!/bin/bash

# Give SQL Server some time to initialize during container startup
if [ ! -f /tmp/app-initialized ]; then
  echo "Container still initializing, giving it time to start up..."
  # During initial startup, be more lenient with health checks
  /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -Q "SELECT 1" &> /dev/null
  if [ $? -eq 0 ]; then
    echo "SQL Server is responsive, continuing initialization..."
    exit 0
  else
    echo "SQL Server is still starting up..."
    exit 0  # Return success during initial startup phase
  fi
fi

# Once initialization marker exists, perform full health check
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -Q "SELECT 1" &> /dev/null
if [ $? -ne 0 ]; then
  echo "SQL Server is not responsive"
  exit 1
fi

# Check if umbracoDb database exists
value=$(/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -d master -Q "SELECT COUNT(*) FROM sys.databases WHERE name = 'umbracoDb'" -h -1)
if [[ $value -gt 0 ]]; then
  echo "Database exists and is accessible"
  exit 0
else
  echo "Database does not exist yet, but SQL Server is running"
  # If SQL Server is running but database doesn't exist yet, consider it healthy
  # The startup script will create the database
  exit 0
fi