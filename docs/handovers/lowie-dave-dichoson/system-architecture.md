# System Architecture Overview

> **Disclaimer:** This diagram reflects my understanding of the system connections as of July 2026. It is not the authoritative truth — verify before relying on it.

---

## Core Transaction Flow

How branch transactions move from teller operations through end-of-day processing and into the accounting system.

```mermaid
graph TD
    subgraph Branch["🏢 Branch Operations"]
        Teller["Teller / Branch Staff"]
        eCore["<b>eCore</b><br/>Primary transaction-processing<br/>web application"]
        eTerminal["<b>eTerminal</b><br/>Fallback transaction<br/>web application"]
        WUPOS["<b>WUPOS</b><br/>Western Union POS<br/>third-party system"]
    end

    Partner["Partner Companies<br/><i>Remittance, Ancillary,<br/>Bills Payment, SSS, etc.</i>"]

    Teller -->|"day-to-day transactions"| eCore
    Teller -->|"fallback (eCore unavailable)"| eTerminal
    Teller -->|"WU transactions only<br/>(eCore unavailable)"| WUPOS

    eCore -->|"connects to"| Partner
    eCore -->|"auto-post transactions"| eTerminal
    WUPOS -->|"auto-post transactions"| eTerminal

    subgraph EOD["🌙 End-of-Day (10:30 PM)"]
        eTerminalEOD["<b>eTerminal EOD Job</b><br/>Transforms raw transactions<br/>into journal entries"]
    end

    eTerminal -->|"all daily cash flows"| eTerminalEOD

    subgraph Morning["☀️ Next Morning"]
        Synapse["<b>Synapse</b><br/>Bridges journal entries<br/>to Navision"]
        TCSG["TCSG Department"]
        Navision["<b>Navision</b><br/>Accounting system"]
    end

    eTerminalEOD -->|"journal entries ready"| Synapse
    TCSG -->|"validates & transfers"| Synapse
    Synapse -->|"posts journal entries"| Navision
```

> eCore is the primary system. eTerminal is the fallback. All cash flows — whether transacted through eCore, eTerminal, or WUPOS — eventually land in eTerminal for branch cash reporting and teller accountability. At 10:30 PM, the EOD background process transforms raw transactions into journal entries. The next morning, TCSG uses Synapse to validate and transfer those entries into Navision.

---

## Western Union Data Pipeline

How Western Union transaction files flow from download through processing, auto-posting, and reporting.

```mermaid
graph TD
    subgraph WUSource["💱 External Source"]
        WUSFG["<b>WUSFG Website</b><br/>AC & ST file downloads"]
    end

    subgraph Processing["⚙️ Processing"]
        Voyager["<b>Voyager</b><br/>Desktop app<br/>processes AC/ST files"]
        Esettlement["<b>eSettlement</b><br/>Retrieves Voyager data,<br/>processes transactions"]
    end

    subgraph Auto["🤖 Auto-Posting"]
        AutoJob["<b>Auto SQL Jobs</b><br/>9:00 AM — journal entries<br/>9:30 AM — transfer to Navision"]
    end

    Navision["<b>Navision</b><br/>Accounting system"]

    WUSFG -->|"AC/ST files downloaded"| Voyager
    Voyager -->|"processed WU data"| Esettlement
    Esettlement -->|"transaction data"| AutoJob
    AutoJob -->|"auto-post journal entries"| Navision

    subgraph Reports["📊 Report Consumers"]
        FTR["<b>FTR Generator</b><br/>Desktop app<br/>reports for TCSG, Accounting, Treasury"]
        VoyagerFX["<b>Voyager FX</b><br/>Desktop app<br/>reports for TCSG, Accounting, Treasury"]
    end

    Voyager -->|"consumes data"| FTR
    Esettlement -->|"consumes data"| VoyagerFX

    eTerminal["<b>eTerminal</b><br/>Core transaction system"]
    Voyager -.->|"WU data reconciled against"| eTerminal
```

> TCSG downloads AC/ST files from WUSFG, processes them in Voyager, then feeds them into eSettlement. Automated SQL jobs handle the rest — creating journal entries at 9:00 AM and transferring to Navision at 9:30 AM (the automated equivalent of what Synapse does manually for eTerminal data). Voyager's WU data is also reconciled against eTerminal's internal WU records to ensure consistency.
>
> FTR Generator and Voyager FX are reporting tools that consume data from Voyager and eSettlement respectively, generating reports for TCSG, Accounting, and Treasury.

---

*Last updated: July 2026*
