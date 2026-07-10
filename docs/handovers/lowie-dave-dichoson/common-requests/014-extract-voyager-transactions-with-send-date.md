# Extract Voyager Transactions with Send Date

## Who Asks

| | |
|---|---|
| **Requested by** | Treasury |
| **How they ask** | Email, Sapphire Ticket |
| **Frequency** | Ad-hoc |

## What It Is

Treasury requests a detailed extract of Western Union payout transactions from Voyager, including their **send date** information. The query pulls from `[Voyager].[dbo].[txnEntry]`, joined to `nacAccount` and `nacLocation` to resolve the location name, and is filtered by the **settlement date** (`repdate`) range for the payout leg of transactions (`SendPayIndicator = 'P'`).

## Key Date Columns

Each transaction carries three distinct dates. Understanding what each represents is essential to interpreting the extract correctly:

| Column | Alias | Meaning |
|---|---|---|
| `RecDateUS` | `RecordedDate` | When the transaction was **initiated** |
| `PayDateUS` | `PayoutDate` | When it was **paid out / received** by the receiver |
| `repdate` | — | When it was **settled to us by Western Union** (drives the filter range) |

## Prerequisites

- Read-only access to the Voyager database
- Working knowledge of T-SQL
- The date range needed for the extract (in `yyyymmdd` format)

## Steps

### 1. Declare parameters

Dates are stored as integers in `yyyymmdd` format. Set the `repdate` (settlement) range for the extract:

```sql
DECLARE @DateFrom INT = 20260101;
DECLARE @DateTo INT = 20260131;
```

### 2. Query for payout transactions

