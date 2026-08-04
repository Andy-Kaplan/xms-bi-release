import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import sql from "mssql";

// ── Connection pool cache (one pool per database) ──────────
const pools = {};

const defaultDb = process.env.MSSQL_DATABASE || "master";

async function getPool(database) {
  const db = database || defaultDb;
  if (!pools[db]) {
    pools[db] = await sql.connect({
      server:   process.env.MSSQL_SERVER,
      database: db,
      user:     process.env.MSSQL_USER,
      password: process.env.MSSQL_PASSWORD,
      port:     parseInt(process.env.MSSQL_PORT || "1433"),
      options: {
        encrypt:                process.env.MSSQL_ENCRYPT === "true",
        trustServerCertificate: process.env.MSSQL_TRUST_CERT !== "false",
      },
    });
  }
  return pools[db];
}

async function runQuery(database, queryText) {
  const pool = await getPool(database);
  const result = await pool.request().query(queryText);
  return result.recordset;
}

// ── Shared param definitions ───────────────────────────────
const dbParam     = z.string().describe("Database name");
const schemaParam = z.string().default("dbo").describe("Schema name");

// ── MCP Server ─────────────────────────────────────────────
const server = new McpServer({
  name: "mcp-sqlserver",
  version: "1.0.0",
});

// Tool: list_databases
server.tool(
  "list_databases",
  "List all accessible user databases on the server",
  {},
  async () => {
    // Connect to master to enumerate databases
    const rows = await runQuery("master", `
      SELECT
        name            AS [Database],
        state_desc      AS [State],
        create_date     AS [Created]
      FROM sys.databases
      WHERE database_id > 4        -- exclude master, tempdb, model, msdb
        AND state_desc = 'ONLINE'
      ORDER BY name
    `);
    return { content: [{ type: "text", text: JSON.stringify(rows, null, 2) }] };
  }
);

