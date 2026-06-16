# Changelog

## 2026-06-16

### Added

- **Handovers introduction:** Populated `handovers/introduction.md` with section overview, handover layout description, and current-handovers table.
- **How to Use guide:** Filled `getting-started/how-to-use.md` — 9-step walkthrough from fork to PR, plus tips.
- **Template:** Filled `getting-started/template.md` — fill-in-the-blanks handover template matching the project structure.
- **Glossary:** Created `getting-started/glossary.md` — company acronyms (PEMI, VEI, VFC), system definitions, team names, and common financial/IT terms.
- **Onboarding Guide:** Created `getting-started/onboarding-guide.md` — role-based reading paths for new ICTG members, managers, and staff at each company.
- **Company pages:** Created `companies/pemi/index.md`, `companies/vei/index.md`, `companies/vfc/index.md` — business context, system-to-handover cross-references, and departments supported by ICTG for each company.
- **Company overview:** Created `companies/index.md` — landing page with group-wide company table.
- **System template:** Created `getting-started/system-template.md` — covers what it is, where it lives, tech stack, access, deployment, common issues, dependencies, and contacts.
- **Common request template:** Created `getting-started/common-request-template.md` — covers who asks, prerequisites, step-by-step instructions, what can go wrong, and escalation paths.
- **README:** Filled `README.md` with project intro, quick links, and local dev instructions.

### Changed

- **Navigation:** Added Companies top-level section (Overview, PEMI, VEI, VFC). Added Onboarding Guide, Glossary, System Template, and Common Request Template under Getting Started.
- **`about.md`:** Updated sectioning convention to match actual folder-based handover structure.
- **`getting-started/index.md`:** Added links to Onboarding Guide, Glossary, and new templates.
- **`about-me.md`:** Fixed company name links to point to the new Companies section.
- **Company pages:** Added footer links to All Companies and Glossary.
- **`handovers/introduction.md`:** Added cross-link to Companies section.
- **`getting-started/how-to-use.md`:** Steps 4 and 5 now reference the System Template and Common Request Template.

## 2026-06-15

### Added

- **Project scaffold:** Initialized MkDocs project with `pyproject.toml`, `mkdocs.yml`, `README.md`, and `main.py`.
- **Core docs:** Created `index.md` (landing page), `about.md` (why handovers matter), and this changelog.
- **Getting Started section:** Added Quick Start guide (`getting-started/index.md`), How to Use walkthrough (`getting-started/how-to-use.md`), and fill-in-the-blanks Template (`getting-started/template.md`).
- **Lowie Dave Dichoson handover — About Me:** Personal profile covering role (Analyst Programmer), tenure (Aug 2023 – Jul 2026), team (ICTG), three supported companies, page organization, and parting notes.
- **Lowie Dave Dichoson handover — Systems (11 stubs):** Created placeholder pages for all systems I supported:
    - `eterminal.md`, `esettlement.md`, `loi-generator.md`, `synapse.md`, `voyager.md`, `voyager-fx.md`, `ftr-generator.md`, `navision.md`, `production-archiving.md`, `clientease-frontend.md`, `clientease-backend.md`
- **Lowie Dave Dichoson handover — Common Requests (4 stubs):** Created numbered incident/request pages:
    - `001-recreation-of-bridge-entries.md`
    - `002-manual-transfer-of-bridge-entries-to-navision.md`
    - `003-backend-formulas-in-esettlement.md`
    - `004-active-users-list.md`
- **Lowie Dave Dichoson handover — Databases:** Created empty `databases/` directory for future schema docs.

### Changed

- **Navigation restructure:** Populated `mkdocs.yml` with full section hierarchy (Getting Started → Handovers → Lowie Dave Dichoson → Systems / Common Requests).
- **Renamed** person overview from `overview.md` to `about-me.md` to avoid confusion with the Getting Started overview.
- **Renamed** `handovers/overview.md` → `handovers/introduction.md`.

### Configured

- **Theme:** Set `shadcn` theme with light/dark Pygments styles, rocket-launch icon, datetime display, and custom accent color.
