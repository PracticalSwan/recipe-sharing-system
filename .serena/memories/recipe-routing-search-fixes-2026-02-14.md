# Recipe Routing and Search Fixes (2026-02-14)

## Scope
- Fix recipe-card -> detail navigation bounce to home.
- Fix edit route flow for `/recipes/edit/:id`.
- Verify like toggle state/count behavior.
- Ensure keyword search (title matching) and difficulty filter behavior.

## Code Changes
- `src/pages/Recipe/RecipeDetail.jsx`
  - Normalized payload handling for `api.recipes.get(id)` by supporting both shapes: `{ recipe: ... }` and direct recipe payload.
  - Added payload guard to avoid undefined access.
  - Updated access rule: non-published recipes are viewable by owner and admin; other users are redirected.
  - Added `user` to effect dependencies for ownership check consistency.
  - Fixed review-author profile links to use nested `review.user.id` fallback (`/users/undefined` regression removed).

- `src/pages/Recipe/CreateRecipe.jsx`
  - Normalized payload handling for edit-mode loader (`data?.recipe ?? data`).
  - Added payload guard.
  - Owner check now compares numeric IDs safely.
  - Category parsing for edit mode now splits comma-separated category strings into arrays.

- `backend/api/search.php`
  - Search query changed to explicit title matching (`r.title LIKE ...`) for deterministic title-based results.

- Test hardening:
  - `tests/e2e.spec.js`: strengthened `TEST-018`, `TEST-020`, and `TEST-039` to assert detail content (`Ingredients`) so route-bounce regressions are caught.

- Documentation updates:
  - `README.md`: Added "Recent Fixes (2026-02-14)" section.
  - `CHANGELOG.md`: Added `[Unreleased] - 2026-02-14` fix entries.

## Verification
- Build: `cmd /c npm run build` succeeded.
- Playwright targeted runs passed:
  - TEST-018 (card -> detail URL)
  - TEST-020 (detail renders title)
  - TEST-034 (search keyword updates URL)
  - TEST-036 (difficulty filter)
  - TEST-039 (search result -> detail)
  - TEST-112 (card like toggle)
- Interactive Playwright checks:
  - Card navigation now remains on `/#/recipes/:id` and detail content loads.
  - Profile-card overlay edit button and detail-page edit button both open `/#/recipes/edit/:id` with edit form populated.
  - Detail-page like button toggles label and updates visible count.
  - Search `Carbonara` returns matching title; difficulty filter `Hard` -> 0 then `Medium` -> 1 for that query.

## Notes
- Existing tests still use loose assertions for some detail checks (e.g., generic `h1` can pass even if route briefly bounces). Consider tightening route-and-content assertions in future hardening pass.