# eTerminal Archiving Configuration

> This documents the actual archiving configuration found in the eTerminal `[Archive Database]` (production). The operation pattern documented here is stable — individual table configurations may change but the mechanism is consistent.
>
> For the shared architecture, stored procedures, key behaviors, and how-to guide, see the [Production Archiving overview](./production-archiving.md).

## Overview

- **Source:** `Navision` database (production)
- **Destination:** `[eterminal-archive.chs97qkefxud.ap-southeast-1.rds.amazonaws.com].Navision` (AWS RDS, Singapore)
- **Retention:** 7 days for all transactional tables
- **Schedule:** All jobs run `DAILY`, typically **after 10:00 PM** Philippine time
- **Prerequisite:** The `Navision.dbo.AutoProcessLogs` table must have a `'GEN-ACC-ENT-SUM'` entry for yesterday — the accounting batch must complete before archiving runs
- **Notifications:** Emails sent via `msdb.dbo.sp_send_dbmail` (profile: `eTerminal`) to `BSS@e-businessphil.ph` with CC to `itadmin@e-businessphil.ph`

---

## ARCHIVING_TABLE — Transactional Archiving Jobs

Each row defines one source table to be archived. All are `ACTIVE = 1`, `RUN_SCHEDULED = DAILY`.

### How the 7-Day Retention Works

For a `DAILY` schedule with `NO_MONTH_DAY = 7`, the stored procedure processes data that is exactly 7 days old. In effect, the source keeps the last 7 days of data, and everything older is moved to the archive. The process catches up one day at a time from the last processed date.

### Known Configured Tables (IDs 1-10)

| ID | Source Table | Date Column | Relation (Child Table) |
|---|---|---|---|
| 1 | `[E-Business Services Inc_$Branch Journal Line]` | `[Posting Date]` | MoneySerialNumber (via `[Document No_]`) |
| 2 | `[Expenses and Utilities]` | `[Posting Date]` | None |
| 3 | `[Miscellaneous]` | `[Transaction Date]` | None |
| 4 | `[Fund Transfer]` | `[Transfer Date]` | None |
| 5 | `[E-Business Services Inc_$AR Topsheet]` | `[TopSheet Date]` | None |
| 6 | `[E-Business Services Inc_$AR Main Vault]` | `[ARMV Date]` | None |
| 7 | `[E-Business Services Inc_$AR Topsheet to Main Vault]` | `[TopSheet Date]` | None |
| 8 | `[OR]` | `[Transaction Date]` | OR_Details (via `[OR Number]`) |
| 9 | `[OR_Registered]` | `[Transaction Date]` | None |
| 10 | `[CPR Journal Entry]` | `[Transaction Date]` | None |

There are 12 more configured tables beyond ID 10 (22 total). All follow the same pattern.

### Source Delete Behavior

- **19 tables** have `SOURCE_DELETE = 1` — rows are deleted from `Navision` production after successful archiving
- **3 tables** have `SOURCE_DELETE = 0` — rows are copied to archive but **kept** in production (these are likely tables shared with other systems or needed for longer-term reporting)

---

## ARCHIVING_TABLE_RELATION — Parent-Child Relationships

When a parent row is archived, matching child rows are archived together to maintain referential integrity. The process inserts child rows via an `INNER JOIN` on the parent table, then deletes the child rows from the source.

| ID | Child Table | Join Key | Parent(s) |
|---|---|---|---|
| 1 | `MoneySerialNumber` | `[Document No_]` | Branch Journal Line (ID 1) |
| 2 | `OR_Details` | `[OR Number]` | OR (ID 8) |
| 3 | `LOISeriesDetails` | `Series` | (table not shown in sample) |

**Example:** When `[OR]` rows are archived, the procedure also copies and deletes matching `OR_Details` rows via `[OR Number]`.

---

## ARCHIVING_UPDATE_TABLE — Reference Data Syncing

These tables are **synced** (copied or updated) to the archive server but **never deleted** from the source. They provide reference/lookup data the archive destination needs locally.

### Action Codes

| Code | Behavior | Use Case |
|---|---|---|
| `2` | **Copy (Insert only)** | Full table copy of new rows, like logs or upload series |
| `3` | **Update + Insert** | Incremental sync for reference tables that change (employees, clusters, dimensions) |

### Configured Tables (IDs 1-10)

