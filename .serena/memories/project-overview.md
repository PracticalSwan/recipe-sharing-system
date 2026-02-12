# Recipe Sharing System — Project Overview

**Project:** Recipe Sharing System (React 19 + Vite + Tailwind v4). CSX3006 Database Systems course project.

**Current Focus:** Database implementation complete with all 14 SQL scripts verified and corrected (February 13, 2026).

**Technology Stack:**
- Frontend: React 19 + Vite + Tailwind v4
- Database: MySQL/MariaDB with 13 tables + 6 triggers + 4 stored procedures
- Backend: Plain PHP (flat procedural, XAMPP) — Phase 4 pending
- Auth: Session-based with HttpOnly cookies
- HTTP: Native fetch() with credentials:'include'

---

## Project Status — 38% Complete (Phases 1-3 of 6)

**✅ Phase 1: Database Design** — 100% Complete
- All 13 tables designed with FKs and constraints
- Naming conventions: singular tables, snake_case columns, `id` PKs

**✅ Phase 2: SQL Data Scripts** — 100% Complete
- Scripts 01-04: Database, tables, indexes, views
- Scripts 05-08: Seed data (users, recipes, reviews, stats)

**✅ Phase 3: Advanced SQL** — 100% Complete
- Script 09-12: Query libraries, stored procedures, functions
- Script 13-14: Triggers, backup/restore utilities
- **February 13, 2026:** Comprehensive review and fixes applied to scripts 09-14 for schema consistency

**⏳ Phase 4: PHP Backend** — 0% Complete (Not Started)
- PDO connection, session management, CRUD API endpoints
- 36 tasks remaining (TASK-057 → TASK-092)

**⏳ Phase 5: Frontend Integration** — 0% Complete (Not Started)
- Session auth integration, API client migration, localStorage replacement
- 23 tasks remaining (TASK-093 → TASK-115)

**⏳ Phase 6: Testing & Docs** — 0% Complete (Not Started)
- end-to-end testing, performance validation, documentation
- 23 tasks remaining (TASK-116 → TASK-138)

---

## Recent Work (February 13, 2026)

**SQL Fixes:** Full review of all 14 SQL scripts vs authoritative schema (02_create_tables.sql). Fixed column name mismatches in scripts 09-14: parent table PK corrections, column renames, ENUM case fixes, removed non-existent columns.

**Plan v2.0 (February 8, 2026):** Merged implementation plan from 181 to 138 tasks. Simplified backend from 23 files (MVC) to 12 files (flat procedural), switched from axios to native fetch(), removed JWT option.

---

## Next Steps

1. Execute SQL scripts 01-14 in phpMyAdmin (build complete database)
2. Create `backend/` folder structure with flat PHP files
3. Implement `database.php` (PDO connection)
4. Implement `auth.php` (register/login/logout)
5. Follow 138-task sequence in [upgrade-database-integration-1.md](../../plan/upgrade-database-integration-1.md)

---

## Implementation Plan: 138 tasks across 6 phases

**Documentation:** [upgrade-database-integration-1.md](../../plan/upgrade-database-integration-1.md) (v2.0)  
**Task Tracking:** [database-integration-implementation-plan-task.md](../database-integration-implementation-plan-task.md)  
**SQL Fix Details:** [csx3006-sql-fixes-2026-02-13.md](../csx3006-sql-fixes-2026-02-13.md)