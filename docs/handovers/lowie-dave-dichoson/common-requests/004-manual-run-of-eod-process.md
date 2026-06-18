# Manual Run of EOD Process

## Who Asks

| | |
|---|---|
| **Requested by** | Accounting Department or initiated by ICTG |
| **How they ask** | Email, Sapphire Ticket, Walk-up |
| **Frequency** | Ad-hoc |

## What It Is

The manual triggering of EOD process is a rare occassion but it really happens sometimes. The reason we had encountered this before is because the PDS rate that this process requires was not configured when it tried to execute.

## When This Request Happens

- The accounting department was ***not able to configure the PDS rate*** on time in the `Navision` system where this process references its PDS rate.

## Prerequisites

- Access to `[Navision]` database of `Eterminal` system
- Permission to run scripts with `EXECUTE` keyword
- Completed Job Request Form (JRF) and Release Notes
- Approved JRF (usually Infra Team Lead and/or the concerned Department's Team Lead)

## Steps

### 1. Run the following script in the `[Navision]` database (Eterminal)

```sql
EXEC [dbo].[AutoCreateSalesBook]
EXEC [dbo].[AutoCreateAR]
EXEC [dbo].[AutoCloseAR]
EXEC [dbo].[emailARTopSheet]
EXEC [dbo].[AutoCreateMV]
EXEC [dbo].[AutoCloseMV]
EXEC [dbo].[emailARMainValut]
EXEC [dbo].[AutoForwardARMVEndingBalance]
EXEC [dbo].[CreateAccountingEntriesOR]
EXEC [dbo].[CreateAccountingEntriesNew]
EXEC [dbo].[GetCPRJournalEntrySummaryPerBranch]
```

### 2. Verify the execution of stored procedures

```sql
SELECT TOP 20
    *
FROM [dbo].[AutoProcessLogs]
ORDER BY [TransactionDate], [ID] DESC;
```

---