# System Architecture Overview

> **Disclaimer:** This diagram reflects my understanding of the system connections as of July 2026. It is not the authoritative truth — verify before relying on it.

## VFC System Landscape

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

    subgraph EOD["🌙 End-of-Day Process (10:30 PM)"]
        eTerminalEOD["<b>eTerminal EOD Job</b><br/>Transforms raw transactions<br/>into journal entries<br/>(accounting format)"]
    end

    eTerminal -->|"all daily cash flows"| eTerminalEOD

    subgraph NextDay["☀️ Next Morning"]
        Synapse["<b>Synapse</b><br/>Bridges journal entries<br/>to Navision"]
        TCSG["TCSG Department"]
        Navision["<b>Navision</b><br/>Accounting system"]
    end

    eTerminalEOD -->|"journal entries ready<br/>for transfer"| Synapse
    TCSG -->|"validates & transfers"| Synapse
    Synapse -->|"posts journal entries"| Navision

    subgraph WUFlow["💱 Western Union Data Flow"]
        WUSFG["<b>WUSFG Website</b><br/>AC & ST file downloads<br/>(external WU source)"]
        Voyager["<b>Voyager</b><br/>Desktop app<br/>processes AC/ST files"]
        Esettlement["<b>eSettlement</b><br/>Retrieves Voyager data,<br/>processes transactions"]
        AutoJob["<b>Auto SQL Jobs</b><br/>9:00 AM — journal entries<br/>9:30 AM — transfer to Navision"]
    end

    WUSFG -->|"AC/ST files downloaded"| Voyager
    Voyager -->|"processed WU data"| Esettlement
    Esettlement -->|"transaction data"| AutoJob
    AutoJob -->|"auto-post journal entries"| Navision

    Voyager -.->|"WU data reconciled against"| eTerminal

    subgraph Reports["📊 Report Generators"]
        FTR["<b>FTR Generator</b><br/>Desktop app<br/>generates reports used by<br/>TCSG, Accounting, Treasury"]
        VoyagerFX["<b>Voyager FX</b><br/>Desktop app<br/>generates reports used by<br/>TCSG, Accounting, Treasury"]
    end

    Voyager -->|"consumes data"| FTR
    Esettlement -->|"consumes data"| VoyagerFX
```

> eCore is the primary system. eTerminal is the fallback. All cash flows — whether transacted through eCore, eTerminal, or WUPOS — eventually land in eTerminal for branch cash reporting and teller accountability. At 10:30 PM, the EOD background process transforms raw transactions into journal entries. The next morning, TCSG uses Synapse to validate and transfer those entries into Navision.
>
> On the Western Union side, TCSG downloads AC/ST files from WUSFG, processes them in Voyager, then feeds them into eSettlement. Automated SQL jobs (9:00 AM journal entries, 9:30 AM transfer to Navision) handle the rest — the automated equivalent of what Synapse does manually for eTerminal data. Voyager's WU data is also reconciled against eTerminal's internal WU records to ensure consistency.
>
> FTR Generator and Voyager FX are reporting tools that consume data from Voyager and eSettlement respectively, generating reports for TCSG, Accounting, and Treasury.

