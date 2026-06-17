# Backend Formula in Esettlement

## Who Asks

| | |
|---|---|
| **Requested by** | Accounting Department or External Auditors |
| **How they ask** | Email, Sapphire Ticket, Walk-up |
| **Frequency** | Ad-hoc |

## What It Is

Esettlement's raw data is coming from the Voyager application and database and Esettlement processes the data internally in its system and transforms it into a processed form of data that can be used for settlement by TCSG department and later on, an automated SQL job translates the processed data into accounting entries that we label as `bridge entries`. In the Esettlement system, there are different formulas used in getting the gross commission, VAT output, Share in FX, and WTAX.

## When This Request Happens

- Accounting usually requires this during their verification process if the `bridge entries` correctly reflect what's in the processed data of Esettlement.
- Auditors need to verify that the `bridge entries` actually match what's in the processed data of Esettlement.

## Prerequisites

- Understanding of how Voyager, Esettlement, and Navision systems connect
- Understanding the underlying backend processes across the systems mentioned above

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