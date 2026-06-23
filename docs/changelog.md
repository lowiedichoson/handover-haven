# Changelog

## 2026-06-15 — Project Initialization

### Added

- **Project scaffold:** Initialized MkDocs project with `pyproject.toml`, `mkdocs.yml`, `README.md`, and `main.py`.
- **Core pages:** Created `index.md` (landing page), `about.md`, and this changelog.
- **Getting Started section:** Added Overview, How to Use guide, Templates, Onboarding Guide, and Glossary.
- **MkDocs configuration:** Material theme with light/dark modes, Mermaid support, code copy, navigation sections, and organized nav structure.

---

## 2026-06-16 — Content Population

### Added

- **Handovers introduction:** Overview of the handover section with layout description and current-handovers table.
- **Lowie Dave Dichoson — About Me:** Personal profile covering role, tenure, supported companies, and parting notes.
- **Systems documented (13):**
  - eTerminal (overview, TCR/BCR simulation, EOD process, auto-create/close TCR, database)
  - eSettlement (overview, backend formulas, database, TCSG daily process)
  - ClientEase (frontend, backend, database, PDF builder, report generator)
  - Voyager, Voyager FX, Synapse, Navision, LOI Generator, FTR Generator, Production Archiving
- **Common Requests documented (13):**
  - Bridge entries: Reverse Entries, Re/create Entries, Transfer Entries to Navision
  - Active Users List, Manual Run of EOD Process, Bypass Synapse Validation
  - Get Bridge Reports, Get MC Approved Transactions, Add ASM Page
  - Add New Fund, Upload Files & Shortened Link, Unsettled Transactions, Extract Historical NAVPS

### Changed

- **Navigation:** Restructured `mkdocs.yml` with full hierarchy — Getting Started, Handovers, person-specific sections with grouped common requests and categorized systems.
- **`about.md`:** Updated sectioning convention to match folder-based handover structure.
- **Renamed** `handovers/overview.md` → `handovers/introduction.md`.
