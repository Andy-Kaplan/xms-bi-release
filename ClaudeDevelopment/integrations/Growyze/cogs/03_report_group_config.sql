/*  Categories to break out by subcategory in REPORT_GROUP.
    Pipe-delimited so bucket names containing commas still work.
    Raddish's catch-all bucket is "Can't Live Without It"; other Growyze
    customers will name theirs differently - this is why it is config.

    RUN THIS AGAINST THE CLIENT (ORGANISATION) DATABASE, NOT `core`.
    GlobalParameters is a per-database deployable object
    (8_Deployment_Objects_Records.sql:25, seeded per-database at line 2432), and
    02_cogs_period_build.sql reads it with a TWO-part name from inside a
    query_sql that sp_ProcessPresentation executes in the calling client
    database's context. A row written to the central `core` database is
    therefore never seen by the build.

    THREE STATES, AND WHY THEY MUST BE TOLD APART (final-review C1).
    The previous wording here - "an empty or missing value means no break-out" -
    described two of them as one, which made a mis-deployed config look like a
    configured choice:
      1. Parameter set in THIS database   -> break-out applies; the fact holds
         rows where REPORT_GROUP <> CATEGORY. This is the intended state here.
      2. Parameter row PRESENT in THIS database with an EMPTY value -> no
         break-out by choice; REPORT_GROUP = CATEGORY everywhere. A legitimate
         configuration for a customer with no catch-all bucket, and spec
         section 6 intends it to be expressible ("adding a customer's bucket is
         a config row, not a code change" - so is having none).
         HOW TO EXPRESS IT: keep the MERGE, set ParameterValue to N''. Do NOT
         express it by deleting the row or by not running this script - an
         ABSENT row is indistinguishable from state 3 below, and check 11
         reports it as FAIL for exactly that reason. Present-and-empty is a
         statement; absent is an accident.
      3. Parameter present but in the WRONG database -> looks identical to (2)
         from every card, every filter and eight of the ten original verify
         checks. STRING_SPLIT(NULL,'|') returns zero rows rather than raising,
         so nothing fails; the whole design section 6 category model just
         quietly does nothing.
    States (2) and (3) are indistinguishable FROM THE FACT ALONE - both leave
    REPORT_GROUP = CATEGORY on every row - which is why verify check 11 does not
    look only at the fact. It reads this parameter IN THE CLIENT DATABASE and
    tests row EXISTENCE separately from value emptiness: a present-but-empty row
    is state 2 (INFO), an absent row is state 3 (FAIL), and a present non-empty
    row is state 1, which it then confirms against the fact. Do not soften that
    check, and do not collapse this comment back into a single "empty or missing
    means no break-out" line - that wording is what made the defect look like a
    choice in the first place.
*/
MERGE INTO [core].[GlobalParameters] AS tgt
USING (VALUES (N'COGS_REPORT_GROUP_BREAKOUT')) AS src (ParameterKey)
    ON tgt.[ParameterKey] = src.[ParameterKey]
WHEN MATCHED THEN UPDATE SET
     [ParameterValue] = N'Can''t Live Without It',
     [Category] = N'GROWYZE_COGS',
     [Description] = N'Pipe-delimited list of CATEGORY values to break out by SUBCATEGORY in F_COGS_PERIOD.REPORT_GROUP. Must live in the ORGANISATION database, not core - the build reads it two-part. Deliberately empty means no break-out; absent here while set elsewhere means the config is in the wrong database (verify check 11).',
     [ModifiedDate] = GETDATE(),
     [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN INSERT ([ParameterKey], [ParameterValue], [Category], [Description])
VALUES (N'COGS_REPORT_GROUP_BREAKOUT', N'Can''t Live Without It', N'GROWYZE_COGS', N'Pipe-delimited list of CATEGORY values to break out by SUBCATEGORY in F_COGS_PERIOD.REPORT_GROUP. Must live in the ORGANISATION database, not core - the build reads it two-part. Deliberately empty means no break-out; absent here while set elsewhere means the config is in the wrong database (verify check 11).');
