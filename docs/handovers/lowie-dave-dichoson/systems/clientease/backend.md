# ClientEase Core API

## What It Is

The backend REST API for PEMI ClientEase — Philequity Management, Inc.'s investor/account management portal. It handles OTP-based email authentication, investor profile creation, file attachments, and reference data lookups. It is consumed by an Angular frontend (PEMIClientEase.UI) and used daily by investors and PEMI operations staff.

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | [GitHub](https://github.com/PEMIClientEase/PEMIClientEase.CoreAPI) |
| **Production URL** | [www.philequity.net/portal/](https://www.philequity.net/portal/) |
| **Staging URL** | [http://192.168.1.112/](http://192.168.1.112/) |
| **Server** | Ask IT Administrators |
| **Database** | `clientease` |

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | C# 12 |
| **Framework** | .NET 8 (ASP.NET Core Web API) |
| **Database** | PostgreSQL (via Npgsql 9.0 + Dapper 2.1) |
| **Hosting** | Docker (Linux container, `mcr.microsoft.com/dotnet/aspnet:8.0`) |
| **Auth** | JWT Bearer tokens (HMAC-SHA256), issued after OTP email verification |
| **Logging** | Serilog — compact JSON to file (daily rolling), console in non-Production |
| **Email** | MailKit 4.16 via Gmail SMTP (port 587, STARTTLS) |
| **Validation** | FluentValidation 12.1 |
| **API Docs** | Swashbuckle (Swagger), API versioning via URL segments (`/v1/`, `/v2/`) |
| **PDF Generation** | Sibling project `PEMIClientEase.PDFGenerator` (referenced as project dependency) |

## Access

| What | How to Get It |
|---|---|
| **Server access** | Ask IT Administrators |
| **Database access** | Ask IT Administrators |
| **Admin panel** | No admin panel; API accessed via Swagger UI at `/swagger` in Development |

> ⚠️ **Never store passwords or connection strings here.** Just say who to contact.

## Deployment

- **Method:** Docker Compose (`docker compose -f docker-compose-uat.yml up --build`); also manual publish via `publish.sh` (bash script: `dotnet publish -c Release -o ./publish`)
- **Pipeline:** [Link to CI/CD — to be filled]
- **Frequency:** [On every merge to main / weekly / on request — to be filled]
- **Who deploys:** [ICTG / DevOps / self-service — to be filled]

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| **PostgreSQL (ClientEaseDb)** | All data reads/writes via Dapper (users, OTP challenges, references, attachments, system errors) | Entire API non-functional |
| **Gmail SMTP** | Sends OTP codes to investors' registered email addresses | OTP send/resend endpoints fail; investors can't authenticate |
| **PEMIClientEase.PDFGenerator** | Project reference — used for generating PDF documents (reports/statements) | PDF generation endpoints fail |
| **Angular Frontend (PEMIClientEase.UI)** | Consumes this API; CORS configured for `localhost:4200` and `https://philequity.net/portal/` | Frontend can't function without the API |


## Handover Notes

### Architecture

- **Vertical slice** organization under `Features/` — each feature has its own `Api/`, `Application/`, `Contracts/`, `Domain/`, and `Infrastructure/` folders.
- **Cross-cutting concerns** live in `Shared/` (configuration, error handling, persistence type handlers, email service, web response helpers).
- **API versioning** uses URL segment strategy (`/v{version:apiVersion}/...`). Current active versions: v1 (authentication, users, references, attachments) and v2 (attachments, references).
- **Dapper** is used as the micro-ORM (no Entity Framework). Custom type handlers registered for `DateOnly` and `TimeOnly`.

### OTP Authentication Flow

- Three endpoints under `POST /v1/auth/otp/{send,verify,resend}`.
- OTP challenges are policy-driven: `OtpPolicy` table defines max send count, max resend attempts, max failed attempts, OTP validity period, and cooling-off period per purpose.
- After successful OTP verification, a JWT session token is issued (configurable lifetime, default 45 minutes).
- JWT validation is strict: issuer, audience, signing key, lifetime, and algorithm (HS256 only) are all enforced. Clock skew is 30 seconds.
- OTP policies and challenges are stored in PostgreSQL and managed by `OtpPolicyProvider` and `OtpChallengeValidator`.

### Configuration

- Environment-specific overrides: `appsettings.Development.json`, environment variables (double-underscore separator for nested keys, e.g., `ConnectionStrings__ClientEaseDb`).
- Docker `.env` file expected when running via `docker-compose`.
- Required config sections: `ConnectionStrings`, `FilePath`, `Assets`, `Smtp`, `OtpSessionToken`, `Cors`.
- Signing key must be at least 32 bytes (validated at startup).

### Known Gaps / TODOs

- End-to-end tests
- Clean up of the N+1 queries on the Repository layers of some features
- Globalized error handling implementation on all features
- `appsettings.json` currently contains a plaintext SMTP password and DB credentials — these should be moved to environment variables/secrets for production.

## Process Flow Diagrams

### 1. OTP Authentication Flow

#### 1a. Send OTP

```mermaid
flowchart TD
    A["<b>Angular App</b><br/>POST /v1/auth/otp/send"] --> B["<b>SendOtpRequestValidator</b><br/><i>FluentValidation</i>"]

    B --> C{"Purpose?"}
    C -->|"create_account"| D["Resolve email from<br/>request.EmailAddress"]
    C -->|"update_account"| E["Resolve email via<br/>ClientAccountNumber<br/><i>(DB lookup)</i>"]

    D --> F
    E --> F

    F["<b>OtpPolicyProvider</b><br/>Get active policy from DB<br/><i>(IMemoryCache, 30-min TTL)</i>"] --> G["<b>OtpSecurityService</b><br/>Generate 6-digit OTP<br/>Hash OTP: PBKDF2-SHA256<br/>Generate challenge token:<br/>32 random bytes → SHA-256 hash"]

    G --> H["<b>AuthenticationRepository</b><br/>fn_insert_otp_information<br/><i>(Npgsql → PostgreSQL)</i>"]

    H --> I["<b>EmailService</b><br/><i>MailKit → Gmail SMTP :587 STARTTLS</i>"]

    I --> J(["Return challengeToken<br/><b>IssuedOtpChallenge</b><br/>token, sentAt, expiresAt"])
```

#### 1b. Verify OTP

```mermaid
flowchart TD
    A["<b>Angular App</b><br/>POST /v1/auth/otp/verify"] --> B["<b>VerifyOtpRequestValidator</b><br/><i>FluentValidation</i>"]

    B --> C["Hash challenge token (SHA-256) →<br/>fetch OtpInformation from DB<br/><i>(fn_get_otp_information_by_challenge_token)</i>"]

    C --> D{"<b>OtpChallengeValidator</b><br/>Challenge exists?<br/>Purpose matches policy?<br/>Status = PENDING?<br/>Code status = ACTIVE?<br/>OTP not expired?<br/>Attempts under limit?"}

    D -->|"No"| E["Register failure<br/>Return error response"]

    D -->|"Yes"| F{"<b>OtpSecurityService</b><br/>IsOtpHashMatch?<br/><i>(constant-time PBKDF2-SHA256 compare)</i>"}

    F -->|"No"| G["Register failed attempt<br/>fn_register_failed_otp_attempt<br/>Return incorrect OTP error"]

    F -->|"Yes"| H["Mark code as verified<br/>fn_mark_otp_code_as_verified"]

    H --> I{"Purpose?"}
    I -->|"update_account"| J["Fetch ClientAccount<br/>from UsersRepository<br/><i>(by account number)</i>"]
    I -->|"create_account"| K

    J --> K["<b>OtpSessionTokenService</b><br/>Generate JWT<br/><i>(HMAC-SHA256, 45-min lifetime)</i>"]

    K --> L["JWT Claims:<br/>sub, jti, iat<br/>token_use: 'otp_session'<br/>otp_verified: 'true'<br/>scope: v1:users:create, etc."]

    L --> M(["Return SessionToken<br/><b>VerifyOtpResponse</b>"])
```

#### 1c. Resend OTP

```mermaid
flowchart TD
    A["<b>Angular App</b><br/>POST /v1/auth/otp/resend"] --> B["<b>ResendOtpRequestValidator</b><br/><i>FluentValidation</i>"]

    B --> C["Hash challenge token →<br/>fetch OtpInformation<br/><i>(fn_get_otp_information_by_challenge_token)</i>"]

    C --> D{"<b>OtpChallengeValidator</b><br/>ValidateCanResend?<br/>Status = PENDING?<br/>Code status = ACTIVE?<br/>SendCount &lt; MaxSendCount?<br/>&gt;60s since last send?"}

    D -->|"No"| E["Return cooldown or<br/>max resend limit error"]

    D -->|"Yes"| F["<b>OtpSecurityService</b><br/>Generate new 6-digit OTP<br/>Hash: PBKDF2-SHA256"]

    F --> G["<b>AuthenticationRepository</b><br/>fn_resend_otp_code<br/><i>(upserts new OTP code)</i>"]

    G --> H["<b>EmailService</b><br/><i>MailKit → Gmail SMTP :587</i>"]

    H --> I(["Return challengeToken<br/><b>IssuedOtpChallenge</b>"])
```

### 2. Architecture & Component Hierarchy

#### 2a. Request Processing Pipeline

```mermaid
flowchart TD
    A["<b>Angular App</b><br/>HTTP Request"] --> B["<b>CORS Middleware</b><br/>AllowAngularApp policy<br/><i>localhost:4200, philequity.net</i>"]

    B --> C["<b>GlobalExceptionMiddleware</b><br/>Catch-all error handler"]

    C --> D["<b>Serilog Request Logging</b><br/>Compact JSON → daily rolling file"]

    D --> E["<b>API Versioning</b><br/>URL segment routing<br/><i>/v{version:apiVersion}/...</i>"]

    E --> F{"Requires<br/>authentication?"}

    F -->|"No"| G["<b>Public Endpoints</b><br/>References GET<br/>Attachments GET<br/>OTP send/verify/resend"]

    F -->|"Yes"| H["<b>JWT Authentication</b><br/>Validate: issuer, audience,<br/>signing key (HMAC-SHA256),<br/>lifetime, algorithm (HS256 only)<br/><i>clock skew: 30s</i>"]

    H --> I{"Token valid?"}
    I -->|"No"| J(["401 Unauthorized"])
    I -->|"Yes"| K["<b>Authorization Policy</b><br/>token_use = 'otp_session'?<br/>otp_verified = 'true'?<br/>Scope includes required scope?"]

    K --> L{"Policy satisfied?"}
    L -->|"No"| M(["403 Forbidden"])
    L -->|"Yes"| G

    G --> N["<b>Controller</b><br/>FluentValidation runs"]

    N --> O["<b>Service</b><br/>Business logic"]

    O --> P["<b>Repository</b><br/>Dapper + NpgsqlConnection"]

    P --> Q["<b>PostgreSQL</b><br/>clientease<br/><i>(all queries via stored functions)</i>"]

    Q --> R["<b>ResponseBuilder</b><br/><i>{ isSuccess, statusCode, messages }</i>"]

    R --> S(["Return JSON to Angular"])
```

#### 2b. OTP Authentication Subsystem

```mermaid
flowchart LR
    subgraph Controller["AuthenticationController"]
        SEND["POST /v1/auth/otp/send"]
        VERIFY["POST /v1/auth/otp/verify"]
        RESEND["POST /v1/auth/otp/resend"]
    end

    subgraph Service["AuthenticationService"]
        SEND_SVC["SendOtpAsync()"]
        VERIFY_SVC["VerifyOtpAsync()"]
        RESEND_SVC["ResendOtpAsync()"]
    end

    subgraph Auth_Engine["OTP Auth Engine"]
        POLICY["OtpPolicyProvider<br/><i>IMemoryCache (30-min TTL)<br/>→ fn_get_active_otp_policy_by_purpose_code</i>"]
        CHALLENGE["OtpChallengeValidator<br/>expiry check<br/>attempt limits<br/>cooldown enforcement"]
        SECURITY["OtpSecurityService<br/>GenerateOtp()<br/>HashOtp() (PBKDF2)<br/>HashToken() (SHA-256)<br/>IsOtpHashMatch()"]
        JWT_SVC["OtpSessionTokenService<br/>GenerateSessionToken()<br/><i>HMAC-SHA256, 45-min lifetime</i>"]
    end

    subgraph Repos["Repositories"]
        AUTH_REPO["AuthenticationRepository<br/>fn_insert_otp_information<br/>fn_get_otp_information_by_challenge_token<br/>fn_mark_otp_code_as_verified<br/>fn_resend_otp_code<br/>fn_register_failed_otp_attempt"]
        POLICY_REPO["OtpPolicyRepository<br/>fn_get_active_otp_policy_by_purpose_code"]
        USERS_REPO["UsersRepository<br/>fn_get_client_account_by_account_number"]
    end

    subgraph External["External"]
        PG["PostgreSQL<br/>clientease"]
        SMTP["Gmail SMTP<br/>:587 STARTTLS"]
        MAIL["EmailService<br/><i>MailKit</i>"]
    end

    SEND -->|"calls"| SEND_SVC
    VERIFY -->|"calls"| VERIFY_SVC
    RESEND -->|"calls"| RESEND_SVC

    SEND_SVC -->|"policy lookup"| POLICY
    SEND_SVC -->|"generate & hash"| SECURITY
    SEND_SVC -->|"insert challenge"| AUTH_REPO
    SEND_SVC -->|"send OTP email"| MAIL

    VERIFY_SVC -->|"policy lookup"| POLICY
    VERIFY_SVC -->|"validate challenge"| CHALLENGE
    VERIFY_SVC -->|"hash match"| SECURITY
    VERIFY_SVC -->|"fetch/update"| AUTH_REPO
    VERIFY_SVC -->|"fetch account"| USERS_REPO
    VERIFY_SVC -->|"issue JWT"| JWT_SVC

    RESEND_SVC -->|"validate can resend"| CHALLENGE
    RESEND_SVC -->|"generate & hash"| SECURITY
    RESEND_SVC -->|"resend OTP"| AUTH_REPO
    RESEND_SVC -->|"send OTP email"| MAIL

    POLICY -->|"Npgsql"| POLICY_REPO
    POLICY_REPO --> PG
    AUTH_REPO --> PG
    USERS_REPO --> PG
    MAIL --> SMTP
```

#### 2c. Feature Map & Dependencies

```mermaid
flowchart LR
    subgraph Entry_Controllers["Controllers"]
        AUTH_CTRL["Authentication<br/>/v1/auth/otp/*"]
        USERS_CTRL["Users<br/>/v1/users"]
        ATTACH_V1["Attachments V1<br/>/v1/attachments"]
        ATTACH_V2["Attachments V2<br/>/v2/attachments"]
        REFS_V1["References V1<br/>/v1/references"]
        REFS_V2["References V2<br/>/v2/references"]
    end

    subgraph Feature_Svcs["Feature Services"]
        AUTH_SVC["AuthenticationService"]
        USERS_SVC["UsersService"]
        ATTACH_SVC["AttachmentService<br/>+ AssetCacheService"]
    end

    subgraph Feature_Repos["Feature Repositories"]
        AUTH_REPO["AuthenticationRepository"]
        USERS_REPO["UsersRepository"]
        ATTACH_REPO["AttachmentRepository"]
        REFS_REPO["ReferencesRepository"]
        POLICY_REPO["OtpPolicyRepository"]
    end

    subgraph Shared["Shared Layer"]
        EMAIL["EmailService<br/><i>MailKit</i>"]
        ERR_MW["GlobalExceptionMiddleware"]
        VALIDATORS["FluentValidation"]
        TYPE_HANDLERS["Dapper Type Handlers<br/>DateOnly / TimeOnly"]
        RESPONSE["ResponseBuilder"]
    end

    subgraph Ext["External Dependencies"]
        PG[("PostgreSQL<br/>clientease")]
        SMTP[("Gmail SMTP")]
        PDF_GEN["PEMIClientEase<br/>.PDFGenerator"]
        ANGULAR["Angular Frontend<br/>PEMIClientEase.UI"]
    end

    subgraph Infra["Infrastructure"]
        DOCKER["Docker<br/>aspnet:8.0"]
        SERILOG["Serilog<br/>file + console"]
        SWAGGER["Swashbuckle<br/><i>dev only</i>"]
        VERSIONING["API Versioning<br/>/v1/ /v2/"]
    end

    ANGULAR -->|"HTTP"| Entry_Controllers
    Entry_Controllers -->|"validates via"| VALIDATORS
    Entry_Controllers -->|"formats via"| RESPONSE
    Entry_Controllers -->|"errors →"| ERR_MW

    AUTH_CTRL --> AUTH_SVC
    USERS_CTRL --> USERS_SVC
    ATTACH_V1 --> ATTACH_SVC
    ATTACH_V2 --> ATTACH_SVC
    REFS_V1 --> REFS_REPO
    REFS_V2 --> REFS_REPO

    AUTH_SVC --> AUTH_REPO
    AUTH_SVC --> POLICY_REPO
    USERS_SVC --> USERS_REPO
    ATTACH_SVC --> ATTACH_REPO

    AUTH_SVC --> EMAIL
    ATTACH_SVC --> PDF_GEN

    Feature_Repos -->|"Dapper/Npgsql"| PG
    EMAIL --> SMTP

    ERR_MW -->|"logs →"| SERILOG
    PG -->|"type mappings"| TYPE_HANDLERS
```

---

*Last updated: July 2026*

