# [System Name]

> Copy this template to `docs/handovers/<your-name>/systems/<system-name>.md`,
> replace the bracketed placeholders, and delete this notice.

## What It Is

[One or two sentences. What does this system do? Who uses it? Example: "eSettlement
handles back-office trade settlement for VFC — it processes bridge entries, generates
accounting feeds, and is used daily by the Transactions & Settlement team."]

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | [GitHub / GitLab / Bitbucket URL] |
| **Production URL** | [https://example.com] |
| **Staging URL** | [https://staging.example.com] |
| **Server** | [Hostname or IP, or "See Synapse for server list"] |
| **Database** | [Database name and server] |

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | [C# / Python / JavaScript / etc.] |
| **Framework** | [.NET 8 / Django / React / etc.] |
| **Database** | [SQL Server / PostgreSQL / etc.] |
| **Hosting** | [IIS / Docker / Azure / on-prem] |

## Access

| What | How to Get It |
|---|---|
| **Source code** | [Which team / person grants repo access] |
| **Server access** | [RDP / SSH / VPN — who to contact for credentials] |
| **Database access** | [Who to ask, connection string location] |
| **Admin panel** | [URL + who can create accounts] |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Deployment

[How is this system deployed? Who does it?]

- **Method:** [Manual copy / CI/CD pipeline / ClickOnce / etc.]
- **Pipeline:** [Link to GitHub Actions / Jenkins / Azure DevOps]
- **Frequency:** [On every merge to main / weekly / on request]
- **Who deploys:** [ICTG / DevOps / self-service]

## Common Issues

| Problem | Likely Cause | Fix |
|---|---|---|
| [e.g., "App pool stops"] | [Memory leak after X days] | [Restart app pool via IIS] |
| [e.g., "Login fails"] | [AD token expired] | [Clear cookies, re-authenticate] |

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| [e.g., Navision] | [Reads chart of accounts] | [Bridge entry posting fails] |
| [e.g., Synapse] | [Routes API calls] | [Nothing reaches the backend] |

## Who to Ask

| Name | Role | What They Know |
|---|---|---|
| [Name] | [Title] | [e.g., "Original developer, knows the DB schema"] |
| [Name] | [Title] | [e.g., "Business owner, knows the rules"] |

## Handover Notes

[Anything that doesn't fit above. Unfinished work, upcoming changes, known tech
debt, gotchas, or tribal knowledge the next person should know.]

---

*Last updated: [Month Year]*
