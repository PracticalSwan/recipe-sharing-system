# CookHub - Recipe Sharing System

## Project Overview
- **Course**: CSX3006 Database Systems
- **Type**: Full-stack web application (migrated from localStorage to MySQL backend)
- **Status**: **100% Complete** (All 6 Phases Done)
- **Last Updated**: 2025-06-15

## Tech Stack
- **Frontend**: React 19.2.0 + Vite 7.3.1 + Tailwind CSS 4.1.18
- **Backend**: Plain PHP (no framework), PDO, session-based auth
- **Database**: MySQL/MariaDB ("cookhub", 13 tables, 2 views, 5 procedures, 6 triggers)
- **Server**: XAMPP (Apache + MySQL + PHP)
- **Testing**: Playwright E2E (35 tests, all passing)
- **Routing**: HashRouter, base `/recipe-sharing-system-deploy/`
- **API Communication**: Native fetch() with credentials:'include', Vite proxy `/api` → `http://localhost/recipe-sharing-system/backend`

## Architecture (3-Tier)

```
┌─────────────────────────┐
│  React + Vite          │  ← Presentation Layer ✅ COMPLETE
│  (port 5173)          │
│  api.js service       │
└──────────┬────────────┘
           │ HTTP/JSON
┌──────────▼────────────┐
│  PHP REST API        │  ← Application Layer ✅ COMPLETE
│  (port 80)           │
│  12 API files        │
│  40+ endpoints       │
│  Sessions + CORS     │
└──────────┬────────────┘
           │ PDO/MySQL
┌──────────▼────────────┐
│  MySQL cookhub       │  ← Data Layer ✅ COMPLETE
│  (port 3306)         │
│  13 tables           │
│  2 views             │
│  5 procedures        │
│  6 triggers          │
└──────────────────────┘
```

## Phase Completion Status

| Phase | Description | Status | Tasks |
|-------|------------|--------|-------|
| Phase 1 | Database Design & DDL | ✅ Complete | TASK-001 to TASK-021 |
| Phase 2 | SQL Data Scripts & Queries | ✅ Complete | TASK-022 to TASK-043 |
| Phase 3 | Advanced SQL (Procedures/Triggers) | ✅ Complete | TASK-044 to TASK-056 |
| Phase 4 | PHP Backend API | ✅ Complete | TASK-057 to TASK-091 |
| Phase 5 | Frontend Integration | ✅ Complete | TASK-093 to TASK-115 |
| Phase 6 | Testing & Deployment Docs | ✅ Complete | TASK-116 to TASK-138 |

## Phase 6 Deliverables (Completed 2025-06-15)

### Testing
- **Playwright E2E**: 35 tests across 7 categories (all passing)
  - Authentication (7), Recipe Browsing (4), Search (3), Recipe CRUD (3), Profile (4), Admin Panel (4), API Integration (5), Navigation & UI (5)
- **Live Browser Testing**: ChromeDevTools MCP verified admin dashboard, user home, login/logout
- **Test Accounts**: admin@cookhub.com/admin, john@cookhub.com/user

### Documentation Created
- `docs/API_DOCUMENTATION.md` — Complete REST API reference (40+ endpoints)
- `docs/DATABASE_SCHEMA.md` — ER diagram, all 13 tables, views, stored procedures
- `docs/DEPLOYMENT_GUIDE.md` — XAMPP setup, database, production deployment
- `docs/TESTING_GUIDE.md` — Playwright setup, 35 test scenarios, CI guide
- `database/README.md` — Database setup instructions and SQL script reference
- `database/run_all_scripts.sql` — Master SQL setup script
- `CHANGELOG.md` — Version history (v1.0.0)
- `README.md` — Updated with full documentation links, testing section

### Bug Fixes Applied During Phase 6
1. XAMPP htdocs junction created for Apache serving
2. Vite proxy target corrected to `/recipe-sharing-system/backend`
3. Password hashes regenerated with correct bcrypt values
4. `jsonResponse()` wraps data in `{data: ...}` envelope
5. Auth endpoints wrap user in `{user: ...}` key
6. Playwright tests split login helpers for admin vs user (admin auto-redirects to /admin)

## Key Files
- `playwright.config.js` — Playwright configuration
- `tests/e2e.spec.js` — 35 E2E test scenarios
- `plan/upgrade-database-integration-1.md` — Implementation plan (97% complete)

***

**Last Updated: June 15, 2025**
**Status: ✅ ALL PHASES COMPLETE**
