/* ============================================================================
   O19 · 02 — Provision the two Ibis hotel orgs
   ----------------------------------------------------------------------------
   Run against : core                    Envs: Test, UAT, Prod
   Executed by : Andy, via the PowerShell runner
   Idempotent  : guarded — AddOrganisation RAISERRORs if the OrganisationCode
                 already exists, so each call is wrapped in IF NOT EXISTS.

   DECISIONS baked in (see DEPLOY.txt):
     · GUID reuse ......... the SAME Prod-microservice GUID is used as
                            @OrganisationCode in ALL THREE envs, so each BI org
                            aligns with its single canonical microservice org.
     · Fixed prefix ....... @Prefix is FIXED (not the live provisioning date)
                            and identical in every env. Combined with GUID
                            reuse this makes DatabaseName — and therefore the
                            O10 kv_prefix — deterministic and env-independent,
                            so Integrations O10 step 1 (KV secrets) can proceed
                            without waiting for provisioning. DatabaseName =
                            @Prefix + '_XMS_' + @OrganisationCode.

   ┌──────────────────────────────────────────────────────────────────────┐
   │  EDIT THIS BLOCK BEFORE RUNNING — values come from the microservice    │
   │  Prod Organisations table (no Prod microservice MCP; pull at exec).    │
   └──────────────────────────────────────────────────────────────────────┘ */
DECLARE @Prefix     nvarchar(255)    = N'20260722';                             -- FIXED, reused in every env
DECLARE @Ibis1Name  nvarchar(255)    = N'Ibis Heathrow';
DECLARE @Ibis1Code  uniqueidentifier = N'7CE02464-9A7E-F111-B337-002248A1EC3D'; -- microservice Prod GUID
DECLARE @Ibis2Name  nvarchar(255)    = N'Ibis Gloucester Road';
DECLARE @Ibis2Code  uniqueidentifier = N'67CA4E6F-9A7E-F111-B337-002248A1EC3D';
/* ---------------------------------------------------------------------------- */

SET NOCOUNT ON;

IF @Ibis1Code IS NULL OR @Ibis2Code IS NULL
BEGIN
    RAISERROR('Fill @Ibis1Code / @Ibis2Code (and names) before running.', 16, 1);
    RETURN;
END

/* Ibis #1 */
IF NOT EXISTS (SELECT 1 FROM [core].[Organisations] WHERE [OrganisationCode] = @Ibis1Code)
    EXEC [core].[AddOrganisation]
         @OrganisationName         = @Ibis1Name,
         @OrganisationPrefix       = @Prefix,
         @OrganisationCode         = @Ibis1Code,
         @CreateDatabaseImmediately = 1,
         @Notes = N'Ibis hotel — Growyze + Mews (O19). GUID reused across Test/UAT/Prod.';
ELSE
    PRINT '>> Ibis #1 already present — skipped.';

/* Ibis #2 */
IF NOT EXISTS (SELECT 1 FROM [core].[Organisations] WHERE [OrganisationCode] = @Ibis2Code)
    EXEC [core].[AddOrganisation]
         @OrganisationName         = @Ibis2Name,
         @OrganisationPrefix       = @Prefix,
         @OrganisationCode         = @Ibis2Code,
         @CreateDatabaseImmediately = 1,
         @Notes = N'Ibis hotel — Growyze + Mews (O19). GUID reused across Test/UAT/Prod.';
ELSE
    PRINT '>> Ibis #2 already present — skipped.';

/* Confirm — DatabaseStatus should progress to ACTIVE once the MI database is up */
SELECT OrganisationID, OrganisationName, OrganisationCode, DatabaseName, DatabaseStatus
FROM   [core].[Organisations]
WHERE  OrganisationCode IN (@Ibis1Code, @Ibis2Code)
ORDER  BY OrganisationName;
