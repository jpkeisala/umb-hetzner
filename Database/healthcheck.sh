#!/bin/bash
# Simple health check that just verifies SQL Server is responding
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -Q "SELECT 1" &> /dev/null
if [ $? -eq 0 ]; then
  echo "SQL Server is responsive"
  exit 0
else
  echo "SQL Server is not responsive"
  exit 1
fi