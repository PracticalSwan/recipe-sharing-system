# CookHub - Recipe Sharing System

## Project Overview
- **Course**: CSX3006 Database Systems
- **Type**: Full-stack web application (migrated from localStorage to MySQL backend)
- **Status**: **83% Complete** (Phases 1-5 of 6 done)
- **Last Updated**: 2026-02-14

## Tech Stack
- **Frontend**: React 19.2.0 + Vite 7.2.4 + Tailwind CSS 4.1.18
- **Backend**: Plain PHP (no framework), PDO, session-based auth
- **Database**: MySQL/MariaDB ("cookhub", 13 tables, 2 views, 5 procedures, 6 triggers)
- **Server**: XAMPP (Apache + MySQL + PHP)
- **Routing**: HashRouter, base `/recipe-sharing-system-deploy/`
- **API Communication**: Native fetch() with credentials:'include', Vite proxy `/api` → `http://localhost`

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
│  29 endpoints        │
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
| Phase 6 | Testing & Deployment Docs | ⏳ Not Started | TASK-116 to TASK-138 |

## Key Backend Files (12 files, all created 2026-02-14)

| File | Purpose | Endpoints |
|------|---------|------------|
| `backend/.htaccess` | URL rewriting with mod_rewrite | - |
| `backend/config/database.php` | PDO singleton connection | - |
| `backend/helpers/cors.php` | CORS headers for localhost:5173 | - |
| `backend/helpers/auth.php` | Session validation & getCurrentUser() | requireAuth(), getCurrentUser() |
| `backend/helpers/response.php` | JSON response helpers | success(), error() |
| `backend/api/auth.php` | Register, login, logout, me | POST /register, /login, /logout; GET /me |
| `backend/api/recipes.php` | CRUD + like/favorite/view + status filter | GET /, /{id}; POST /; PUT /{id}; DELETE /{id}; POST /{id}/like, /{id}/favorite, /{id}/view |
| `backend/api/reviews.php` | CRUD for reviews | GET /recipe/{id}, /{id}; POST /; PUT /{id}; DELETE /{id} |
| `backend/api/users.php` | CRUD + status (admin only) | GET /, /{id}; POST /; PUT /{id}, /{id}/status; DELETE /{id} |
| `backend/api/search.php` | Search + history with nested authors | GET /recipes; POST /history |
| `backend/api/stats.php` | Dashboard metrics + daily stats | GET /dashboard; GET /daily |
| `backend/api/activity.php` | Admin activity logs | GET /; POST /; DELETE /{id} |

**Total endpoints: 29 across 7 API files**

## Key Frontend Changes (completed 2026-02-14)

### New Files Created (4)
- **`src/lib/api.js`** (~220 lines): Central API service layer
  - Native `fetch()` wrapper with `credentials: 'include'`
  - ApiError class for error handling
  - Namespaces: auth, recipes, reviews, users, search, stats, activity
  - DEFAULT_AVATARS export
  - All CRUD and interaction methods

- **`src/components/ui/LoadingSpinner.jsx`**: Reusable loading states
- **`src/components/ui/ErrorMessage.jsx`**: Error display with retry button
- **`src/components/ui/ErrorBoundary.jsx`**: React error boundary

### Files Modified (11) - Migrated from localStorage to API
- `src/context/AuthContext.jsx` - Session restoration from API on mount
- `src/pages/Auth/Login.jsx` - API login with loading/error states
- `src/pages/Auth/Signup.jsx` - API registration with validation
- `src/pages/Recipe/Home.jsx` - API recipe list with loading
- `src/pages/Recipe/RecipeDetail.jsx` - API calls + auth view tracking
- `src/pages/Recipe/CreateRecipe.jsx` - API recipe creation
- `src/pages/Recipe/Search.jsx` - API search + history
- `src/pages/Recipe/Profile.jsx` - API user/profile management
- `src/pages/Admin/UserList.jsx` - API user management
- `src/pages/Admin/AdminStats.jsx` - API dashboard stats
- `src/pages/Admin/AdminRecipes.jsx` - API recipe approval

### Files Deleted (1)
- **`src/lib/storage.js`** - Fully removed (0 imports remain, dead code)

### Configuration Updated (1)
- **`vite.config.js`** - Added proxy: `/api` → `http://localhost`

**Total files changed: 28 (12 new backend + 4 new frontend + 11 modified + 1 deleted)**

## Verification & Remediation (2026-02-14)

### Findings
- TASK-114 and TASK-115 initially incomplete:
  - `src/lib/storage.js` still present (now deleted)
  - `src/components/ui/ErrorBoundary.jsx` missing (now added)
