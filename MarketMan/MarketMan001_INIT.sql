USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddIntegration]
		@IntegrationName = N'Marketman001',
		@IntegrationDisplayName = N'Market Man Version 1'

SELECT	'Return Value' = @return_value

GO


UPDATE [core].[Integrations] SET
[APIEndpointDetail] = '{
    "api_info": {
        "source": "marketman",
        "version": "v3",
        "base_url": "https://api.marketman.com"
    },
    "endpoints": {
        "store": {
            "description": "Store list data",
            "endpoint": "buyers/partneraccounts/GetAuthorisedAccounts",
            "rename_cols": {
                "Guid": "storeId",
                "BuyerName": "StoreName"
            },
            "unique_identifier": "Guid",
            "request_method": "POST"
        },
        "orders_by_sentDate": {
            "description": "Orders data by sent date",
            "endpoint": "buyers/orders/GetOrdersBySentDate",
            "unravel_properties": {
                "Orders": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "Items",
                        "CatalogItemID"
                    ): None
                },
                {
                    (
                        "HistoryLog",
                        "ID"
                    ): None
                }
            ],
            "header_identifiers": [
                (
                    "OrderNumber",
                )
            ],
            "unique_identifier": "OrderNumber",
            "request_method": "POST",
            "request_body_properties": {
                "DateTimeFromUTC": "YYYY/MM/DD HH24:MI:SS",
                "DateTimeToUTC": "YYYY/MM/DD HH24:MI:SS",
                "BuyerGuid": "replacement_id"
            }
        },
        "menu_profitability": {
            "description": "Menu profitability data",
            "endpoint": "buyers/inventory/GetMenuProfitability",
            "unravel_properties": {
                "Items": [
                    "explode",
                    "unnest"
                ]
            },
            "unique_identifier": "ID",
            "request_method": "POST",
            "request_body_properties": {
                "DateTimeFromUTC": "YYYY/MM/DD HH24:MI:SS",
                "DateTimeToUTC": "YYYY/MM/DD HH24:MI:SS",
                "BuyerGuid": "replacement_id"
            }
        },
        "categories": {
            "description": "Inventory item categories",
            "endpoint": "buyers/categories/GetCategories",
            "unravel_properties": {
                "Categories": [
                    "explode",
                    "unnest"
                ]
            },
            "unique_identifier": "ID",
            "request_method": "POST",
            "request_body_properties": {
                "BuyerGuid": "replacement_id"
            }
        },
        "inventory_items": {
            "description": "Inventory items data",
            "endpoint": "buyers/inventory/GetInventoryItems",
            "unravel_properties": {
                "Items": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "PurchaseItems",
                        "ProductCode"
                    ): None
                }
            ],
            "header_identifiers": [
                (
                    "ID",
                )
            ],
            "unique_identifier": "ID",
            "request_method": "POST",
            "request_body_properties": {
                "GetDeleted": True,
                "BuyerGuid": "replacement_id"
            }
        },
        "inventory_preps": {
            "description": "Inventory preps data",
            "endpoint": "buyers/inventory/GetPreps",
            "unravel_properties": {
                "Items": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "SubItems",
                        "ItemID"
                    ): None
                }
            ],
            "header_identifiers": [
                (
                    "ID",
                    "header_item_id"
                )
            ],
            "unique_identifier": "ID",
            "request_method": "POST",
            "request_body_properties": {
                "GetDeleted": True,
                "BuyerGuid": "replacement_id"
            }
        },
        "menu_items": {
            "description": "Menu items data",
            "endpoint": "buyers/inventory/GetMenuItems",
            "unravel_properties": {
                "Items": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "LocationSyncInfos",
                        "TypeID"
                    ): None
                },
                {
                    (
                        "SubItems",
                        "ItemID"
                    ): None
                }
            ],
            "header_identifiers": [
                (
                    "ID",
                )
            ],
            "unique_identifier": "ID",
            "request_method": "POST",
            "request_body_properties": {
                "GetDeleted": True,
                "BuyerGuid": "replacement_id"
            }
        },
        "vendors": {
            "description": "Inventory item vendors",
            "endpoint": "buyers/items/GetVendors",
            "unravel_properties": {
                "Vendors": [
                    "explode",
                    "unnest"
                ]
            },
            "unique_identifier": "Guid",
            "request_method": "POST",
            "request_body_properties": {
                "BuyerGuid": "replacement_id"
            }
        },
        "tax_levels": {
            "description": "Tax levels",
            "endpoint": "buyers/Taxes/GetTaxLevels",
            "unravel_properties": {
                "TaxLevels": [
                    "explode",
                    "unnest"
                ]
            },
            "unique_identifier": "ID",
            "request_method": "POST",
            "request_body_properties": {
                "BuyerGuid": "replacement_id"
            }
        },
        "transfers": {
            "description": "Transfers data by date",
            "endpoint": "buyers/inventory/GetTransfers",
            "unravel_properties": {
                "Transfers": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "Lines",
                        "LineID"
                    ): None
                }
            ],
            "header_identifiers": [
                (
                    "ID",
                )
            ],
            "unique_identifier": "ID",
            "request_method": "POST",
            "request_body_properties": {
                "DateTimeFromUTC": "YYYY/MM/DD HH24:MI:SS",
                "DateTimeToUTC": "YYYY/MM/DD HH24:MI:SS",
                "BuyerGuid": "replacement_id"
            }
        },
        "waste_events": {
            "description": "Waste events data by date",
            "endpoint": "buyers/inventory/GetWasteEvents",
            "unravel_properties": {
                "WasteEvents": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "Lines",
                        "LineID"
                    ): None
                }
            ],
            "header_identifiers": [
                (
                    "ID",
                )
            ],
            "unique_identifier": "ID",
            "request_method": "POST",
            "request_body_properties": {
                "DateTimeFromUTC": "YYYY/MM/DD HH24:MI:SS",
                "DateTimeToUTC": "YYYY/MM/DD HH24:MI:SS",
                "BuyerGuid": "replacement_id"
            }
        },
        "inventory_counts": {
            "description": "Inventory counts data by date",
            "endpoint": "buyers/inventory/GetInventoryCounts",
            "unravel_properties": {
                "InventoryCounts": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "Lines",
                        "LineID"
                    ): [
                        {
                            (
                                "CountDefDetails",
                                "CountDefID"
                            ): None
                        }
                    ]
                }
            ],
            "header_identifiers": [
                (
                    "ID",
                )
            ],
            "unique_identifier": "ID",
            "request_method": "POST",
            "request_body_properties": {
                "DateTimeFromUTC": "YYYY/MM/DD HH24:MI:SS",
                "DateTimeToUTC": "YYYY/MM/DD HH24:MI:SS",
                "GetLineDetails": True,
                "GetCountDefDetails": True,
                "BuyerGuid": "replacement_id"
            }
        },
        "uom_types": {
            "description": "UOM types",
            "endpoint": "buyers/inventory/GetUOMTypes",
            "unravel_properties": {
                "UOMs": [
                    "explode",
                    "unnest"
                ]
            },
            "unique_identifier": "ID",
            "request_method": "POST",
            "request_body_properties": {
                "BuyerGuid": "replacement_id"
            }
        },
        "production_events": {
            "description": "Production events data by date",
            "endpoint": "buyers/inventory/GetProductionEventsByDate",
            "unravel_properties": {
                "ProductionEvents": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "ProductionItems",
                        "ItemID"
                    ): None
                }
            ],
            "header_identifiers": [
                (
                    "EventID",
                )
            ],
            "unique_identifier": "EventID",
            "request_method": "POST",
            "request_body_properties": {
                "StartDateUTC": "YYYY/MM/DD HH24:MI:SS",
                "EndDateUTC": "YYYY/MM/DD HH24:MI:SS",
                "BuyerGuid": "replacement_id"
            }
        },
        "sales_by_date": {
            "description": "Sales data by date",
            "endpoint": "buyers/sales/GetSalesByDates",
            "unravel_properties": {
                "SaleSummaries": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "CategorySummaries",
                        "CategoryName"
                    ): None
                }
            ],
            "header_identifiers": [
                (
                    "SaleSummaryID",
                )
            ],
            "unique_identifier": "SaleSummaryID",
            "request_method": "POST",
            "request_body_properties": {
                "DateTimeFromUTC": "YYYY/MM/DD HH24:MI:SS",
                "DateTimeToUTC": "YYYY/MM/DD HH24:MI:SS",
                "BuyerGuid": "replacement_id"
            }
        },
        "docs_by_date": {
            "description": "Docs data by date",
            "endpoint": "buyers/docs/GetDocsByDocDate",
            "unravel_properties": {
                "Docs": [
                    "explode",
                    "unnest"
                ]
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "HistoryLog",
                        "ID"
                    ): None
                },
                {
                    (
                        "Items",
                        "CatalogItemID"
                    ): [
                        {
                            (
                                "Credits",
                                "NoValidID"
                            ): None
                        }
                    ]
                }
            ],
            "header_identifiers": [
                (
                    "DocNumber",
                )
            ],
            "unique_identifier": "DocNumber",
            "request_method": "POST",
            "request_body_properties": {
                "DateTimeFromUTC": "YYYY/MM/DD HH24:MI:SS",
                "DateTimeToUTC": "YYYY/MM/DD HH24:MI:SS",
                "BuyerGuid": "replacement_id"
            }
        },
        "buyer_users": {
            "description": "Buyer users data",
            "endpoint": "buyers/users/GetBuyerUsers",
            "unravel_properties": {
                "BuyerUsers": [
                    "explode",
                    "unnest"
                ]
            },
            "unique_identifier": "ID",
            "request_method": "POST",
            "request_body_properties": {
                "BuyerGuid": "replacement_id"
            }
        },
        "actual_vs_theo": {
            "description": "Actual vs Theoretical data by date",
            "endpoint": "buyers/inventory/GetActualTheoDataByBuyer",
            "unravel_properties": {
            },
            "lists_obj_after_unravel": [
                {
                    (
                        "ActualTheoDataRows",
                        "ItemID"
                    ): None
                },
                {
                    (
                        "ActualTheoCategoriesTotalsRows",
                        "NoValidID"
                    ): None
                }
            ],
            "header_identifiers": [
                (
                    "RequestID",
                )
            ],
            "unique_identifier": "RequestID",
            "request_method": "POST",
            "request_body_properties": {
                "StartDateUTC": "YYYY/MM/DD",
                "EndDateUTC": "YYYY/MM/DD",
                "BuyerGuid": "replacement_id"
            }
        }
    }
}'
,
[IntegrationType] = 'INVENTORY'

WHERE [IntegrationName] = 'Marketman001'