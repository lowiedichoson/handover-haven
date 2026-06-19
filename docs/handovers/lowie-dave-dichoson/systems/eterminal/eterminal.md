# eTerminal

## What It Is

eTerminal is the point-of-sale system of Vantage Financial Corporation. While eCore serves as the main system where actual transactions are performed (connecting to partners' APIs), eTerminal is where those transactions are ultimately placed and accounted for.

All transactions must be properly accounted for in eTerminal because it houses the teller's cash reports and the branch's cash report — which holds the total accumulated amounts for each transaction type, including but not limited to:

- WU inbound / outbound
- Remitly, Ria, Xoom, MG inbound transactions
- Bills payments
- Airline ticketing
- And others

If eCore ever fails to automatically transfer a transaction to eTerminal, eTerminal has the capability to manually post the transaction if necessary.

eTerminal is also where the **end-of-day (EOD)** background process runs. See [EOD Process](eod-process.md)

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | Ask the Developer Team Lead for the source repository |
| **Production URL** | Ask IT Administrators |
| **Staging URL** | Ask IT Administrators |
| **Server** | Ask IT Administrators |
| **Database(s)** | `Navision` |

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
| **Source code** | Ask the Developer Team Lead for repo access |
| **Server access** | Request SQL Server Authentication credentials from the Server Administrator |
| **Database access** | Request read-only database access from the Database Administrator |
| **Branch and User Maintenance** | Branch Operations |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Deployment

- **Method:** Manual replacement of code files on the server
- **Pipeline:** None
- **Frequency:** On request
- **Who deploys:** Developers, Server/Database Administrators

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| None | — | — |

## Who to Ask

| Team / Department | What They Know |
|---|---|
| Developer Team | Backend and database ownership |
| Branch Operations | User provisioning, branch and sub-agent maintenance |
| Treasury Operations | RFPs and LOIs |
| TCSG Department | Pulling and processing Voyager raw data, processing daily settlement, generating transactional reports |

---

*Last updated: June 2026*
