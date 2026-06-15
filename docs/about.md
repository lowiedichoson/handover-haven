# About This Guide

## Why Handover Haven Exists

When someone leaves, the team loses more than a person — they lose context,
relationships, tribal knowledge, and often months of institutional memory.
A good handover captures all of that **before** the last day.

This site is the team's single source of truth for:
- What each person owned
- What state they left it in
- Who to talk to next
- The unwritten rules nobody documented

## How It Works

1. **When you resign**, fork this repo, add your handover using the
   [template](getting-started/template.md), and open a PR.
2. **When you onboard**, read the handovers relevant to your role.
3. **When you discover something missing**, add it. This is a living document.

## Sectioning Convention

Every handover lives under `docs/handovers/<your-name>/` as a folder with
subpages. This keeps things scannable and prevents anyone from dumping
everything into one giant file.

Each handover folder follows a consistent structure:

- `about-me.md` — 🧑 Personal info, role, tenure, team, and parting notes
- `systems/` — 📁 One file per system: what it does, repo links, deployment, access, quirks
- `common-requests/` — 📋 Numbered runbooks for recurring tasks and incidents
- `databases/` — 🗄️ Schemas, key tables, and data flows (optional)

The [Getting Started guide](getting-started/how-to-use.md) walks through
creating each of these, and the [template](getting-started/template.md) gives
you a head start.

## For Future Contributors

You don't need permission. If you're leaving, **your handover belongs here.**
Follow the [Getting Started guide](getting-started/how-to-use.md), use the
template, and add your name to the nav in `mkdocs.yml`.

The only rule: **leave it better than you found it.**