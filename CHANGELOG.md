# Changelog

All notable changes to the CookHub Recipe Sharing System are documented here.

## [1.0.1] - 2026-02-14

### Fixed
- Fixed recipe card/detail navigation regression by normalizing `api.recipes.get()` payload handling in `RecipeDetail` and `CreateRecipe`.
- Fixed edit-route bounce from `/recipes/edit/:id` for valid owners by handling direct recipe payloads (not only `{ recipe: ... }` wrapper).
- Updated recipe detail access control to allow owners to open their own non-published recipes while still blocking unauthorized viewers.
- Updated backend search keyword behavior to match recipe titles explicitly (`r.title LIKE ...`) so title search is deterministic.
- Strengthened Playwright regression assertions for recipe-detail navigation (`TEST-018`, `TEST-020`, `TEST-039`) to ensure detail content is rendered, not just URL changes.
- Verified recipe navigation, edit flow, like toggle, keyword search, and difficulty filtering with Playwright targeted checks.
- Fixed recipe updates changing `published` recipes to `pending` unexpectedly by preserving current status on owner edits.
- Fixed owner profile recipe visibility by allowing authenticated own-profile requests to use `status=all`.
- Fixed recipe view counting so each authenticated user increments a recipe view only once.
- Fixed review submission to support one review per user/recipe with update-on-resubmit behavior.
- Fixed search reset behavior to clear all filter inputs and URL query parameters.
- Fixed profile edit modal dismissal by disabling outside-click and Escape auto-close for the edit form.
- Fixed suspended account aria-label/title messaging for disabled like/save actions.
- Fixed admin activity feed noise by excluding active/inactive status transitions from Recent Activity.
- Fixed logout status handling so users become `inactive` on logout; added stale-active synchronization in user/admin stats endpoints.
- Expanded Playwright regression coverage to 127 scenarios (`TEST-001`..`TEST-127`) and verified full suite pass.
- Updated `docs/API_DOCUMENTATION.md` to reflect view dedupe/auth, review upsert semantics, recipe status visibility rules, and admin activity feed filtering behavior.
- Updated `docs/TESTING_GUIDE.md` to reflect the 127-test suite, current helper accounts, and new regression test block (`TEST-120`..`TEST-127`).

## [1.0.0] - 2025-06-15

### Phase 1: Project Foundation & Database Setup
- Created MySQL database `cookhub` with `utf8mb4_unicode_ci` encoding
- Designed and implemented 13 tables: `user`, `session`, `recipe`, `ingredient`, `instruction`, `recipe_image`, `review`, `like_record`, `favorite`, `recipe_view`, `search_history`, `daily_stat`, `activity_log`
- Created 27+ performance indexes across all tables
- Created 2 database views: `vw_recipe_with_stat`, `vw_user_dashboard_stat`
- Created 4 stored procedures: `usp_CreateRecipe`, `usp_DeleteRecipe`, `usp_ApproveRecipe`, `usp_GetRecipeStat`
- Created 1 function: `fn_CalculateAvgRating`
- Seeded database with 12 users (3 admin, 9 regular), 10 recipes, reviews, and statistics

### Phase 2: PHP Backend API Development
- Built RESTful API with 7 endpoint modules: `auth`, `recipes`, `reviews`, `search`, `users`, `stats`, `activity`
- Implemented session-based authentication with HttpOnly cookies and 24-hour expiry
- Created PDO database singleton with prepared statements (SQL injection prevention)
- Implemented CORS handler with origin whitelist
- Added JSON response helpers with consistent `{data: ...}` envelope format
- Apache `.htaccess` URL rewriting for clean API paths

### Phase 3: Frontend-Backend Integration
- Migrated frontend from localStorage to PHP/MySQL backend via `api.js` service layer
- Connected all React pages to live API endpoints
- Implemented session-aware AuthContext with `me` endpoint verification
- Added real-time like/favorite toggle functionality
- Connected recipe CRUD operations to backend
- Connected review creation and deletion to backend

### Phase 4: Admin Dashboard & User Management
- Built admin dashboard with live statistics from database
- Implemented user management (list, search, status change, delete)
- Implemented recipe moderation (approve, reject, delete)
- Created activity logging for admin actions
- Role-based route protection (admin auto-redirect, user access control)

### Phase 5: Search & Analytics
- Full-text search across recipe titles, descriptions, and ingredients
- Search history tracking per user
- Category and difficulty filtering
- Sort by newest, oldest, popular, rating
- Daily statistics aggregation
- Recipe view tracking

### Phase 6: Testing, Documentation & Deployment
- Created comprehensive Playwright E2E test suite (35 tests)
- All tests passing: Authentication (7), Recipe Browsing (4), Search (3), CRUD (3), Profile (4), Admin (4), API (5), UI (5)
- Live browser testing with ChromeDevTools verification
- Created API documentation with all 40+ endpoints
- Created database schema documentation with ER diagram
- Created deployment guide for XAMPP environment
- Created testing guide with test scenarios
- Created database README with setup instructions
- Updated project README with complete documentation

### Infrastructure
- React 19.2.0 with Vite 7.3.1 and Tailwind CSS 4.1.18
- HashRouter for client-side routing
- Vite proxy for API requests during development
- XAMPP directory junction for Apache serving
- Playwright with Chromium for automated testing
