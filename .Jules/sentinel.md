# Sentinel's Journal - Critical Security Learnings

## 2025-05-15 - [Authorization Bypass in Recipe Access]
**Vulnerability:** Authorization bypass in `backend/api/recipes.php` where non-admin users could view pending or rejected recipes by explicitly passing the `status` parameter in the list view or by accessing the recipe ID directly in the detail view.
**Learning:** Authorization checks were only applied to a specific "view all" mode, and were completely missing from the individual resource retrieval logic. This allowed access to sensitive non-public content via simple parameter manipulation or direct ID access (IDOR).
**Prevention:** Enforce status restrictions by default in all queries and verify ownership or administrative roles before returning sensitive resources, especially when fetching by a user-provided ID.
