-- ============================================
-- NCRAloha001 INIT - regenerated from UAT 2026-07-06 15:17:46
-- ============================================
USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddIntegration]
		@IntegrationName = N'NCRAloha001',
		@IntegrationDisplayName = N'NCRAloha001'

SELECT	'Return Value' = @return_value

GO

UPDATE [core].[Integrations] SET
[APIEndpointDetail] = '{
    "api_info": {
        "source": "ncr",
        "version": "v3",
        "base_url": "https://api.ncr.com/rt"
    },
    "endpoints": {
        "store": {
            "description": "Store list data",
            "endpoint": "",
            "rename_cols": {
                "pulseId": "storeId"
            },
            "unique_identifier": "pulseId",
            "request_method": "GET"
        },
        "sales": {
            "description": "Sales data",
            "endpoint": "sales",
            "unravel_properties": {
                "links": [
                    "explode"
                ]
            },
            "unique_identifier": "id",
            "request_method": "GET"
        },
        "sales_check": {
            "description": "Sales check data",
            "endpoint": "sales/check",
            "unravel_properties": {
                "checks": [
                    "explode",
                    "unnest"
                ]
            },
            "unique_identifier": "id",
            "request_method": "GET"
        },
        "sales_stream": {
            "description": "Sales stream data",
            "endpoint": "sales/stream",
            "unravel_properties": {
                "checks": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "clears",
                        "id"
                    ): [
                        {
                            (
                                "linkedItems",
                                "id"
                            ): None
                        }
                    ]
                },
                {
                    (
                        "comps",
                        "id"
                    ): [
                        {
                            (
                                "linkedItems",
                                "id"
                            ): None
                        }
                    ]
                },
                {
                    (
                        "events",
                        "id"
                    ): [
                        {
                            (
                                "linkedItems",
                                "id"
                            ): None
                        }
                    ]
                },
                {
                    (
                        "items",
                        "id"
                    ): [
                        {
                            (
                                "categories",
                                "id"
                            ): None
                        }
                    ]
                },
                {
                    (
                        "payments",
                        "id"
                    ): [
                        {
                            (
                                "linkedItems",
                                "id"
                            ): None
                        }
                    ]
                },
                {
                    (
                        "promos",
                        "id"
                    ): [
                        {
                            (
                                "linkedItems",
                                "id"
                            ): None
                        }
                    ]
                },
                {
                    (
                        "responsibleEmployees",
                        "id"
                    ): [
                        {
                            (
                                "linkedItems",
                                "id"
                            ): None
                        }
                    ]
                },
                {
                    (
                        "surcharges",
                        "id"
                    ): [
                        {
                            (
                                "linkedItems",
                                "id"
                            ): None
                        }
                    ]
                },
                {
                    (
                        "voids",
                        "id"
                    ): [
                        {
                            (
                                "linkedItems",
                                "id"
                            ): None
                        }
                    ]
                }
            ],
            "header_identifiers": [
                (
                    "storeId",
                ),
                (
                    "dob",
                ),
                (
                    "id",
                    "checks_id"
                )
            ],
            "unique_identifier": "id",
            "request_method": "GET"
        },
        "labor": {
            "description": "Labor data",
            "endpoint": "labor",
            "unravel_properties": {
                "shifts": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "payRates",
                        "id"
                    ): None
                },
                {
                    (
                        "breaks",
                        "id"
                    ): None
                }
            ],
            "header_identifiers": [
                (
                    "storeId",
                ),
                (
                    "dob",
                ),
                (
                    "id",
                    "shifts_id"
                )
            ],
            "unique_identifier": "id",
            "request_method": "GET"
        }
    },
    "pagination": {
        "pagination_value_key": "marker",
        "pagination_flag_key": "moreDataImmediatelyAvailable"
    }
}'
WHERE [IntegrationName] = N'NCRAloha001';
GO
