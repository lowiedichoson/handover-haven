# eSettlement

## What It Is

eSettlement is the core system responsible for processing raw transaction data from Voyager, which originates from Western Union's WUSFG system. Because the data comes from a third party, eSettlement applies its internal formulas to transform it into settlement reports for TCSG validation, Requests for Payment (RFPs), and Letters of Intent (LOIs). These transactions are then further processed into accounting entries, which the Accounting department books and posts into Navision to ensure every transaction is properly accounted for.

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | [GitHub](https://github.com/vantage-vei/eSettlement) |
| **Production URL** | Ask IT Administrators |
| **Staging URL** | Ask IT Administrators |
| **Server** | Ask IT Administrators |
| **Database(s)** | `BridgeDb`, `Voyager`, `Treasury` |

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | Visual Basic, JavaScript |
| **Framework** | .NET Framework, ASP.NET Web Forms |
| **Database** | SQL Server |
| **Hosting** | IIS |

## Access

| What | How to Get It |
|---|---|
| **Server access** | Ask IT Administrators |
| **Database access** | Ask IT Administrators |
| **Admin panel** | Branch Operations |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Deployment

- **Method:** Manual replacement of code files on the server
- **Pipeline:** None
- **Frequency:** On request
- **Who deploys:** Developers, Server/Database Administrators

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| Voyager | Pulls data from this system | No transaction-related processes can complete |
| Navision | Transfers data to this system | No accounting entry processes can complete |

## Who to Ask

| Team / Department | What They Know |
|---|---|
| Developer Team | Backend and database ownership |
| Branch Operations | User provisioning, branch and sub-agent maintenance |
| Treasury Operations | RFPs and LOIs |
| TCSG Department | Pulling and processing Voyager raw data, processing daily settlement, generating transactional reports |

## Handover Notes

### Unfinished Work
- Audit logs enhancement — QA testing, bug fixes from test results, and deployment release
- Manual creation of bridge entries enhancement to replace the automated job
- Manual transferring of bridge entries to Navision enhancement to replace the automated job
- Feature branch in GitHub for modernizing the user interface using Bootstrap 5
- Feature branch in GitHub for modernizing the JavaScript code by removing legacy JavaScript libraries and replacing them with vanilla modern JavaScript

### Known Tech Debts
- Current production uses legacy JavaScript libraries such as Knockout.js, jQuery
- Rollback module **hard deletes** data without proper archiving or user event logging, limiting visibility into root causes when errors occur

---

*Last updated: June 2026*

