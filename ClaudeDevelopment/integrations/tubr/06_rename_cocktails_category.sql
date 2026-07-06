/*
    Rename Cocktails category PRODUCT_ID
    ------------------------------------
    The Oak & Vine demo data uses 'CAT_COCK' as the PRODUCT_ID for the
    Cocktails category. Tubr GetCatalog surfaces this as category_id, where
    'CAT_COCK' reads poorly. Rename it to 'CAT_CKTL' to match the platform's
    4-char letter-strip convention (CAT_DESS, CAT_BURG, CAT_SOFT, CAT_START).

    Why this works without touching hubs/links:
        - HUB_PRODUCT.HUB_ID is a hash surrogate (unchanged by this rename).
        - LNK_LOCATION_OCCASION_PRODUCT joins on HUB_IDs, not PRODUCT_ID.
        - SAT_PRODUCT holds both PRODUCT_ID and PARENT_ID as plain strings.
        - PresentationControl hierarchy CTE joins child.PARENT_ID = parent.PRODUCT_ID,
          so as long as we update the category row AND every child's PARENT_ID
          in the same transaction, the hierarchy stays intact.
        - D_PRODUCT only stores BOTTOM_PRODUCT_ID (leaf), not category IDs.
          The category name (MIDDLE_1_NAME / TOP_NAME) is derived from
          PRODUCT_NAME which is unchanged, so D_PRODUCT will rebuild cleanly
          on the next sp_ProcessPresentation run.

    Run against the Oak & Vine UAT database:
        USE [20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87];
        :r 06_rename_cocktails_category.sql

    Idempotent: a re-run finds zero CAT_COCK rows and is a no-op.
*/

SET NOCOUNT ON;

DECLARE @OldId NVARCHAR(255) = N'CAT_COCK';
DECLARE @NewId NVARCHAR(255) = N'CAT_CKTL';

BEGIN TRY
    BEGIN TRAN;

    DECLARE @CatRows  INT;
    DECLARE @ChildRows INT;

    -- Defensive: bail if the new id already exists on a different HUB
    IF EXISTS (
        SELECT 1
        FROM   [datavault].[SAT_PRODUCT]
        WHERE  PRODUCT_ID = @NewId
          AND  CURRENT_FLAG = 1
    )
    BEGIN
        ROLLBACK;
        RAISERROR(N'PRODUCT_ID %s already exists in SAT_PRODUCT. Aborting rename.', 16, 1, @NewId);
        RETURN;
    END;

    -- 1. Rename the category row (PRODUCT_ID = CAT_COCK)
    UPDATE [datavault].[SAT_PRODUCT]
    SET    PRODUCT_ID = @NewId
    WHERE  PRODUCT_ID = @OldId;
    SET @CatRows = @@ROWCOUNT;

    -- 2. Rewire every child whose PARENT_ID points at the old category id
    UPDATE [datavault].[SAT_PRODUCT]
    SET    PARENT_ID = @NewId
    WHERE  PARENT_ID = @OldId;
    SET @ChildRows = @@ROWCOUNT;

    PRINT CONCAT(N'Renamed ', @CatRows, N' category row(s) and rewired ', @ChildRows, N' child PARENT_ID reference(s).');

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
END CATCH;

-- ---------------------------------------------------------------------------
-- Verification: confirm category + children all carry the new id
-- ---------------------------------------------------------------------------
SELECT PRODUCT_ID, PRODUCT_NAME, PARENT_ID, BOTTOM_LEVEL
FROM   [datavault].[SAT_PRODUCT]
WHERE  CURRENT_FLAG = 1
  AND (PRODUCT_ID = @NewId OR PARENT_ID = @NewId)
ORDER  BY BOTTOM_LEVEL, PRODUCT_NAME;

-- ---------------------------------------------------------------------------
-- Post-step (run separately): rebuild D_PRODUCT so the presentation layer
-- reflects the renamed category in any flattened columns.
--
--      EXEC [core].[sp_ProcessPresentation];
--
-- (D_PRODUCT itself stores BOTTOM_PRODUCT_ID only, so the category text is
-- already correct via MIDDLE_1_NAME / TOP_NAME from PRODUCT_NAME.)
-- ---------------------------------------------------------------------------
