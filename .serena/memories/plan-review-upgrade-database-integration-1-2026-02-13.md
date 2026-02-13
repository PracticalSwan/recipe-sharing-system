# Plan Review - upgrade-database-integration-1 (2026-02-13)

## Context
- Reviewed `plan/upgrade-database-integration-1.md` as a pre-implementation quality check.
- Objective: identify blockers, contradictions, and execution risks before Phase 4 backend work.

## Key Findings
- High: SQL guideline uses SQL Server parameter syntax (`@param`) while target DB is MySQL/MariaDB.
- High: Minimum DB version is declared as MySQL 5.7+, but the plan expects features that require MySQL 8.0+ (CTE and enforced CHECK behavior).
- Medium: Recipe detail task says viewing requires authentication, but API table marks `GET /api/recipes/{id}` as public.
- Medium: Endpoint total is stated as 31, but current table defines 29 endpoints.
- Medium: File summary count says 51 tracked files, but listed categories sum to 52.
- Low: File contains encoding artifacts (`â†’`, `âœ…`) that reduce readability and increase maintenance risk.

## Recommended Next Steps
1. Correct SQL conventions section for MySQL syntax and naming rules.
2. Update minimum DB version/dependency assumptions to MySQL 8.0+ (or explicitly define MariaDB-compatible alternatives).
3. Resolve auth behavior for recipe detail view and align tasks, API reference, and tests.
4. Recompute and fix summary counts (endpoints and file totals).
5. Normalize file encoding to UTF-8 and clean corrupted symbols.

## Resolution Applied (2026-02-13)
- Updated plan directly to fix all identified findings.
- Confirmed policy decision from user: application is authentication-gated for normal usage; data endpoints are authenticated except register/login.
- Updated recipe view-tracking rule: track only authenticated non-admin users.
- Updated DB baseline in plan: MySQL 8.0+ or MariaDB 10.4+.
- Corrected endpoint and file summary totals.
- Re-encoded plan content to remove mojibake artifacts and restore readable symbols.
