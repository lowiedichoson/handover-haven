# Active Users List

## Who Asks

| | |
|---|---|
| **Requested by** | Branch Operations or External Auditors |
| **How they ask** | Email, Sapphire Ticket, Walk-up |
| **Frequency** | Ad-hoc |

## What It Is

This request is initiated by either the Branch Operations Department or External Auditors, who need an up-to-date list of active users from both `Esettlement` and `Eterminal`.

> If you only need the users for **Eterminal**, start with [Step 1](#1-run-the-following-script-in-navision-database).  
> If you only need the users for **Esettlement**, start with [Step 3](#3-run-the-following-script-in-bridgedb-database).

## When This Request Happens

- Branch Operations or Auditors require an updated list of active users from the `Esettlement` and `Eterminal` systems.
- Auditors need to verify that certain actions or events recorded in the systems were performed by the actual user who initiated them.

## Prerequisites

- Read-only access to the `[Navision]` database (for `Eterminal`)
- Read-only access to the `[BridgeDb]` database (for `Esettlement`)
- An email request from the requesting department

## Steps

### 1. Run the following script in the `[Navision]` database (Eterminal)

```sql
SELECT
	a.[OperatorID],
	a.[Last Name] + ', ' + a.[First Name] [Name],
	a.[OperatorEmployeeNumber] [Employee Number],
	--a.[Old OperatorID],
	(CASE WHEN a.[Status] = 0 THEN 'Active' ELSE 'Inactive' END) [Status],
	(CASE WHEN a.[RoleID] = '' THEN 'Teller' ELSE a.RoleID END) [RoleID],
	a.[E-Mail],
	c.[Name] [Branch],
	a.[DateTimeCreated],
	--a.[DateTimeUpdated],
	a.[DatetimeDeactivated],
	a.[Created by],
	b.[EventDateTime] [Last Login Date]
FROM [dbo].[E-Business Services Inc_$Employee] a
OUTER APPLY (
	SELECT TOP 1 b.[EventDateTime]
	FROM [AuditTrail] b
	WHERE a.[OperatorID] = b.[UserID]
	AND b.[EventDescription] = 'Login'
	ORDER BY b.[EventDateTime] DESC
	) b
INNER JOIN [dbo].[E-Business Services Inc_$Dimension Value] c ON a.[Branch Code] = c.[Code]
ORDER BY [OperatorID] ASC
```

### 2. Extract the results to Excel / Google Sheets

1. In the results view, right-click the top-left corner of the grid and select **Copy with Headers**.
2. Paste the results into an Excel file or Google Sheet.
3. Share the file via email for proper documentation.

### 3. Run the following script in the `[BridgeDb]` database (Esettlement)

```sql
SELECT 
    a.[username] [Username],
    UPPER(a.[lastname]) + ', ' + UPPER(a.[firstname]) [Name],
    a.[emp_number] [Employee ID],
    (CASE WHEN a.[Status] = 1 THEN 'ACTIVE' ELSE 'INACTIVE' END) [Status],
    --a.[Status_Locked] [Status Locked],
    a.[date_created] [Date Created],
    a.[Password_Datetime_Changed] [Password DateTime Changed],
    CASE 
		WHEN a.[roleid] = 1 THEN UPPER('ADMINISTRATOR')
		WHEN a.[roleid] = 2 THEN UPPER('USER')
		WHEN a.[roleid] = 3 THEN UPPER('Treasury Admin')
		WHEN a.[roleid] = 4 THEN UPPER('Treasury Operations')
		ELSE '' 
	END [Role ID],
    CASE 
		WHEN a.[approvallevel] = 1 THEN 'MAKER' 
		WHEN a.[approvallevel] = 2 THEN 'CHECKER'
		ELSE 'APPROVER' 
	END [Approval Level],
    b.[logtime] [Last Login Date] -- Get the latest login time
FROM [Users] a
OUTER APPLY (
    SELECT TOP 1 b.[logtime]
    FROM [Audit_Trail_Pocket] b
    WHERE a.[username] = b.[user] 
    AND b.[event] = 'Login'
    ORDER BY b.[logtime] DESC
) b
WHERE a.[username] <> ''
ORDER BY a.[username]
```

### 4. Extract the Esettlement results

Repeat [Step 2](#2-extract-the-results-to-excel--google-sheets) for the `Esettlement` results.

---
*Last updated: June 2026*