| ID | Table | Action | Key Field | Notes |
|---|---|---|---|---|
| 1 | `[E-Business Services Inc_$Employee]` | Update+Insert (3) | `No_` | |
| 2 | `[Cash Advance]` | Insert (2) | `ID` | |
| 3 | `CDDUploadSeries` | Insert (2) | `Series` | |
| 4 | `CurrencyExchangeRate` | Insert (2) | `ID` | |
| 5 | `CustomerTransactionLogs` | Insert (2) | `ID` | |
| 6 | `Cluster` | Update+Insert (3) | `ID` | |
| 7 | `[Cluster Branch]` | Update+Insert (3) | `ID` | |
| 8 | `EmailAddressesNotification` | Update+Insert (3) | `ID` | |
| 9 | `[E-Business Services Inc_$Dimension Value]` | Update+Insert (3) | `Code` | Extra join: `[Dimension Code] = A.[Dimension Code]` |
| 10 | `[eTerminal]` | Update+Insert (3) | `eTerminalID` | |

There is 1 more configured table beyond ID 10 (11 total).

---

## Process Flow Diagrams

### 1. Gate & Setup — ARCHIVING_EXECUTE Entry Point

```mermaid
flowchart TD
    A["<b>SQL Agent Job</b><br/>calls ARCHIVING_EXECUTE"] --> B{"GEN-ACC-ENT-SUM<br/>completed yesterday?<br/><i>(Navision.AutoProcessLogs)</i>"}
    B -->|No| C["Send failure email<br/><i>Auto Process not yet completed</i>"]
    C --> D(["END"])
    B -->|Yes| E["Cursor loop:<br/>SELECT ID FROM ARCHIVING_TABLE<br/>WHERE ACTIVE = 1"]
    E --> F["<b>ARCHIVING_PROCESS(@ID)</b>"]
    F --> G["Read config from<br/>ARCHIVING_TABLE row"]
    G --> H["Calculate date range<br/>DAILY: today − NO_MONTH_DAY<br/>MONTHLY: last month"]
    H --> I{"Current time<br/>&lt; 10:00 PM?"}
    I -->|Yes| J["Skip to next day<br/>(wait for nightly window)"]
    J --> H
    I -->|No| K["<b>ARCHIVING_MATCHCOLUMNS</b><br/>Sync schema: source → dest<br/>(ALTER TABLE ADD missing cols)"]
    K --> L["<b>ARCHIVING_GETTABLECOLUMNS</b><br/>Get comma-separated column list<br/>(excludes timestamp)"]
    L --> M("Continue to<br/><b>Per-Table Processing</b>")
```

### 2. Procedure Call Hierarchy

```mermaid
flowchart LR
    subgraph Entry["Entry Points"]
        EXEC["ARCHIVING_EXECUTE"]
        UPEXEC["ARCHIVING_UPDATE_TABLE_EXECUTE"]
    end
    subgraph Engine["Core Engines"]
        PROC["ARCHIVING_PROCESS"]
        UPPROC["ARCHIVING_UPDATE_TABLE_PROCESS"]
    end
    subgraph Helpers["Shared Helpers"]
        GETCOLS["GETTABLECOLUMNS"]
        MATCHCOLS["MATCHCOLUMNS"]
    end
    subgraph Config["Config Tables"]
        AT["ARCHIVING_TABLE"]
        ATR["ARCHIVING_TABLE_RELATION"]
        AUT["ARCHIVING_UPDATE_TABLE"]
    end
    subgraph Logs["Log Tables"]
        LOGS["AutoProcessArchiveLogs"]
        APL["Navision.AutoProcessLogs"]
    end
    subgraph External["External"]
        DBMAIL["sp_send_dbmail"]
        DEST["eterminal-archive RDS"]
        SRC["Navision"]
    end

    EXEC -->|"guard: GEN-ACC-ENT-SUM"| PROC
    UPEXEC --> UPPROC
    PROC --> AT
    PROC --> ATR
    PROC --> GETCOLS
    PROC --> MATCHCOLS
    PROC --> LOGS
    PROC --> DBMAIL
    PROC -->|"INSERT/DELETE"| DEST
    PROC -->|"DELETE"| SRC
    UPPROC --> AUT
    UPPROC --> GETCOLS
    UPPROC --> MATCHCOLS
    UPEXEC --> APL
    UPPROC -->|"UPDATE/INSERT"| DEST
```

---

*Last updated: July 2026*
