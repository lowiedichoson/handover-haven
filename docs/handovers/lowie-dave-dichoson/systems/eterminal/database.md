# eTerminal Database

## Overview

eTerminal uses `Navision` as its main database. This page documents the tables you'll commonly encounter during debugging, reporting, and maintenance tasks.

> ⚠️ **Naming clarification** — Internally, the databases are poorly named:
> - **eTerminal system** → uses the **Navision** database (hosted on eTerminal's server)
> - **Navision system** (desktop app) → uses **EBIZ PROD DATABASE** (hosted on a separate server)
> 
> When this document refers to the `Navision` database, it means eTerminal's database — not the desktop application's.

> For the formulas behind the computed values for Teller's Cash Report, see [TCR Simulation](tcr-simulation.md).  
> For the formulas behind the computed values for Branch's Cash Report, see [BCR Simulation](bcr-simulation.md).

---

## Database Summary

| Database | Purpose | When You Query It |
|---|---|---|
| `Navision` | Core database of the eTerminal system where its main tables are housed |  |


---

## Navision

### Key Tables

| Table | What It Stores |
|---|---|
| `[dbo].[AuditTrail]` | User event logs — transactions, fund transfers, etc. are logged here |
| `[dbo].[CPR Journal Entry]` | CPR journal entries inserted when the creation of entries runs at end of day |
| `[dbo].[E-Business Services Inc_$AR Main Vault]` | Branch cash report data |
| `[dbo].[E-Business Services Inc_$AR Topsheet]` | Teller's cash report data |
| `[dbo].[E-Business Services Inc_$AR Topsheet to Main Vault]` | Archived TCR submission dates — when a teller submits their TCR, the final data is saved here |
| `[dbo].[E-Business Services Inc_$Branch Journal Line]` | Individual transactions — all types (remittance, bills payment, airline ticketing, etc.) including those transacted from eCore and manual postings in eTerminal |
| `[dbo].[E-Business Services Inc_$Currency Exchange Rate]` | PDS rate, synced from Navision to eTerminal via a SQL job |
| `[dbo].[E-Business Services Inc_$Dimension Value]` | Branch information — shipping address, branch code, name, etc. |
| `[dbo].[E-Business Services Inc_$Employee]` | Employee / teller information — employee ID, operator ID, name, password, status, etc. |
| `[dbo].[E-Business Services Inc_$JournalVoucher]` | A copy of Navision's own `JournalVoucher` table — after individual transaction entries are created, they are summarized, totaled, and grouped, then housed here. The Navision SQL job reads from this table for the accounting department's posting needs |
| `[dbo].[Miscellaneous]` | Miscellaneous transactions are inserted here |
| `[dbo].[OR]` | Transactions with official receipts (OR) are saved here — actual transactions live in `[dbo].[E-Business Services Inc_$Branch Journal Line]`, and their corresponding ORs are saved here |

### Key Stored Procedures

| Stored Procedure | What It Does | Called By |
|---|---|---|
| `[dbo].[CreateAccountingEntriesNew]` | Creates CPR journal entries from raw transaction data in `[dbo].[E-Business Services Inc_$Branch Journal Line]` | EOD Process job |
| `[dbo].[CreateAccountingEntriesOR]` | Creates CPR journal entries from OR data in `[dbo].[OR]` — together with `CreateAccountingEntriesNew`, saves results into `[dbo].[CPR Journal Entry]` | EOD Process job |
| `[dbo].[emailCDDBalance]` | Sends an email containing the CDD Balance `.xlsx` report | SQL job |
| `[dbo].[emailCohEnding]` | Sends an email containing the COH Ending Balance `.xlsx` report | SQL job |
| `[dbo].[GetCDDBalance]` | Fetches data for the CDD Balance report and populates the `.xlsx` report (Sheet 1) | SQL job |
| `[dbo].[GetCDDperBank]` | Fetches data for the CDD Balance report (Sheet 2) and populates the `.xlsx` report | SQL job |
| `[dbo].[GetCOHEndingBalance]` | Fetches data for the COH Ending Balance report and populates the `.xlsx` report | SQL job |
| `[dbo].[GetCPRJournalEntrySummaryPerBranch]` | Summarizes and groups individual entries from `[dbo].[CPR Journal Entry]` and populates the results into `[dbo].[E-Business Services Inc_$JournalVoucher]` to make them ready for Navision posting | EOD Process job |
| `[dbo].[GetOpenMainVaultPHP]` / `[dbo].[GetOpenTopsheetUSD]` | GETs and UPDATEs data in `[dbo].[E-Business Services Inc_$AR Topsheet to Main Vault]` — used by the BCR module | BCR module |
| `[dbo].[GetOpenTopsheetPHP]` / `[dbo].[GetOpenTopsheetUSD]` | GETs and UPDATEs data in `[dbo].[E-Business Services Inc_$AR Topsheet]` — used by the TCR module | TCR module |

---

## Common Lookup Patterns

> Practical scenarios — "I need to do X → here's where to look."

| Scenario | Where to Look | Notes |
|---|---|---|
| **TCR amounts not tallying with Cash on Hand CPR entries** | Check `[dbo].[E-Business Services Inc_$AR Topsheet]` and `[dbo].[AuditTrail]` — query by operator ID | Verify that the teller's login history aligns with the branch code of their TCR |
| **BCR amounts not tallying with Cash on Hand CPR entries** | Check `[dbo].[E-Business Services Inc_$AR Main Vault]`, the fund transfer table, and timestamps of when it was closed and compare to the TCR's | Compare closure timestamps between BCR and TCR to identify mismatches |
| **TCSG / Accounting dept. asks for a certain amount in their journal entries** | Trace through `[dbo].[E-Business Services Inc_$JournalVoucher]` → `[dbo].[CPR Journal Entry]` → `[dbo].[E-Business Services Inc_$Branch Journal Line]` → `[dbo].[OR]` to verify that the summed totals in `[dbo].[E-Business Services Inc_$JournalVoucher]` back-track to the actual transaction amounts that were grouped. Also review the formulas in `[dbo].[CreateAccountingEntriesNew]` and `[dbo].[CreateAccountingEntriesOR]` and check for any `GROUP BY` clauses used | Start from the `[dbo].[E-Business Services Inc_$JournalVoucher]` total and drill down to individual transactions to confirm the grouping logic is correct |

---

## Table Relationships

The core data flow moves through these tables in sequence:

1. **Individual transactions** are stored in `[dbo].[E-Business Services Inc_$Branch Journal Line]` (all transactions) and `[dbo].[OR]` (official receipts).
2. **`[dbo].[CreateAccountingEntriesNew]`** processes data from `[dbo].[E-Business Services Inc_$Branch Journal Line]`, and **`[dbo].[CreateAccountingEntriesOR]`** processes data from `[dbo].[OR]` — both populate **`[dbo].[CPR Journal Entry]`**.
3. Once `[dbo].[CPR Journal Entry]` is populated, **`[dbo].[GetCPRJournalEntrySummaryPerBranch]`** groups the data (see the SP for exact `GROUP BY` logic) and inserts the summarized results into **`[dbo].[E-Business Services Inc_$JournalVoucher]`**.
4. The Navision SQL job then reads from `[dbo].[E-Business Services Inc_$JournalVoucher]` for the accounting department's posting needs.

### Backtracking via DocumentNo

The `[DocumentNo]` column in `[dbo].[E-Business Services Inc_$JournalVoucher]` encodes enough information to trace back to **`[dbo].[CPR Journal Entry]`**. From there, you can drill further into the raw tables.

**Sample:** `ET414032TP20260621`

| Segment | Value | Meaning |
|---|---|---|
| `ET` | `ET` | eTerminal system identifier |
| `414032` | Branch code | The branch that owns this entry. In `[dbo].[CPR Journal Entry]`, the branch code uses dots as separators (e.g., `4.14.032`). Query that table using the dotted format to find related records |
| `T` | `T` or `O` | **T** — entry originated from `[dbo].[E-Business Services Inc_$Branch Journal Line]`  
**O** — entry originated from `[dbo].[OR]` |
| `P` | `P` or `U` | **P** — PHP transaction  
**U** — USD transaction |
| `20260621` | Date | The date when the transaction was performed / posted (`YYYYMMDD`) |

### From CPR Journal Entry to Raw Transactions

Once you've identified the matching records in `[dbo].[CPR Journal Entry]`, use the following columns to backtrack to the source:

| CPR Journal Entry Column | Branch Journal Line (`Data Source = TRANS`) | OR (`Data Source = OR`) |
|---|---|---|
| `[Document No]` | `[Document No]` (may contain `_` or extra spacing) | `[OR Number]` |
| `[Branch Code]` (dotted, e.g., `4.14.032`) | `[Unit Code (Dimension)]` | — |
| `[Currency Code]` | `[Currency Code]` (may be without space) | `[Currency Code]` |
| `[Transaction Date]` | `[Posting Date]` | `[Transaction Date]` |

**How to read it:**
- If `[Data Source]` is **`TRANS`** → the entry came from `[dbo].[E-Business Services Inc_$Branch Journal Line]`. Query that table using `[Unit Code (Dimension)]`, `[Document No]`, `[Currency Code]`, and `[Posting Date]`.
- If `[Data Source]` is **`OR`** → the entry came from `[dbo].[OR]`. Query that table using `[OR Number]`, `[Currency Code]`, and `[Transaction Date]`.

> ⚠️ Column mappings listed above are based on observed patterns. If you encounter discrepancies, inspect the actual table schemas to confirm.

---

*Last updated: June 2026*

