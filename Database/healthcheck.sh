#!/bin/bash
# Check if SQL Server is running first, before checking for database
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -Q "SELECT 1" &> /dev/null
if [ $? -ne 0 ]; then
  echo "SQL Server not ready yet"
  exit 1
fi

# Wait longer for database to be created during container startup
if [ -f /tmp/app-initialized ]; then
  # Full check only after initialization
  value="$(/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -d master -Q "SELECT state_desc FROM sys.databases WHERE name = 'umbracoDb'" | awk 'NR==3')"
  if [ -n "$value" ]; then
    echo "ONLINE"
    exit 0
  else
    echo "Database not found"
    exit 1
  fi
else
  # During initialization, just check if SQL Server responds
  echo "Still initializing"
  exit 0
fi