# PEMIClientEase.UI

## What It Is

The Angular 19 single-page frontend for PEMI ClientEase — Philequity Management, Inc.'s investor onboarding and account management portal. It provides a guided multi-step onboarding flow with OTP-based email authentication, investor profile creation, deferred file uploads, and reference data lookups. It consumes the PEMIClientEase.CoreAPI backend REST API and is used daily by investors opening or updating PEMI accounts.

## Where It Lives

| What | Where |
|---|---|
| **Source repo** | Ask the Developer Team Lead for the source repository |
| **Production URL** | Ask IT Administrators |
| **Staging URL** | Ask IT Administrators |
| **Dev server** | `http://localhost:4200/` (`npm start`) |
| **Container** | Docker multi-stage build (Node 20 Alpine → NGINX Alpine), `docker-compose.yml` for local container deployment |
| **Backend API** | PEMIClientEase.CoreAPI — consumed at the `apiBaseUrl` configured in `src/app/core/constants/environment.ts` (dev: `http://localhost:5228/`) |

## Tech Stack

| Layer | Technology |
|---|---|
| **Language** | TypeScript 5.7 |
| **Framework** | Angular 19.2 (standalone components, signals, new control flow) |
| **UI Library** | PrimeNG 19 + PrimeIcons 7 |
| **Styling** | Tailwind CSS 4 + `tailwindcss-primeui` plugin + PostCSS |
| **State Management** | Angular signals (`signal()`, `computed()`, `input()`, `output()`) |
| **Forms** | Reactive Forms (Angular `@angular/forms`) |
| **HTTP** | Angular `HttpClient` with functional interceptors |
| **Routing** | Angular Router with lazy-loaded standalone components, in-memory scroll restoration, and anchor scrolling |
| **Hosting** | Docker multi-stage (Node 20 Alpine build → NGINX Alpine serve) |
| **Testing** | Unit: Karma + Jasmine; E2E: Cypress 15 |
| **Linting** | Angular ESLint + TypeScript ESLint |
| **Auth** | JWT Bearer tokens (HMAC-SHA256) injected via `otpSessionAuthInterceptor` on protected POST endpoints |
| **Build Meta** | Custom `scripts/generate-build-version.mjs` — generates `src/app/core/constants/build-version.generated.ts` with version + build ID |

## Access

| What | How to Get It |
|---|---|
| **Source code** | This repository — request access from the Developer Team Lead |
| **Dev server** | Clone repo → `npm install` → `npm start` → `http://localhost:4200/` |
| **UAT build** | `npm run build:uat` or `npm run start:uat` |
| **Production build** | `npm run build:prod` → output at `dist/pemiclient-ease.ui/browser/` |
| **Admin panel** | No admin panel; this is the investor-facing frontend only |

> ⚠️ **Never store passwords, API keys, or connection strings here.** Just say who to contact.

## Deployment

- **Method:** Docker multi-stage build (`Dockerfile`) and Docker Compose (`docker-compose.yml`); also manual NGINX serve of `dist/` output
- **Pipeline:** [Link to CI/CD — to be filled]
- **Frequency:** [On every merge to main / weekly / on request — to be filled]
- **Who deploys:** [ICTG / DevOps / self-service — to be filled]
- **Build commands:**
  - Development: `npm start` (or `ng serve`)
  - UAT: `npm run build:uat` (or `ng build --configuration uat`)
  - Production: `npm run build:prod` (or `npm run build`)
  - Docker: `docker compose up --build`

## Common Issues

| Problem | Likely Cause | Fix |
|---|---|---|
| [to be filled] | [to be filled] | [to be filled] |

## Dependencies

| System / Service | How It Depends | What Breaks If It's Down |
|---|---|---|
| **PEMIClientEase.CoreAPI** | All data reads/writes — reference data (countries, states, cities, banks, system references, questions), OTP auth (send/verify/resend), user submission, and file attachments | Entire frontend is non-functional; onboarding flow cannot proceed |
| **NGINX** (production) | Serves built static assets and handles SPA fallback routing (`error_page 404 /index.html`) | Application unreachable |
| **Node.js / npm** (dev/build) | Required for Angular CLI, dependency installation, and the build pipeline | Can't develop, build, or run locally |

## Who to Ask

| Name | Role | What They Know |
|---|---|---|
| [to be filled] | [to be filled] | [to be filled] |

## Handover Notes

### Architecture

- **Standalone component architecture** — all components use `standalone: true`, no `NgModule` except the app bootstrap.
- **Vertical feature slices** under `src/app/features/` — each feature (landing, onboarding, legal, errors) is self-contained with its own components, directives, guards, models, and services.
- **Core infrastructure** in `src/app/core/` — singleton services (`providedIn: 'root'`), HTTP interceptors, route guards, app-wide constants, and the PrimeNG theme preset.
- **Shared UI** in `src/app/shared/` — reusable pieces: `responsive-header`, `responsive-footer`, `loading-spinner`, along with shared models, validators, directives, and utilities.
- **Lazy loading** throughout — every route uses `loadComponent` with dynamic `import()` in `src/app/app.routes.ts`.
- **`@app/*` path alias** defined in `tsconfig.json` for clean imports across the codebase.

