# SQL/Backend Compatibility Fixes (2026-02-14)

## Context
User requested ensuring `database/*.sql` scripts work with the currently implemented PHP backend.

## Validation Approach
- Reviewed backend SQL usage across `backend/api/*.php` and `backend/helpers/auth.php`.
- Cross-checked against DDL in `database/02_create_tables.sql`.
- Reviewed scripts `database/09` to `database/14` for schema and execution-flow compatibility.

## Key Issues Found and Fixed
1. Trigger-state leakage in seeding workflow:
   - `database/05_seed_users.sql` disabled triggers and always reset to NULL, which could override an outer wrapper state.
   - `database/08_seed_stats.sql` inserted `recipe_view` rows without trigger guard, causing non-deterministic daily_stat side effects when triggers are enabled.

2. Trigger fallback admin id risk:
   - `database/13_triggers.sql` used `COALESCE(@current_admin_id, 1)` in `trg_Recipe_DeleteCleanup`, which can fail FK integrity if user id 1 is absent.

## Changes Applied
- `database/05_seed_users.sql`
  - Added save/restore of prior trigger state using `@PREV_DISABLE_TRIGGERS`.
- `database/08_seed_stats.sql`
  - Added save/disable/restore trigger-state guard around seed inserts.
- `database/13_triggers.sql`
  - Changed delete-log fallback from hardcoded `1` to `OLD.author_id`.
- `database/14_backup_restore.sql`
  - Updated rebuild sequence comments to reflect script-level trigger-state preservation.
- `README.md`
  - Added reset/seed note documenting trigger-state preservation behavior.

## Outcome
- SQL scripts are better aligned with backend behavior and safer under both standalone seed execution and wrapper-based rebuild execution.
- No runtime DB execution was performed in this environment; validation was static and flow-based.
