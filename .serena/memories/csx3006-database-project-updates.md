# CSX3006 Database Project - Implementation Updates

**Last Updated:** February 8, 2026

---

## Project Summary

**Course:** CSX3006 Database Systems  
**Project:** Recipe Sharing System - MySQL Database Integration  
**Status:** Phases 1-3 SQL Complete — Plan v2.0 Merged — Phase 4 PHP Backend Pending

---

## Latest Update: Plan v2.0 Merge (February 8, 2026)

The implementation plan was completely merged and rewritten:
- **File:** `plan/upgrade-database-integration-1.md` (v2.0)
- **Source:** Merged v1.0 (on disk) + v2.0 draft (`upgrade-to-fullstack-xampp-option1.md`)
- **Result:** 138 tasks (down from 181), simplified backend, cleaner numbering

### v2.0 Key Simplifications
| Aspect | v1.0 | v2.0 |
|--------|------|------|
| Backend structure | 23 files, MVC pattern | 12 files, flat procedural |
| HTTP client | axios | Native fetch() |
| Auth approach | Session + JWT option | Session only |
| Task count | 181 | 138 |
| PHP style | Models/Controllers/Middleware | config/ + helpers/ + api/*.php |
| Dependencies | Composer possible | No Composer (CON-007) |

### New Sections Added
- API Endpoint Reference (31 endpoints across 7 files)
- Database Reference (tables, views, procedures, triggers)
- ALT-007 (axios rejected), ALT-008 (MVC rejected)
- Version history

---

## Key Design Decisions (Unchanged)

### Recipe View Table - Authenticated Users Only
- `user_id` NOT NULL — no guest tracking (REQ-MIG-003)
- ON DELETE CASCADE for user_id FK
- Rationale: accurate analytics, simplified privacy, no bot noise

### Session-Based Auth (v2.0 — JWT removed)
- `session` table with `session_token` (VARCHAR 255 UNIQUE)
- `bin2hex(random_bytes(32))` for token generation
- HttpOnly cookie with SameSite=Lax
- `credentials: 'include'` in fetch requests

### Flat PHP Backend (v2.0 — MVC removed)
- Each api/*.php handles routing via `$_SERVER['REQUEST_METHOD']`
- `.htaccess` with mod_rewrite for clean URLs
- PDO with prepared statements for all DB access
- No Composer, no frameworks, no external packages

---

## Database Architecture

### Core Components

| Component | Count | Details |
|-----------|-------|---------|
| **Tables** | 13 | user, recipe, ingredient, instruction, recipe_image, review, favorite, like_record, recipe_view, search_history, daily_stat, activity_log, session |
| **Views** | 2 | vw_recipe_with_stat, vw_user_dashboard_stat |
| **Stored Procedures** | 4+1 | usp_CreateRecipe, usp_DeleteRecipe, usp_ApproveRecipe, usp_GetRecipeStat, fn_CalculateAvgRating |
| **Triggers** | 6 | Automatic maintenance and statistics updates |
| **Indexes** | 25+ | Foreign key, search, composite, and date-based indexes |

### Design Principles
- 3NF Normalization
- Singular table names, snake_case columns
- Surrogate keys (AUTO_INCREMENT INT)
- Cascade deletes for referential integrity
- UPPERCASE SQL keywords
- Comprehensive indexing for read-heavy browsing

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| **Database** | MySQL/MariaDB via XAMPP |
| **Backend API** | Plain PHP (no frameworks, no Composer) |
| **HTTP Client** | Native fetch() with credentials:'include' |
| **Frontend** | React 19 + Vite + Tailwind v4 |
| **Auth** | Session-based (server-side session table + HttpOnly cookie) |
| **Password** | bcrypt via password_hash() |

---

## Implementation Progress

| Phase | Tasks | Range | Status |
|-------|-------|-------|--------|
| Phase 1: Database Design | 21 | TASK-001 → TASK-021 | ✅ SQL Complete |
| Phase 2: SQL Data Scripts | 22 | TASK-022 → TASK-043 | ✅ Complete |
| Phase 3: Advanced SQL | 13 | TASK-044 → TASK-056 | ✅ Complete |
| Phase 4: PHP Backend | 36 | TASK-057 → TASK-092 | ⏳ Not Started |
| Phase 5: Frontend Integration | 23 | TASK-093 → TASK-115 | ⏳ Not Started |
| Phase 6: Testing & Docs | 23 | TASK-116 → TASK-138 | ⏳ Not Started |
| **Total** | **138** | | **38% Complete** |

---

## SQL Scripts (All 14 Complete — 2026-02-07)

| # | File | Purpose |
|---|------|---------|
| 01 | `01_create_database.sql` | CREATE DATABASE cookhub with UTF8MB4 |
| 02 | `02_create_tables.sql` | All 13 tables with FKs, constraints |
| 03 | `03_create_indexes.sql` | 25+ indexes across all tables |
| 04 | `04_create_views.sql` | vw_recipe_with_stat, vw_user_dashboard_stat |
| 05 | `05_seed_users.sql` | 3 admins + 9 users with bcrypt hashes |
| 06 | `06_seed_recipes.sql` | 13 recipes, 52 ingredients, 56 instructions, 13 images |
| 07 | `07_seed_reviews.sql` | 25 reviews, 14 likes, 7 favorites |
| 08 | `08_seed_stats.sql` | 23 recipe views, 30 daily stats, 15 search history, 18 activity logs |
| 09 | `09_common_queries.sql` | 5 common SELECT queries |
| 10 | `10_admin_queries.sql` | 5 admin dashboard queries |
| 11 | `11_analytics_queries.sql` | 6 analytics queries |
| 12 | `12_stored_procedures.sql` | 4 procs + 1 function |
| 13 | `13_triggers.sql` | 6 triggers with @DISABLE_TRIGGERS pattern |
| 14 | `14_backup_restore.sql` | Backup/restore docs, health check |

**User-to-ID mapping:** admin=1, olivia=2, marcus=3, john=4, maria=5, tom=6, amy=7, kevin=8, sarah=9, daniel=10, lina=11, omar=12

---

## Naming Conventions Reference

| Element | Convention | Example |
|---------|------------|---------|
| Tables | singular, snake_case | user, recipe_view |
| Columns | singular, snake_case | first_name, author_id |
| Primary Keys | id | user.id, recipe.id |
| Foreign Keys | {table}_id | author_id, recipe_id |
| Indexes | idx_{table}_{cols} | idx_recipe_author_status |
| Views | vw_{description} | vw_recipe_with_stat |
| Procedures | usp_{Action}{Entity} | usp_CreateRecipe |
| Functions | fn_{Action}{Entity} | fn_CalculateAvgRating |
| Triggers | trg_{Table}_{Event} | trg_User_NewUserStat |

---

## Documentation & Notion Links

### Local Files
- `plan/upgrade-database-integration-1.md` — Implementation plan v2.0
- `guides/database_implementation_logic_explanation.md` — Design logic (1418 lines)
- `guides/SQL_SCRIPTS.md` — Consolidated SQL reference
- `guides/SETUP_GUIDE_PHPMYADMIN.md` — Database setup guide

### Notion Pages
- Implementation Plan: https://www.notion.so/2fde35b852f08152b4ade1f4b1233c38
- Database Reference: https://www.notion.so/2fee35b852f081f3a208f2436961d94f
- SQL Scripts Reference: https://www.notion.so/300e35b852f081c5a148ec7aa1cee4c8

---

## Next Steps

1. **Begin Phase 4:** PHP Backend API Development (TASK-057+)
2. Create `backend/` folder structure with flat PHP files
3. Implement database.php (PDO connection) first
4. Build auth.php (register/login/logout) second
5. Follow the 138-task sequence in plan v2.0
