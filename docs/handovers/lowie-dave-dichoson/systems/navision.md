# Navision

## What It Is

Dynamics NAV (also known as Navision) is a legacy Enterprise Resource Planning (ERP) solution for businesses. It is currently the primary system the accounting department uses for booking all three companies' transactions and managing overall cash flows.

Our version of Dynamics NAV is legacy and has been out of support since I started working here. We, the IT department, support the accounting department by querying its SQL Server database to gain visibility into their transactions. However, at the moment, we don't have structured documentation of how the database tables connect to one another.

## Where It Lives

| What | Where |
|---|---|
| **Production URL** | Accessed by accounting via Amazon Workspace |
| **Server** | `172.30.0.210` |
| **Database(s)** | `[EBIZ PROD DATABASE]` |

## Key Tables in Database

| Table | What It Stores |
|---|---|
| `[dbo].[E-Business Services, Inc_$JournalVoucher]` | Parked CPR and Bridge entries are stored here ***before*** they get posted by the accounting team |
| `[dbo].[E-Business Services, Inc_$JournalVoucherHistory]` | CPR and Bridge stored here ***after*** they get posted by the accounting team |
| `[dbo].[E-Business Services, Inc_$Currency Exchange Rate]` | Stores the USD and PHP exchange rate value and they're updated on a daily basis by accounting team |
| `[dbo].[E-Business Services, Inc_$G_L Entry]` | Also stores CPR and Bridge entries after they get posted, just like `JournalVoucherHistory`. However, unlike `JournalVoucherHistory` — which keeps the entries as-is — in this table the entries are assigned a ***new*** `[Document No_]` value from a separate series numbering specific to this table, while their ***original*** `[Document No_]` value becomes the `[External Document No_]` column |
| `[dbo].[SynapseUser]` | Stores the user accounts information in accessing the [Synapse](synapse.md) application |

## Key Stored Procedures

| Stored Procedure | What It Does | Called By |
|---|---|---|
| `[dbo].[GetBridgeEntries]` | Fetches the Bridge entries created from the `Esettlement` system | SQL Job at 9:00 AM |
| `[dbo].[GetEterminalAccountingEntries]` | Fetches the Debit & Credit amounts created from `Eterminal` system | Generate and export buttons in [synapse](synapse.md) system |
| `[dbo].[UploadETERMINALEntries]` | Fetches the CPR entries from Eterminal system and populates them into `[E-Business Services, Inc_$JournalVoucher]` table | Upload button in [synapse](synapse.md) system |

## Access

| What | How to Get It |
|---|---|
| **Application usage** | Credentials to login on Amazon Workspace |

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| **Eterminal** | CPR journal entries are originating from this system | Accounting cannot post the CPR journal entries |
| **Esettlement** | Bridge journal entries | Accounting cannot post the Bridge journal entries |

## Who to Ask

| Team / Department | What They Know |
|---|---|
| **IT Infrastructure** | Database ownership |
| **Accounting** | Daily process |

---

*Last updated: June 2026*
