# Adding New ASM Page

## Who Asks

| | |
|---|---|
| **Requested by** | PEMI Sales Team |
| **How they ask** | Email, Sapphire Ticket |
| **Frequency** | Yearly |

## What It Is

Adding a new ASM page is a yearly request from the PEMI Sales Team. It is a web page that displays the Annual Stockholders' Meeting (ASM) information for the mutual funds and services that Philequity Management, Inc. offers.

## Personal Preference

- I usually copy the previous year's ASM page as a baseline and update the necessary information to match the current date and the content provided by the requestor.

## What They Usually Provide

- Proposed shortened link for the new web page
- Attachments (usually PDF, but may vary) to be uploaded to the server, along with a shortened link for each


## Prerequisites

- Familiarity with navigating the PEMI Website source code
- HTML/CSS, JavaScript, and PHP knowledge
- VS Code, PHP 5.6.40, and XAMPP on your development environment
- Access to the source code repository on GitHub
- ***If deploying to production:*** approved JRF and release files (a compilation of new and/or modified files that need to be deployed to production)

## Steps

### 1. Copy and Rename `ASM2025.htm` → `ASM2026.htm`

- Ensure that any `.htm` files you create are placed inside the `templates/` directory of the source code.
- Apply your changes in the `.htm` file, strictly following the content provided by the requestor.

### 2. Copy and Rename `ASM2025.php` → `ASM2026.php`

- This will serve as the server-side code for your template file (`.htm`).
- Apply changes if necessary.
- `.php` files are usually placed at the root directory. If they are better suited for a subdirectory, use your judgment to determine the appropriate location.

### 3. Attachments

- If videos need to be attached, they are typically deployed to a specific directory on the production server. Currently, we place them in a single folder so they can be referenced as needed in the `.htm` file.

---

*Last updated: June 2026*
