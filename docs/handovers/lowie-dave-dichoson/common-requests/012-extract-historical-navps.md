# Extract Historical NAVPS

**NAVPS** — Net Asset Value Per Share

## Who Asks

| | |
|---|---|
| **Requested by** | PEMI Sales Team |
| **How they ask** | Email, Sapphire Ticket |
| **Frequency** | Ad-hoc |

## What It Is

This request comes from the Sales Team asking us to extract historical NAVPS data from the PEMI Website's database. The data is straightforward to retrieve via the server's `phpmyadmin` from the `dailyfunds` table.

## Prerequisites

- Proficiency navigating `phpmyadmin`
- Working knowledge of MySQL
- Access to the production server's `phpmyadmin`
- Valid login credentials for `phpmyadmin`

## Steps

1. **Log in to phpmyadmin** — Navigate to the production server's `phpmyadmin` URL and log in using your credentials.

2. **Select the database** — Once logged in, click on the `philequity` database from the left-hand sidebar to select it.

3. **Select the table** — From the list of tables within the `philequity` database, click on the `dailyfunds` table. This table stores all daily fund NAVPS records.

4. **Open the Export screen** — On the top menu bar, click the **Export** tab. This opens the export configuration page.

5. **Configure the export settings** — The export screen provides several options:
   - **Export method:** Choose **Custom** for more control (lets you select specific rows, columns, or date ranges). Use **Quick** if you want the entire table as-is.
   - **Format:** Select **CSV** (usually the requested format for this report).
   - **Rows to export (if using Custom):** You can specify a date range or row limit to narrow down the exported data (e.g., export only records from a specific year).
   - **CSV-specific options (if using CSV format):**
     - *Columns separated with:* `,`
     - *Columns enclosed with:* `"`
     - *Columns escaped with:* `\`
     - *Replace NULL with:* (leave blank)
     - Optionally check *"Put columns names in the first row"* to include headers.

6. **Export the file** — Once all settings are configured, click the **Go** button at the bottom of the page. The browser will download the exported file (usually a `.csv` file).

---

*Last updated: June 2026*
