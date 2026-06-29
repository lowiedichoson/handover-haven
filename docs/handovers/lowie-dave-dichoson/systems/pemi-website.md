# PEMI Website

## What It Is

PEMI Website is the legacy website of Philequity Management, Inc. It's a blog-like website where investors or clients visit to read the latest news and updates. It also displays the daily NAVPS of our mutual funds, which are updated on a daily basis. 

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | [GitHub](https://github.com/vantage-vei/philequity-website) |
| **Production URL** | [www.philequity.net](https://www.philequity.net) |
| **Staging URL** | Ask IT Administrators |
| **Server** | Linux server — Ask IT Administrators |
| **Database(s)** | `philequity` |

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | PHP 5.6.40, JavaScript |
| **Framework** | Vanilla PHP, XAMPP |
| **Database** | MySQL |
| **Hosting** | Apache Web Server |

## Key Tables in Database

| Table | What It Stores |
|---|---|
|  | |

## Access

| What | How to Get It |
|---|---|
| **Server access** | Ask IT Administrators |
| **Database access** | Access phpMyAdmin via the production server's URL — credentials provided by IT Administrators |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Deployment

- **Method:** Manual upload of files via WinSCP to the Linux server
- **Pipeline:** None
- **Frequency:** On request
- **Who deploys:** Developers, Server/Database Administrators

## Who to Ask

| Team / Department | What They Know |
|---|---|
| Developer Team | Backend and database ownership |
| PEMI Sales & PEMI Fund Accounting | Admin Maintenance |

## Common Requests

| Request | Description |
|---|---|
| [New ASM Page](../common-requests/008-new-asm-page.md) | Create a yearly Annual Stockholders' Meeting page |
| [Adding a New Fund](../common-requests/009-adding-of-new-fund.md) | Add new mutual fund pages, templates, and database records |
| [Uploading Files and Creating Shortened Links](../common-requests/010-uploading-of-files-and-shortened-link.md) | Upload PDFs and set up clean redirect links |
| [Extract Historical NAVPS](../common-requests/012-extract-historical-navps.md) | Export historical NAVPS data from phpMyAdmin |

## Handover Notes

### Known Tech Debts
- Technology stack is outdated

---

*Last updated: June 2026*

