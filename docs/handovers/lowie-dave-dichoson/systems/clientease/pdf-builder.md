# PEMIClientEase.PDFGenerator

## What It Is

A class library that generates **Client Information Summary PDFs** for Philequity (PEMI) investor onboarding and account management workflows. It is consumed by a parent ASP.NET web API — the API collects investor data and feeds it to `InvestorDocument`, which composes a multi-section PDF covering personal details, addresses, employment, FATCA/PEP compliance, risk profile, bank details, coinvestors, declarations, video verification schedules, and uploaded attachments. The same document can be rendered as an **internal compliance copy** (with attachments) or a **client-facing copy** (without attachments).

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | [GitHub](https://github.com/PEMIClientEase/PEMIClientEase.PDFGenerator) |

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | C# 12 |
| **Framework** | .NET 8.0 (LTS) |
| **PDF Library** | QuestPDF 2025.12.1 (Community License) |
| **Project Type** | Class Library (`Microsoft.NET.Sdk`) |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| **[Parent ASP.NET Web API](backend.md)**  | Provides the investor data models (`PrimaryInvestor`, `Coinvestor`, etc.) | PDF cannot be downloaded by the investor / user |
| **QuestPDF NuGet** | Core PDF rendering engine | Everything fails — no PDF output |
| **ClientEase Report Generator** | Provides the list version of data models, intended for Sales team | PDFs of the investors will not be generated |

## Process Flow Diagrams

### 1. PDF Generation Flow

#### 1a. Data Input & Setup

```mermaid
flowchart TD
    A["<b>ClientEase API</b><br/>Caller: AttachmentService"] --> B["Fetch investor data from<br/>PostgreSQL clientease<br/><i>(Users + Attachments repos)</i>"]

    B --> C["Build <b>PrimaryInvestor</b> model<br/>personal info, addresses, employment,<br/>bank, risk profile, coinvestors,<br/>questionnaire items, PEP persons,<br/>files, schedules"]

    C --> D["Load static assets"]
    D --> D1["Company logo (PNG bytes)<br/><i>from Assets/ on filesystem</i>"]
    D --> D2["Checkbox SVG string<br/><i>checked + unchecked</i>"]

    D1 --> E
    D2 --> E

    E["<b>new InvestorDocument(</b><br/>primary, logo, checkBox,<br/>uncheckedBox, isClientFacing<b>)</b>"] --> F{"isClientFacing?"}

    F -->|"false (internal)"| G["<b>Full compliance copy</b><br/>Includes all attachments/images"]
    F -->|"true (client)"| H["<b>Client-facing copy</b><br/>Excludes attachment images<br/><i>(privacy redaction)</i>"]

    G --> I
    H --> I

    I["<i>Static constructor:</i><br/><b>QuestPDF.Settings.License =<br/>LicenseType.Community</b>"] --> J["document.<b>GeneratePdf(stream)</b><br/>or <b>GeneratePdf(filePath)</b>"]

    J --> K(["Return PDF stream<br/>to Angular frontend<br/>as HTTP download"])
```

#### 1b. Document Composition Pipeline

```mermaid
flowchart TD
    A["<b>InvestorDocument.Compose()</b><br/><i>called by QuestPDF engine</i>"] --> B["Set <b>page layout</b><br/>Margin: 30px all sides"]

    B --> C["<b>ComposeHeader()</b>"]
    C --> C1["Logo image<br/><i>120px constant width</i>"]
    C --> C2["Title text<br/><i>CLIENT INFORMATION SUMMARY<br/>16pt ExtraBold, blue</i>"]
    C --> C3["Action text<br/><i>Client Account Creation<br/>or Client Account Update<br/>11pt SemiBold, blue</i>"]

    C1 --> D
    C2 --> D
    C3 --> D

    D["<b>ComposeContent()</b><br/>Vertical column, 5px spacing"] --> E{"See<br/>1c. Section Rendering Order"}

    E --> F["<b>Page breaks</b> inserted at:<br/>1. After VideoVerification<br/>2. After Declaration<br/>3. Within ImagesComponent<br/><i>(between person/file-type groups)</i>"]

    F --> G["<b>Footer</b> on every page"]
    G --> G1["Line 1: Date and Time Created:<br/><i>PH time (UTC+8), MMMM dd, yyyy - h:mm tt</i>"]
    G --> G2["Line 2: Ticket Number"]
    G1 --> H
    G2 --> H

    H(["PDF rendered to<br/>Stream / FilePath"])
```

#### 1c. Section Rendering Order

```mermaid
flowchart TD
    A["<b>ComposeContent()</b> starts"] --> B["1. <b>AccountAndSubmissionComponent</b><br/>2-column table: ticket#, account name,<br/>submission date/time"]
    B --> C["2. <b>VideoVerificationComponent</b><br/>Schedule options: date + time"]

    C --> D["<b>── PAGE BREAK ──</b>"]

    D --> E["3. <b>'Primary Investor' badge</b><br/><i>Yellow background, centered</i>"]
    E --> F["4. <b>InformationComponent</b><br/>17 personal info fields<br/><i>(IUserInformation)</i>"]
    F --> G["5. <b>AddressComponent</b><br/>Permanent + present address, contacts<br/><i>(IUserAddress)</i>"]
    G --> H["6. <b>EmploymentComponent</b><br/>7 employment + 3 financial fields<br/><i>(IUserEmployment)</i>"]
    H --> I["7. <b>USPersonDeclarationComponent</b><br/>FATCA Q&A<br/><i>(QuestionnaireItems: Compliance)</i>"]
    I --> J["8. <b>PEPComponent</b><br/>Politically Exposed Person table<br/><i>(List&lt;UserPEPRelatedPerson&gt;)</i>"]
    J --> K["9. <b>IRPQComponent</b><br/>4-column risk profiling table<br/><i>(QuestionnaireItems: Risk Profiling)</i>"]
    K --> L["10. <b>RiskProfileComponent</b><br/>Risk score + profile + override checkboxes"]
    L --> M["11. <b>BankComponent</b><br/>6 bank detail fields"]

    M --> N{"Has<br/>coinvestors?"}
    N -->|"Yes"| O["12. Per Coinvestor:<br/><b>CoinvestorsComponent</b>"]
    O --> O1["Badge: 'Co-Investor #N' or 'ITF'"]
    O1 --> O2["Information + Address"]
    O2 --> O3{"Role = ITF?"}
    O3 -->|"No"| O4["Employment"]
    O3 -->|"Yes"| O5["Skip employment & PEP"]
    O4 --> O6["FATCA + PEP (COINVESTOR only)"]
    O6 --> P
    O5 --> P

    N -->|"No"| P["13. <b>DeclarationComponent</b><br/>Terms & conditions checkboxes<br/><i>(+ Coinvestor Conformity if hasCoinvestors)</i>"]

    P --> Q["<b>── PAGE BREAK ──</b>"]

    Q --> R{"isClientFacing?"}
    R -->|"false"| S["14. <b>ImagesComponent</b><br/>Specimen signatures, ID presented,<br/>proof of billing, ITF birth certificates<br/><i>(page breaks between persons)</i>"]
    R -->|"true"| T["SKIP: no attachments<br/><i>(client-facing copy)</i>"]

    S --> U
    T --> U

    U["15. <b>NotesComponent</b><br/>Bordered notes box<br/><i>(static legal text + bullet points)</i>"]

    U --> V(["ComposeContent() complete"])
```

### 2. Architecture & Component Hierarchy

> The architecture follows a **React-like component model** for PDF composition. QuestPDF's `IComponent` interface (single `Compose()` method) works as a render unit — each of the 14 components takes typed "props" (data models/interfaces) and renders its portion of the PDF. `PrimaryInvestor` and `Coinvestor` both implement the same 4 shared interfaces (`IUserInformation`, `IUserAddress`, `IUserEmployment`, `IUserFiles`), so the same components (`InformationComponent`, `AddressComponent`, `EmploymentComponent`) are reused for both roles with zero code duplication. `CoinvestorsComponent` acts as a wrapper component that conditionally renders child components based on `RoleType` (ITF skips employment and PEP sections).

#### 2a. Class & Interface Hierarchy

```mermaid
flowchart LR
    subgraph QuestPDF["QuestPDF Framework"]
        IDOC["IDocument"]
        ICOMP["IComponent"]
    end

    subgraph Main["Main Document"]
        INVESTOR["<b>InvestorDocument</b><br/>Compose()<br/>ComposeHeader()<br/>ComposeContent()<br/>GetMetadata()<br/>GetSettings()"]
    end

    subgraph Components["14 IComponent Implementations"]
        INFO["InformationComponent"]
        ADDR["AddressComponent"]
        EMPL["EmploymentComponent"]
        BANK["BankComponent"]
        RISK["RiskProfileComponent"]
        US_PERSON["USPersonDeclarationComponent"]
        PEP["PoliticallyExposedPersonComponent"]
        IRPQ["IRPQComponent"]
        COINVESTOR["CoinvestorsComponent"]
        DECL["DeclarationComponent"]
        ACCT["AccountAndSubmissionComponent"]
        VIDEO["VideoVerificationComponent"]
        IMAGES["ImagesComponent"]
        NOTES["NotesComponent"]
    end

    subgraph Interfaces["Shared Interfaces"]
        IINFO["IUserInformation<br/><i>22 properties</i>"]
        IADDR["IUserAddress<br/><i>15 properties</i>"]
        IEMPL["IUserEmployment<br/><i>11 properties</i>"]
        IFILES["IUserFiles<br/><i>List&lt;UserFiles&gt;</i>"]
    end

    subgraph Models["Data Models"]
        PRIMARY["PrimaryInvestor<br/><i>implements all 4 interfaces</i>"]
        COINV["Coinvestor<br/><i>implements all 4 interfaces</i>"]
        RESULT["UserResult"]
        SCHED["Schedule"]
        QITEM["QuestionnaireItem"]
        UFILES["UserFiles"]
        PEP_REL["UserPEPRelatedPerson"]
    end

    subgraph Helpers["Helpers & Constants"]
        COLOR["Color<br/><i>Blue, Yellow, Gray</i>"]
        TITLES["Titles + Descriptions"]
        FTYPES["FileTypes<br/><i>ESignature, ID, etc.</i>"]
        RTYPES["RoleTypes<br/><i>PRIMARY, COINVESTOR, ITF</i>"]
        NOTES_TXT["NoteSentences"]
    end

    IDOC -->|"implements"| INVESTOR
    ICOMP -->|"implements"| Components

    Interfaces -->|"implemented by"| PRIMARY
    Interfaces -->|"implemented by"| COINV

    INFO -->|"uses"| IINFO
    ADDR -->|"uses"| IADDR
    EMPL -->|"uses"| IEMPL
    IMAGES -->|"uses"| IFILES

    INVESTOR -->|"composes"| Components
    INVESTOR -->|"references"| Helpers
    Components -->|"references"| Models
```

#### 2b. Component → Data Dependencies

```mermaid
flowchart LR
    subgraph Data_Sources["Data Sources"]
        PRI["<b>PrimaryInvestor</b>"]
        CO["<b>Coinvestor</b>"]
        QI["List&lt;<b>QuestionnaireItem</b>&gt;"]
        PEP["List&lt;<b>UserPEPRelatedPerson</b>&gt;"]
        SCH["List&lt;<b>Schedule</b>&gt;"]
        SVG["<b>SVG strings</b><br/>(checkbox icons)"]
        LOGO["<b>byte[]</b><br/>(logo PNG)"]
    end

    subgraph Component_Req["Components & Required Data"]
        ACCT_C["<b>AccountAndSubmission</b><br/>PrimaryInvestor"]
        VID_C["<b>VideoVerification</b><br/>List&lt;Schedule&gt;"]
        INFO_C["<b>Information</b><br/>IUserInformation + RoleType"]
        ADDR_C["<b>Address</b><br/>IUserAddress + RoleType"]
        EMPL_C["<b>Employment</b><br/>IUserEmployment"]
        BANK_C["<b>Bank</b><br/>PrimaryInvestor <i>(direct)</i>"]
        RISK_C["<b>RiskProfile</b><br/>PrimaryInvestor + SVG"]
        FATCA_C["<b>USPersonDeclaration</b><br/>QuestionnaireItems<br/><i>filter: Compliance</i>"]
        PEP_C["<b>PEP</b><br/>List&lt;UserPEPRelatedPerson&gt;"]
        IRPQ_C["<b>IRPQ</b><br/>QuestionnaireItems<br/><i>filter: Risk Profiling</i>"]
        COINV_C["<b>Coinvestors</b><br/>Coinvestor<br/><i>(aggregates sub-components)</i>"]
        DECL_C["<b>Declaration</b><br/>SVGs + QuestionnaireItems<br/>(filter: 4 checkbox categories)<br/>+ hasCoinvestors flag"]
        IMG_C["<b>Images</b><br/>PrimaryInvestor<br/><i>(IUserFiles → Files lists)</i>"]
        NOTES_C["<b>Notes</b><br/>NoteSentences <i>(static text)</i>"]
    end

    PRI -->|"feeds"| ACCT_C
    PRI -->|"feeds"| INFO_C
    PRI -->|"feeds"| ADDR_C
    PRI -->|"feeds"| EMPL_C
    PRI -->|"feeds"| BANK_C
    PRI -->|"feeds"| RISK_C
    PRI -->|"via .QuestionnaireItems"| QI
    PRI -->|"via .RelatedPoliticallyExposedPersons"| PEP
    PRI -->|"via .Result.Schedules"| SCH
    PRI -->|"feeds"| IMG_C

    CO -->|"feeds"| COINV_C
    CO -->|"feeds"| INFO_C
    CO -->|"feeds"| ADDR_C
    CO -->|"feeds"| EMPL_C

    QI -->|"category: Compliance"| FATCA_C
    QI -->|"category: Risk Profiling"| IRPQ_C
    QI -->|"4 checkbox categories"| DECL_C

    PEP -->|"feeds"| PEP_C
    SCH -->|"feeds"| VID_C
    SVG -->|"checkboxes"| RISK_C
    SVG -->|"checkboxes"| DECL_C

    LOGO -->|"header"| PRI
```

#### 2c. Integration with ClientEase API

```mermaid
flowchart LR
    subgraph ClientEase_API["ClientEase Core API"]
        ATTACH["AttachmentService<br/><i>GetAttachmentAsync()</i>"]
        ATTACH_REPO["AttachmentRepository"]
        USERS_REPO["UsersRepository"]
        ASSETS["AssetCacheService<br/><i>logo PNG, SVG checkboxes<br/>ISingleton, filesystem cache</i>"]
    end

    subgraph PDFGenerator["PEMIClientEase.PDFGenerator"]
        INVESTOR["<b>InvestorDocument</b>"]
        COMPOSE["Compose()"]
        HEADER["ComposeHeader()"]
        CONTENT["ComposeContent()"]
        GENERATE["GeneratePdf(stream)"]
    end

    subgraph External["External"]
        PG["PostgreSQL<br/>clientease"]
        FS["Filesystem<br/>Assets/"]
        QUEST["QuestPDF Engine<br/><i>v2025.12.1</i>"]
        ANGULAR["Angular Frontend<br/>PEMIClientEase.UI"]
    end

    ATTACH --> ATTACH_REPO
    ATTACH --> USERS_REPO
    ATTACH --> ASSETS

    ATTACH_REPO -->|"fn_get_files_per_investor<br/>fn_get_primary_investor_by_user_id<br/>fn_get_questionnaire_items<br/>fn_get_pep_answers<br/>fn_get_coinvestors<br/>fn_get_user_schedules"| PG
    USERS_REPO -->|"user info, addresses,<br/>employment, bank,<br/>risk profile"| PG

    ASSETS -->|"reads"| FS

    ATTACH -->|"builds PrimaryInvestor + loads assets"| INVESTOR
    INVESTOR --> COMPOSE
    COMPOSE --> HEADER
    COMPOSE --> CONTENT
    COMPOSE --> QUEST

    INVESTOR --> GENERATE
    GENERATE -->|"PDF byte stream"| ANGULAR

    CONTENT -->|"renders 14 IComponents<br/>in ordered sequence"| INVESTOR
```

---

*Last updated: July 2026*
