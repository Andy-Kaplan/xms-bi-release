"""Generate a core.DeploymentObjects registration script from plain T-SQL body files.

Hand-doubling quotes across long object definitions is error-prone, so each object's
definition is kept as plain readable T-SQL and the escaped registration script is
generated from a declarative manifest.

Usage:  python build_registration.py <manifest.json>

Manifest shape:
{
  "out": "01_event_tables_deployment_objects.sql",
  "header": "one-line description of the file",
  "notes": ["optional extra comment lines"],
  "objects": [
    {"name": "EVENT_OUTBOX", "type": "TABLE", "order": 109,
     "category": "Core Tables", "body": "01a_event_outbox_body.sql",
     "description": "no single quotes allowed here"}
  ]
}
"""
import io
import json
import re
import sys

# A genuine trailing GO batch separator: GO as the only token on its own
# line (optionally surrounded by whitespace), not any word ending in "go"
# such as CARGO.
TRAILING_GO_RE = re.compile(r"(?im)^[ \t]*GO[ \t]*$")

DROP_BY_TYPE = {
    "TABLE": "DROP TABLE {SCHEMA}.[{name}];",
    "PROCEDURE": "DROP PROCEDURE {SCHEMA}.[{name}];",
    "FUNCTION": "DROP FUNCTION {SCHEMA}.[{name}];",
}

FILE_HEADER = """-- =============================================================================
-- {header}
-- =============================================================================
-- GENERATED FILE - do not edit by hand.
-- Regenerate with:  python build_registration.py {manifest}
-- Source of truth for each object definition is its body file:
--
{bodies}{notes}--
-- Deploy to the CORE database only; objects reach org DBs via the rollout script.
-- Idempotent and re-runnable.
-- =============================================================================

SET NOCOUNT ON;
GO
"""

OBJECT_BLOCK = """
-- -----------------------------------------------------------------------------
-- {name} ({otype}, execution order {order})
-- Body: {body}
-- -----------------------------------------------------------------------------
DECLARE @Script NVARCHAR(MAX) = N'{escaped}';
DECLARE @Drop   NVARCHAR(MAX) = N'{drop}';
DECLARE @Desc   NVARCHAR(500) = N'{description}';

MERGE INTO [core].[DeploymentObjects] AS tgt
USING (VALUES (N'{name}', N'{otype}')) AS src (ObjectName, ObjectType)
ON tgt.ObjectName = src.ObjectName AND tgt.ObjectType = src.ObjectType
WHEN MATCHED THEN
    UPDATE SET
        ExecutionOrder = {order},
        Category       = N'{category}',
        Description    = @Desc,
        CreationScript = @Script,
        DropScript     = @Drop,
        IsActive       = 1,
        ModifiedDate   = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ObjectName, ObjectType, ExecutionOrder, Category, Description,
            CreationScript, DropScript, IsActive, CreatedDate)
    VALUES (N'{name}', N'{otype}', {order}, N'{category}', @Desc,
            @Script, @Drop, 1, GETDATE());

PRINT 'DeploymentObjects: {name} registered (order {order})';
GO
"""


def build(manifest_path):
    m = json.loads(io.open(manifest_path, encoding="utf-8").read())
    objects = m["objects"]

    bodies = "".join(
        "--   {:<16} {:>3}  <- {}\n".format(o["name"], o["order"], o["body"]) for o in objects
    )
    notes = "".join("-- {}\n".format(n) for n in m.get("notes", []))

    out = FILE_HEADER.format(
        header=m["header"], manifest=manifest_path, bodies=bodies, notes=notes
    )

    for o in objects:
        body = io.open(o["body"], encoding="utf-8").read().rstrip()
        last_line = body.splitlines()[-1] if body else ""
        if TRAILING_GO_RE.match(last_line):
            raise SystemExit(
                "{}: body must not end with GO - it is executed via EXEC().".format(o["body"])
            )
        for field in ("description", "category", "name"):
            if "'" in o[field]:
                raise SystemExit(
                    "{}: {} must not contain a single quote.".format(o["name"], field)
                )
        if o["type"] not in DROP_BY_TYPE:
            raise SystemExit("{}: unsupported type {}".format(o["name"], o["type"]))

        drop = DROP_BY_TYPE[o["type"]].replace("{name}", o["name"])

        out += OBJECT_BLOCK.format(
            name=o["name"],
            otype=o["type"],
            order=o["order"],
            category=o["category"],
            body=o["body"],
            description=o["description"],
            escaped=body.replace("'", "''"),
            drop=drop.replace("'", "''"),
        )

    io.open(m["out"], "w", encoding="utf-8", newline="\n").write(out)
    print("wrote {} ({} chars, {} object(s))".format(m["out"], len(out), len(objects)))
    return m["out"]


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    build(sys.argv[1])


if __name__ == "__main__":
    main()
