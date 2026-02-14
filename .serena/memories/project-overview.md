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
React+Vite (port 5173) → PHP REST API (XAMPP, port 80) → MySQL (port 3306)
```

## Phase Completion Status

| Phase | Description | Status | Tasks |
|-------|------------|--------|-------|
| Phase 1 | Database Design & DDL | ✅ Complete | TASK-001 to TASK-021 |
| Phase 2 | SQL Data Scripts & Queries | ✅ Complete | TASK-022 to TASK-043 |
| Phase 3 | Advanced SQL (Procedures/Triggers) | ✅ Complete | TASK-044 to TASK-056 |
| Phase 4 | PHP Backend API | ✅ Complete | TASK-057 to TASK-091 |
| Phase 5 | Frontend Integration | ✅ Complete (except TASK-114, TASK-115) | TASK-093 to TASK-113 |
| Phase 6 | Testing & Deployment Docs | ⏳ Not Started | TASK-116 to TASK-138 |

## Key Backend Files (12 files, all created 2026-02-14)
- `backend/.htaccess` - URL rewriting
- `backend/config/database.php` - PDO singleton
- `backend/helpers/cors.php`, `auth.php`, `response.php` - Helpers
- `backend/api/auth.php` - Register/login/logout/me
- `backend/api/recipes.php` - CRUD + like/favorite/view + status=all filter
- `backend/api/reviews.php` - CRUD for reviews
- `backend/api/users.php` - CRUD + status (admin)
- `backend/api/search.php` - Search + history (nested author objects)
- `backend/api/stats.php` - Dashboard (with today metrics) + daily stats
- `backend/api/activity.php` - Admin activity logs

## Key Frontend Changes (completed 2026-02-14)
- **`src/lib/api.js`** (~220 lines): Central API service layer with apiFetch wrapper, ApiError class, namespaces for auth/recipes/reviews/users/search/stats/activity, DEFAULT_AVATARS export
- **All 11 page/component files migrated** from storage.js to api.js (async, loading states, error handling)
- **`src/lib/storage.js`**: Dead code — zero imports remain, pending deletion
- **New UI components**: LoadingSpinner.jsx, ErrorMessage.jsx
- **`vite.config.js`**: Proxy added `/api` → `http://localhost`

## Recent Work (Sessions 4-9, completed 2026-02-14)
- Created all 12 PHP backend files with full CRUD endpoints
- Created api.js service layer replacing all storage.js calls
- Migrated all frontend files from localStorage/storage.js to async API calls
- Fixed property path issues (nested `recipe.author` objects)
- Fixed backend bugs (main_image subquery, search nested authors, status=all filter, today metrics)
- Added Vite proxy configuration
- Zero compile errors confirmed across all files

## Next Steps (Phase 6)
- TASK-114: Delete storage.js (currently dead code with 0 imports)
- TASK-115: Create ErrorBoundary component
- TASK-116 to TASK-138: Testing, documentation, Postman collection, deployment guide
- End-to-end integration testing with XAMPP
