USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddOrganisation]
		@OrganisationName = N'Three Rocks Cafe',
		@OrganisationPrefix = N'20250917',
		@OrganisationCode = 'C14CF568-588D-F011-B3CD-000D3AD9E9D4'

SELECT	'Return Value' = @return_value

GO

USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddOrganisation]
		@OrganisationName = N'Three Rocks Mexicana',
		@OrganisationPrefix = N'20250917',
		@OrganisationCode = '3667B921-5B8D-F011-B3CD-000D3AD9E9D4'

SELECT	'Return Value' = @return_value

GO

USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddOrganisation]
		@OrganisationName = N'NeighboursSurvey',
		@OrganisationPrefix = N'20251202',
		@OrganisationCode = '3EBF26FE-E14A-40ED-A355-9A411B1273B4'

SELECT	'Return Value' = @return_value

GO

USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddOrganisation]
		@OrganisationName = N'Frankie & Bennys',
		@OrganisationPrefix = N'20251112',
		@OrganisationCode = '2D8F2756-6641-4885-BF14-8090135B6281'

SELECT	'Return Value' = @return_value

GO

USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddOrganisation]
		@OrganisationName = N'Bella Italia',
		@OrganisationPrefix = N'20251112',
		@OrganisationCode = 'DBAB95ED-112E-42C6-B0E9-E0BFD20709D9'

SELECT	'Return Value' = @return_value

GO

USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddOrganisation]
		@OrganisationName = N'Amalfi',
		@OrganisationPrefix = N'20251208',
		@OrganisationCode = 'B66AA165-592B-4F3F-ACF5-46D4B049801A'

SELECT	'Return Value' = @return_value

GO

USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddOrganisation]
		@OrganisationName = N'Chiquito',
		@OrganisationPrefix = N'20251208',
		@OrganisationCode = '44775945-DB97-453C-BBBC-F54C7773D358'

SELECT	'Return Value' = @return_value

GO

USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddOrganisation]
		@OrganisationName = N'Las Iguanas',
		@OrganisationPrefix = N'20251208',
		@OrganisationCode = '9C4FAF85-28D8-46CA-91B2-19DD48C2CEAA'

SELECT	'Return Value' = @return_value

GO

USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddOrganisation]
		@OrganisationName = N'GrowyzeDev',
		@OrganisationPrefix = N'20251208',
		@OrganisationCode = '94A4B719-EB0F-421F-AD03-ABECDD888B14'

SELECT	'Return Value' = @return_value

GO