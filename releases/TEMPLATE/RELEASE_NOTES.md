# Release v{X.Y} — {Title}

**Date:** YYYY-MM-DD
**Author:** {name}
**Rollback Tier:** {1 | 2 | 3}

---

## Summary

{Brief description of what this release contains and why.}

## Changes

### Core Platform
- {Change description} — `{script_name}.sql`

### Integration: {IntegrationName} (if applicable)
- {Change description} — `{script_name}.sql`

### Microservice Report DB (if applicable)
- {Change description} — `ms_{script_name}.sql`

## Per-Org Steps Required

- [ ] sp_DeployObjects (if deployment object records changed)
- [ ] sp_GenerateDataVaultTables (if new DV entities added)
- [ ] Targeted presentation table creation (if new presentation tables added)
- [ ] UploadEntityMappings for {integration} (if entity mappings changed)

## Document Sync

- [ ] {List docs updated as part of this release}

## Rollback

**Tier {N}:**

{For Tier 1: "Re-run sp_DeployObjects with previous DeploymentObjects records."}
{For Tier 2: Provide specific compensating SQL to revert data record changes.}
{For Tier 3: "Restore from backup taken at YYYY-MM-DD HH:MM before script execution."}

## Validation Checklist

- [ ] All delta scripts executed without error
- [ ] sp_DeployObjects run for all active orgs (if applicable)
- [ ] UploadEntityMappings called for affected integrations (if applicable)
- [ ] sp_GenerateDataVaultTables run for all active orgs (if new entities)
- [ ] Spot-check vis cards in frontend (Test/UAT/Prod only)
- [ ] Confirm data pipeline runs successfully after changes
- [ ] Document sync completed (if applicable)
- [ ] Rollback steps documented above
