# Sentinel's Journal - Critical Security Learnings

## 2025-05-15 - [Authorization Bypass in Recipe Access]
**Vulnerability:** Authorization bypass in `backend/api/recipes.php` where non-admin users could view pending or rejected recipes by explicitly passing the `status` parameter in the list view or by accessing the recipe ID directly in the detail view.
**Learning:** Authorization checks were only applied to a specific "view all" mode, and were completely missing from the individual resource retrieval logic. This allowed access to sensitive non-public content via simple parameter manipulation or direct ID access (IDOR).
**Prevention:** Enforce status restrictions by default in all queries and verify ownership or administrative roles before returning sensitive resources, especially when fetching by a user-provided ID.

## 2025-05-22 - [Broken Access Control in User Status Enforcement]
**Vulnerability:** The backend `requireAuth` helper only verified the existence of a valid session but did not check the user's account status (`suspended` or `pending`). This allowed restricted users to perform authenticated actions (like, favorite, review, create recipes) if they already had an active session.
**Learning:** Authentication (identity verification) and Authorization (permission verification) are distinct steps. Even if a user is authenticated, their account state must be validated for every protected operation.
**Prevention:** Centralize authorization logic to include account status checks. All protected endpoints using `requireAuth` now automatically benefit from status-based access control.
