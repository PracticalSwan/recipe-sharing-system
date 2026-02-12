# Database Integration Implementation Plan Task

## Task Overview

**Date Created:** 2026-02-04  
**Last Updated:** 2026-02-08  
**Project:** Recipe Sharing System (CSX3006 Database Systems Course)  
**Status:** Phases 1-3 Complete — Plan v2.0 Merged — Phase 4+ Pending

## What Was Done

### Plan Merge: v1.0 → v2.0 (February 8, 2026)

The implementation plan was **completely rewritten** by merging v1.0 (`upgrade-database-integration-1.md`) with the v2.0 draft (`upgrade-to-fullstack-xampp-option1.md`). The merged document replaces 181 tasks with a cleaner 138-task plan.

#### Key Changes in v2.0 Merge

**Backend Simplified (Major Change):**
- **v1.0**: 23 PHP files in MVC pattern (models/, controllers/, middleware/)
- **v2.0**: 12 PHP files in flat procedural structure (config/, helpers/, api/)
- NO Composer, NO external frameworks, NO MVC pattern
- Each `api/*.php` file handles its own routing via `$_SERVER['REQUEST_METHOD']`
- Constraint CON-007 added: "No external PHP frameworks or Composer packages — plain PHP only"
- ALT-008 added documenting why MVC was rejected

**HTTP Client Changed:**
- **v1.0**: axios with interceptors
- **v2.0**: Native `fetch()` with `credentials: 'include'`
- ALT-007 added documenting why axios was rejected
- No additional npm dependency needed

**Auth Simplified:**
- **v1.0**: Session-based auth (primary) with JWT option noted
- **v2.0**: Session-based ONLY — JWT option fully removed
- Session table + HttpOnly cookie with SameSite=Lax

**Task Numbering Fixed:**
- **v1.0**: Had duplicate TASK-021 at Phase 2 start, Phase 6 renumbering issues, 181 total
- **v2.0**: Clean sequential TASK-001 to TASK-138 (no gaps, no duplicates)
- Phase 2 now starts at TASK-022

**OOP Patterns Removed:**
- Removed PAT-001 to PAT-004 (Repository, Singleton, Builder, Strategy patterns)
- Not applicable with flat procedural PHP approach

**Sections Added:**
- Section 8: API Endpoint Reference (31 endpoints across 7 files)
- Section 9: Database Reference (tables, views, procedures, triggers summary)
- Version history at document end

### Previous Updates (v1.0 history)

1. **2026-02-04**: Initial plan created, then updated with SQL naming conventions from `sql-sp-generation.instructions.md`, frontend-to-backend verification audit (63 storage.js calls mapped), gaps identified and filled (Profile.jsx, Admin pages, search history endpoints)
2. **2026-02-07**: All Phase 1-3 SQL scripts implemented (14 files), 53 tasks marked complete, guides/SQL_SCRIPTS.md created, Notion pages updated

## Implementation Status

### ✅ COMPLETED

1. **Phase 1: Database Design** (TASK-001 to TASK-021) — 18 of 21 tasks ✅
   - All DDL scripts: 01_create_database.sql through 04_create_views.sql
   - 13 tables, 2 views, 25+ indexes
   - TASK-001 to TASK-003 (ER diagrams/normalization) remain unchecked

2. **Phase 2: SQL Data Scripts** (TASK-022 to TASK-043) — 22 of 22 tasks ✅
   - All seed data: 05_seed_users.sql through 08_seed_stats.sql
   - All query scripts: 09_common_queries.sql through 11_analytics_queries.sql

3. **Phase 3: Advanced SQL** (TASK-044 to TASK-056) — 13 of 13 tasks ✅
   - Stored procedures: 12_stored_procedures.sql (4 procedures + 1 function)
   - Triggers: 13_triggers.sql (6 triggers with @DISABLE_TRIGGERS pattern)
   - Backup/restore: 14_backup_restore.sql

### ⏳ NOT YET IMPLEMENTED

