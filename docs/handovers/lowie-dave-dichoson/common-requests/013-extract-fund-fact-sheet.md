# Extract Fund Fact Sheet

Fund Fact Sheets are monthly/quarterly PDF documents published on the PEMI Website.

## Who Asks

| | |
|---|---|
| **Requested by** | PEMI Sales Team |
| **How they ask** | Email, Sapphire Ticket |
| **Frequency** | Ad-hoc |

## What It Is

The Sales Team requests dated fund fact sheets from the PEMI Website. These files are stored in the server's database and filesystem. Retrieving them requires querying the `philequity` database via `phpmyadmin` to find the file reference, then locating the actual file on the production server.

## Prerequisites

- Proficiency navigating `phpmyadmin`
- Working knowledge of MySQL
- Access to the production server's `phpmyadmin`
- Valid login credentials for `phpmyadmin`
- Access to the production server's file system

## Steps

> **Note:** This guide uses the *Downloads Center* category as a walkthrough example. Adapt the category and search terms to match the specific fund fact sheet you're looking for.

1. **Log in to phpmyadmin** — Navigate to the production server's `phpmyadmin` URL and log in using your credentials.

2. **Select the database** — Once logged in, click on the `philequity` database from the left-hand sidebar to select it.

3. **Identify available categories** — Run the following query to see all categories in the PEMI Website:

    ```sql
    SELECT DISTINCT category
    FROM contents;
    ```

    The results will show which PEMI Website category the file you need is stored under. Identify the relevant category (e.g., *Download Center*).

4. **Find the report name** — With the category identified, query for the specific report names within that category:

    ```sql
    SELECT DISTINCT name
    FROM contents
    WHERE category = 'Download Center';
    ```

    The results will list all report names under that category. Identify the exact report(s) you need from the list.

5. **Look up file references in `subcontent`** — Once you've identified the report name, proceed to the `subcontent` table to find the actual file reference:

    ```sql
    SELECT *
    FROM subcontent
    WHERE category = 'PAOF Fact Sheets';
    ```

    This returns all reports uploaded under the given subcategory.

6. **Examine the query results** — Focus on the following two columns:

    | Column | Description |
    |---|---|
    | `name` | The display title in the PEMI Website Admin Panel |
    | `docfile` | The actual file name on the production server |

    Look through the results to find the file you need.

7. **Locate and retrieve the file** — Using the `docfile` value from the previous query, navigate to the production server's source files and search for the file by its name. Once located, copy or download it to provide to the requester.

---

*Last updated: June 2026*
