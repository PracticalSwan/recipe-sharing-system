# CookHub - Recipe Sharing System

## Project Overview
- **Course**: CSX3006 Database Systems
- **Type**: Full-stack web application (migrated from localStorage to MySQL backend)
- **Status**: **100% Complete** (All 6 Phases Done + Post-Phase Enhancements)
- **Last Updated**: 2026-06-21

## Tech Stack
- **Frontend**: React 19.2.0 + Vite 7.3.1 + Tailwind CSS 4.1.18
- **Backend**: Plain PHP (no framework), PDO, session-based auth
- **Database**: MySQL/MariaDB ("cookhub", 13 tables, 2 views, 5 procedures, 6 triggers)
- **Server**: XAMPP (Apache + MySQL + PHP)
- **Testing**: Playwright E2E (127 tests, all passing)
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

## Post-Phase Enhancements (2026-06-21)

### SQL Consolidation (`database/1.sql`)
- Consolidated all DDL, DML, and programmatic SQL from scripts 01-13 into a single annotated file
- **89 numbered commands** (CMD-001 to CMD-089) with section headers
- Sections: Create Database (01), Create Tables (02), Create Indexes (03), Create Views (04), Seed Users (05), Seed Recipes (06), Seed Reviews (07), Seed Stats (08), Stored Procedures (12), Triggers (13)
- Read-only query scripts (09, 10, 11) excluded — they are reference-only
- Each command annotated with source script, purpose, and UI/API link

### Comprehensive Code Commenting (37+ files)
Added JSDoc/PHPDoc documentation headers, inline comments, and section markers across the entire codebase:

**Backend (11 files):**
- `backend/config/database.php` — PHPDoc for Database singleton, PDO config
- `backend/helpers/auth.php` — Auth helper functions (getSessionUser, requireAuth, requireAdmin)
- `backend/helpers/cors.php` — CORS handler documentation
- `backend/helpers/response.php` — JSON response helper docs
- `backend/api/auth.php` — Login/register/logout/me endpoint docs
- `backend/api/recipes.php` — Full CRUD + status management endpoint docs
- `backend/api/reviews.php` — Review create/update/delete endpoint docs
- `backend/api/users.php` — User profile and admin management docs
- `backend/api/search.php` — Search and history endpoint docs
- `backend/api/stats.php` — Dashboard statistics endpoint docs
- `backend/api/activity.php` — Activity feed endpoint docs

**Frontend Core (5 files):**
- `src/main.jsx` — App bootstrap and router setup
- `src/App.jsx` — Route definitions and layout composition
- `src/index.css` — Tailwind directives and custom styles
- `src/lib/api.js` — API service layer with fetch wrapper (~220 lines)
- `src/lib/utils.js` — Utility functions (cn, date formatting)

**Frontend Context & Layouts (4 files):**
- `src/context/AuthContext.jsx` — Auth state management and session persistence
- `src/layouts/RootLayout.jsx`, `AuthLayout.jsx`, `AdminLayout.jsx`

**Frontend Components (12 files):**
- Layout: `Navbar.jsx`, `Sidebar.jsx`
- Recipe: `RecipeCard.jsx`
- UI: `Badge.jsx`, `Button.jsx`, `Card.jsx`, `ErrorBoundary.jsx`, `ErrorMessage.jsx`, `Input.jsx`, `LoadingSpinner.jsx`, `Modal.jsx`, `Table.jsx`, `Tabs.jsx`

**Frontend Pages (8 files):**
- Auth: `Login.jsx`, `Signup.jsx`
- Recipe: `Home.jsx`, `Search.jsx`, `RecipeDetail.jsx`, `CreateRecipe.jsx`, `Profile.jsx`
- Admin: `AdminStats.jsx`, `UserList.jsx`, `AdminRecipes.jsx`

## Phase 6 Deliverables

### Testing
- **Playwright E2E**: 127 tests across multiple categories (all passing)
- **Live Browser Testing**: ChromeDevTools MCP verified 14 feature areas
- **Test Accounts**: admin@cookhub.com/admin, john@cookhub.com/user

### Documentation
- `docs/API_DOCUMENTATION.md` — Complete REST API reference (40+ endpoints)
- `docs/DATABASE_SCHEMA.md` — ER diagram, all 13 tables, views, stored procedures
- `docs/DEPLOYMENT_GUIDE.md` — XAMPP setup, database, production deployment
- `docs/TESTING_GUIDE.md` — Playwright setup, 127 test scenarios, CI guide
- `database/README.md` — Database setup instructions and SQL script reference
- `database/run_all_scripts.sql` — Master SQL setup script
- `database/1.sql` — Consolidated SQL script (89 numbered commands)
- `CHANGELOG.md` — Version history (v1.0.0 through v1.0.4)
- `README.md` — Updated with full documentation links

## Key Files
- `playwright.config.js` — Playwright configuration
- `tests/e2e.spec.js` — 127 E2E test scenarios
- `plan/upgrade-database-integration-1.md` — Implementation plan (100% complete)
- `database/1.sql` — Consolidated SQL (89 commands, CMD-001 to CMD-089)

***

**Last Updated: June 21, 2026**
**Status: ✅ ALL PHASES COMPLETE + POST-PHASE ENHANCEMENTS**
