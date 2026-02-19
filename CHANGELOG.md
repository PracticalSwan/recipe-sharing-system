# Changelog

All notable changes to the CookHub Recipe Sharing System are documented here.

## [1.0.5] - 2026-02-20

### Changed
- Recipe edits by contributors now automatically change status to 'pending' requiring admin reapproval
- Admins can no longer edit recipe content directly (must use approve/reject workflow)
- Recipe status is preserved when no actual content changes are made (prevents unnecessary re-approval for identical submissions)

## [1.0.4] - 2026-02-18

### Fixed
- Implemented centralized backend error handling in `backend/helpers/response.php` with JSON-safe exception/error/shutdown handling (`initializeErrorHandling()`), consistent error payloads, and optional error codes.
- Enabled centralized backend error initialization in all API entry points: `auth`, `recipes`, `reviews`, `search`, `stats`, `activity`, and `users`.
- Removed sensitive exception message leakage from recipe/user destructive-operation API responses by returning safe 500-level messages with stable error codes.
- Standardized authorization failure responses in `backend/helpers/auth.php` via shared `errorResponse(...)` contract.
- Hardened frontend API client (`src/lib/api.js`) with request timeout handling, network-failure mapping, resilient JSON parsing, richer `ApiError`, and reusable `getErrorMessage(...)` extraction.
- Replaced silent frontend catches with user-visible error feedback across core flows: home feed, search, recipe detail actions, recipe create/edit, profile operations, admin stats/recipe/user pages, and auth pages.

### Validated
- Lint passed: `npm run lint`.
- Production build passed: `npm run build`.

## [1.0.3] - 2026-02-16

### Fixed
- Fixed author profile page showing "User not found" when visiting another user's profile (Profile.jsx accessed `data.user` instead of `data`).
- Fixed profile edit wiping user favorites by adding favorites query to the `PUT /users/{id}` response in `backend/api/users.php`.
- Fixed login error message persisting after user modifies input fields (added `setError('')` to onChange handlers).
- Fixed "1 views" grammar on recipe detail page — now correctly shows "1 view" (singular).
- Removed non-functional "Forgot password?" placeholder link from login page.
- Added `autocomplete` and `name` attributes to all login and signup form inputs for proper browser autofill support.

### Verified (Live Browser Testing)
- All 14 feature areas tested via Chrome DevTools live browser interaction.
- Auth flows (login, signup, logout, pending restrictions).
- Home page (recipe cards, like/save toggles, search bar, View All).
- Search & filters (keyword, difficulty, category, combined, reset, sort, history).
- Recipe detail (hero image, metadata, ingredients, instructions, reviews).
- Ratings & reviews (create, update, delete with confirmation).
- Recipe CRUD (create with pending status, edit, delete with confirmation).
- Profile & edit profile (avatar selector, form fields, favorites preserved).
- Favorites flow (save/unsave from card, detail, and favorites tab).
- Admin dashboard (stats, activity feed, system health).
- Admin user management (search, approve, suspend).
- Admin recipe management (approve, reject, delete).
- Edge cases: route protection, role-based access, non-existent resources.
- Security: XSS prevention (React JSX escaping), SQL injection prevention (PDO prepared statements).

## [1.0.2] - 2026-02-16

### Fixed
- Removed hardcoded create-mode defaults in `CreateRecipe` so category, difficulty, prep time, cook time, and servings now initialize empty for new recipe submissions.
- Added explicit difficulty-required validation and placeholder option in the create/edit recipe form.

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
