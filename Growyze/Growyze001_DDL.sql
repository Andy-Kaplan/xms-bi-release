-- API Table DDL Export
-- Schema: int_growyze001
-- Generated: 2026-01-12 14:25:15
-- Total Tables: 57

-- Table: DL_DELIVERYNOTES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_DELIVERYNOTES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES]
(
    [id] nvarchar(MAX) NULL,
    [deliveryNoteNumber] nvarchar(MAX) NULL,
    [po] nvarchar(MAX) NULL,
    [deliveryDate] nvarchar(MAX) NULL,
    [dateOfScanning] nvarchar(MAX) NULL,
    [completedDate] nvarchar(MAX) NULL,
    [approvedDate] nvarchar(MAX) NULL,
    [inQueryDate] nvarchar(MAX) NULL,
    [rejectedDate] nvarchar(MAX) NULL,
    [extractedFile] nvarchar(MAX) NULL,
    [status] nvarchar(MAX) NULL,
    [message] nvarchar(MAX) NULL,
    [messageQueryToSupplier] nvarchar(MAX) NULL,
    [hasReceivedQtyDiscrepancies] nvarchar(MAX) NULL,
    [hasDNQtyDiscrepancies] nvarchar(MAX) NULL,
    [hasReceivedOrderQtyDiscrepancies] nvarchar(MAX) NULL,
    [hasNoOrderedProducts] nvarchar(MAX) NULL,
    [hasNoDeliveredProducts] nvarchar(MAX) NULL,
    [isCreatedManuallyWithoutOrder] nvarchar(MAX) NULL,
    [commentFromOrder] nvarchar(MAX) NULL,
    [isInvoiced] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_DELIVERYNOTES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_DELIVERYNOTES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_DELIVERYNOTES', N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES]
(
    [id] nvarchar(MAX) NULL,
    [deliveryNoteNumber] nvarchar(MAX) NULL,
    [po] nvarchar(MAX) NULL,
    [deliveryDate] nvarchar(MAX) NULL,
    [dateOfScanning] nvarchar(MAX) NULL,
    [completedDate] nvarchar(MAX) NULL,
    [approvedDate] nvarchar(MAX) NULL,
    [inQueryDate] nvarchar(MAX) NULL,
    [rejectedDate] nvarchar(MAX) NULL,
    [extractedFile] nvarchar(MAX) NULL,
    [status] nvarchar(MAX) NULL,
    [message] nvarchar(MAX) NULL,
    [messageQueryToSupplier] nvarchar(MAX) NULL,
    [hasReceivedQtyDiscrepancies] nvarchar(MAX) NULL,
    [hasDNQtyDiscrepancies] nvarchar(MAX) NULL,
    [hasReceivedOrderQtyDiscrepancies] nvarchar(MAX) NULL,
    [hasNoOrderedProducts] nvarchar(MAX) NULL,
    [hasNoDeliveredProducts] nvarchar(MAX) NULL,
    [isCreatedManuallyWithoutOrder] nvarchar(MAX) NULL,
    [commentFromOrder] nvarchar(MAX) NULL,
    [isInvoiced] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_DELIVERYNOTES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_DELIVERYNOTES_ORGANIZATIONS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_DELIVERYNOTES_ORGANIZATIONS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES_ORGANIZATIONS]
(
    [delivery_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_DELIVERYNOTES_ORGANIZATIONS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_DELIVERYNOTES_ORGANIZATIONS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_DELIVERYNOTES_ORGANIZATIONS', N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES_ORGANIZATIONS]
(
    [delivery_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_DELIVERYNOTES_ORGANIZATIONS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_DELIVERYNOTES_ORGANIZATIONSNAMES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_DELIVERYNOTES_ORGANIZATIONSNAMES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES_ORGANIZATIONSNAMES]
(
    [delivery_id] nvarchar(MAX) NULL,
    [organizationsNames] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_DELIVERYNOTES_ORGANIZATIONSNAMES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_DELIVERYNOTES_ORGANIZATIONSNAMES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_DELIVERYNOTES_ORGANIZATIONSNAMES', N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES_ORGANIZATIONSNAMES]
(
    [delivery_id] nvarchar(MAX) NULL,
    [organizationsNames] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_DELIVERYNOTES_ORGANIZATIONSNAMES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_DELIVERYNOTES_PRODUCTS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_DELIVERYNOTES_PRODUCTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES_PRODUCTS]
(
    [delivery_id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [code] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [orderQty] nvarchar(MAX) NULL,
    [orderQtyInCase] nvarchar(MAX) NULL,
    [orderCaseSize] nvarchar(MAX) NULL,
    [dnQty] nvarchar(MAX) NULL,
    [receivedQty] nvarchar(MAX) NULL,
    [receivedQtyInCase] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [comment] nvarchar(MAX) NULL,
    [isConfirmed] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaDNQty] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaReceivedQty] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaReceivedOrderedQty] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_DELIVERYNOTES_PRODUCTS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_DELIVERYNOTES_PRODUCTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_DELIVERYNOTES_PRODUCTS', N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES_PRODUCTS]
(
    [delivery_id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [code] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [orderQty] nvarchar(MAX) NULL,
    [orderQtyInCase] nvarchar(MAX) NULL,
    [orderCaseSize] nvarchar(MAX) NULL,
    [dnQty] nvarchar(MAX) NULL,
    [receivedQty] nvarchar(MAX) NULL,
    [receivedQtyInCase] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [comment] nvarchar(MAX) NULL,
    [isConfirmed] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaDNQty] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaReceivedQty] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaReceivedOrderedQty] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_DELIVERYNOTES_PRODUCTS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_DELIVERYNOTES_SUPPLIER
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_DELIVERYNOTES_SUPPLIER' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES_SUPPLIER]
(
    [delivery_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [contactName] nvarchar(MAX) NULL,
    [email] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_DELIVERYNOTES_SUPPLIER',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_DELIVERYNOTES_SUPPLIER' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_DELIVERYNOTES_SUPPLIER', N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES_SUPPLIER]
(
    [delivery_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [contactName] nvarchar(MAX) NULL,
    [email] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_DELIVERYNOTES_SUPPLIER', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_DELIVERYNOTES_SUPPLIER_EMAILS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_DELIVERYNOTES_SUPPLIER_EMAILS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES_SUPPLIER_EMAILS]
(
    [delivery_id] nvarchar(MAX) NULL,
    [supplier_id] nvarchar(MAX) NULL,
    [emails] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_DELIVERYNOTES_SUPPLIER_EMAILS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_DELIVERYNOTES_SUPPLIER_EMAILS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_DELIVERYNOTES_SUPPLIER_EMAILS', N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES_SUPPLIER_EMAILS]
(
    [delivery_id] nvarchar(MAX) NULL,
    [supplier_id] nvarchar(MAX) NULL,
    [emails] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_DELIVERYNOTES_SUPPLIER_EMAILS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_INVOICES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_INVOICES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_INVOICES]
(
    [id] nvarchar(MAX) NULL,
    [invoiceNumber] nvarchar(MAX) NULL,
    [deliveryNoteNumber] nvarchar(MAX) NULL,
    [deliveryNoteId] nvarchar(MAX) NULL,
    [po] nvarchar(MAX) NULL,
    [dateOfIssue] nvarchar(MAX) NULL,
    [dateOfScanning] nvarchar(MAX) NULL,
    [dueDate] nvarchar(MAX) NULL,
    [approvedDate] nvarchar(MAX) NULL,
    [inQueryDate] nvarchar(MAX) NULL,
    [rejectedDate] nvarchar(MAX) NULL,
    [extractedFile] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [grossTotalCost] nvarchar(MAX) NULL,
    [totalVat] nvarchar(MAX) NULL,
    [expectedTotalCost] nvarchar(MAX) NULL,
    [invoicedTotalCost] nvarchar(MAX) NULL,
    [deltaTotalCost] nvarchar(MAX) NULL,
    [deltaInvoicedExpectedTotalCost] nvarchar(MAX) NULL,
    [status] nvarchar(MAX) NULL,
    [message] nvarchar(MAX) NULL,
    [messageQueryToSupplier] nvarchar(MAX) NULL,
    [expectedPo] nvarchar(MAX) NULL,
    [expectedDeliveryNoteNumber] nvarchar(MAX) NULL,
    [hasQtyDiscrepancies] nvarchar(MAX) NULL,
    [hasProductPriceDiscrepancies] nvarchar(MAX) NULL,
    [hasNoReceivedProducts] nvarchar(MAX) NULL,
    [hasNoInvoicedProducts] nvarchar(MAX) NULL,
    [hasNoOrderedProducts] nvarchar(MAX) NULL,
    [hasTotalCostDiscrepancy] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_INVOICES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_INVOICES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_INVOICES', N'CREATE TABLE [int_growyze001].[DL_INVOICES]
(
    [id] nvarchar(MAX) NULL,
    [invoiceNumber] nvarchar(MAX) NULL,
    [deliveryNoteNumber] nvarchar(MAX) NULL,
    [deliveryNoteId] nvarchar(MAX) NULL,
    [po] nvarchar(MAX) NULL,
    [dateOfIssue] nvarchar(MAX) NULL,
    [dateOfScanning] nvarchar(MAX) NULL,
    [dueDate] nvarchar(MAX) NULL,
    [approvedDate] nvarchar(MAX) NULL,
    [inQueryDate] nvarchar(MAX) NULL,
    [rejectedDate] nvarchar(MAX) NULL,
    [extractedFile] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [grossTotalCost] nvarchar(MAX) NULL,
    [totalVat] nvarchar(MAX) NULL,
    [expectedTotalCost] nvarchar(MAX) NULL,
    [invoicedTotalCost] nvarchar(MAX) NULL,
    [deltaTotalCost] nvarchar(MAX) NULL,
    [deltaInvoicedExpectedTotalCost] nvarchar(MAX) NULL,
    [status] nvarchar(MAX) NULL,
    [message] nvarchar(MAX) NULL,
    [messageQueryToSupplier] nvarchar(MAX) NULL,
    [expectedPo] nvarchar(MAX) NULL,
    [expectedDeliveryNoteNumber] nvarchar(MAX) NULL,
    [hasQtyDiscrepancies] nvarchar(MAX) NULL,
    [hasProductPriceDiscrepancies] nvarchar(MAX) NULL,
    [hasNoReceivedProducts] nvarchar(MAX) NULL,
    [hasNoInvoicedProducts] nvarchar(MAX) NULL,
    [hasNoOrderedProducts] nvarchar(MAX) NULL,
    [hasTotalCostDiscrepancy] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_INVOICES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_INVOICES_DELIVERYNOTES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_INVOICES_DELIVERYNOTES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_INVOICES_DELIVERYNOTES]
(
    [invoice_id] nvarchar(MAX) NULL,
    [deliveryNoteId] nvarchar(MAX) NULL,
    [deliveryNoteNumber] nvarchar(MAX) NULL,
    [po] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_INVOICES_DELIVERYNOTES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_INVOICES_DELIVERYNOTES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_INVOICES_DELIVERYNOTES', N'CREATE TABLE [int_growyze001].[DL_INVOICES_DELIVERYNOTES]
(
    [invoice_id] nvarchar(MAX) NULL,
    [deliveryNoteId] nvarchar(MAX) NULL,
    [deliveryNoteNumber] nvarchar(MAX) NULL,
    [po] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_INVOICES_DELIVERYNOTES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_INVOICES_GLOBALDISCREPANCIES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_INVOICES_GLOBALDISCREPANCIES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_INVOICES_GLOBALDISCREPANCIES]
(
    [invoice_id] nvarchar(MAX) NULL,
    [globalDiscrepancies] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_INVOICES_GLOBALDISCREPANCIES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_INVOICES_GLOBALDISCREPANCIES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_INVOICES_GLOBALDISCREPANCIES', N'CREATE TABLE [int_growyze001].[DL_INVOICES_GLOBALDISCREPANCIES]
(
    [invoice_id] nvarchar(MAX) NULL,
    [globalDiscrepancies] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_INVOICES_GLOBALDISCREPANCIES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_INVOICES_ORGANIZATIONS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_INVOICES_ORGANIZATIONS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_INVOICES_ORGANIZATIONS]
(
    [invoice_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_INVOICES_ORGANIZATIONS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_INVOICES_ORGANIZATIONS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_INVOICES_ORGANIZATIONS', N'CREATE TABLE [int_growyze001].[DL_INVOICES_ORGANIZATIONS]
(
    [invoice_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_INVOICES_ORGANIZATIONS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_INVOICES_ORGANIZATIONSNAMES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_INVOICES_ORGANIZATIONSNAMES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_INVOICES_ORGANIZATIONSNAMES]
(
    [invoice_id] nvarchar(MAX) NULL,
    [organizationsNames] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_INVOICES_ORGANIZATIONSNAMES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_INVOICES_ORGANIZATIONSNAMES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_INVOICES_ORGANIZATIONSNAMES', N'CREATE TABLE [int_growyze001].[DL_INVOICES_ORGANIZATIONSNAMES]
(
    [invoice_id] nvarchar(MAX) NULL,
    [organizationsNames] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_INVOICES_ORGANIZATIONSNAMES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_INVOICES_PRODUCTS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_INVOICES_PRODUCTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_INVOICES_PRODUCTS]
(
    [invoice_id] nvarchar(MAX) NULL,
    [description] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [code] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [orderCaseSize] nvarchar(MAX) NULL,
    [dnReceivedQty] nvarchar(MAX) NULL,
    [receivedQtyInCase] nvarchar(MAX) NULL,
    [invoiceQty] nvarchar(MAX) NULL,
    [invoiceQtyInCase] nvarchar(MAX) NULL,
    [invoicePrice] nvarchar(MAX) NULL,
    [orderPrice] nvarchar(MAX) NULL,
    [expectedTotalCost] nvarchar(MAX) NULL,
    [invoicedTotalCost] nvarchar(MAX) NULL,
    [comment] nvarchar(MAX) NULL,
    [isConfirmed] nvarchar(MAX) NULL,
    [isAcceptedPrice] nvarchar(MAX) NULL,
    [isDuplicated] nvarchar(MAX) NULL,
    [xero] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaQty] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaPrice] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaInvoicedExpectedTotalCost] nvarchar(MAX) NULL,
    [productDiscrepancies_notOrdered] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_INVOICES_PRODUCTS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_INVOICES_PRODUCTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_INVOICES_PRODUCTS', N'CREATE TABLE [int_growyze001].[DL_INVOICES_PRODUCTS]
(
    [invoice_id] nvarchar(MAX) NULL,
    [description] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [code] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [orderCaseSize] nvarchar(MAX) NULL,
    [dnReceivedQty] nvarchar(MAX) NULL,
    [receivedQtyInCase] nvarchar(MAX) NULL,
    [invoiceQty] nvarchar(MAX) NULL,
    [invoiceQtyInCase] nvarchar(MAX) NULL,
    [invoicePrice] nvarchar(MAX) NULL,
    [orderPrice] nvarchar(MAX) NULL,
    [expectedTotalCost] nvarchar(MAX) NULL,
    [invoicedTotalCost] nvarchar(MAX) NULL,
    [comment] nvarchar(MAX) NULL,
    [isConfirmed] nvarchar(MAX) NULL,
    [isAcceptedPrice] nvarchar(MAX) NULL,
    [isDuplicated] nvarchar(MAX) NULL,
    [xero] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaQty] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaPrice] nvarchar(MAX) NULL,
    [productDiscrepancies_deltaInvoicedExpectedTotalCost] nvarchar(MAX) NULL,
    [productDiscrepancies_notOrdered] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_INVOICES_PRODUCTS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_INVOICES_SAGEINVOICE
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_INVOICES_SAGEINVOICE' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_INVOICES_SAGEINVOICE]
(
    [invoice_id] nvarchar(MAX) NULL,
    [invoiceNumber] nvarchar(MAX) NULL,
    [invoiceDate] nvarchar(MAX) NULL,
    [dueDate] nvarchar(MAX) NULL,
    [netCost] nvarchar(MAX) NULL,
    [grossTotalCost] nvarchar(MAX) NULL,
    [totalVat] nvarchar(MAX) NULL,
    [sageSupplier_id] nvarchar(MAX) NULL,
    [sageSupplier_name] nvarchar(MAX) NULL,
    [sageSupplier_email] nvarchar(MAX) NULL,
    [sageSupplier_displayedAs] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_INVOICES_SAGEINVOICE',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_INVOICES_SAGEINVOICE' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_INVOICES_SAGEINVOICE', N'CREATE TABLE [int_growyze001].[DL_INVOICES_SAGEINVOICE]
(
    [invoice_id] nvarchar(MAX) NULL,
    [invoiceNumber] nvarchar(MAX) NULL,
    [invoiceDate] nvarchar(MAX) NULL,
    [dueDate] nvarchar(MAX) NULL,
    [netCost] nvarchar(MAX) NULL,
    [grossTotalCost] nvarchar(MAX) NULL,
    [totalVat] nvarchar(MAX) NULL,
    [sageSupplier_id] nvarchar(MAX) NULL,
    [sageSupplier_name] nvarchar(MAX) NULL,
    [sageSupplier_email] nvarchar(MAX) NULL,
    [sageSupplier_displayedAs] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_INVOICES_SAGEINVOICE', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_INVOICES_SAGEINVOICE_LINEITEMS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_INVOICES_SAGEINVOICE_LINEITEMS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_INVOICES_SAGEINVOICE_LINEITEMS]
(
    [invoice_id] nvarchar(MAX) NULL,
    [sageInvoice_id] nvarchar(MAX) NULL,
    [description] nvarchar(MAX) NULL,
    [netCost] nvarchar(MAX) NULL,
    [account_id] nvarchar(MAX) NULL,
    [account_name] nvarchar(MAX) NULL,
    [account_code] nvarchar(MAX) NULL,
    [account_displayedAs] nvarchar(MAX) NULL,
    [taxRate_id] nvarchar(MAX) NULL,
    [taxRate_name] nvarchar(MAX) NULL,
    [taxRate_percentage] nvarchar(MAX) NULL,
    [taxRate_displayedAs] nvarchar(MAX) NULL,
    [account_type_id] nvarchar(MAX) NULL,
    [account_type_displayedAs] nvarchar(MAX) NULL,
    [account_taxRate_id] nvarchar(MAX) NULL,
    [account_taxRate_name] nvarchar(MAX) NULL,
    [account_taxRate_percentage] nvarchar(MAX) NULL,
    [account_taxRate_displayedAs] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_INVOICES_SAGEINVOICE_LINEITEMS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_INVOICES_SAGEINVOICE_LINEITEMS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_INVOICES_SAGEINVOICE_LINEITEMS', N'CREATE TABLE [int_growyze001].[DL_INVOICES_SAGEINVOICE_LINEITEMS]
(
    [invoice_id] nvarchar(MAX) NULL,
    [sageInvoice_id] nvarchar(MAX) NULL,
    [description] nvarchar(MAX) NULL,
    [netCost] nvarchar(MAX) NULL,
    [account_id] nvarchar(MAX) NULL,
    [account_name] nvarchar(MAX) NULL,
    [account_code] nvarchar(MAX) NULL,
    [account_displayedAs] nvarchar(MAX) NULL,
    [taxRate_id] nvarchar(MAX) NULL,
    [taxRate_name] nvarchar(MAX) NULL,
    [taxRate_percentage] nvarchar(MAX) NULL,
    [taxRate_displayedAs] nvarchar(MAX) NULL,
    [account_type_id] nvarchar(MAX) NULL,
    [account_type_displayedAs] nvarchar(MAX) NULL,
    [account_taxRate_id] nvarchar(MAX) NULL,
    [account_taxRate_name] nvarchar(MAX) NULL,
    [account_taxRate_percentage] nvarchar(MAX) NULL,
    [account_taxRate_displayedAs] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_INVOICES_SAGEINVOICE_LINEITEMS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_INVOICES_SUPPLIER
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_INVOICES_SUPPLIER' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_INVOICES_SUPPLIER]
(
    [invoice_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [contactName] nvarchar(MAX) NULL,
    [email] nvarchar(MAX) NULL,
    [currency] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_INVOICES_SUPPLIER',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_INVOICES_SUPPLIER' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_INVOICES_SUPPLIER', N'CREATE TABLE [int_growyze001].[DL_INVOICES_SUPPLIER]
(
    [invoice_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [contactName] nvarchar(MAX) NULL,
    [email] nvarchar(MAX) NULL,
    [currency] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_INVOICES_SUPPLIER', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ORDERS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_ORDERS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_ORDERS]
(
    [id] nvarchar(MAX) NULL,
    [po] nvarchar(MAX) NULL,
    [status] nvarchar(MAX) NULL,
    [isSentToSupplier] nvarchar(MAX) NULL,
    [skippedSendingToSupplier] nvarchar(MAX) NULL,
    [notes] nvarchar(MAX) NULL,
    [comments] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [placedDate] nvarchar(MAX) NULL,
    [createdDate] nvarchar(MAX) NULL,
    [completedDate] nvarchar(MAX) NULL,
    [canceledDate] nvarchar(MAX) NULL,
    [expectedDeliveryDate] nvarchar(MAX) NULL,
    [approvedBy] nvarchar(MAX) NULL,
    [extractedFile] nvarchar(MAX) NULL,
    [isDelivered] nvarchar(MAX) NULL,
    [deliveryAddress_addressLine1] nvarchar(MAX) NULL,
    [deliveryAddress_addressLine2] nvarchar(MAX) NULL,
    [deliveryAddress_city] nvarchar(MAX) NULL,
    [deliveryAddress_postCode] nvarchar(MAX) NULL,
    [deliveryAddress_country] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ORDERS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ORDERS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ORDERS', N'CREATE TABLE [int_growyze001].[DL_ORDERS]
(
    [id] nvarchar(MAX) NULL,
    [po] nvarchar(MAX) NULL,
    [status] nvarchar(MAX) NULL,
    [isSentToSupplier] nvarchar(MAX) NULL,
    [skippedSendingToSupplier] nvarchar(MAX) NULL,
    [notes] nvarchar(MAX) NULL,
    [comments] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [placedDate] nvarchar(MAX) NULL,
    [createdDate] nvarchar(MAX) NULL,
    [completedDate] nvarchar(MAX) NULL,
    [canceledDate] nvarchar(MAX) NULL,
    [expectedDeliveryDate] nvarchar(MAX) NULL,
    [approvedBy] nvarchar(MAX) NULL,
    [extractedFile] nvarchar(MAX) NULL,
    [isDelivered] nvarchar(MAX) NULL,
    [deliveryAddress_addressLine1] nvarchar(MAX) NULL,
    [deliveryAddress_addressLine2] nvarchar(MAX) NULL,
    [deliveryAddress_city] nvarchar(MAX) NULL,
    [deliveryAddress_postCode] nvarchar(MAX) NULL,
    [deliveryAddress_country] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ORDERS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ORDERS_ITEMS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_ORDERS_ITEMS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_ORDERS_ITEMS]
(
    [order_id] nvarchar(MAX) NULL,
    [productId] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [code] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [estimatedCost] nvarchar(MAX) NULL,
    [quantity] nvarchar(MAX) NULL,
    [orderInCase] nvarchar(MAX) NULL,
    [productCase_code] nvarchar(MAX) NULL,
    [productCase_size] nvarchar(MAX) NULL,
    [productCase_price] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ORDERS_ITEMS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ORDERS_ITEMS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ORDERS_ITEMS', N'CREATE TABLE [int_growyze001].[DL_ORDERS_ITEMS]
(
    [order_id] nvarchar(MAX) NULL,
    [productId] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [code] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [estimatedCost] nvarchar(MAX) NULL,
    [quantity] nvarchar(MAX) NULL,
    [orderInCase] nvarchar(MAX) NULL,
    [productCase_code] nvarchar(MAX) NULL,
    [productCase_size] nvarchar(MAX) NULL,
    [productCase_price] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ORDERS_ITEMS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ORDERS_ORGANIZATIONS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_ORDERS_ORGANIZATIONS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_ORDERS_ORGANIZATIONS]
(
    [order_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ORDERS_ORGANIZATIONS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ORDERS_ORGANIZATIONS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ORDERS_ORGANIZATIONS', N'CREATE TABLE [int_growyze001].[DL_ORDERS_ORGANIZATIONS]
(
    [order_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ORDERS_ORGANIZATIONS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ORDERS_ORGANIZATIONSNAMES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_ORDERS_ORGANIZATIONSNAMES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_ORDERS_ORGANIZATIONSNAMES]
(
    [order_id] nvarchar(MAX) NULL,
    [organizationsNames] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ORDERS_ORGANIZATIONSNAMES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ORDERS_ORGANIZATIONSNAMES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ORDERS_ORGANIZATIONSNAMES', N'CREATE TABLE [int_growyze001].[DL_ORDERS_ORGANIZATIONSNAMES]
(
    [order_id] nvarchar(MAX) NULL,
    [organizationsNames] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ORDERS_ORGANIZATIONSNAMES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ORDERS_SUPPLIER
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_ORDERS_SUPPLIER' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_ORDERS_SUPPLIER]
(
    [order_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [accountNumber] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [contactName] nvarchar(MAX) NULL,
    [email] nvarchar(MAX) NULL,
    [currency] nvarchar(MAX) NULL,
    [internalSupplier] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ORDERS_SUPPLIER',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ORDERS_SUPPLIER' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ORDERS_SUPPLIER', N'CREATE TABLE [int_growyze001].[DL_ORDERS_SUPPLIER]
(
    [order_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [accountNumber] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [contactName] nvarchar(MAX) NULL,
    [email] nvarchar(MAX) NULL,
    [currency] nvarchar(MAX) NULL,
    [internalSupplier] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ORDERS_SUPPLIER', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_PRODUCTS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_PRODUCTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_PRODUCTS]
(
    [id] nvarchar(MAX) NULL,
    [groupId] nvarchar(MAX) NULL,
    [mainProductId] nvarchar(MAX) NULL,
    [supplierId] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [autoGenBarcode] nvarchar(MAX) NULL,
    [posId] nvarchar(MAX) NULL,
    [code] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [notes] nvarchar(MAX) NULL,
    [description] nvarchar(MAX) NULL,
    [minQtyInStock] nvarchar(MAX) NULL,
    [favourite] nvarchar(MAX) NULL,
    [preferred] nvarchar(MAX) NULL,
    [supplierName] nvarchar(MAX) NULL,
    [countOfProductsInGroup] nvarchar(MAX) NULL,
    [stockOnHand] nvarchar(MAX) NULL,
    [stockTakeDate] nvarchar(MAX) NULL,
    [avgWeeklyConsumption] nvarchar(MAX) NULL,
    [awaitingDelivery] nvarchar(MAX) NULL,
    [lastOrdered] nvarchar(MAX) NULL,
    [lastOrderedLocation] nvarchar(MAX) NULL,
    [lastCountedQty] nvarchar(MAX) NULL,
    [productCase_code] nvarchar(MAX) NULL,
    [productCase_size] nvarchar(MAX) NULL,
    [productCase_price] nvarchar(MAX) NULL,
    [allergensValidation_action] nvarchar(MAX) NULL,
    [allergensValidation_date] nvarchar(MAX) NULL,
    [orderedIn_single] nvarchar(MAX) NULL,
    [orderedIn_pack] nvarchar(MAX) NULL,
    [orderedIn_both] nvarchar(MAX) NULL,
    [accounting_xeroAccounting] nvarchar(MAX) NULL,
    [allergensValidation_user_id] nvarchar(MAX) NULL,
    [allergensValidation_user_username] nvarchar(MAX) NULL,
    [allergensValidation_user_firstName] nvarchar(MAX) NULL,
    [allergensValidation_user_lastName] nvarchar(MAX) NULL,
    [accounting_sageAccounting_taxRate_id] nvarchar(MAX) NULL,
    [accounting_sageAccounting_taxRate_name] nvarchar(MAX) NULL,
    [accounting_sageAccounting_taxRate_percentage] nvarchar(MAX) NULL,
    [accounting_sageAccounting_taxRate_displayedAs] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_id] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_name] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_code] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_displayedAs] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_type_id] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_type_displayedAs] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_taxRate_id] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_taxRate_name] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_taxRate_percentage] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_taxRate_displayedAs] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_PRODUCTS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_PRODUCTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_PRODUCTS', N'CREATE TABLE [int_growyze001].[DL_PRODUCTS]
(
    [id] nvarchar(MAX) NULL,
    [groupId] nvarchar(MAX) NULL,
    [mainProductId] nvarchar(MAX) NULL,
    [supplierId] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [autoGenBarcode] nvarchar(MAX) NULL,
    [posId] nvarchar(MAX) NULL,
    [code] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [notes] nvarchar(MAX) NULL,
    [description] nvarchar(MAX) NULL,
    [minQtyInStock] nvarchar(MAX) NULL,
    [favourite] nvarchar(MAX) NULL,
    [preferred] nvarchar(MAX) NULL,
    [supplierName] nvarchar(MAX) NULL,
    [countOfProductsInGroup] nvarchar(MAX) NULL,
    [stockOnHand] nvarchar(MAX) NULL,
    [stockTakeDate] nvarchar(MAX) NULL,
    [avgWeeklyConsumption] nvarchar(MAX) NULL,
    [awaitingDelivery] nvarchar(MAX) NULL,
    [lastOrdered] nvarchar(MAX) NULL,
    [lastOrderedLocation] nvarchar(MAX) NULL,
    [lastCountedQty] nvarchar(MAX) NULL,
    [productCase_code] nvarchar(MAX) NULL,
    [productCase_size] nvarchar(MAX) NULL,
    [productCase_price] nvarchar(MAX) NULL,
    [allergensValidation_action] nvarchar(MAX) NULL,
    [allergensValidation_date] nvarchar(MAX) NULL,
    [orderedIn_single] nvarchar(MAX) NULL,
    [orderedIn_pack] nvarchar(MAX) NULL,
    [orderedIn_both] nvarchar(MAX) NULL,
    [accounting_xeroAccounting] nvarchar(MAX) NULL,
    [allergensValidation_user_id] nvarchar(MAX) NULL,
    [allergensValidation_user_username] nvarchar(MAX) NULL,
    [allergensValidation_user_firstName] nvarchar(MAX) NULL,
    [allergensValidation_user_lastName] nvarchar(MAX) NULL,
    [accounting_sageAccounting_taxRate_id] nvarchar(MAX) NULL,
    [accounting_sageAccounting_taxRate_name] nvarchar(MAX) NULL,
    [accounting_sageAccounting_taxRate_percentage] nvarchar(MAX) NULL,
    [accounting_sageAccounting_taxRate_displayedAs] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_id] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_name] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_code] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_displayedAs] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_type_id] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_type_displayedAs] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_taxRate_id] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_taxRate_name] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_taxRate_percentage] nvarchar(MAX) NULL,
    [accounting_sageAccounting_account_taxRate_displayedAs] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_PRODUCTS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_PRODUCTS_ALLERGENS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_PRODUCTS_ALLERGENS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_PRODUCTS_ALLERGENS]
(
    [product_id] nvarchar(MAX) NULL,
    [allergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_PRODUCTS_ALLERGENS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_PRODUCTS_ALLERGENS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_PRODUCTS_ALLERGENS', N'CREATE TABLE [int_growyze001].[DL_PRODUCTS_ALLERGENS]
(
    [product_id] nvarchar(MAX) NULL,
    [allergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_PRODUCTS_ALLERGENS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_PRODUCTS_BARCODES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_PRODUCTS_BARCODES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_PRODUCTS_BARCODES]
(
    [product_id] nvarchar(MAX) NULL,
    [barcodes] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_PRODUCTS_BARCODES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_PRODUCTS_BARCODES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_PRODUCTS_BARCODES', N'CREATE TABLE [int_growyze001].[DL_PRODUCTS_BARCODES]
(
    [product_id] nvarchar(MAX) NULL,
    [barcodes] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_PRODUCTS_BARCODES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_PRODUCTS_INGREDIENTS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_PRODUCTS_INGREDIENTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_PRODUCTS_INGREDIENTS]
(
    [product_id] nvarchar(MAX) NULL,
    [ingredients] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_PRODUCTS_INGREDIENTS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_PRODUCTS_INGREDIENTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_PRODUCTS_INGREDIENTS', N'CREATE TABLE [int_growyze001].[DL_PRODUCTS_INGREDIENTS]
(
    [product_id] nvarchar(MAX) NULL,
    [ingredients] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_PRODUCTS_INGREDIENTS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_PRODUCTS_MAYCONTAINALLERGENS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_PRODUCTS_MAYCONTAINALLERGENS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_PRODUCTS_MAYCONTAINALLERGENS]
(
    [product_id] nvarchar(MAX) NULL,
    [mayContainAllergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_PRODUCTS_MAYCONTAINALLERGENS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_PRODUCTS_MAYCONTAINALLERGENS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_PRODUCTS_MAYCONTAINALLERGENS', N'CREATE TABLE [int_growyze001].[DL_PRODUCTS_MAYCONTAINALLERGENS]
(
    [product_id] nvarchar(MAX) NULL,
    [mayContainAllergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_PRODUCTS_MAYCONTAINALLERGENS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_PRODUCTS_ORGANIZATIONS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_PRODUCTS_ORGANIZATIONS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_PRODUCTS_ORGANIZATIONS]
(
    [product_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_PRODUCTS_ORGANIZATIONS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_PRODUCTS_ORGANIZATIONS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_PRODUCTS_ORGANIZATIONS', N'CREATE TABLE [int_growyze001].[DL_PRODUCTS_ORGANIZATIONS]
(
    [product_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_PRODUCTS_ORGANIZATIONS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES]
(
    [id] nvarchar(MAX) NULL,
    [mainRecipeId] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [description] nvarchar(MAX) NULL,
    [notes] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [posId] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [totalCostPercent] nvarchar(MAX) NULL,
    [totalCostPercentBasedOnSalePriceWithTax] nvarchar(MAX) NULL,
    [profit] nvarchar(MAX) NULL,
    [profitPercent] nvarchar(MAX) NULL,
    [salePrice] nvarchar(MAX) NULL,
    [targetMarginPercent] nvarchar(MAX) NULL,
    [taxPercent] nvarchar(MAX) NULL,
    [suggestedSalePrice] nvarchar(MAX) NULL,
    [suggestedSalePriceWithTax] nvarchar(MAX) NULL,
    [salePriceWithTax] nvarchar(MAX) NULL,
    [calcSalePriceWithTax] nvarchar(MAX) NULL,
    [profitBasedOnSalePriceWithTax] nvarchar(MAX) NULL,
    [profitPercentBasedOnSalePriceWithTax] nvarchar(MAX) NULL,
    [otherIngredients] nvarchar(MAX) NULL,
    [otherIngredientsCost] nvarchar(MAX) NULL,
    [createdDate] nvarchar(MAX) NULL,
    [portionCount] nvarchar(MAX) NULL,
    [status] nvarchar(MAX) NULL,
    [folder] nvarchar(MAX) NULL,
    [hasDeletedIngredients] nvarchar(MAX) NULL,
    [useSalesPriceFromLatestSales] nvarchar(MAX) NULL,
    [yield_size] nvarchar(MAX) NULL,
    [yield_measure] nvarchar(MAX) NULL,
    [featuredFile_mainFileId] nvarchar(MAX) NULL,
    [featuredFile_fileId] nvarchar(MAX) NULL,
    [featuredFile_fileName] nvarchar(MAX) NULL,
    [featuredFile_createdAt] nvarchar(MAX) NULL,
    [portion_size] nvarchar(MAX) NULL,
    [portion_measure] nvarchar(MAX) NULL,
    [portion_cost] nvarchar(MAX) NULL,
    [waste_cost] nvarchar(MAX) NULL,
    [waste_percent] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES', N'CREATE TABLE [int_growyze001].[DL_RECIPES]
(
    [id] nvarchar(MAX) NULL,
    [mainRecipeId] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [description] nvarchar(MAX) NULL,
    [notes] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [posId] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [totalCostPercent] nvarchar(MAX) NULL,
    [totalCostPercentBasedOnSalePriceWithTax] nvarchar(MAX) NULL,
    [profit] nvarchar(MAX) NULL,
    [profitPercent] nvarchar(MAX) NULL,
    [salePrice] nvarchar(MAX) NULL,
    [targetMarginPercent] nvarchar(MAX) NULL,
    [taxPercent] nvarchar(MAX) NULL,
    [suggestedSalePrice] nvarchar(MAX) NULL,
    [suggestedSalePriceWithTax] nvarchar(MAX) NULL,
    [salePriceWithTax] nvarchar(MAX) NULL,
    [calcSalePriceWithTax] nvarchar(MAX) NULL,
    [profitBasedOnSalePriceWithTax] nvarchar(MAX) NULL,
    [profitPercentBasedOnSalePriceWithTax] nvarchar(MAX) NULL,
    [otherIngredients] nvarchar(MAX) NULL,
    [otherIngredientsCost] nvarchar(MAX) NULL,
    [createdDate] nvarchar(MAX) NULL,
    [portionCount] nvarchar(MAX) NULL,
    [status] nvarchar(MAX) NULL,
    [folder] nvarchar(MAX) NULL,
    [hasDeletedIngredients] nvarchar(MAX) NULL,
    [useSalesPriceFromLatestSales] nvarchar(MAX) NULL,
    [yield_size] nvarchar(MAX) NULL,
    [yield_measure] nvarchar(MAX) NULL,
    [featuredFile_mainFileId] nvarchar(MAX) NULL,
    [featuredFile_fileId] nvarchar(MAX) NULL,
    [featuredFile_fileName] nvarchar(MAX) NULL,
    [featuredFile_createdAt] nvarchar(MAX) NULL,
    [portion_size] nvarchar(MAX) NULL,
    [portion_measure] nvarchar(MAX) NULL,
    [portion_cost] nvarchar(MAX) NULL,
    [waste_cost] nvarchar(MAX) NULL,
    [waste_percent] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_ALLERGENS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_ALLERGENS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_ALLERGENS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [allergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_ALLERGENS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_ALLERGENS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_ALLERGENS', N'CREATE TABLE [int_growyze001].[DL_RECIPES_ALLERGENS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [allergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_ALLERGENS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_DISHES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_DISHES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_DISHES]
(
    [recipe_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_DISHES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_DISHES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_DISHES', N'CREATE TABLE [int_growyze001].[DL_RECIPES_DISHES]
(
    [recipe_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_DISHES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_INGREDIENTS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_INGREDIENTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_INGREDIENTS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [usedQty] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [usedQtyInProductMeasure] nvarchar(MAX) NULL,
    [wasteQty] nvarchar(MAX) NULL,
    [wasteMeasure] nvarchar(MAX) NULL,
    [pureQty] nvarchar(MAX) NULL,
    [pureMeasure] nvarchar(MAX) NULL,
    [cost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_INGREDIENTS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_INGREDIENTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_INGREDIENTS', N'CREATE TABLE [int_growyze001].[DL_RECIPES_INGREDIENTS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [usedQty] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [usedQtyInProductMeasure] nvarchar(MAX) NULL,
    [wasteQty] nvarchar(MAX) NULL,
    [wasteMeasure] nvarchar(MAX) NULL,
    [pureQty] nvarchar(MAX) NULL,
    [pureMeasure] nvarchar(MAX) NULL,
    [cost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_INGREDIENTS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_INGREDIENTS_PRODUCT
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_INGREDIENTS_PRODUCT' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_INGREDIENTS_PRODUCT]
(
    [recipe_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [supplierId] nvarchar(MAX) NULL,
    [supplierName] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [isDeleted] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_INGREDIENTS_PRODUCT',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_INGREDIENTS_PRODUCT' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_INGREDIENTS_PRODUCT', N'CREATE TABLE [int_growyze001].[DL_RECIPES_INGREDIENTS_PRODUCT]
(
    [recipe_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [supplierId] nvarchar(MAX) NULL,
    [supplierName] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [isDeleted] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_INGREDIENTS_PRODUCT', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_INGREDIENTS_PRODUCT_ALLERGENS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_INGREDIENTS_PRODUCT_ALLERGENS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_INGREDIENTS_PRODUCT_ALLERGENS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [product_id] nvarchar(MAX) NULL,
    [allergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_INGREDIENTS_PRODUCT_ALLERGENS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_INGREDIENTS_PRODUCT_ALLERGENS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_INGREDIENTS_PRODUCT_ALLERGENS', N'CREATE TABLE [int_growyze001].[DL_RECIPES_INGREDIENTS_PRODUCT_ALLERGENS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [product_id] nvarchar(MAX) NULL,
    [allergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_INGREDIENTS_PRODUCT_ALLERGENS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_INGREDIENTSINPRODUCTS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_INGREDIENTSINPRODUCTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_INGREDIENTSINPRODUCTS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [ingredientsInProducts] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_INGREDIENTSINPRODUCTS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_INGREDIENTSINPRODUCTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_INGREDIENTSINPRODUCTS', N'CREATE TABLE [int_growyze001].[DL_RECIPES_INGREDIENTSINPRODUCTS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [ingredientsInProducts] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_INGREDIENTSINPRODUCTS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_MAYCONTAINALLERGENS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_MAYCONTAINALLERGENS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_MAYCONTAINALLERGENS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [mayContainAllergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_MAYCONTAINALLERGENS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_MAYCONTAINALLERGENS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_MAYCONTAINALLERGENS', N'CREATE TABLE [int_growyze001].[DL_RECIPES_MAYCONTAINALLERGENS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [mayContainAllergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_MAYCONTAINALLERGENS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_ORGANIZATIONS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_ORGANIZATIONS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_ORGANIZATIONS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_ORGANIZATIONS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_ORGANIZATIONS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_ORGANIZATIONS', N'CREATE TABLE [int_growyze001].[DL_RECIPES_ORGANIZATIONS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_ORGANIZATIONS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_SECTIONS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_SECTIONS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_SECTIONS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_SECTIONS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_SECTIONS', N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_SECTIONS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_SECTIONS_ELEMENTS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [type] nvarchar(MAX) NULL,
    [otherIngredient_name] nvarchar(MAX) NULL,
    [otherIngredient_cost] nvarchar(MAX) NULL,
    [otherIngredient_usedQty] nvarchar(MAX) NULL,
    [otherIngredient_measure] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_SECTIONS_ELEMENTS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_SECTIONS_ELEMENTS', N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [type] nvarchar(MAX) NULL,
    [otherIngredient_name] nvarchar(MAX) NULL,
    [otherIngredient_cost] nvarchar(MAX) NULL,
    [otherIngredient_usedQty] nvarchar(MAX) NULL,
    [otherIngredient_measure] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_SECTIONS_ELEMENTS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [usedQty] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [usedQtyInProductMeasure] nvarchar(MAX) NULL,
    [wasteQty] nvarchar(MAX) NULL,
    [wasteMeasure] nvarchar(MAX) NULL,
    [pureQty] nvarchar(MAX) NULL,
    [pureMeasure] nvarchar(MAX) NULL,
    [cost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT', N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [usedQty] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [usedQtyInProductMeasure] nvarchar(MAX) NULL,
    [wasteQty] nvarchar(MAX) NULL,
    [wasteMeasure] nvarchar(MAX) NULL,
    [pureQty] nvarchar(MAX) NULL,
    [pureMeasure] nvarchar(MAX) NULL,
    [cost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [supplierId] nvarchar(MAX) NULL,
    [supplierName] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [isDeleted] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT', N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [supplierId] nvarchar(MAX) NULL,
    [supplierName] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [isDeleted] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_ALLERGENS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_ALLERGENS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_ALLERGENS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [product_id] nvarchar(MAX) NULL,
    [allergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_ALLERGENS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_ALLERGENS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_ALLERGENS', N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_ALLERGENS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [product_id] nvarchar(MAX) NULL,
    [allergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_ALLERGENS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_INGREDIENTS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_INGREDIENTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_INGREDIENTS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [product_id] nvarchar(MAX) NULL,
    [ingredients] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_INGREDIENTS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_INGREDIENTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_INGREDIENTS', N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_INGREDIENTS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [product_id] nvarchar(MAX) NULL,
    [ingredients] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_INGREDIENTS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_MAYCONTAINALLERGENS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_MAYCONTAINALLERGENS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_MAYCONTAINALLERGENS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [product_id] nvarchar(MAX) NULL,
    [mayContainAllergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_MAYCONTAINALLERGENS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_MAYCONTAINALLERGENS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_MAYCONTAINALLERGENS', N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_MAYCONTAINALLERGENS]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [product_id] nvarchar(MAX) NULL,
    [mayContainAllergens] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_MAYCONTAINALLERGENS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_RECIPES_SECTIONS_ELEMENTS_RECIPE
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_RECIPE' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_RECIPE]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES_SECTIONS_ELEMENTS_RECIPE',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES_SECTIONS_ELEMENTS_RECIPE' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES_SECTIONS_ELEMENTS_RECIPE', N'CREATE TABLE [int_growyze001].[DL_RECIPES_SECTIONS_ELEMENTS_RECIPE]
(
    [recipe_id] nvarchar(MAX) NULL,
    [sections_id] nvarchar(MAX) NULL,
    [elements_id] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES_SECTIONS_ELEMENTS_RECIPE', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_SALES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_SALES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_SALES]
(
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [from] nvarchar(MAX) NULL,
    [to] nvarchar(MAX) NULL,
    [totalSales] nvarchar(MAX) NULL,
    [nonMatchingPosIdsCount] nvarchar(MAX) NULL,
    [autoGeneratedPosIdsCount] nvarchar(MAX) NULL,
    [isFromSquare] nvarchar(MAX) NULL,
    [isLive] nvarchar(MAX) NULL,
    [salesOrigin] nvarchar(MAX) NULL,
    [createdAt] nvarchar(MAX) NULL,
    [updatedAt] nvarchar(MAX) NULL,
    [metadata] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_SALES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_SALES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_SALES', N'CREATE TABLE [int_growyze001].[DL_SALES]
(
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [from] nvarchar(MAX) NULL,
    [to] nvarchar(MAX) NULL,
    [totalSales] nvarchar(MAX) NULL,
    [nonMatchingPosIdsCount] nvarchar(MAX) NULL,
    [autoGeneratedPosIdsCount] nvarchar(MAX) NULL,
    [isFromSquare] nvarchar(MAX) NULL,
    [isLive] nvarchar(MAX) NULL,
    [salesOrigin] nvarchar(MAX) NULL,
    [createdAt] nvarchar(MAX) NULL,
    [updatedAt] nvarchar(MAX) NULL,
    [metadata] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_SALES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_SALES_ORGANIZATIONS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_SALES_ORGANIZATIONS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_SALES_ORGANIZATIONS]
(
    [sales_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_SALES_ORGANIZATIONS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_SALES_ORGANIZATIONS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_SALES_ORGANIZATIONS', N'CREATE TABLE [int_growyze001].[DL_SALES_ORGANIZATIONS]
(
    [sales_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_SALES_ORGANIZATIONS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES]
(
    [id] nvarchar(MAX) NULL,
    [date] nvarchar(MAX) NULL,
    [updatedAt] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES', N'CREATE TABLE [int_growyze001].[DL_WASTES]
(
    [id] nvarchar(MAX) NULL,
    [date] nvarchar(MAX) NULL,
    [updatedAt] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES_DISHES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES_DISHES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES_DISHES]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES_DISHES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES_DISHES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES_DISHES', N'CREATE TABLE [int_growyze001].[DL_WASTES_DISHES]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES_DISHES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES_DISHES_DISH
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES_DISHES_DISH' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES_DISHES_DISH]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES_DISHES_DISH',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES_DISHES_DISH' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES_DISHES_DISH', N'CREATE TABLE [int_growyze001].[DL_WASTES_DISHES_DISH]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES_DISHES_DISH', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES_DISHES_WASTESPERDAY
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES_DISHES_WASTESPERDAY' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES_DISHES_WASTESPERDAY]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [fullQty] nvarchar(MAX) NULL,
    [partialQty] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [reason] nvarchar(MAX) NULL,
    [timeOfRecord] nvarchar(MAX) NULL,
    [reporter] nvarchar(MAX) NULL,
    [comment] nvarchar(MAX) NULL,
    [wasteOrigin] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES_DISHES_WASTESPERDAY',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES_DISHES_WASTESPERDAY' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES_DISHES_WASTESPERDAY', N'CREATE TABLE [int_growyze001].[DL_WASTES_DISHES_WASTESPERDAY]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [fullQty] nvarchar(MAX) NULL,
    [partialQty] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [reason] nvarchar(MAX) NULL,
    [timeOfRecord] nvarchar(MAX) NULL,
    [reporter] nvarchar(MAX) NULL,
    [comment] nvarchar(MAX) NULL,
    [wasteOrigin] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES_DISHES_WASTESPERDAY', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES_ORGANIZATIONS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES_ORGANIZATIONS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES_ORGANIZATIONS]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES_ORGANIZATIONS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES_ORGANIZATIONS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES_ORGANIZATIONS', N'CREATE TABLE [int_growyze001].[DL_WASTES_ORGANIZATIONS]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [organizations] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES_ORGANIZATIONS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES_ORGANIZATIONSNAMES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES_ORGANIZATIONSNAMES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES_ORGANIZATIONSNAMES]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [organizationsNames] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES_ORGANIZATIONSNAMES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES_ORGANIZATIONSNAMES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES_ORGANIZATIONSNAMES', N'CREATE TABLE [int_growyze001].[DL_WASTES_ORGANIZATIONSNAMES]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [organizationsNames] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES_ORGANIZATIONSNAMES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES_PRODUCTS
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES_PRODUCTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES_PRODUCTS]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES_PRODUCTS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES_PRODUCTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES_PRODUCTS', N'CREATE TABLE [int_growyze001].[DL_WASTES_PRODUCTS]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES_PRODUCTS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES_PRODUCTS_PRODUCT
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES_PRODUCTS_PRODUCT' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES_PRODUCTS_PRODUCT]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES_PRODUCTS_PRODUCT',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES_PRODUCTS_PRODUCT' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES_PRODUCTS_PRODUCT', N'CREATE TABLE [int_growyze001].[DL_WASTES_PRODUCTS_PRODUCT]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [barcode] nvarchar(MAX) NULL,
    [category] nvarchar(MAX) NULL,
    [subCategory] nvarchar(MAX) NULL,
    [unit] nvarchar(MAX) NULL,
    [measure] nvarchar(MAX) NULL,
    [size] nvarchar(MAX) NULL,
    [price] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES_PRODUCTS_PRODUCT', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES_PRODUCTS_WASTESPERDAY
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES_PRODUCTS_WASTESPERDAY' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES_PRODUCTS_WASTESPERDAY]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [fullQty] nvarchar(MAX) NULL,
    [partialQty] nvarchar(MAX) NULL,
    [partialQtyInProductMeasure] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [wasteMeasure] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [reason] nvarchar(MAX) NULL,
    [timeOfRecord] nvarchar(MAX) NULL,
    [reporter] nvarchar(MAX) NULL,
    [comment] nvarchar(MAX) NULL,
    [wasteRecipeRecordId] nvarchar(MAX) NULL,
    [recipeName] nvarchar(MAX) NULL,
    [wasteDishRecordId] nvarchar(MAX) NULL,
    [dishName] nvarchar(MAX) NULL,
    [wasteOrigin] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES_PRODUCTS_WASTESPERDAY',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES_PRODUCTS_WASTESPERDAY' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES_PRODUCTS_WASTESPERDAY', N'CREATE TABLE [int_growyze001].[DL_WASTES_PRODUCTS_WASTESPERDAY]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [fullQty] nvarchar(MAX) NULL,
    [partialQty] nvarchar(MAX) NULL,
    [partialQtyInProductMeasure] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [wasteMeasure] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [reason] nvarchar(MAX) NULL,
    [timeOfRecord] nvarchar(MAX) NULL,
    [reporter] nvarchar(MAX) NULL,
    [comment] nvarchar(MAX) NULL,
    [wasteRecipeRecordId] nvarchar(MAX) NULL,
    [recipeName] nvarchar(MAX) NULL,
    [wasteDishRecordId] nvarchar(MAX) NULL,
    [dishName] nvarchar(MAX) NULL,
    [wasteOrigin] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES_PRODUCTS_WASTESPERDAY', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES_RECIPES
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES_RECIPES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES_RECIPES]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES_RECIPES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES_RECIPES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES_RECIPES', N'CREATE TABLE [int_growyze001].[DL_WASTES_RECIPES]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES_RECIPES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES_RECIPES_RECIPE
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES_RECIPES_RECIPE' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES_RECIPES_RECIPE]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES_RECIPES_RECIPE',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES_RECIPES_RECIPE' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES_RECIPES_RECIPE', N'CREATE TABLE [int_growyze001].[DL_WASTES_RECIPES_RECIPE]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [name] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES_RECIPES_RECIPE', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_WASTES_RECIPES_WASTESPERDAY
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES_RECIPES_WASTESPERDAY' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES_RECIPES_WASTESPERDAY]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [fullQty] nvarchar(MAX) NULL,
    [partialQty] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [reason] nvarchar(MAX) NULL,
    [timeOfRecord] nvarchar(MAX) NULL,
    [reporter] nvarchar(MAX) NULL,
    [comment] nvarchar(MAX) NULL,
    [wasteOrigin] nvarchar(MAX) NULL,
    [wasteMeasure] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_WASTES_RECIPES_WASTESPERDAY',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES_RECIPES_WASTESPERDAY' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES_RECIPES_WASTESPERDAY', N'CREATE TABLE [int_growyze001].[DL_WASTES_RECIPES_WASTESPERDAY]
(
    [waste_day_id] nvarchar(MAX) NULL,
    [id] nvarchar(MAX) NULL,
    [fullQty] nvarchar(MAX) NULL,
    [partialQty] nvarchar(MAX) NULL,
    [totalQty] nvarchar(MAX) NULL,
    [totalCost] nvarchar(MAX) NULL,
    [reason] nvarchar(MAX) NULL,
    [timeOfRecord] nvarchar(MAX) NULL,
    [reporter] nvarchar(MAX) NULL,
    [comment] nvarchar(MAX) NULL,
    [wasteOrigin] nvarchar(MAX) NULL,
    [wasteMeasure] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES_RECIPES_WASTESPERDAY', 1, SYSTEM_USER, GETDATE(), 1);
END
GO
