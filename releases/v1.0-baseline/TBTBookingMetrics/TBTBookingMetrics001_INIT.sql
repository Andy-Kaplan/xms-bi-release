-- ============================================
-- TBTBookingMetrics001 INIT - regenerated from UAT 2026-07-06 15:17:46
-- ============================================
USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddIntegration]
		@IntegrationName = N'TBTBookingMetrics001',
		@IntegrationDisplayName = N'TBT Booking Metrics'

SELECT	'Return Value' = @return_value

GO

UPDATE [core].[Integrations] SET
[APIEndpointDetail] = '{
  "api_info": {
	  "source": "tbtbookingmetrics",
	  "base_url": "https://netapi-test.bigtablegroup.com"
  },
  "endpoints": {
	  "booking_metrics": {
		  "description": "Booking metrics data by date range",
		  "endpoint": "api/admin/reporting/booking-metrics",
		  "request_method": "GET"
	  }
  }
}'
WHERE [IntegrationName] = N'TBTBookingMetrics001';
GO
