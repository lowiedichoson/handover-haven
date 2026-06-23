# Uploading Files and Creating Shortened Links

## Who Asks

| | |
|---|---|
| **Requested by** | PEMI Sales Team |
| **How they ask** | Email, Sapphire Ticket |
| **Frequency** | Ad-hoc |

## What It Is

There are instances where the PEMI Sales Team needs to add a new file (usually a PDF) containing information to share with investors, or create a clean redirect to an existing page. They request a customized shortened link so it's clean and easy to share — for example, `www.philequity.net/ASM2025` or `www.philequity.net/BDO_BillsPaymentGuidelines` — instead of a long, unmemorable URL.

## What They Usually Provide

- The file to be uploaded (usually PDF, but may vary)
- The desired shortened link name (e.g., `ASM2025`)

## Prerequisites

- Access to the PEMI Website production server (via FTP or similar)
- PHP knowledge
- Approved JRF and release files (if deploying to production)

## Steps

### 1. Create a Folder Named After the Shortened Link

On the production server, create a new folder in the root directory of the source code. Name it exactly as the desired shortened link.

### 2. Add an `index.php` File Inside the Folder

Inside the newly created folder, place an `index.php` file with a redirect header. What it redirects to depends on the request:

**Scenario A — Redirect to a PHP page** (e.g., `www.philequity.net/ASM2025` → `ASM2025.php`):

```php
<?php
session_start();

header('Location: https://www.philequity.net/ASM2025.php');

?>
```

**Scenario B — Redirect directly to a PDF** in the same folder (e.g., `www.philequity.net/BDO_BillsPaymentGuidelines` → a PDF):

```php
<?php
session_start();

header('Location: /BDO_BillsPaymentGuidelines/PEMI BDO Bills Payment - Guidelines_Revised_2026.pdf');

?>
```

### 3. Upload the File (if applicable)

If the link points to a PDF (Scenario B), upload the PDF file inside the same folder alongside the `index.php`.

---

---

*Last updated: June 2026*
