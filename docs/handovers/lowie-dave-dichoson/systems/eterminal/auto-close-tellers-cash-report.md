# Auto Close TCR

## What It Is

Automatic closing of TCR is one of the steps in the EOD Process SQL Job that runs daily on the eTerminal server. It corresponds to the **`[dbo].[AutoCloseAR]`** step in the [EOD Process](eod-process.md) and the [Manual Run of EOD Process](../../common-requests/004-manual-run-of-eod-process.md). It's a **fallback operation** that ensures auto-created TCRs have been properly computed and displays the actual transactions that were tagged to the specific teller who owns this TCR.

Auto-close performs the same operation as when a teller manually submits their TCR using the eTerminal TCR module. For the detailed breakdown of what happens during TCR closing or submission, see [TCR Simulation](tcr-simulation.md).

## Why It Exists

Same reasons as [Auto Create TCR](auto-create-tellers-cash-report.md) — even when a teller couldn't access the system to close their TCR, the auto-close fallback handles it for them. This covers scenarios like:

1. **Unlikely but possible** — the teller had access to the terminal and the branch was operational, but they simply didn't close their TCR.
2. **External disruptions** — power outage (can't turn on terminals/computers), internet connection issues, or other reasons that prevented terminal or computer access.

## Auto-Close Condition

The system will auto-close a TCR if **both** of the following are true:

| # | Condition | Description |
|---|---|---|
| 1 | **Current date** | The TCR's transaction date matches the current date being processed |
| 2 | **Not yet closed** | The `[Closed]` column value is `0`, meaning the TCR hasn't been submitted yet |

---

*Last updated: June 2026*
