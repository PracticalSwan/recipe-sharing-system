Documentation sync completed after live testing/regression fixes.

Updated files:
- README.md
- CHANGELOG.md
- docs/API_DOCUMENTATION.md
- docs/TESTING_GUIDE.md

What was synchronized:
1) README
- Confirmed E2E coverage shown as 127/127.
- Corrected last-active wording to reflect logout + stale-active auto-sync (removed browser-close implication).

2) CHANGELOG (Unreleased)
- Added explicit entries noting API and testing documentation synchronization after regression fixes.

3) API docs
- Documented login behavior that inactive users are promoted to active and last_active is refreshed.
- Documented logout behavior that active/inactive users are set inactive with last_active update.
- Documented GET /recipes status=all restrictions (admin or owner authorId context).
- Documented PUT /recipes/{id} status behavior (owner edits preserve status, admin can override).
- Documented POST /recipes/{id}/view now requires auth and deduplicates per user/recipe; response includes viewRecorded and viewCount.
- Documented POST /reviews as upsert semantics with 201 create / 200 update.
- Documented user/status and stats stale-active sync behavior (5-minute threshold).
- Documented admin activity feed exclusions for active/inactive status-only transitions in /stats and /activity endpoints.

4) Testing guide
- Replaced outdated 35-test plan with current 127-test suite overview across 16 suites.
- Updated helper account from john@cookhub.com to user@cookhub.com.
- Added dedicated regression coverage table for TEST-120..TEST-127 tied to known issues.
- Updated latest result snapshot to 127/127 pass and added grep command for regression-only runs.

Notes:
- No code behavior changed in this docs-only sync beyond text updates.
- Repository still has modified test source from prior fix pass (tests/e2e.spec.js) as expected.