4. **Phase 4: PHP Backend** (TASK-057 to TASK-092) — 36 tasks
   - Flat structure: backend/config/, backend/helpers/, backend/api/
   - 12 PHP files total (was 23 in v1.0)
   - 31 API endpoints across 7 api/*.php files

5. **Phase 5: Frontend Integration** (TASK-093 to TASK-115) — 23 tasks
   - src/lib/api.js (fetch-based, replaces storage.js)
   - 11 page files to modify
   - 3 new UI components (LoadingSpinner, ErrorMessage, ErrorBoundary)
   - storage.js to be deleted

6. **Phase 6: Testing & Docs** (TASK-116 to TASK-138) — 23 tasks
   - 45 test cases defined (TEST-001 to TEST-045)
   - 7 documentation files to create

## Key Files

| File | Purpose | Status |
|------|---------|--------|
| `plan/upgrade-database-integration-1.md` | Implementation plan v2.0 (merged) | ✅ Updated 2026-02-08 |
| `guides/database_implementation_logic_explanation.md` | Logic explanation | ✅ Created |
| `database/*.sql` (14 files) | SQL scripts | ✅ Complete (2026-02-07) |
| `guides/SQL_SCRIPTS.md` | All SQL scripts consolidated | ✅ Complete (2026-02-07) |
| `backend/**/*.php` (12 files) | PHP API (flat structure) | ⏳ Pending |
| `src/lib/api.js` | Frontend API layer (native fetch) | ⏳ Pending |

## Backend Structure Reference (v2.0)

```
backend/
├── .htaccess             # URL rewriting for clean API routes
├── config/
│   └── database.php      # PDO connection (singleton pattern)
├── helpers/
│   ├── cors.php          # CORS headers for localhost:5173
│   ├── auth.php          # Session validation & getCurrentUser
│   └── response.php      # JSON response helpers
└── api/
    ├── auth.php           # POST register/login/logout, GET me
    ├── recipes.php        # CRUD + like/favorite/view
    ├── reviews.php        # CRUD for reviews
    ├── users.php          # CRUD + status (admin)
    ├── search.php         # Search + history
    ├── stats.php          # Dashboard + daily stats
    └── activity.php       # Admin activity logs
```

## Task Count Summary

| Version | Total Tasks | Backend Files | HTTP Client | Auth |
|---------|-------------|---------------|-------------|------|
| v1.0 | 181 | 23 (MVC) | axios | Session + JWT option |
| v2.0 | 138 | 12 (flat) | fetch() | Session only |

## SQL Naming Convention Summary

```
Tables:          singular, snake_case     → user, recipe, recipe_view
Columns:         singular, snake_case     → author_id, created_at
Primary Keys:    id                       → user.id, recipe.id
Foreign Keys:    {table}_id               → author_id, recipe_id
Stored Procs:    usp_PascalCase          → usp_CreateRecipe
Functions:       fn_PascalCase           → fn_CalculateAvgRating
Views:           vw_snake_case           → vw_recipe_with_stat
Triggers:        trg_Table_Action        → trg_User_NewUserStat
Indexes:         idx_table_column        → idx_recipe_author_status
```

## Frontend→Backend Integration (63 storage.js calls → api.js)

All 63 localStorage calls from storage.js mapped to API endpoints:
- User Management: 15 calls → auth.php + users.php
- Recipe Management: 11 calls → recipes.php
- Review Management: 5 calls → reviews.php
- Engagement: 8 calls → recipes.php (like/favorite/view)
- Search & History: 4 calls → search.php
- Statistics & Activity: 9 calls → stats.php + activity.php
- Guest tracking: REMOVED (REQ-MIG-003)

## Important Reminders

- Follow `sql-sp-generation.instructions.md` for all SQL code
- Use prepared statements (PDO) in PHP for security
- Plain PHP only — NO Composer, NO frameworks (CON-007)
- Native fetch() with credentials:'include' — NO axios
- Session-based auth ONLY — NO JWT
- All recipe views require authenticated users (REQ-MIG-003)
- Test each phase before moving to the next
- Keep existing React frontend working during migration

## Next Steps

1. **START HERE:** Begin Phase 4 — PHP Backend API Development (TASK-057+)
2. Follow the 138-task sequence in `upgrade-database-integration-1.md` v2.0
3. Reference `guides/database_implementation_logic_explanation.md` for design decisions
4. Implement one phase at a time, testing each before proceeding
