# PEMIClientEase.PDFGenerator

## What It Is

A class library that generates **Client Information Summary PDFs** for Philequity (PEMI) investor onboarding and account management workflows. It is consumed by a parent ASP.NET web API — the API collects investor data and feeds it to `InvestorDocument`, which composes a multi-section PDF covering personal details, addresses, employment, FATCA/PEP compliance, risk profile, bank details, coinvestors, declarations, video verification schedules, and uploaded attachments. The same document can be rendered as an **internal compliance copy** (with attachments) or a **client-facing copy** (without attachments).

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | [GitHub](https://github.com/PEMIClientEase/PEMIClientEase.PDFGenerator) |
| **Production URL** | Ask IT Administrators |
| **Staging URL** | Ask IT Administrators |
| **Server** | Ask IT Administrators |
| **Database** | No direct database access — data arrives via models from the parent API |

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | C# 12 |
| **Framework** | .NET 8.0 (LTS) |
| **PDF Library** | QuestPDF 2025.12.1 (Community License) |
| **Project Type** | Class Library (`Microsoft.NET.Sdk`) |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| **[Parent ASP.NET Web API](backend.md)**  | Provides the investor data models (`PrimaryInvestor`, `Coinvestor`, etc.) | PDF cannot be downloaded by the investor / user |
| **QuestPDF NuGet** | Core PDF rendering engine | Everything fails — no PDF output |
| **ClientEase Report Generator** | Provides the list version of data models, intended for Sales team | PDFs of the investors will not be generated |

---

*Last updated: June 2026*
