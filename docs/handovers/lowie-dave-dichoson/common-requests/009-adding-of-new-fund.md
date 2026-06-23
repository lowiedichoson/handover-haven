# Adding a New Fund

## Who Asks

| | |
|---|---|
| **Requested by** | PEMI Sales Team / Management |
| **How they ask** | Email, Meeting |
| **Frequency** | Ad-hoc |

## What It Is

Adding a new fund is required whenever Philequity Management, Inc. launches a new mutual fund. The PEMI Website has an admin panel, but it lacks the functionality to add a new fund entirely through it. As a result, most of the work involves manually coding new pages and adding the necessary records directly into the database.

## What They Usually Provide

- Name of the new fund
- Fund details (investment objective, currency, fund manager, etc.)
- Fund factsheet and other marketing materials
- Benchmark index data for comparison (e.g., PSEi, BPHILR) — **only if the fund needs to be compared against an index**

## Prerequisites

- Access to the PEMI Website source code repository on GitHub
- Access to the production database (via phpmyadmin)
- HTML/CSS, JavaScript, PHP, and MySQL knowledge
- VS Code, PHP 5.6.40, and XAMPP on your development environment
- ***If deploying to production:*** approved JRF and release files

## Files to Create or Modify

> 📁 *Based on the PGFI (Philequity Global Fund, Inc.) release. Adjust file names per fund.*

### Root-level PHP / CSS

| File | Action |
|---|---|
| `{fund_code}.php` (e.g., `pgfi.php`) | **Create** — main fund page |
| `{fund_code}_graph.php` (e.g., `pgfi_graph.php`) | **Create** — graph/chart page |
| `index.php` | **Modify** |
| `downloadCenter.php` | **Modify** |
| `redeem.php` | **Modify** |
| `pefi_historicalnavps.php` | **Modify** |
| `redeem_settlement_account_number.php` | **Modify** |
| `returnCalculator.php` | **Modify** |
| `styles.css` | **Modify** |

### `templates/`

| File | Action |
|---|---|
| `templates/{fund_code}.htm` (e.g., `pgfi.htm`) | **Create** — main template |
| `templates/{fund_code}_tag_menu.htm` | **Create** — tag menu |
| `templates/{fund_code}_description.htm` | **Create** — description section |
| `templates/{fund_code}_features.htm` | **Create** — features section |
| `templates/{fund_code}_fund_performance.htm` | **Create** — performance section |
| `templates/leftmenu.htm` | **Modify** |
| `templates/index.htm` | **Modify** |
| `templates/paof.htm` | **Modify** |
| `templates/summaryOfProducts.htm` | **Modify** |
| `templates/downloadCenter.htm` | **Modify** |

### `includes/`

| File | Action |
|---|---|
| `includes/template_engine_v1.php` | **Modify** |
| `includes/common.php` | **Modify** |

### `Admin/`

| File | Action |
|---|---|
| `Admin/admin.html` | **Modify** |
| `Admin/navigator.php` | **Modify** |
| `Admin/dailymxwd.php` | **Create** — only if fund needs benchmark/comparison index tracking |
| `Admin/dailynavps.php` | **Modify** |
| `Admin/download.php` | **Modify** |
| `Admin/includes/admin_common.php` | **Modify** |
| `Admin/includes/dailymxwd_default.php` | **Create** — only if fund needs benchmark/comparison index tracking |
| `Admin/includes/dailymxwd_add_edit.php` | **Create** — only if fund needs benchmark/comparison index tracking |
| `Admin/includes/dailymxph_default.php` | **Modify** |
| `Admin/includes/dailymxph_add_edit.php` | **Modify** |
| `Admin/includes/dailynavps_default.php` | **Modify** |
| `Admin/includes/dailynavps_add_edit.php` | **Modify** |
| `Admin/includes/downloadcenter_default.php` | **Modify** |
| `Admin/includes/downloadcenter_add_edit.php` | **Modify** |
| `Admin/includes/download_add_edit.php` | **Modify** |

### `images/`

| File | Action |
|---|---|
| `images/{fund_code}-logo.jpg` (e.g., `philequity-global-fund-inc.jpg`) | **Add** — fund logo/photo |
| `images/{fund_code}-product-highlight-sheet.png` | **Add** — highlight sheet thumbnail |

### `Forms/` (PDFs)

| File | Action |
|---|---|
| `Forms/{fund_code} - Product Highlight Sheet.pdf` | **Add** — fund-specific PDF |

