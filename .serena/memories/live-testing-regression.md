# Combined Memory: Live Testing, Regression Fixes, and Docs Sync (2026-02-16)

## Source Memories
- `comprehensive-live-testing-2026-02-16`
- `live-testing-regression-fixes-2026-02-14`
- `docs-sync-live-testing-fixes-2026-02-14`
- `recipe-routing-search-fixes-2026-02-14`
- `create-recipe-empty-defaults-2026-02-16`

## Consolidated Summary
This combined memory captures end-to-end validation and follow-up fixes across auth, recipe flows, search/filtering, profile UX, reviews, admin activity quality, and documentation alignment.

### Major Verified Outcomes
- Full Playwright suite reached 127/127 passing.
- Live feature validation covered auth, home/search, recipe detail, create/edit, profile/favorites, reviews, and admin dashboards/workflows.

### Core Functional Fixes
1. Recipe lifecycle consistency
- Owner edits preserve recipe status (no forced `pending` on edit).
- Owner profile can query `status=all` so pending own recipes remain visible.

2. Recipe detail and navigation robustness
- Recipe payload handling normalized for both `{ recipe: ... }` and direct payload shape in detail/edit flows.
- Access control allows owner/admin access to non-published recipes.
- Route-bounce regression to home addressed and guarded by stronger tests.

3. Engagement correctness
- Recipe views deduplicated per authenticated user/recipe; response returns `viewRecorded` and `viewCount`.
- Like/save disabled messaging improved for pending/suspended users with status-specific aria/title copy.

4. Reviews behavior
- Reviews endpoint supports upsert semantics (single review per user/recipe; resubmission updates).
- UI reflects update mode where applicable.

5. Search and filter behavior
- Search title matching made deterministic (`title LIKE ...` path).
- Reset filters clears local state and URL params.

6. Profile/admin UX and audit quality
- Edit profile modal configured to avoid accidental dismissal (overlay/Escape behavior controlled).
- Login/logout account active state handling hardened with stale-active auto-sync.
- Admin recent activity excludes active/inactive churn noise.

7. Create form quality and security
- Image URL protocol restricted to `http/https`.
- Validation errors clear when corresponding fields are corrected.
- Create Recipe now starts with empty create-mode values for category/difficulty/prep/cook/servings; difficulty requires explicit selection.

### Documentation Sync Completed
- `README.md`, `CHANGELOG.md`, `docs/API_DOCUMENTATION.md`, `docs/TESTING_GUIDE.md` updated to reflect actual behavior and coverage.
- API docs synced for status visibility rules, view dedupe/auth, review upsert semantics, and admin activity filtering.

## Open Risks / Follow-ups
- IDOR hardening on user endpoints.
- CSRF protection and rate limiting strategy.
- Move DB credentials and cookie security policies to env/production-safe config.
- Keep regression tests for these fixes mandatory in CI (especially TEST-120..TEST-127 and navigation/detail guards).