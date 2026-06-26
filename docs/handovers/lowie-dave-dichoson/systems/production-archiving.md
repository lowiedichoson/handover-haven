# Production Archiving

## What It Is

Production Archiving is a set of **SQL Server Agent jobs** that automatically transfer transaction-relevant data from production databases into dedicated archive databases on separate archive servers. This prevents the production databases from accumulating historical data beyond their configured retention periods.

There are two separate archiving environments:

| Archive Environment | Source Systems | Retention Period | Archive Server |
|---|---|---|---|
| **eTerminal Archive** | eTerminal | **7 days** | eTerminal's dedicated archive server |
| **eSettlement / Voyager Archive** | eSettlement, Voyager | **37 days** | Voyager server's archive environment |

Only **transaction-relevant tables** are included in the archiving process — configuration, user, and reference tables stay in production.

> To review the archiving configuration, connect to the respective production server's `[Archive Database]`. Each one contains the stored procedures and table configurations that govern what gets moved and when.

## Key Tables in the `[Archive Database]`

| Table | What It Stores |
|---|---|
| `[dbo].[ARCHIVING_TABLE]` | **Archiving configuration table.** Each row defines one source table to be archived, including: source & destination catalog/schema/table names, date column used for filtering, relationship mappings (`relation id`, `relation field`), retention period in months or days, email recipients for notifications, whether the archiving is active or inactive, last run date, last error message (if any), processed last date, run schedule, and whether data is deleted from the source after archiving |

## Access

| What | How to Get It |
|---|---|
| **Server access** | Ask IT Administrators |
| **Database access** | Ask IT Administrators |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

*Last updated: June 2026*

