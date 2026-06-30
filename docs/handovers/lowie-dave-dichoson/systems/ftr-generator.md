# FTR Generator

## What It Is

FTR Generator is a desktop application for Vantage Financial Corporation that generates **Final Transaction Reports (FTR)** — the daily settlement reports for sub-agents (SAs). These reports break down all money transfer transactions (inbound/outbound) in both Peso and USD, showing send amounts, charges, payouts, commissions, VAT, withholding tax, and documentary stamp tax.

The output is a password-protected Excel file (`.xls`) saved to `C:\SAReport\YYYY\MM\DD\` containing two worksheets per currency:
- **FTR sheet** — detailed daily settlement with per-transaction breakdown
- **Accountability Report sheet** — summarized accountability by sub-agent for the period

If generation is blocked, the app reports whether daily settlement is still in progress or the data is not yet available.

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | [GitHub](https://github.com/vantagejoven/FTR-Generator) |
| **Production URL** | Desktop application — not web-deployed |
| **Server** | Ask IT Administrators |
| **Database(s)** | `BridgeDB` |

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | Visual Basic (.NET) |
| **Framework** | .NET Framework 4.0, Windows Forms |
| **Database** | SQL Server |
| **Office Integration** | Excel COM Interop |

## Access

| What | How to Get It |
|---|---|
| **Server access** | Ask IT Administrators |
| **Database access** | Ask IT Administrators |
| **Application usage** | Authorized users with DB credentials |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Deployment

- **Method:** Manual — compile in Visual Studio and replace the executable on the target machine
- **Pipeline:** None
- **Frequency:** On request, or when changes are made
- **Who deploys:** Developers

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| **BridgeDB (SQL Server)** | All transaction data, user authentication, and FTR data are queried from this database | The app cannot load SA lists, authenticate users, or generate reports |
| **Network Drive Access** | `Class1.vb` maps network drives via Windows API (`WNetAddConnection2`) for file output | Reports may fail to save if the output path is on a network drive |

## Who to Ask

| Team / Department | What They Know |
|---|---|
| **Developer Team** | Backend and database ownership |
| **Branch Operations** | Sub-agent (SA) maintenance |
| **Treasury Operations** | Settlement and reconciliation processes |

---

*Last updated: June 2026*

