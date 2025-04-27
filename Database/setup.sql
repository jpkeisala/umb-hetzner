USE [master]
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'umbracoDb')
    BEGIN
        CREATE DATABASE [umbracoDb]
    END;
GO

USE umbracoDb;