# Database Reference

A consolidated reference of all databases across systems, showing which systems share which databases and how data flows between them.

---

## Overview

| Database | Server | Shared By | Purpose |
|---|---|---|---|
| **EBIZ PROD DATABASE** | `172.30.0.210` | [Navision](systems/navision.md), [Synapse](systems/synapse.md) | Core ERP / Navision database — holds accounting entries, general ledger, and Synapse's bridge data |
| **Navision** *(eTerminal's DB)* | `172.30.0.125` | [eTerminal](systems/eterminal/eterminal.md) | eTerminal's operational database — teller cash reports, branch journal lines, CPR entries |
| **BridgeDb** | `172.30.1.209` | [eSettlement](systems/esettlement/esettlement.md), [FTR Generator](systems/ftr-generator.md) | Settlement transaction data, bridge accounting entries, FTR report source |
| **Voyager** | `172.30.1.209` | [eSettlement](systems/esettlement/esettlement.md), [Voyager FX](systems/voyager-fx.md) | Western Union Voyager raw transaction data |
| **Treasury** | `172.30.1.209` | [Voyager FX](systems/voyager-fx.md) | Treasury / accounting entries, FX settlement data |
| **Ideal Funds** | Ask IT Administrators | [LOI Generator](systems/loi-generator.md) | Oracle — PEMI mutual funds data |
| **Cashtrea** | Ask IT Administrators | [LOI Generator](systems/loi-generator.md) | Oracle — VEI transaction data |
| **philequity** | Ask IT Administrators | [PEMI Website](systems/pemi-website.md) | MySQL — PEMI website content and NAVPS data |

---

*Last updated: June 2026*
