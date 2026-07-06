-- ============================================
-- Marketman001 FINAL - regenerated from UAT 2026-06-02 10:45:23
-- Uploads entity mappings to the data vault load engine
-- ============================================
USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[UploadEntityMappings]
		@intSchema = N'int_marketman001'

SELECT	'Return Value' = @return_value

GO