# Re/create Bridge Entries

## Who Asks

| | |
|---|---|
| **Requested by** | Accounting or TCSG Department|
| **How they ask** | Email, Sapphire Ticket, Walk-up |
| **Frequency** | Ad-hoc |

## What It Is

At the time of writing, accounting requires the bridge entries to be ready for posting in the Navision system. Without them, their standard operating procedure is incomplete for the day. Bridge entries are automatically created from the Esettlement system via a SQL Job in the database.

## When This Request Happens
- The initial entries generated are incorrect as verified by TCSG & Accounting department.
- The automated process that does the creation of entries failed for some reason, and you'd have to do it manually as a band-aid solution.

## Prerequisites

- Access to the Esettlement server and `BridgeDb` database in SQL Server Management Studio (SSMS)
- Access to execute stored procedures on `BridgeDb`
- Completed Job Request Form (JRF) and Release Notes
- Approved JRF (usually Infra Team Lead and/or the concerned Department's Team Lead)

## Steps

> ⚠️ **Before you start**, determine the state of the existing entries:
>
> - **Not yet transferred to Navision?** Roll back that date's data first using the Rollback module in Esettlement.
> - **Already in Navision?** Reverse the entries in Navision first so it's as if they never existed.
> - **Do this in a staging environment PRIOR** to proceeding in production environment.
> Once the above is resolved, proceed with the steps below.

### 1. Create a new copy of the stored procedure `txnCreateActngEntries`

The new copy of the stored procedure should have a date suffix for the transaction you're planning to create the bridge entries for. See example below.

```sql
-- Example: after the underscore (_), place the date
CREATE PROCEDURE [dbo].[txnCreateActngEntries_20260616]
```

### 2. In the stored procedure, look for the variable `@varRepDate`

```sql
-- This is an actual code block from the stored procedure, look for it.
IF EXISTS (
		SELECT TOP 1 TransactionDate
		FROM [CreatedEntries]
		WHERE [SourceData] = 'BRIDGE'
		)
BEGIN
	SELECT TOP 1 @varRepDate = TransactionDate
	FROM [dbo].[CreatedEntries]
	WHERE [SourceData] = 'BRIDGE'
	ORDER BY TransactionDate DESC

	SET @varRepDate = dateadd(DD, 1, @varRepDate)
END
ELSE
BEGIN
	SET @varRepDate = convert(CHAR(8), getdate(), 112)
END

-- This is where you'll add a hard-coded value for @varRepDate
SET @varRepDate = '20260616'
```

### 3. Execute the stored procedure

Executing the script will create a new stored procedure named `dbo.txnCreateActngEntries_20260616`.
Execute the script by pressing F5 in SSMS or clicking the Play button.

### 4. Verify the stored procedure is created

Once done with the execution of the script, refresh the server connection in Object Explorer.
Navigate to the `BridgeDb` database, look for Programmability -> Stored Procedures -> and locate your stored procedure here.

### 5. Execute the script in the production environment

The server / database administrator will run the script in the production environment with your assistance. This will create the bridge entries for the target date if executed properly.

### 6. Post-deployment verification

You can verify the successful execution of the script in two ways:

a. Run the following query to check if the created entries now exist in the `dbo.JournalVoucherNEW` table.

```sql
SELECT 
    *
FROM [dbo].[JournalVoucherNEW]
WHERE [TransactionDate] = '20260616'; -- update the date if needed
```

The above query will return the bridge entries created for the date selected.

b. Run the following query to check if the stored procedure created a log entry in the `dbo.CreatedEntries` table.

```sql
SELECT
    *
FROM [dbo].[CreatedEntries]
WHERE [TransactionDate] = '20260616'; -- update the date if needed
```

At the end of the stored procedure `dbo.txnCreateActngEntries`, it inserts a log entry into this table. If the script executed successfully, it will be returned as the result of the above query.

### 7. Next steps

After the bridge entries are created, the next step is to transfer them to the Navision system. See [Transfer Bridge Entries to Navision](002-transfer-entries-to-navision.md).

## What Can Go Wrong

| Symptom | Likely Cause | What to Do |
|---|---|---|
| Stored procedure runs but no entries appear in `JournalVoucherNEW` | `@varRepDate` wasn't hard-coded correctly | Double-check the date format is `YYYYMMDD` and that the `SET @varRepDate` line is placed after the `END` of the `ELSE` block |
| "Permission denied" or "Could not find stored procedure" | Wrong database context in SSMS | Make sure the active database is set to `BridgeDb` (use the dropdown in the SSMS toolbar, or add `USE [BridgeDb]` at the top of your script) |
| Entries already exist for that date | Someone already ran the procedure for this date | Check `dbo.CreatedEntries` first. If entries exist, coordinate with Accounting before re-running |

## Escalation

If you can't resolve this after following the steps above:

| Priority | Contact | Role |
|---|---|---|
| 1st | Roy Labanon | Developer Team Leader |
| 2nd | Geoffrey Rendon | Analyst Programmer |
| 3rd | Daryl Cavan | Database Administrator |

---