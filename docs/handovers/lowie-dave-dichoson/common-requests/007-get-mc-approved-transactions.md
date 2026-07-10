# Get MC Approved Transactions

## Who Asks

| | |
|---|---|
| **Requested by** | Treasury |
| **How they ask** | Email, Sapphire Ticket |
| **Frequency** | Ad-hoc |

## What It Is

MC (Money Change) transactions refer to currency exchange transactions processed in the eTerminal system. This query retrieves approved MC transactions where the customer requested a specific rate, resulting in a difference between the **Requested Rate** and the **Exchange Rate**. Treasury uses this data for benchmarking and historical analysis.

## Prerequisites

- Read-only access to the eTerminal archive environment
- Familiarity with the date range needed for the analysis
- The archive environment retains historical MC transaction data

## Steps

### 1. Declare parameters

Possible values for `@ApprovalMark`:

| Value | Status |
|:---:|---|
| `1` | Approved |
| `2` | Disapproved |
| `3` | Canceled |

```sql
DECLARE @ApprovalMark INT = 1;
DECLARE @DateFrom DATETIME = '20220101';
DECLARE @DateTo   DATETIME = '20221231';
```

### 2. Query for approved MC transactions

```sql
SELECT
    CONVERT(CHAR(10), a.[Posting Date], 111) [Transaction Date],
    a.[Transaction Type],
    a.[Transaction Sub Type],
    a.[User ID],
    a.[Unit Code (Dimension)] [Branch Code],
    TRIM(c.[Name]) [Branch Name],
    a.[Document No_],
	a.[Control No_],
    a.[Account Name],
    CAST(ROUND(ISNULL(a.[Exchange Rate], 0), 2) AS DECIMAL(18,2)) [Exchange Rate],
    CAST(ROUND(ISNULL(a.[Requested Rate], 0), 2) AS DECIMAL(18,2)) [Requested Rate],
    CAST(ROUND(ISNULL(a.[Principal Amount], 0), 2) AS DECIMAL(18,2)) [Principal Amount],
    CAST(ROUND(ISNULL(a.[Principal Amount (LCY)], 0), 2) AS DECIMAL(18,2)) [Principal Amount (LCY)],
    (CASE WHEN [Admin Approved] = 1 THEN 'APPROVED' ELSE '' END) [Approval Status]
FROM [E-Business Services Inc_$Branch Journal Line] a
INNER JOIN [E-Business Services Inc_$Dimension Value] c ON a.[Unit Code (Dimension)] = c.[Code]
WHERE [Admin Approved] = @ApprovalMark
AND [Posting Date] BETWEEN @DateFrom AND @DateTo
AND [Transaction Type] = 'MC'
AND [Adjustment ID] <> -1 -- excludes voided transactions
AND [Requested Rate] <> [Exchange Rate] -- only apply this condition if the requestor requires it
ORDER BY [Document No_] ASC;
```

### 3. Notes

- **`[Adjustment ID] <> -1`** — excludes voided transactions.
- **`[Admin Approved]`** — `1` = Approved, `2` = Disapproved, `3` = Canceled.
- Rate and amount columns are **rounded to 2 decimal places** via `ROUND(..., 2)`.
- The `RateDifference` can be computed manually as `[Exchange Rate] - [Requested Rate]`.
- This query joins to `[E-Business Services Inc_$Dimension Value]` to resolve the branch name from the branch code.

---

*Last updated: June 2026*
