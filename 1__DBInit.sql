-- =============================================
-- SQL Server Managed Instance Initialization Script
-- Creates databases and schemas for new instances
-- =============================================

USE master;
GO

-- =============================================
-- Create core Database
-- =============================================
PRINT 'Creating core database...';

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'core')
BEGIN
    CREATE DATABASE [core];
    PRINT 'core database created successfully.';
END
ELSE
BEGIN
    PRINT 'core database already exists.';
END
GO

-- =============================================
-- Create Schemas in core Database
-- =============================================
USE [core];
GO

PRINT 'Creating schemas in core database...';

-- Create 'core' schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'core')
BEGIN
    EXEC('CREATE SCHEMA [core]');
    PRINT 'Schema [core] created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema [core] already exists.';
END
GO