```sql
SELECT 
	a.[ID]
	,c.[Name]
	,a.[Account]
	,a.[TxnDateUS]
	,a.[TxnDateLOC]
	,a.[SendPayIndicator]
	,a.[Direction]
	,a.[Adjustment_ID]
	,CAST(a.[RecDateUS] AS VARCHAR(8)) as [RecordedDate]
	,CAST(
        RIGHT('0' + CAST(a.[RecDateUSHour] AS VARCHAR(2)), 2) + ':' + 
        RIGHT('0' + CAST(a.[RecDateUSMinutes] AS VARCHAR(2)), 2) 
    AS TIME(0)) AS [RecordedTime]
	,CAST(a.[PayDateUS] AS VARCHAR(8)) AS [PayoutDate]
	,CAST(
        RIGHT('0' + CAST(a.[PayDateUSHour] AS VARCHAR(2)), 2) + ':' + 
        RIGHT('0' + CAST(a.[PayDateUSMinutes] AS VARCHAR(2)), 2) 
    AS TIME(0)) AS [PayoutTime]
	,a.[SetDateUS]
	,a.[SetDateUSHour]
	,a.[SetDateUSMinutes]
	,a.[RecDateLOC]
	,a.[PayDateLOC]
	,a.[SetDateLOC]
	,a.[AgentSurrogate]
	,a.[RecCountryCode]
	,a.[PayCountryCode]
	,a.[IntendedPayCountryCode]
	,a.[RecCurrencyCode]
	,a.[PayCurrencyCode]
	,a.[IntraAgentAccount]
	,a.[FixedIndicator]
	,a.[ProductCode]
	,a.[ProductGroup]
	,a.[Status]
	,a.[RecPrincipalUSD]
	,a.[TotalChargesUSD]
	,a.[BasicChargesUSD]
	,a.[DeliveryChargesUSD]
	,a.[AdditionalChargesUSD]
	,a.[PhoneNotificationChargesUSD]
	,a.[MessageChargesUSD]
	,a.[ClearPrincipalUSD]
	,a.[ClearChargesUSD]
	,a.[ClearFXUSD]
	,a.[TaxesUSD]
	,a.[Tax1USD]
	,a.[Tax2USD]
	,a.[Tax3USD]
	,a.[PayPrincipalUSD]
	,a.[ShareOfChargesUSD]
	,a.[ShareOfFXUSD]
	,a.[RecPrincipalREC]
	,a.[TotalChargesREC]
	,a.[BasicChargesREC]
	,a.[DeliveryChargesREC]
	,a.[AdditionalChargesREC]
	,a.[PhoneNotificationChargesREC]
	,a.[MessageChargesREC]
	,a.[ClearPrincipalREC]
	,a.[ClearChargesREC]
	,a.[ClearFXREC]
	,a.[TaxesREC]
	,a.[Tax1REC]
	,a.[Tax2REC]
	,a.[Tax3REC]
	,a.[PayPrincipalREC]
	,a.[ShareOfChargesREC]
	,a.[ShareOfFXREC]
	,a.[RecPrincipalLOC]
	,a.[TotalChargesLOC]
	,a.[BasicChargesLOC]
	,a.[DeliveryChargesLOC]
	,a.[AdditionalChargesLOC]
	,a.[PhoneNotificationChargesLOC]
	,a.[MessageChargesLOC]
	,a.[ClearPrincipalLOC]
	,a.[ClearChargesLOC]
	,a.[ClearFXLOC]
	,a.[TaxesLOC]
	,a.[Tax1LOC]
	,a.[Tax2LOC]
	,a.[Tax3LOC]
	,a.[PayPrincipalLOC]
	,a.[ShareOfChargesLOC]
	,a.[ShareOfFXLOC]
	,a.[RecPrincipalPAY]
	,a.[TotalChargesPAY]
	,a.[BasicChargesPAY]
	,a.[DeliveryChargesPAY]
	,a.[AdditionalChargesPAY]
	,a.[PhoneNotificationChargesPAY]
	,a.[MessageChargesPAY]
	,a.[ClearPrincipalPAY]
	,a.[ClearChargesPAY]
	,a.[ClearFXPAY]
	,a.[TaxesPAY]
	,a.[Tax1PAY]
	,a.[Tax2PAY]
	,a.[Tax3PAY]
	,a.[PayPrincipalPAY]
	,a.[ShareOfChargesPAY]
	,a.[ShareOfFXPAY]
	,a.[RecPayoutRate]
	,a.[PayPayoutRate]
	,a.[RecSettlementRate]
	,a.[PaySettlementRate]
	,a.[Spread]
	,a.[TerminalID]
	,a.[OperatorID]
	,a.[AdditionalCheckIndicator]
	,a.[CheckNumber1]
	,a.[CheckNumber2]
	,a.[CheckNumber3]
	,a.[CheckVoid1]
	,a.[CheckVoid2]
	,a.[CheckVoid3]
	,a.[CheckAmount1]
	,a.[CheckAmount2]
	,a.[CheckAmount3]
	,a.[CheckCashed1]
	,a.[CheckCashed2]
	,a.[CheckCashed3]
	,a.[Source]
	,a.[SubAgentCommFXUSD]
	,a.[SubAgentCommChargesUSD]
	,a.[SubAgentCommFXLOC]
	,a.[SubAgentCommChargesLOC]
	,a.[LOCCurrencyCode]
	,a.[QuickPayRelationshipUSD]
	,a.[QuickPayRelationshipREC]
	,a.[QuickPayRelationshipLOC]
	,a.[QuickPayRelationshipPAY]
	,a.[USDToLOCRate]
	,a.[Extra1]
	,a.[SubAgentCommACT]
	,a.[RUCOOC]
	,a.[RecCity]
	,a.[PayCity]
	,a.[RecState]
	,a.[PayState]
	,a.[RepDate]
	,a.[SetCycle]
	,a.[MTCN]
	,a.[MTCN_hash]
	,a.[Company]
	,a.[WUCardNumber]
	,a.[TwoLegsFX]
	,a.[ForSysRefNumber]
	,a.[ForSysIdentifier]
	,a.[ForSysOperatorID]
	,a.[ForSysCounterID]
	,a.[SpareAC01]
	,a.[SpareAC02]
	,a.[SpareAC03]
FROM [dbo].[txnEntry] a
INNER JOIN [nacAccount] b on a.Account = b.Number
INNER JOIN [nacLocation] c on b.Location_ID = c.ID
WHERE [repdate] BETWEEN @DateFrom AND @DateTo
AND a.[SendPayIndicator] = 'P'
ORDER BY [RecordedDate];
```

## Notes

- **`SendPayIndicator = 'P'`** — restricts the extract to the **payout (Pay)** leg of transactions. Use `'S'` for the send leg if requested.
- **Filter is on `repdate`** — the range narrows results by **settlement date** (when Western Union settled the transaction to us), not by initiation or payout date.
- **Time reconstruction** — `RecordedTime` and `PayoutTime` are built by zero-padding the separate hour and minute columns (`RecDateUSHour`/`RecDateUSMinutes` and `PayDateUSHour`/`PayDateUSMinutes`) and casting the `HH:mm` string to `TIME(0)`.
- **Date format** — `@DateFrom` and `@DateTo` are integers in `yyyymmdd` format, matching how dates are stored in `txnEntry`.
- **Join path** — `txnEntry.Account` → `nacAccount.Number`, then `nacAccount.Location_ID` → `nacLocation.ID`, to resolve the location `Name`.

---

*Last updated: July 2026*
