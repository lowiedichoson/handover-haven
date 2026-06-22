# EOD Process

## Overview

The EOD (End-of-Day) Process is a **SQL job** that runs on the eTerminal server. It finalizes all data for the current date, covering branch transactions, official receipts, TCRs, BCRs, archiving, and the creation of accounting entries. This serves as the final action intended for the current date's data.

**Schedule:** Daily at **10:30 PM**  
**Estimated Duration:** Finishes around **11:10 PM onwards**

---

## Steps

The EOD process executes the following stored procedures in sequence. The steps are grouped into two phases: **TCR/BCR finalization** (Steps 1–8) and **Accounting entries creation** (Steps 9–11).

### Phase 1: TCR / BCR Finalization

| # | Stored Procedure | What It Does | Key Tables Affected |
|---|---|---|---|
| 1 | `[dbo].[AutoCreateSalesBook]` | Creates sales book entries from raw transaction data | `[dbo].[E-Business Services Inc_$Branch Journal Line]` |
| 2 | `[dbo].[AutoCreateAR]` | Auto creates teller's cash report | `[dbo].[E-Business Services Inc_$AR Topsheet]` |
| 3 | `[dbo].[AutoCloseAR]` | Closes the teller's cash report (TCR) for the day, finalizing all teller-level entries | `[dbo].[E-Business Services Inc_$AR Topsheet]`, `[dbo].[E-Business Services Inc_$AR Topsheet to Main Vault]` |
| 4 | `[dbo].[emailARTopSheet]` | Sends the TCR (Teller Cash Report) `.xlsx` report via email to relevant recipients | *(Read-only — queries AR Topsheet data)* |
| 5 | `[dbo].[AutoCreateMV]` | Auto creates branch's cash report | `[dbo].[E-Business Services Inc_$AR Main Vault]` |
| 6 | `[dbo].[AutoCloseMV]` | Closes the branch cash report (BCR) for the day, finalizing all branch-level entries | `[dbo].[E-Business Services Inc_$AR Main Vault]`, `[dbo].[E-Business Services Inc_$AR Topsheet to Main Vault]` |
| 7 | `[dbo].[emailARMainValut]` | Sends the BCR (Branch Cash Report) `.xlsx` report via email to relevant recipients | *(Read-only — queries AR Main Vault data)* |
| 8 | `[dbo].[AutoForwardARMVEndingBalance]` | Forwards the ending balance from the current day's Main Vault to the next day as the opening balance | `[dbo].[E-Business Services Inc_$AR Main Vault]` |

### Phase 2: Accounting Entries Creation

| # | Stored Procedure | What It Does | Key Tables Affected |
|---|---|---|---|
| 9 | `[dbo].[CreateAccountingEntriesOR]` | Creates CPR journal entries from OR (official receipt) data | `[dbo].[OR]` → `[dbo].[CPR Journal Entry]` |
| 10 | `[dbo].[CreateAccountingEntriesNew]` | Creates CPR journal entries from raw transaction data | `[dbo].[E-Business Services Inc_$Branch Journal Line]` → `[dbo].[CPR Journal Entry]` |
| 11 | `[dbo].[GetCPRJournalEntrySummaryPerBranch]` | Summarizes and groups individual CPR entries by branch, then populates the results into the `[dbo].[E-Business Services Inc_$JournalVoucher]` table for Navision posting | `[dbo].[CPR Journal Entry]` → `[dbo].[E-Business Services Inc_$JournalVoucher]` |

---

## Verification

After the EOD process completes, you can verify its execution by querying the process logs:

```sql
SELECT TOP 20
    *
FROM [dbo].[AutoProcessLogs]
ORDER BY [TransactionDate], [ID] DESC;
```

---

*Last updated: June 2026*
