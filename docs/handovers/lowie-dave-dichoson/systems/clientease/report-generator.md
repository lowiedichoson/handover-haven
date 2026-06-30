# PEMIClientEase.ReportGen

## What It Is

A console application that generates **Client Information Summary** PDF file. It  populates the PDF based on the parameter passed to it when triggered. The PDF it generates contain sensitive details such as personal, employment, addresses, politically-exposed persons, risk score results, and attachments file that identify a specific person or investor. The files that this console application generate are intended for the PEMI Sales Team, as they are the one who verifies and validates these information for further processing such as account opening or updating depending on what the user requested. 

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | [GitHub](https://github.com/PEMIClientEase/PEMIClientEase.GenReport) |
| **Production URL** | Ask IT Administrators |
| **Staging URL** | Ask IT Administrators |
| **Server** | Ask IT Administrators |
| **Database** | `clientease` |

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | C# 12 |
| **Framework** | .NET 8.0 |
| **Database** | PostgreSQL |
| **Project Type** | Console Application |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| **`clientease`** database  | Provides the investor data models (`PrimaryInvestor`, `Coinvestor`, etc.) | PDF cannot be downloaded by the investor / user |
| **[PEMIClientEase.PDFGenerator](pdf-builder.md)** | Core PDF rendering engine | Everything fails — no PDF output |

---

*Last updated: June 2026*
