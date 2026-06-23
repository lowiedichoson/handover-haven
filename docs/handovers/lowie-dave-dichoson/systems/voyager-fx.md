# Voyager FX

## What It Is

Voyager FX is a web application for **Vantage Financial Corporation** that provides access to **Western Union Voyager foreign exchange (FX) settlement data**. It allows users to push daily settlement transactions from the Treasury database to the Voyager system and generate consolidated accountability reports — both daily and monthly — covering FX principal amounts, charges, and revenues broken down by branch in USD and PHP.

The output consists of Excel (`.xls`) files saved to `C:\Voyager Report\YYYY\MM\<TYPE>\` containing:
- **Voyager Revenue** — charges and FX breakdowns for inbound (API/APZ) and outbound (APZ) transactions, per branch in USD and PHP
- **Voyager FX** — FX principal (USD Buy / PHP Sell) and FX total (USD Sell / PHP Buy), per branch

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | Ask the Developer Team Lead for the source repository |
| **Production URL** | Ask IT Administrators |
| **Staging URL** | Ask IT Administrators |
| **Server** | Ask IT Administrators |
| **Database(s)** | `Voyager`, `Treasury` |

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | Visual Basic (.NET) |
| **Framework** | .NET Framework 4.0, ASP.NET Web Forms |
| **Frontend** | Knockout.js 3.2.0, jQuery 2.1.1, AjaxControlToolkit 16.1.1 |
| **Database** | SQL Server |
| **Excel Output** | EPPlus 4.1.0 |
| **JSON Serialization** | Newtonsoft.Json 9.0.1 |

## Access

| What | How to Get It |
|---|---|
| **Source code** | In this repository at `FXReport/` |
| **Server access** | Request SQL Server Authentication credentials from the Server Administrator |
| **Database access** | Request database access from the Database Administrator |
| **Application usage** | Authorized users with ASP.NET membership credentials (Forms Authentication) |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Deployment

- **Method:** Manual — compile in Visual Studio and publish to the on-premises web server
- **Pipeline:** None
- **Frequency:** On request, or when changes are made
- **Who deploys:** Developers

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| **Voyager Database (SQL Server)** | FX transaction data and Western Union Voyager operations data are stored here | Report generation and push transactions fail |
| **Treasury Database (SQL Server)** | Settlement data for `updateSettlement_Vantage_V2`, charges, FX inbound/outbound, and monthly aggregation stored procedures | Push transactions and consolidated reports cannot be generated |
| **Local File System on the server** | Reports are saved to `C:\Voyager Report\YYYY\MM\<TYPE>\` | Reports cannot be written to disk |

## Who to Ask

| Team / Department | What They Know |
|---|---|
| Developer Team | Backend and database ownership |
| Accounting Team | Users of the system |

---

*Last updated: June 2026*
