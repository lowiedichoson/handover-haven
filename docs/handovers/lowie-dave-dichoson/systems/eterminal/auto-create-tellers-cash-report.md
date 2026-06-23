# Auto Create TCR

## What It Is

Automatic creation of TCR is one of the steps in the EOD Process SQL Job that runs daily on the eTerminal server. It corresponds to the **`[dbo].[AutoCreateAR]`** step in the [EOD Process](eod-process.md) and the [Manual Run of EOD Process](../../common-requests/004-manual-run-of-eod-process.md). It's a **fallback operation** that ensures a Teller's Cash Report is created for tellers who, for various reasons, were unable to create one themselves during the day.

## Why It Exists

Even when a teller couldn't access the system to log or record their transactions, the auto-create fallback handles it for them. This covers scenarios like:

1. **Unlikely but possible** — the teller had access to the terminal and the branch was operational, but they simply didn't create their TCR.
2. **External disruptions** — power outage (can't turn on terminals/computers), internet connection issues, or other reasons that prevented terminal or computer access.

## Auto-Creation Conditions

The system will auto-create a TCR for a teller if any of the following conditions are met:

| # | Condition | Description |
|---|---|---|
| 1 | **Has transactions but no TCR** | The teller has transactions inserted in `[dbo].[E-Business Services Inc_$Branch Journal Line]` but doesn't have a TCR for the current date yet |
| 2 | **Has eBarls transactions tagged to them** | eBarls transactions are those remotely done by another teller at a different branch through their terminal, and after processing, they tag those transactions to the owner of the actual transaction. If the teller has eBarls transactions tagged to them and no TCR exists, the system creates one |
| 3 | **Has a floating amount from the previous day** | The teller's previous date's TCR has a non-zero `[Ending Balance]`, meaning there's a floating amount that wasn't declared as either cash shortage or cash overage (depending on whether the sign is `+` or `-`) |

---

*Last updated: June 2026*