// Tool: list_tables
server.tool(
  "list_tables",
  "List tables in a database schema, optionally filtered by name prefix",
  {
    database: dbParam,
    schema:   schemaParam,
    prefix:   z.string().default("").describe("Optional table name prefix (e.g. DL_)"),
  },
  async ({ database, schema, prefix }) => {
    const rows = await runQuery(database, `
      SELECT
        t.TABLE_NAME,
        p.row_count AS ROW_COUNT,
        COUNT(c.COLUMN_NAME) AS COLUMN_COUNT
      FROM INFORMATION_SCHEMA.TABLES t
      JOIN INFORMATION_SCHEMA.COLUMNS c
        ON c.TABLE_SCHEMA = t.TABLE_SCHEMA AND c.TABLE_NAME = t.TABLE_NAME
      LEFT JOIN (
        SELECT OBJECT_SCHEMA_NAME(object_id) AS s, OBJECT_NAME(object_id) AS n,
               SUM(row_count) AS row_count
        FROM sys.dm_db_partition_stats
        WHERE index_id IN (0,1)
        GROUP BY object_id
      ) p ON p.s = t.TABLE_SCHEMA AND p.n = t.TABLE_NAME
      WHERE t.TABLE_SCHEMA = '${schema}'
        AND t.TABLE_TYPE = 'BASE TABLE'
        ${prefix ? `AND t.TABLE_NAME LIKE '${prefix.replace(/'/g, "''")}%'` : ""}
      GROUP BY t.TABLE_NAME, p.row_count
      ORDER BY t.TABLE_NAME
    `);
    return { content: [{ type: "text", text: JSON.stringify(rows, null, 2) }] };
  }
);

// Tool: describe_table
server.tool(
  "describe_table",
  "Get column definitions for a table",
  {
    database: dbParam,
    schema:   schemaParam,
    table:    z.string().describe("Table name"),
  },
  async ({ database, schema, table }) => {
    const rows = await runQuery(database, `
      SELECT
        c.ORDINAL_POSITION AS [#],
        c.COLUMN_NAME      AS [Column],
        CASE
          WHEN c.CHARACTER_MAXIMUM_LENGTH IS NOT NULL
            THEN c.DATA_TYPE + '(' +
              CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX'
                   ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) END + ')'
          WHEN c.NUMERIC_PRECISION IS NOT NULL AND c.NUMERIC_SCALE IS NOT NULL
            THEN c.DATA_TYPE + '(' + CAST(c.NUMERIC_PRECISION AS NVARCHAR)
                 + ',' + CAST(c.NUMERIC_SCALE AS NVARCHAR) + ')'
          ELSE c.DATA_TYPE
        END                AS [Full Type],
        c.IS_NULLABLE      AS [Nullable],
        c.COLUMN_DEFAULT   AS [Default],
        CAST(ep.value AS NVARCHAR(MAX)) AS [Description]
      FROM INFORMATION_SCHEMA.COLUMNS c
      LEFT JOIN sys.extended_properties ep
        ON ep.major_id  = OBJECT_ID('${schema}.${table}')
        AND ep.minor_id = c.ORDINAL_POSITION
        AND ep.class = 1 AND ep.name = 'MS_Description'
      WHERE c.TABLE_SCHEMA = '${schema}'
        AND c.TABLE_NAME   = '${table}'
      ORDER BY c.ORDINAL_POSITION
    `);
    return { content: [{ type: "text", text: JSON.stringify(rows, null, 2) }] };
  }
);

// Tool: sample_table
server.tool(
  "sample_table",
  "Return the first N rows from a table",
  {
    database: dbParam,
    schema:   schemaParam,
    table:    z.string().describe("Table name"),
    rows:     z.number().int().min(1).max(100).default(5),
  },
  async ({ database, schema, table, rows }) => {
    const data = await runQuery(
      database,
      `SELECT TOP (${rows}) * FROM [${schema}].[${table}]`
    );
    return { content: [{ type: "text", text: JSON.stringify(data, null, 2) }] };
  }
);

// Tool: query
server.tool(
  "query",
  "Run a read-only SELECT query against a specific database",
  {
    database: dbParam,
    sql:      z.string().describe("The SELECT query to execute"),
  },
  async ({ database, sql: queryText }) => {
    const trimmed = queryText.trimStart().toUpperCase();
    if (!trimmed.startsWith("SELECT") && !trimmed.startsWith("WITH")) {
      return {
        content: [{ type: "text", text: "Error: only SELECT/WITH queries are permitted." }],
        isError: true,
      };
    }
    const data = await runQuery(database, queryText);
    return { content: [{ type: "text", text: JSON.stringify(data, null, 2) }] };
  }
);

// ── Write-access guard (DEV/TEST/UAT only; Prod hard-blocked) ─
// Two independent locks, both must pass:
//   1. MSSQL_ALLOW_WRITE === "true"  — set ONLY on the xms-bi-{dev,test,uat}
//      entries in .mcp.json. Absent on microservice-* and any Prod entry.
//   2. server name must NOT contain "prod" — belt-and-braces, independent of
//      the flag, so a Prod connection can never gain write even by mistake.
const MSSQL_SERVER  = process.env.MSSQL_SERVER || "";
const IS_PROD       = /prod/i.test(MSSQL_SERVER);
const WRITE_ENABLED = process.env.MSSQL_ALLOW_WRITE === "true" && !IS_PROD;

// Tool: execute (state-changing T-SQL — INSERT/UPDATE/DELETE/EXEC/DDL)
server.tool(
  "execute",
  "Run a state-changing T-SQL batch (INSERT/UPDATE/DELETE/EXEC/DDL) against a database. Enabled on DEV/TEST/UAT only; refuses Prod. Supports GO-separated batches. Prod changes must be run by a human via the PowerShell runner.",
  {
    database: dbParam,
    sql:      z.string().describe("The T-SQL to execute. May contain GO batch separators."),
  },
  async ({ database, sql: batchText }) => {
    if (IS_PROD) {
      return {
        content: [{ type: "text", text: `Error: execute is disabled for Prod (server '${MSSQL_SERVER}'). Run Prod changes manually via the PowerShell runner.` }],
        isError: true,
      };
    }
    if (!WRITE_ENABLED) {
      return {
        content: [{ type: "text", text: "Error: write access is not enabled for this connection (MSSQL_ALLOW_WRITE is not 'true'). This tool is enabled only on the xms-bi-dev/test/uat servers." }],
        isError: true,
      };
    }
    const pool = await getPool(database);
    // GO is a client batch separator, not valid T-SQL — split on it.
    const batches = batchText
      .split(/^\s*GO\s*;?\s*$/gim)
      .map(b => b.trim())
      .filter(b => b.length > 0);
    const out = [];
    for (let i = 0; i < batches.length; i++) {
      const r = await pool.request().batch(batches[i]);
      out.push({
        batch: i + 1,
        rowsAffected: r.rowsAffected,
        recordset: r.recordset ? r.recordset.slice(0, 50) : undefined,
      });
    }
    return { content: [{ type: "text", text: JSON.stringify({ server: MSSQL_SERVER, database, batchCount: batches.length, results: out }, null, 2) }] };
  }
);

// ── Start ──────────────────────────────────────────────────
const transport = new StdioServerTransport();
await server.connect(transport);