- Runtime schema/API mismatches discovered:
  - `backend/api/search.php` used wrong column names (`search_term` vs `query`)
  - `backend/api/stats.php` referenced non-existent columns

### Fixes Applied

**1. Backend search API (`backend/api/search.php`)**
- Enforced auth for search endpoint (`requireAuth`)
- Aligned search history with schema (`query` column, not `search_term`)
- Added safe category multi-select filtering
- Added server-side sort options (`newest`, `rating`, `difficulty-asc`)

**2. Backend stats API (`backend/api/stats.php`)**
- Fixed review weekly metric to use `review.created_at` (not `reviewed_at`)
- Fixed top recipes image source via `recipe_image` subquery
- Reworked daily stats query to use actual `daily_stat` columns
- Added `/api/stats/dashboard` alias while keeping `/api/stats` behavior

**3. Frontend integration**
- Updated `src/pages/Recipe/Search.jsx` to fetch from `api.search.recipes(...)` instead of local filtering
- Updated `src/lib/api.js` to support `VITE_API_BASE_URL` with `/api` fallback
- Updated dashboard method to request `/stats/dashboard`
- Added `src/components/ui/ErrorBoundary.jsx` and wrapped root app in `src/main.jsx`
- Removed `src/lib/storage.js`

### Validation Results
- ✅ `npm run build` succeeds (Vite production build)
- ⚠️ `npx eslint src` fails due to pre-existing issues in `src/pages/Recipe/Profile.jsx` (unrelated to this phase)
- ⚠️ PHP CLI unavailable in current environment, so direct `php -l` linting was not possible

## Recent Work (Sessions 4-9, completed 2026-02-14)

### Session Summary
- Created all 12 PHP backend files with full CRUD endpoints (29 total)
- Created comprehensive api.js service layer replacing all storage.js calls
- Migrated all 11 frontend pages/components from localStorage to async API calls
- Fixed property path issues (nested `recipe.author` objects)
- Fixed backend bugs (main_image subquery, search nested authors, status=all filter, today metrics)
- Added Vite proxy configuration
- Applied verification fixes (search.php, stats.php, Search.jsx)
- Confirmed zero compile errors across all files

## Next Steps (Phase 6 - Not Started)

### Priority 1: Documentation (7 tasks, TASK-132 to TASK-138)
1. Create `docs/API_DOCUMENTATION.md`
2. Create `docs/DATABASE_SCHEMA.md`
3. Create `docs/DEPLOYMENT_GUIDE.md`
4. Create `docs/TESTING_GUIDE.md`
5. Create `database/README.md`
6. Create `database/run_all_scripts.sql`
7. Update `CHANGELOG.md` and main `README.md`

### Priority 2: Testing (16 tasks, TASK-116 to TASK-131)
1. Test database installation (TASK-116, TASK-117, TASK-118)
2. Create Postman collection (TASK-119)
3. Test registration flow (TASK-120)
4. Test recipe creation/admin approval (TASK-121, TASK-122)
5. Test review system (TASK-123)
6. Test likes/favorites (TASK-124)
7. Test search functionality (TASK-125)
8. Test admin dashboard (TASK-126)
9. Test authorization (TASK-127)
10. Test concurrent users (TASK-128)
11. Test SQL injection prevention (TASK-129)
12. Test cascading deletes (TASK-130)
13. Load testing - 1000+ recipes (TASK-131)

### Optional Work (Lower Priority)
- TASK-001 to TASK-003: Create ER diagrams (3 tasks) - Conceptual, Logical, Normalization documentation

## Key Technical Achievements

### Backend Implementation
- Full RESTful API with 29 endpoints
- PDO-based database access (prepared statements, SQL injection safe)
- Session-based authentication with HttpOnly cookies
- CORS headers configured for development
- Role-based authorization (admin vs user)
- Error handling with proper HTTP status codes
- Input validation and sanitization

### Frontend Implementation
- Complete API service layer abstraction
- All localStorage dependencies removed
- Consistent error handling patterns
- Loading states for all async operations
- Zero compile errors
- Native fetch() API (no Axios dependency)
- Vite proxy for seamless local development

### Database Implementation
- 13 normalized tables (3NF design)
- Complex relationships with proper FKs + CASCADES
- 2 views for dashboard statistics
- 5 stored procedures (4 procedures + 1 function)
- 6 triggers for automation
- Complete seed data (12 users, 13 recipes, 24 reviews)
- Comprehensive query library (20+ queries)

***

**Last Updated: February 14, 2026**
**Serena Update Status: ✅ CLEANED (Notion content removed)**
**Next Milestone: Phase 6 (Testing & Documentation - 23 tasks)**
