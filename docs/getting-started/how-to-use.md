# How to Use

This guide walks you through adding your handover, step by step.

## Prerequisites

- A [GitHub](https://github.com) account
- [Git](https://git-scm.com) installed locally
- Basic familiarity with Markdown (don't worry — the template does the heavy lifting)

## Step 1: Fork & Clone the Repo

Fork the repository on GitHub, then clone your fork:

```bash
git clone https://github.com/<your-username>/handover-haven.git
cd handover-haven
```

## Step 2: Create Your Folder

Make a folder under `docs/handovers/` using your full name in kebab-case:

```bash
mkdir -p docs/handovers/firstname-lastname
```

Inside it, create these subfolders (you'll fill them in later):

```bash
mkdir -p docs/handovers/firstname-lastname/systems
mkdir -p docs/handovers/firstname-lastname/common-requests
mkdir -p docs/handovers/firstname-lastname/databases
```

## Step 3: Copy the Template

Copy the [Template](template.md) into your folder as `about-me.md`:

```bash
cp docs/getting-started/template.md docs/handovers/firstname-lastname/about-me.md
```

Open `about-me.md` and fill in every section. The more detail, the better —
future you (and your replacement) will thank you.

## Step 4: Add Your Systems

For each system you own, create a Markdown file under `systems/`. At minimum,
cover:

- What the system does
- Where the source code lives (repo links)
- How it's deployed
- Who has access
- Any known issues or quirks

Name the file after the system: `billing-api.md`, `admin-dashboard.md`, etc.

## Step 5: Document Common Requests

If you handled recurring tasks, document them under `common-requests/`. Number
them for easy scanning:

```
common-requests/
  001-reset-user-passwords.md
  002-monthly-report-generation.md
  003-database-restore.md
```

Each file should explain:

- **What the request is** (who asks, how often)
- **How to resolve it** (step-by-step)
- **Who to escalate to** if it goes beyond your scope

## Step 6: Update the Navigation

Open `mkdocs.yml` and add your section under the `Handovers` nav:

```yaml
nav:
  - Handovers:
      - Introduction: handovers/introduction.md
      # ...existing entries...
      - Your Name:
          - About Me: handovers/firstname-lastname/about-me.md
          - Systems:
              - System A: handovers/firstname-lastname/systems/system-a.md
              - System B: handovers/firstname-lastname/systems/system-b.md
          - Common Requests:
              - Request 1: handovers/firstname-lastname/common-requests/001-example.md
```

## Step 7: Preview Locally (Optional)

Install MkDocs and preview your changes:

```bash
pip install mkdocs
mkdocs serve
```

Open `http://127.0.0.1:8000` in your browser and make sure everything looks
right.

## Step 8: Open a Pull Request

Commit your changes, push, and open a PR on GitHub:

```bash
git checkout -b add-handover-firstname-lastname
git add .
git commit -m "docs: add handover for Firstname Lastname"
git push -u origin add-handover-firstname-lastname
```

Add a teammate as a reviewer if you want a sanity check, then merge.

## Step 9: Update the Changelog

Add an entry to `docs/changelog.md` under the current date so the team knows
you've documented your handover.

## Tips

- **Don't store secrets.** Write *who to contact* for credentials, never the
  credentials themselves.
- **Be specific.** "Restart the billing service" is better than "Fix billing
  issues."
- **Link everything.** Repos, dashboards, runbooks, ticket queues — the more
  pointers, the fewer dead ends.
- **You don't need perfection.** A handover that's 80% complete today is worth
  more than one that's 100% complete after you've already left.
