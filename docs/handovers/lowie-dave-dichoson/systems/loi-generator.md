# LOI Generator

## What It Is

LOI Generator is a web application built to automate the creation of Letters of Intent (LOI) for the Treasury Operations team's daily transaction processing. It supports an 8-person department that handles a wide range of financial transactions — including foreign exchange, equities, fixed deposits, and other treasury instruments — by eliminating manual document preparation and reducing the risk of errors.

The output is a `.pdf` file containing the correct transaction amounts, settlement details, counterparty bank names, addressees, and authorized signatories. The system serves both Vantage Equities, Inc. and Philequity Management, Inc., ensuring that each entity's LOI adheres to its respective branding, signatory rules, and transaction workflows.

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | [GitHub](https://github.com/vantage-vei/LOI-Generator) |
| **Production URL** | Ask IT Administrators |
| **Server** | Ask IT Administrators |
| **Database(s)** | `Ideal Funds`, `Cashtrea` |

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | C#, JavaScript |
| **Framework** | .NET Framework 4.7, Alpine.js |
| **Database** | Oracle SQL |
| **Reports** | RDLC |

## Access

| What | How to Get It |
|---|---|
| **Server access** | Ask IT Administrators |
| **Database access** | Ask IT Administrators |
| **Application usage** | Same credentials users use in logging in on Cashtrea app |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Deployment

- **Method:** Manual — compile in Visual Studio and replace the executable on the target machine
- **Pipeline:** None
- **Frequency:** On request, or when changes are made
- **Who deploys:** Developers

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| **Ideal Funds** | PEMI's transaction data for the mutual funds | The app cannot produce Letter of Intent for PEMI's transactions |
| **Cashtrea** | VEI's transaction data | The app cannot produce LOI for VEI's transactions |

## Who to Ask

| Team / Department | What They Know |
|---|---|
| **Developer Team** | Backend and database ownership |
| **Treasury Operations** | Daily process |

---

*Last updated: June 2026*
