-- ============================================
-- Growyze001 INIT - regenerated from UAT 2026-06-02 10:45:23
-- ============================================
USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddIntegration]
		@IntegrationName = N'Growyze001',
		@IntegrationDisplayName = N'Growyze'

SELECT	'Return Value' = @return_value

GO

UPDATE [core].[Integrations] SET
[APIEndpointDetail] = '  {
      "api_info": {
          "source": "growyze",
          "version": "v1",
          "base_url": "https://prod.growyze.com"
      },
      "endpoints": {
          "products": {
              "description": "Products/inventory items data",
              "endpoint": "products",
              "lists_dicts_obj_after_unravel": [
                  {("allergens", "NoValidID"): None},
                  {("barcodes", "NoValidID"): None},
                  {("ingredients", "NoValidID"): None},
                  {("mayContainAllergens", "NoValidID"): None},
                  {("organizations", "NoValidID"): None}
              ],
              "header_identifiers": [("id", "product_id")],
              "unique_identifier": "id",
              "request_method": "GET"
          },
          "recipes": {
              "description": "Recipes/dishes data with ingredients and sections",
              "endpoint": "recipes",
              "lists_dicts_obj_after_unravel": [
                  {("allergens", "NoValidID"): None},
                  {("dishes", "id"): None},
                  {("files", "fileId"): None},
                  {("ingredients", "NoValidID"): None},
                  {("ingredientsInProducts", "NoValidID"): None},
                  {("mayContainAllergens", "NoValidID"): None},
                  {("organizations", "NoValidID"): None},
                  {("sections", "name"): [
                      {("elements", "type"): [
                          {("ingredient", "NoValidID"): None,
                           ("recipe", "type"): [
                              {("recipe", "id"): [
                                  {("allergens", "NoValidID"): None},
                                  {("ingredientsInProducts", "NoValidID"): None},
                                  {("mayContainAllergens", "NoValidID"): None}
                              ]}
                          ]}
                      ]}
                  ]}
              ],
              "header_identifiers": [("id", "recipe_id")],
              "unique_identifier": "id",
              "request_method": "GET"
          },
          "orders": {
              "description": "Purchase orders data",
              "endpoint": "orders",
              "lists_dicts_obj_after_unravel": [
                  {("approvers", "username"): None},
                  {("items", "productId"): None},
                  {("organizations", "NoValidID"): None},
                  {("organizationsNames", "NoValidID"): None},
                  {("supplier", "id"): [
                      {("deliveriesContact", "contactName"): [
                          {("emails", "NoValidID"): None}
                      ]},
                      {("invoicesContact", "contactName"): [
                          {("emails", "NoValidID"): None}
                      ]},
                      {("orderApprovals", "enabled"): [
                          {("approvers", "username"): None}
                      ]},
                      {("orderReminders", "orderDay"): None},
                      {("ordersContact", "contactName"): [
                          {("emails", "NoValidID"): None}
                      ]},
                      {("organizations", "NoValidID"): None}
                  ]}
              ],
              "header_identifiers": [("id", "order_id")],
              "unique_identifier": "id",
              "request_method": "GET"
          },
          "delivery-notes": {
              "description": "Delivery notes/receipts data",
              "endpoint": "delivery-notes",
              "lists_dicts_obj_after_unravel": [
                  {("files", "fileId"): None},
                  {("globalDiscrepancies", "NoValidID"): None},
                  {("organizations", "NoValidID"): None},
                  {("organizationsNames", "NoValidID"): None},
                  {("products", "code"): None},
                  {("supplier", "id"): [
                      {("emails", "NoValidID"): None}
                  ]}
              ],
              "header_identifiers": [("id", "delivery_id")],
              "unique_identifier": "id",
              "request_method": "GET"
          },
          "invoices": {
              "description": "Invoices data with products and accounting integrations",
              "endpoint": "invoices",
              "lists_dicts_obj_after_unravel": [
                  {("commentFromOrders", "NoValidID"): None},
                  {("deliveryNotes", "deliveryNoteId"): None},
                  {("files", "fileId"): None},
                  {("globalDiscrepancies", "NoValidID"): None},
                  {("organizations", "NoValidID"): None},
                  {("organizationsNames", "NoValidID"): None},
                  {("products", "code"): None},
                  {("sageInvoice", "invoiceNumber"): [
                      {("lineItems", "description"): None}
                  ]},
                  {("supplier", "id"): [
                      {("emails", "NoValidID"): None}
                  ]},
                  {("xeroInvoice", "invoiceNumber"): [
                      {("lineItems", "description"): [
                          {("trackingCategory", "id"): [
                              {("options", "id"): None}
                          ]}
                      ]}
                  ]}
              ],
              "header_identifiers": [("id", "invoice_id")],
              "unique_identifier": "id",
              "request_method": "GET"
          },
          "sales": {
              "description": "Sales data with items and sub-sales",
              "endpoint": "sales",
              "lists_dicts_obj_after_unravel": [
                  {("items", "posId"): None},
                  {("organizations", "NoValidID"): None},
                  {("subSales", "id"): [
                      {("organizations", "NoValidID"): None}
                  ]}
              ],
              "header_identifiers": [("id", "sales_id")],
              "unique_identifier": "id",
              "request_method": "GET",
              "request_query_parameters": {
                  "from": "YYYY-MM-DDTHH:mm:ss.SSSZ",
                  "to": "YYYY-MM-DDTHH:mm:ss.SSSZ",
              }
          },
          "wastes": {
              "description": "Waste data by day with dishes, products, and recipes",
              "endpoint": "wastes",
              "lists_dicts_obj_after_unravel": [
                  {("dishes", "NoValidID"): [
                      {("dish", "id"): None},
                      {("wastesPerDay", "id"): [
                          {("files", "fileId"): None}
                      ]}
                  ]},
                  {("organizations", "NoValidID"): None},
                  {("organizationsNames", "NoValidID"): None},
                  {("products", "NoValidID"): [
                      {("product", "id"): None},
                      {("wastesPerDay", "id"): [
                          {("files", "fileId"): None}
                      ]}
                  ]},
                  {("recipes", "NoValidID"): [
                      {("recipe", "id"): None},
                      {("wastesPerDay", "id"): [
                          {("files", "fileId"): None}
                      ]}
                  ]}
              ],
              "header_identifiers": [("id", "waste_day_id")],
              "unique_identifier": "id",
              "request_method": "GET",
              "request_query_parameters": {
                  "from": "YYYY-MM-DDTHH:mm:ss.SSSZ",
                  "to": "YYYY-MM-DDTHH:mm:ss.SSSZ",
              }
          },
          "salesdetail": {
              "description": "Individual sales record with items",
              "endpoint": "sales/{sale_id}",
              "lists_dicts_obj_after_unravel": [
                  {("organizations", "NoValidID"): None},
                  {("items", "posId"): None},
                  {("subSales", "id"): [
                      {("organizations", "NoValidID"): None}
                  ]}
              ],
              "header_identifiers": [("id", "sale_id")],
              "unique_identifier": "id",
              "request_method": "GET"
          },
          "dishes": {
              "description": "Dishes/menu items data with ingredients and sections",
              "endpoint": "dishes",
              "lists_dicts_obj_after_unravel": [
                  {("allergens", "NoValidID"): None},
                  {("files", "fileId"): None},
                  {("ingredientsInProducts", "NoValidID"): None},
                  {("mayContainAllergens", "NoValidID"): None},
                  {("menus", "id"): None},
                  {("organizations", "NoValidID"): None},
                  {("sections", "name"): [
                      {("elements", "type"): [
                          {("ingredient", "NoValidID"): [
                              {("product", "id"): [
                                  {("allergens", "NoValidID"): None},
                                  {("ingredients", "NoValidID"): None},
                                  {("mayContainAllergens", "NoValidID"): None}
                              ]}
                          ]},
                          {("recipe", "type"): [
                              {("recipe", "id"): [
                                  {("allergens", "NoValidID"): None},
                                  {("ingredientsInProducts", "NoValidID"): None},
                                  {("mayContainAllergens", "NoValidID"): None}
                              ]}
                          ]}
                      ]}
                  ]}
              ],
              "header_identifiers": [("id", "dish_id")],
              "unique_identifier": "id",
              "request_method": "GET"
          },
          "stocktakereports": {
              "description": "Stock take reports list with date filtering",
              "endpoint": "stock-take/report",
              "lists_dicts_obj_after_unravel": [
                  {("stockTakeReport", "id"): [
                      {("organizations", "NoValidID"): None},
                      {("subStockTakeReports", "id"): None}
                  ]}
              ],
              "header_identifiers": [("stockTakeReport_id", "stocktakereport_id")],
              "unique_identifier": "stockTakeReport_id",
              "request_method": "GET",
              "request_query_parameters": {
                  "from": "YYYY-MM-DDTHH:mm:ss.SSSZ",
                  "to": "YYYY-MM-DDTHH:mm:ss.SSSZ",
              }
          },
          "stocktakereportdetail": {
              "description": "Individual stock take report with category breakdown and sub-reports",
              "endpoint": "stock-take/report/{report_id}",
              "lists_dicts_obj_after_unravel": [
                  {("amountByCategories", "category"): None},
                  {("organizations", "NoValidID"): None},
                  {("subStockTakeReports", "id"): [
                      {("amountByCategories", "category"): None},
                      {("organizations", "NoValidID"): None}
                  ]}
              ],
              "header_identifiers": [("id", "stocktakereport_id")],
              "unique_identifier": "id",
              "request_method": "GET"
          },
          "stocktakereportproducts": {
              "description": "Products with quantities and amounts for a stock take report",
              "endpoint": "stock-take/report/{report_id}/products",
              "lists_dicts_obj_after_unravel": [],
              "header_identifiers": [("barcode", "barcode")],
              "unique_identifier": "barcode",
              "request_method": "GET"
          }
      }
  }'
WHERE [IntegrationName] = N'Growyze001';
GO
