# Transfer Bridge Entries to Navision

## Who Asks

| | |
|---|---|
| **Requested by** | Accounting or TCSG Department |
| **How they ask** | Email, Sapphire Ticket, Walk-up |
| **Frequency** | Ad-hoc |

## What It Is

Transferring the bridge entries to the Navision system is a crucial step of the daily processes of the TCSG & Accounting department. As of writing, the transfer is done automatically via SQL Job in the database, scheduled to run daily at 9:30 AM.

## Two Approaches to Transferring the Entries

There are two scenarios that lead to a manual transfer:

- **Reverse + Recreate** — you came from [reversing](000-reverse-bridge-entries.md) and [recreating](001-recreation-of-bridge-entries.md) because the initially generated entries were incorrect as validated by TCSG & Accounting.
- **Create only** — you came straight from [creating](001-recreation-of-bridge-entries.md) because no entries were generated to begin with.

## When This Request Happens
- The initial entries generated contain incorrect amounts as verified by TCSG & Accounting department.
- The automated process that does the transfer of entries failed for some reason, and you'd have to do it manually as a band-aid solution.

## Prerequisites

- Access to the Navision `172.30.0.210` server and `[EBIZ PROD DATABASE]` database in SQL Server Management Studio (SSMS)
- Access to execute stored procedures on `[EBIZ PROD DATABASE]`
- Completed Job Request Form (JRF) and Release Notes
- Approved JRF (usually Infra Team Lead and/or the concerned Department's Team Lead)

## Steps

> ⚠️ **Before you start**, determine the state of the existing entries:
>
> - **Not yet transferred to Navision?** Proceed with the steps of this request.
> - **Already in Navision?** Reverse the entries in Navision first so it's as if they never existed.
> - **Do this in a staging environment PRIOR** to proceeding in production environment.
> Once the above is resolved, proceed with the steps below.

### 1. Create a copy of the stored procedure `GetBridgeEntries`

The new copy of the stored procedure should have a date suffix for the transaction you're planning to transfer the bridge entries for. See example below.

```sql
-- Example: after the underscore (_), place the date
CREATE PROCEDURE [dbo].[GetBridgeEntries_20260616]
```

### 2. In the stored procedure, look for the variable `@TransactionDate`

```sql
IF EXISTS (
		SELECT TOP 1 TransactionDate
		FROM [EBIZ PROD DATABASE].[dbo].[UploadedEntries]
		WHERE [SourceData] = 'BRIDGE'
		)
BEGIN
	SELECT TOP 1 @TransactionDate = TransactionDate
	FROM [EBIZ PROD DATABASE].[dbo].[UploadedEntries]
	WHERE [SourceData] = 'BRIDGE'
	ORDER BY TransactionDate DESC

	SET @TransactionDate = dateadd(DD, 1, @TransactionDate)
END
ELSE
BEGIN
	SET @TransactionDate = convert(CHAR(8), getdate(), 112)
END
	
    -- hard-code a date value for the @TransactionDate variable 
    SET @TransactionDate = '20260616' -- update if needed
```

### 3. Add the `C` Prefix (Reverse + Recreate route only)

If you're coming from the **reverse + recreate** route, you need to add a `C` prefix to the `[DocumentNo]` column in the `INSERT...SELECT` block below (the reversal used `R`, the correction uses `C`). Look for this code block in the stored procedure:

If you're coming from the **create only** route, **skip this step** — no prefix is needed.

```sql
insert into [EBIZ PROD DATABASE].[dbo].[E-Business Services, Inc_$JournalVoucher]
	(
	[DocumentType]
	,[TransactionDate]
	,[DocumentNo]
	,[AccountType]
	,[AccountNo]
	,[Description]
	,[Amount]
	,[DimensionCode]
	,[ProductCode]
	,[CurrencyCode]
	,[ExchangeRate]
	,[Posted]
	,[brsaid]
	,[BranchSA]
	,[DeductedAmount]
	,[UserID]
	,[Rate Type]
	,[JournalType]
	,[VATIdentifier]
	,[JournalBatchName]
	,[GenPostingType]
	,[VATBusPostingGroup]
	,[VATProdPostingGroup]
	,[WHTBusPostingGroup]
	,[WHTProdPostingGroup]
	,[SourceDocumentType]
	,[GlobalDimensionCode])

SELECT
	[DocumentType]
	,[TransactionDate]
	,'C' + [DocumentNo] [DocumentNo] -- add C to identify the entries as the correct ones
	,[AccountType]
	,[AccountNo]
	,[Description]
	,SUM([Amount]) Amount
	,[DimensionCode]
	,[ProductCode]
	,[CurrencyCode]
	,[ExchangeRate]
	,[Posted]
	,[brsaid]
	,[BranchSA]
	,[DeductedAmount]
	,[UserID]
	,[Rate Type]
	,'GENERAL JOURNAL'[JournalType]
	,''[VATIdentifier]
	,''[JournalBatchName]
	,''[GenPostingType]
	,''[VATBusPostingGroup]
	,''[VATProdPostingGroup]
	,''[WHTBusPostingGroup]
	,''[WHTProdPostingGroup]
	,''[SourceDocumentType]
	,''[GlobalDimensionCode]
FROM [54.251.109.171].[BridgeDb].[dbo].[JournalVoucherNEW]
where TransactionDate = @TransactionDate
GROUP BY
	[DocumentType]
	,[TransactionDate]
	,[DocumentNo]
	,[AccountType]
	,[AccountNo]
	,[Description]
	,[DimensionCode]
	,[ProductCode]
	,[CurrencyCode]
	,[ExchangeRate]
	,[Posted]
	,[brsaid]
	,[BranchSA]
	,[DeductedAmount]
	,[UserID]
	,[Rate Type]
```

### 4. Execute the stored procedure

Executing the script will create a new stored procedure named `dbo.GetBridgeEntries_20260616`.
Execute the script by pressing F5 in SSMS or clicking the Play button.

> *Make sure to change the **`ALTER`** to **`CREATE`** keyword so you can avoid the error that says you cannot alter a non-existent stored procedure.*

### 5. Verify the stored procedure is created

Once done with the execution of the script, refresh the server connection in Object Explorer.
Navigate to the `[EBIZ PROD DATABASE]` database, look for Programmability -> Stored Procedures -> and locate your stored procedure here.

### 6. Execute the script in the production environment

The server / database administrator will run the script in the production environment with your assistance. This will create the bridge entries for the target date if executed properly.

### 7. Post-deployment verification

You can verify the successful execution of the script in two ways:

a. Run the following query to check if the created entries now exist in the `dbo.[E-Business Services, Inc_$JournalVoucher]` table.

```sql
SELECT 
    *
FROM [dbo].[E-Business Services, Inc_$JournalVoucher]
WHERE [TransactionDate] = '20260616'; -- update the date if needed
AND [DocumentType] = 'Bridge' -- only fetch bridge entries
```

The above query will return the bridge entries created for the date selected.

b. Run the following query to check if the stored procedure created a log entry in the `[dbo].[UploadedEntries]` table.

```sql
SELECT
    *
FROM [dbo].[UploadedEntries]
WHERE [TransactionDate] = '20260616'; -- update the date if needed
```

At the end of the stored procedure `dbo.GetBridgeEntries`, it inserts a log entry into this table. If the script executed successfully, it will be returned as the result of the above query.

### 7. Next steps

Next steps are handled by accounting department, they will handle validating and posting the bridge entries in Navision.

## What Can Go Wrong

| Symptom | Likely Cause | What to Do |
|---|---|---|
| Stored procedure runs but no entries appear in `[E-Business Services, Inc_$JournalVoucher]` | `@TransactionDate` wasn't hard-coded correctly | Double-check the date format is `YYYYMMDD` and that the `SET @TransactionDate` line is placed after the `END` of the `ELSE` block |
| "Permission denied" or "Could not find stored procedure" | Wrong database context in SSMS | Make sure the active database is set to `[EBIZ PROD DATABASE]` (use the dropdown in the SSMS toolbar, or add `USE [EBIZ PROD DATABASE]` at the top of your script) |
| Entries already exist for that date | Someone already ran the procedure for this date | Check `dbo.UploadedEntries` first. If entries exist, coordinate with Accounting before re-running |

## Escalation

If you can't resolve this after following the steps above:

| Priority | Contact | Role |
|---|---|---|
| 1st | Roy Labanon | Developer Team Leader |
| 2nd | Geoffrey Rendon | Analyst Programmer |
| 3rd | Daryl Cavan | Database Administrator |

---
*Last updated: June 2026*
