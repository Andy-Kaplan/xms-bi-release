-- ============================================
-- 1__DBInit.sql
-- Regenerated from UAT 2026-07-06 15:17:16
-- Server: xms-mssqlman-ne-uat.public.9358333fb9bd.database.windows.net
-- ============================================

-- =============================================
-- SQL Server Managed Instance Initialization Script
-- Creates databases and schemas for new instances
-- Regenerated from UAT 2026-07-06 15:17:16
-- =============================================

USE master;
GO

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

USE [core];
GO

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

