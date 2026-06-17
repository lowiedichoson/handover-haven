# Synapse

## What It Is

Synapse is the bridge system that transfers generated CPR entries from Eterminal to Navision for the Accounting department's posting, ensuring all daily transactions are properly accounted for. 

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | Ask the Developer Team Lead for the source repository |
| **Production URL** | Ask IT Administrators |
| **Staging URL** | Ask IT Administrators |
| **Server** | Ask IT Administrators |
| **Database(s)** | `EBIZ PROD DATABASE` |

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

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Deployment

- **Method:** Manual replacement of code files on the server
- **Pipeline:** None
- **Frequency:** On request
- **Who deploys:** Developers, Server/Database Administrators

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| Eterminal | Pulls data from this system | Accounting department's posting in Navision cannot complete |

## Who to Ask

| Team / Department | What They Know |
|---|---|
| Developer Team | Backend and database ownership |
| TCSG Department | Triggers the transferring of CPR entries |

## Handover Notes

### Known Tech Debts
- Technology stack is outdated.
- One of its stored procedures **invisibly** maps a GL Code value to another GL Code value.
- This system can be deprovisioned — its current functionality already exists in the eSettlement system but has not been fixed yet.

---

*Last updated: June 2026*
