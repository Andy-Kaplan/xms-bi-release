USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[UploadEntityMappings]
		@intSchema = N'int_surveyhero001'

SELECT	'Return Value' = @return_value

GO
