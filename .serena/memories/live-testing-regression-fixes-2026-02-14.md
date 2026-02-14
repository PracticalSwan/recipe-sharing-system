Task: Live Playwright + Chrome DevTools validation and automatic fixes for recipe-sharing-system.

What was validated:
- End-to-end coverage for auth, recipe CRUD, recipe detail, search/filtering, profile, reviews/ratings, likes/favorites, admin dashboard, user management, and recipe moderation.
- Full suite run: 127/127 passing in tests/e2e.spec.js.

Key functional fixes implemented:
1) Recipe lifecycle consistency
- backend/api/recipes.php: owner edits now preserve existing recipe status by default (no forced pending on edit).
- backend/api/recipes.php + src/pages/Recipe/Profile.jsx: own profile can fetch status=all so newly created/pending items remain visible to owner.

2) View counting correctness
- backend/api/recipes.php view endpoint now records one unique view per authenticated user/recipe and returns viewRecorded + updated viewCount.
- src/pages/Recipe/RecipeDetail.jsx consumes returned viewCount.

3) Reviews behavior
- backend/api/reviews.php POST now upserts (one review per user/recipe; second post updates existing review).
- src/pages/Recipe/RecipeDetail.jsx uses same endpoint for create/update and updates button label to Update when user already reviewed.

4) Search/filter reset
- src/pages/Recipe/Search.jsx reset now clears all local filters + URL search params.

5) Profile modal UX
- src/components/ui/Modal.jsx adds closeOnOverlayClick/closeOnEscape controls.
- src/pages/Recipe/Profile.jsx edit profile modal configured to stay open unless explicit close.

6) Account state + admin audit activity quality
- backend/api/auth.php login marks inactive users active; logout sets user inactive.
- backend/api/users.php and backend/api/stats.php auto-sync stale active users to inactive using last_active timeout.
- backend/api/users.php, backend/api/stats.php, backend/api/activity.php exclude active/inactive transitions from admin recent activity logs.

7) Pending/suspended interaction messaging
- src/components/recipe/RecipeCard.jsx and src/pages/Recipe/RecipeDetail.jsx now show status-specific tooltip/aria copy for disabled like/save controls.

8) Minor UI/control consistency
- src/components/layout/Navbar.jsx and src/components/layout/Sidebar.jsx await logout() before navigation.
- src/pages/Recipe/RecipeDetail.jsx hides owner edit/delete when user cannot interact due to account status.

Test-suite updates:
- tests/e2e.spec.js: repaired stale tests and added regression tests TEST-120..TEST-127 covering create visibility, one-time view increment, review upsert, reset filters, profile modal persistence, suspended labels, admin activity filtering, and logout inactive status.

Documentation updates applied in same task:
- README.md updated test count and recent-fixes section to reflect behavior changes.
- CHANGELOG.md updated Unreleased section with live-testing regression fixes and expanded E2E coverage.

Recommended next continuity step:
- Keep regression tests TEST-120..TEST-127 mandatory in CI for future merges touching auth/recipes/search/profile/admin activity logic.