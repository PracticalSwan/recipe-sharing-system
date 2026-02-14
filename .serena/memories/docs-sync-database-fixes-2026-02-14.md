# Documentation Sync for Database Fixes (2026-02-14)

## Goal
Update project documentation to reflect recent database script behavior changes:
- Trigger-state preservation in seed scripts (`05_seed_users.sql`, `08_seed_stats.sql`)
- Trigger delete-log fallback update in `13_triggers.sql`
- Rebuild sequence adjustment in `14_backup_restore.sql`

## Files Updated
1. `guides/SETUP_GUIDE_PHPMYADMIN.md`
- Removed outdated mandatory manual trigger toggle steps before/after seeding.
- Added note that seed scripts now preserve and restore `@DISABLE_TRIGGERS` automatically.
- Added optional wrapper-mode note for advanced users.

2. `guides/SQL_SCRIPTS.md`
- Updated execution-order table (removed manual trigger disable/enable steps).
- Updated embedded `05_seed_users.sql` snippet to show `@PREV_DISABLE_TRIGGERS` save/restore flow.
- Updated embedded trigger snippet fallback to `COALESCE(@current_admin_id, OLD.author_id)`.
- Updated embedded timestamp trigger snippets to `BEFORE INSERT` with NULL checks for `created_at` and `updated_at`.
- Updated embedded rebuild sequence to match current `14_backup_restore.sql` comments.

3. `guides/database_implementation_logic_explanation.md`
- Updated `trg_Recipe_DeleteCleanup` example to include `admin_id` with fallback `COALESCE(@current_admin_id, OLD.author_id)`.

## Verification
- Searched docs for stale patterns:
  - Removed outdated manual rebuild toggles from setup/rebuild guidance.
  - Removed old `COALESCE(@current_admin_id, 1)` usage from documented trigger examples.
  - Confirmed updated docs contain the new trigger-state preservation language.

## Notes
- `README.md` already contained an updated seed execution note from prior changes; no additional modifications were necessary in this pass.