# Get Bridge Reports

## Who Asks

| | |
|---|---|
| **Requested by** | Compliance, TCSG |
| **How they ask** | Email, Sapphire Ticket, Walk-up |
| **Frequency** | Ad-hoc |

## What It Is

Bridge reports are used to verify the bridge entries transferred to Navision. They're one of the reports both TCSG and the Accounting department use to verify amounts before posting in Navision.

## When This Request Happens

- Compliance / Internal Audit group samples the requested data as part of their audit review.

## Prerequisites

- If data is already in the archive environment, read-only access to that server's `BridgeDb` database
- If data is still in production, just let them get the reports themselves using the eSettlement system.
- Knowledge of the tables in the query shown below so you can modify it to suit exactly what you need.

## Steps

> This query is derived from the stored procedure `[dbo].[spgetRepbyParamAll]` — the same procedure called when the **Generate** button is clicked inside the **Bridge Reports** module in the eSettlement system.

### 1. Declare parameters in the query

Possible values for the following parameters are:  

- @Currency - `API` or `APZ`  
- @RepDateFrom - any date that is needed, as long as the format is `yyyyMMdd`  
- @RepDateTo - any date that is needed, as long as the format is `yyyyMMdd` and it should be later than @RepDateFrom  
- @Description - `SUB-AGENT` or `BRANCH`  
- @ID - `0` if all sub-agents or branches; modify if you need to extract a specific branch's or sub-agent's transactions

```sql
DECLARE @Currency VARCHAR(3) = 'API';
DECLARE @RepDateFrom VARCHAR(8) = '20260413';
DECLARE @RepDateTo VARCHAR(8) = '20260415';
DECLARE @Description VARCHAR(10) = 'SUB-AGENT';
DECLARE @ID INT = 0;
```

### 2. Query for getting the report

```sql
IF @Currency = 'API'
	BEGIN

	SELECT 
		brsadetail.brsaid,
		isnull(brsadetail.brsabankflg, 0) AS brsabankflg,
		brsadetail.costcenter,
		txnentry.mtcn,
		txnentry.terminalid,
		txnentry.operatorid,
		txnprocessed.repdate,
		CASE WHEN txnprocessed.repdate >= '20170418' THEN txnprocessed.ivat ELSE 0 END AS ivat,
		brsadetail.brsaname,
		brsadetail.brsadesc,
		isnull(brsacomm.safxrate, 0) AS safxrate,
		txnprocessed.sendpayindicator,
		txnprocessed.direction,
		grosscomm,
		ovat,
		sacommission,
		sasfx,
		wtax,
		duetosa,
		duetobranch,
		duefromwu,
		sfx,
		recprincipalloc AS sploc,
		totalchargesloc AS scloc,
		clearprincipalloc AS pploc,
		clearchargesloc AS csloc,
		clearfxloc AS fxloc,
		@Currency as currency,
		substring(brsabankgl.glcodephp, 1, 5) AS glcodephp,
		substring(brsabankgl.glcodeusd, 1, 5) AS glcodeusd,
		brsabankgl.gldescphp,
		brsabankgl.gldescusd,
		txnentry.ProductCode,
		txnentry.ProductGroup
	FROM [VOYAGER-ARCH].[BridgeDb].[dbo].[txnprocessed]
	INNER JOIN [VOYAGER-PROD].[BridgeDb].[dbo].brsaaccount ON txnprocessed.account = brsaaccount.account
	INNER JOIN [VOYAGER-PROD].[BridgeDb].[dbo].brsadetail ON brsaaccount.brsaid = brsadetail.brsaid
	INNER JOIN [VOYAGER-ARCH].[BridgeDb].[dbo].txnentry ON txnprocessed.id = txnentry.id
	INNER JOIN [VOYAGER-PROD].[BridgeDb].[dbo].brsacomm ON brsadetail.brsaid = brsacomm.brsaid
	LEFT JOIN [VOYAGER-PROD].[BridgeDb].[dbo].brsabankgl ON brsadetail.brsaid = brsabankgl.brsaid
	--WHERE substring(txnprocessed.account, 1, 3) = @cur
	WHERE txnprocessed.account LIKE @Currency + '%'
	AND brsadetail.brsadesc = @Description
	AND brsadetail.brsaid = coalesce((CASE WHEN @ID = 0 THEN NULL ELSE @ID END), brsadetail.brsaid)
	AND txnprocessed.repdate BETWEEN @RepDateFrom AND @RepDateTo
	ORDER BY
		txnentry.repdate,
		brsadetail.brsaid,
		txnprocessed.account,
		txnprocessed.sendpayindicator ASC;

	END

ELSE
	BEGIN

	SELECT brsadetail.brsaid,
		isnull(brsadetail.brsabankflg, 0) AS brsabankflg,
		brsadetail.costcenter,
		txnentry.mtcn,
		txnentry.terminalid,
		txnentry.operatorid,
		txnprocessed.repdate,
		CASE WHEN txnprocessed.repdate >= '20170418' THEN txnprocessed.ivat ELSE 0 END AS ivat,
		brsadetail.brsaname,
		brsadetail.brsadesc,
		isnull(brsacomm.safxrate, 0) AS safxrate,
		txnprocessed.sendpayindicator,
		txnprocessed.direction,
		grosscomm,
		ovat,
		sacommission,
		sasfx,
		wtax,
		duetosa,
		duetobranch,
		duefromwu,
		sfx,
		recprincipalusd AS sploc,
		totalchargesusd AS scloc,
		clearprincipalusd AS pploc,
		clearchargesusd AS csloc,
		clearfxusd AS fxloc,
		@Currency as currency,
		substring(brsabankgl.glcodephp, 1, 5) AS glcodephp,
		substring(brsabankgl.glcodeusd, 1, 5) AS glcodeusd,
		brsabankgl.gldescphp,
		brsabankgl.gldescusd,
		txnentry.ProductCode,
		txnentry.ProductGroup
	FROM [VOYAGER-ARCH].[BridgeDb].[dbo].txnprocessed
	INNER JOIN [VOYAGER-PROD].[BridgeDb].[dbo].brsaaccount ON txnprocessed.account = brsaaccount.account
	INNER JOIN [VOYAGER-PROD].[BridgeDb].[dbo].brsadetail ON brsaaccount.brsaid = brsadetail.brsaid
	INNER JOIN [VOYAGER-ARCH].[BridgeDb].[dbo].txnentry ON txnprocessed.id = txnentry.id
	INNER JOIN [VOYAGER-PROD].[BridgeDb].[dbo].brsacomm ON brsadetail.brsaid = brsacomm.brsaid
	LEFT JOIN [VOYAGER-PROD].[BridgeDb].[dbo].brsabankgl ON brsadetail.brsaid = brsabankgl.brsaid
	--WHERE substring(txnprocessed.account, 1, 3) = @cur
	WHERE txnprocessed.account LIKE @Currency + '%'
	AND brsadetail.brsadesc = @Description
	AND brsadetail.brsaid = coalesce((CASE WHEN @ID = 0 THEN NULL ELSE @ID END), brsadetail.brsaid)
	AND txnprocessed.repdate BETWEEN @RepDateFrom AND @RepDateTo
	ORDER BY
		txnentry.repdate,
		brsadetail.brsaid,
		txnprocessed.account,
		txnprocessed.sendpayindicator ASC;

	END
```

---


*Last updated: June 2026*
