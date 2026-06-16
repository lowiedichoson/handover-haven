# [Request Title]

> Copy this template to `docs/handovers/<your-name>/common-requests/NNN-description.md`,
> replace the bracketed placeholders, and delete this notice.

## Who Asks

| | |
|---|---|
| **Requested by** | [Department / role / team — e.g., "Accounting department"] |
| **How they ask** | [Email / ticket / Slack / walk-up] |
| **Frequency** | [Daily / Weekly / Monthly / Quarterly / Ad-hoc] |

## What It Is

[One or two sentences. What are they asking for and why? Example: "Accounting
needs bridge entries from eSettlement manually recreated in Navision when the
automated sync fails — usually after a holiday or system outage."]

## Prerequisites

- [Access to system X]
- [VPN connected]
- [Admin rights on Y]
- [Approval from Z before proceeding]

## Steps

### 1. [First Action]

[What to do. Include exact menu paths, commands, or URLs.]

```sql
-- Example: query to verify the issue
SELECT * FROM BridgeEntries WHERE Status = 'Failed'
```

### 2. [Second Action]

[What to do next.]

```bash
# Example: command to run
python reconcile.py --date 2026-06-16
```

### 3. [Third Action]

[Continue until the task is complete.]

### 4. Verify

[How to confirm the fix worked. What should the user see? What numbers should
match?]

## What Can Go Wrong

| Symptom | Cause | What to Do |
|---|---|---|
| [e.g., "Duplicate entries appear"] | [Ran the script twice] | [Delete duplicates in Navision, re-run once] |
| [e.g., "Script won't run"] | [VPN disconnected] | [Reconnect VPN, try again] |

## Escalation

If you can't resolve this after following the steps above:

| Priority | Contact | Role |
|---|---|---|
| 1st | [Name / Team] | [e.g., "Senior dev who knows the integration"] |
| 2nd | [Name / Team] | [e.g., "Manager who can authorize workarounds"] |

---

*Last updated: [Month Year]*
