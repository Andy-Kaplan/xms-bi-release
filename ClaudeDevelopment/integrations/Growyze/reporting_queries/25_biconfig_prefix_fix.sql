-- ============================================================
-- Script: 25_biconfig_prefix_fix.sql
-- Purpose: Fix Padel Social BiConfig DbPrefix in report DB
--
-- Root cause: Padel Social's BiConfig record has DbPrefix
--   '20251208' (copied from DEV GrowyzeDev org) instead of
--   the correct UAT prefix '20260310'. The microservice
--   constructs the client DB name as {DbPrefix}_XMS_{OrgId},
--   so it connects to a database that does not exist, causing
--   ALL dashboard cards for Padel Social to fail.
--
-- Fix: Update DbPrefix to '20260310'.
--
-- Affects: 1 BiConfig record in the microservice report DB
--   - OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
--     (Padel Social, OrgID 10 on UAT)
--
-- Run against: microservice report database (UAT)
-- ============================================================

UPDATE dbo.BiConfig
SET DbPrefix = '20260310',
    DateUpdated = SYSUTCDATETIME()
WHERE OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
  AND DbPrefix = '20251208'
  AND IsDeleted = 0;