### `database-scripts/`

| File | Action |
|---|---|
| `database-scripts/insert_to_funds_table.txt` | INSERT INTO `funds` |
| `database-scripts/insert_to_contents.txt` | INSERT INTO `contents` |
| `database-scripts/insert_description_to_subcontent.txt` | INSERT INTO `subcontent` (Description) |
| `database-scripts/insert_features_to_subcontent.txt` | INSERT INTO `subcontent` (Features) |
| `database-scripts/insert_snapshot_to_subcontent.txt` | INSERT INTO `subcontent` (Snapshot) |
| `database-scripts/insert_fund_performance_to_subcontent.txt` | INSERT INTO `subcontent` (Fund Performance) |
| `database-scripts/update-invest-and-redeem-page.txt` | UPDATE `contents` |
| `database-scripts/create_daily_mxwd_table.txt` | CREATE TABLE `dailymxwd` (only if fund needs a benchmark/comparison index — see note below) |
| `database-scripts/create-backup-tables.txt` | Backup existing tables before changes |

### Database Tables Affected

| Table | Operation | Notes |
|---|---|---|
| `funds` | **INSERT** | Fund master list record |
| `contents` | **INSERT + UPDATE** | Content entries; update invest/redeem page |
| `subcontent` | **INSERT** (×4) | Snapshot, Fund Performance, Features, Description |
| `dailymxwd` | **CREATE** _(optional)_ | Only if fund needs a benchmark/comparison index (e.g., PSEi, BPHILR) — data must be provided by the requestor |

## Steps

### 1. Add Fund Records to the Database

The database stores fund information in dedicated tables. You will need to insert new rows for the fund being added — this typically includes entries in the following tables (based on the PGFI release):

| Table | What to Insert |
|---|---|
| `funds` | Fund master record (eid, type, amounts, status, etc.) |
| `contents` | Main content entry for the fund |
| `subcontent` | 4 rows — Description, Features, Snapshot, Fund Performance |

> **Note on benchmark/comparison index:** Some funds need to be compared against a market index (e.g., PSEi, BPHILR) on their performance page. For PGFI, a new `dailymxwd` table was created for this. Other funds may use an existing table if their benchmark index is already tracked in the database. Check with the requestor — if they don't provide benchmarking data, skip this entirely.

Always back up existing tables before making changes.

Open phpMyAdmin and run the scripts in `database-scripts/` sequentially.

### 2. Create Fund-Specific Pages

Create the necessary template and PHP files for the new fund. Based on the PGFI release, this typically includes:

**New files to create (model after an existing fund):**  
- `{fund_code}.php` — main fund page (root)  
- `{fund_code}_graph.php` — graph/chart page (root)  
- `templates/{fund_code}.htm` — main template  
- `templates/{fund_code}_tag_menu.htm` — tag menu  
- `templates/{fund_code}_description.htm` — description section  
- `templates/{fund_code}_features.htm` — features section  
- `templates/{fund_code}_fund_performance.htm` — fund performance section

**Existing files to modify:**  
- Update `templates/leftmenu.htm`, `templates/index.htm`, `templates/summaryOfProducts.htm` to add navigation links to the new fund  
- Update `includes/template_engine_v1.php` and `includes/common.php` to register the new fund  
- Update `index.php`, `downloadCenter.php`, `redeem.php`, etc. to include the new fund

### 3. Update Admin Panel

Modify the admin files to support the new fund in the backend interface:

- `Admin/admin.html` and `Admin/navigator.php` — add navigation entries
- `Admin/dailynavps.php` + includes — register the fund for NAVPS entry
- `Admin/dailymxwd.php` + includes — create only if the fund needs a benchmark/comparison index (e.g., PSEi, BPHILR)
- `Admin/download.php` + includes — register the fund in download center
- `Admin/includes/admin_common.php` — add fund to admin common config

### 4. Upload Attachments and Configure Shortened Links

Upload any provided attachments (factsheets, PDFs, images) to the appropriate directory on the server. Create shortened links for them as needed and reference them in the fund pages.

### 5. Verify Locally Before Deployment

Run the website locally using XAMPP to verify that:

- The new fund pages render correctly.
- NAVPS data loads and displays properly.
- Navigation links point to the correct URLs.
- All attachments are accessible.

Once verified, proceed with the standard deployment process (JRF, release files, etc.).

---

*Last updated: June 2026*
