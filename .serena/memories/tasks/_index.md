# Tasks Index — CSX3006 Recipe Sharing System

**Last Updated:** February 13, 2026

---

## Active Tasks

*No active tasks currently in progress.*

---

## Pending Tasks

### Database & Backend
- [TASK-DB-001] Execute SQL scripts (01-14) on phpMyAdmin to build complete database structure
- [TASK-BK-001] Initialize PHP backend folder structure (`backend/`)
- [TASK-BK-002] Implement `database.php` (PDO connection)
- [TASK-BK-003] Implement `auth.php` (register/login/logout with session)
- [TASK-BK-004] Implement recipe CRUD endpoints (`recipes.php`)
- [TASK-BK-005] Implement review endpoints (`reviews.php`)
- [TASK-BK-006] Implement favorite/like endpoints (`favorites.php`, `likes.php`)

### Frontend Integration
- [TASK-FE-001] Update `AuthContext.jsx` to use session-based auth instead of localStorage
- [TASK-FE-002] Update API calls to use `fetch()` with credentials:'include'
- [TASK-FE-003] Replace localStorage usage with API calls for data persistence
- [TASK-FE-004] Update Admin pages to use PHP API endpoints
- [TASK-FE-005] Update Recipe pages to use PHP API endpoints

### Testing & Documentation
- [TASK-TEST-001] Test authentication flow (register → login → session → logout)
- [TASK-TEST-002] Test recipe CRUD operations via API
- [TASK-TEST-003] Test admin moderation workflow (approve/reject)
- [TASK-TEST-004] Update README.md with backend setup instructions

---

## Completed Tasks

### SQL Scripts & Database Design
- [TASK-SQL-001] Create comprehensive SQL script documentation ✅
- [TASK-SQL-002] Develop all 14 database scripts (01-14) ✅
  - Script 01: `create_database.sql` — Database creation with UTF8MB4
  - Script 02: `create_tables.sql` — All 13 tables with FKs
  - Script 03: `create_indexes.sql` — 25+ performance indexes
  - Script 04: `create_views.sql` — 2 dashboard views
  - Script 05-08: Seed data (users, recipes, reviews, stats)
  - Script 09-12: Query libraries (common, admin, analytics, procedures)
  - Script 13: `triggers.sql` — 6 automation triggers
  - Script 14: `backup_restore.sql` — Maintenance scripts
- [TASK-SQL-003] Create database implementation logic explanation document ✅
- [TASK-SQL-004] Create SQL scripts reference guide ✅
- [TASK-SQL-005] Create phpMyAdmin setup guide ✅

### Implementation Planning
- [TASK-PLAN-001] Draft initial implementation plan v1.0 with 181 tasks ✅
- [TASK-PLAN-002] Simplify to plan v2.0 with 138 tasks ✅
  - Reduced backend from MVC to flat procedural
  - Changed axios to native fetch()
  - Removed JWT option (session-only auth)
  - Reduced Composer dependencies to none
- [TASK-PLAN-003] Merge implementation plan and upload to Notion ✅

### SQL Scripts Review & Fixes
- [TASK-FIX-001] Comprehensive review of all SQL scripts vs authoritative schema ✅ (February 13, 2026)
- [TASK-FIX-002] Fix `09_common_queries.sql` (5 queries completely rewritten) ✅
- [TASK-FIX-003] Fix `10_admin_queries.sql` (5 queries completely rewritten) ✅
- [TASK-FIX-004] Fix `11_analytics_queries.sql` (6 queries completely rewritten) ✅
- [TASK-FIX-005] Fix `12_stored_procedures.sql` (4 procedures + 1 function rewritten) ✅
- [TASK-FIX-006] Fix `13_triggers.sql` (2 targeted fixes across triggers) ✅
- [TASK-FIX-007] Fix `14_backup_restore.sql` (1 targeted fix) ✅
- [TASK-FIX-008] Verify all SQL scripts for consistency and correctness ✅

### Documentation Updates
- [TASK-DOC-001] Create comprehensive SQL fixes documentation memory ✅
- [TASK-DOC-002] Create recent work summary memory ✅
- [TASK-DOC-003] Update main project memory with SQL fix details ✅
- [TASK-DOC-004] Create Serena memory organization tasks index ✅

---

## Abandoned Tasks

*No abandoned tasks.*

---

## Task Statistics

| Category | Total | Completed | In Progress | Pending |
|-----------|-------|-----------|-------------|---------|
| **Database & SQL** | 12 | 12 | 0 | 0 |
| **Backend (PHP)** | 6 | 0 | 0 | 6 |
| **Frontend Integration** | 5 | 0 | 0 | 5 |
| **Testing & Docs** | 4 | 0 | 0 | 4 |
| **Planning** | 3 | 3 | 0 | 0 |
| **Documentation** | 4 | 4 | 0 | 0 |
| **Total** | **34** | **19** | **0** | **15** |

---

## Priority Queue

1. **HIGH:** TASK-BK-002 — Implement `database.php` (PDO connection) — **Blocks all backend work**
2. **HIGH:** TASK-BK-003 — Implement `auth.php` (register/login/logout) — **Essential for user system**
3. **MEDIUM:** TASK-BK-004 — Implement recipe CRUD endpoints — **Core functionality**
4. **MEDIUM:** TASK-FE-001 — Update AuthContext.jsx — **Frontend dependency**
5. **LOW:** TASK-TEST-001 — Test authentication flow — **Verification after implementation**

---

## Notes

### Phase Progress (From v2.0 Plan)
- ✅ Phase 1: Database Design (TASK-001 → TASK-021) — **100% Complete**
- ✅ Phase 2: SQL Data Scripts (TASK-022 → TASK-043) — **100% Complete**
- ✅ Phase 3: Advanced SQL (TASK-044 → TASK-056) — **100% Complete**
- ⏳ Phase 4: PHP Backend (TASK-057 → TASK-092) — **0% Complete** (Not Started)
- ⏳ Phase 5: Frontend Integration (TASK-093 → TASK-115) — **0% Complete** (Not Started)
- ⏳ Phase 6: Testing & Docs (TASK-116 → TASK-138) — **0% Complete** (Not Started)

**Overall Project Status:** **38% Complete (Phases 1-3 of 6)**

---

## Related Memories

- [csx3006-database-project-updates.md](../csx3006-database-project-updates.md) — Project overview and main updates
- [csx3006-sql-fixes-2026-02-13.md](../csx3006-sql-fixes-2026-02-13.md) — Detailed SQL fixes documentation
- [recent-work-summary-2026-02-13.md](../recent-work-summary-2026-02-13.md) — Session-by-session work log
