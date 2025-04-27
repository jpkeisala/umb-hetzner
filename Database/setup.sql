USE [master]
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'umbracoDb')
BEGIN
    CREATE DATABASE [umbracoDb]
    PRINT 'Database umbracoDb created successfully'
END
ELSE
BEGIN
    PRINT 'Database umbracoDb already exists'
END
GO

USE umbracoDb;
GO

PRINT 'Setup complete'
GO