### Application Bootstrap (`app.config.ts`)

Key providers in order:
1. `provideZoneChangeDetection({ eventCoalescing: true })`
2. `provideRouter(routes, withInMemoryScrolling({ anchorScrolling, scrollPositionRestoration }))`
3. `provideHttpClient(withInterceptors([otpSessionAuthInterceptor]))`
4. `provideAnimationsAsync()`
5. `providePrimeNG({ theme: { preset: CustomPreset } })` — CustomPreset defined in `src/app/core/constants/preset.ts`
6. `APP_INITIALIZER` — prefetches common onboarding reference data via `OnboardingDataService.prefetchCommonData()`

### Onboarding Flow

1. **Landing page** (`/`) — user selects account action (open new / update existing) and account type (individual / joint) via the `get-started` component.
2. **OTP verification** (`/otp-verification-page`) — user enters email, receives OTP, verifies it. On success, a JWT session token is stored and injected into subsequent API calls by `otpSessionAuthInterceptor`.
3. **Multi-step form** (`/onboarding-form-page`) — 8 steps managed by `StepperFormService`: Personal Info, Address & Contact, Employment Details, U.S. Declaration, PEP, IRPQ, Bank Details, Co-investors (joint accounts only). Each step is a standalone reactive form group.
4. **Verify details** (`/verify-details-page`) — review all entered data before submission.
5. **Schedule verification** (`/schedule-verification-page`) — select appointment slots for identity verification.
6. **Declaration confirmation** (`/declaration-confirmation-page`) — final compliance declarations.
7. **Acknowledgement** (`/acknowledgement-page`) — submission result and confirmation.

### Key Services

| Service | Location | Role |
|---|---|---|
| `ApiGetService` | `src/app/core/services/` | Typed GET requests with caching; unwraps `ApiResponse<T>` envelopes |
| `ApiPostService` | `src/app/core/services/` | Typed POST requests; file upload and final user submission |
| `ApiCacheService` | `src/app/core/services/` | Request-level cache to deduplicate GET calls |
| `OnboardingDataService` | `src/app/features/onboarding/data-access/` | Central cache for all dropdown/reference data; lazy-loads by form domain |
| `StepperFormService` | `src/app/features/onboarding/data-access/` | Owns all reactive form groups; manages step navigation and co-investor dynamics |
| `UserPostingService` | `src/app/features/onboarding/data-access/` | Aggregates form data, uploads pending files, submits final payload |
| `FileQueueService` | `src/app/features/onboarding/data-access/` | Deferred file upload queue |
| `OtpSessionService` | `src/app/features/onboarding/data-access/` | Manages OTP JWT token lifecycle |
| `AccountTypeService` | `src/app/core/services/` | Tracks selected account action, account type, and onboarding state for guards |
| `LoadingService` | `src/app/core/services/` | Global loading overlay state |

### File Upload Design

- **Deferred upload pattern** — files are queued in `FileQueueService` during form steps but NOT uploaded until final submission.
- This prevents orphaned file uploads for abandoned sessions.
- On final submit, `UserPostingService` uploads all queued files first via `ApiPostService.uploadFile()`, then posts the complete onboarding payload.
- File upload panels are reusable via the shared `file-upload-panel` component.

### OTP Authentication (Frontend)

- JWT token is obtained from the backend after successful OTP verification.
- `OtpSessionService` stores the token and provides `getAuthorizationHeader()`.
- `otpSessionAuthInterceptor` (functional interceptor) attaches the `Authorization: Bearer <token>` header to protected POST endpoints (`/v1/users`, `/v1/attachments/`).
- If the token is missing or expired, the interceptor redirects to `/otp-verification-page`.
- `onboardingGuard` protects all downstream onboarding routes; redirects to `/` if onboarding hasn't started.
- `otpDeactivateGuard` prevents accidental navigation away from the OTP page.

### Environment Configurations

Three environments managed via file replacement in `angular.json`:
- **Development** (`environment.ts`): `apiBaseUrl: 'http://localhost:5228/'`, `production: false`
- **UAT** (`environment.uat.ts`): `production: false`, points to UAT API
- **Production** (`environment.prod.ts`): `production: true`, points to production API

### Styling

- **Tailwind CSS 4** with the `tailwindcss-primeui` plugin for tight PrimeNG integration.
- **PrimeNG theme** uses a custom preset (`src/app/core/constants/preset.ts`) with CSS layers ordered as `tailwind, primeng`.
- Global styles in `src/styles.css`; component-specific styles are co-located with components.
- `primeicons` CSS loaded via `angular.json` styles array.

### Known Gaps / TODOs

- `AccountTypeService` contains hardcoded values flagged with TODOs — do not remove silently; flag for human review.
- Cypress E2E tests exist for the four main flows but coverage of edge cases (validation errors, network failures) is limited.
- No visual regression or accessibility automation testing in the pipeline.
- The `docker-compose.yml` references a volume path (`./clientease-ui/pemiclient-ease.ui/browser`) that may need adjustment for CI environments.

---

*Last updated: June 2026*
