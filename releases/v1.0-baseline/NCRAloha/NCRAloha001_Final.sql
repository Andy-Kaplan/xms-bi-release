-- ============================================
-- NCRAloha001 FINAL - regenerated from UAT 2026-07-06 15:17:46
-- Uploads entity mappings to the data vault load engine
-- ============================================
USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[UploadEntityMappings]
		@intSchema = N'int_ncraloha001'

SELECT	'Return Value' = @return_value

GO