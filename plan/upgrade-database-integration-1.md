---
goal: Integrate MySQL Database Backend into Recipe Sharing System
version: 2.0
date_created: 2026-02-04
last_updated: 2026-02-14
owner: CSX3006 Database Systems Course Project
status: 'In Progress (83% Complete — Phases 1-5 Done)'
tags: [database, backend, php, mysql, api, migration, architecture, xampp]
---

# Introduction

![Status: In Progress](https://img.shields.io/badge/status-83%25%20Complete-blue)

This implementation plan outlines the complete migration of the Recipe Sharing System from a localStorage-based frontend-only application to a full-stack web application with MySQL database backend and PHP RESTful API. The plan maintains all existing frontend functionality while demonstrating comprehensive database design, SQL scripting, and backend development skills required for the CSX3006 Database Systems course.

The migration will transform the current React+Vite application into a three-tier architecture (Presentation Layer → Application Layer → Data Layer) while preserving all features including authentication, recipe management, reviews, favorites, search, and admin dashboard functionality.

**Architecture Overview:**

```
┌─────────────────────────┐
│   React + Vite + TW4    │  ← Presentation Layer (port 5173)
│   (fetch + credentials) │
└───────────┬─────────────┘
            │ HTTP (JSON)
┌───────────▼─────────────┐
│   PHP REST API (XAMPP)   │  ← Application Layer (port 80/8080)
│   Plain PHP, no framework│
│   PDO + Prepared Stmts   │
│   Session-based Auth     │
└───────────┬─────────────┘
            │ PDO/MySQL
┌───────────▼─────────────┐
│   MySQL / MariaDB        │  ← Data Layer (port 3306)
│   Database: cookhub      │
│   13 tables, 2 views     │
│   5 procedures, 6 triggers│
└─────────────────────────┘
```

## 1. Requirements & Constraints

### Database Requirements
- **REQ-DB-001**: Use MySQL/MariaDB relational database management system
- **REQ-DB-002**: Database schema must be properly normalized (3NF minimum)
- **REQ-DB-003**: All tables must have appropriate primary keys (singular form: `id`)
- **REQ-DB-004**: All foreign key constraints must be named and defined inline
- **REQ-DB-005**: All foreign key constraints must have `ON DELETE CASCADE` and `ON UPDATE CASCADE` options where appropriate
- **REQ-DB-006**: Implement proper indexes for query performance optimization
- **REQ-DB-007**: Use appropriate data types for all columns
- **REQ-DB-008**: All table names must be in singular form (e.g., `user`, not `users`)
- **REQ-DB-009**: All column names must be in singular form and use snake_case naming convention
- **REQ-DB-010**: All tables must have `created_at` timestamp column for creation tracking
- **REQ-DB-011**: All tables must have `updated_at` timestamp column for modification tracking

### SQL Script Requirements (Course Requirements)
- **REQ-SQL-001**: Provide complete DDL scripts for database and table creation
- **REQ-SQL-002**: Provide DML scripts for data seeding with sample data
- **REQ-SQL-003**: Include complex SELECT queries demonstrating JOINs, subqueries, aggregation
- **REQ-SQL-004**: Document all SQL scripts with comments explaining purpose
- **REQ-SQL-005**: Include stored procedures for complex operations
- **REQ-SQL-006**: Implement triggers for automatic logging/statistics updates
- **REQ-SQL-007**: Create views for commonly used complex queries

### Backend API Requirements
- **REQ-API-001**: Implement RESTful API using plain PHP (compatible with XAMPP environment)
- **REQ-API-002**: Use PDO (PHP Data Objects) for secure database access
- **REQ-API-003**: Implement prepared statements to prevent SQL injection
- **REQ-API-004**: All endpoints must return JSON responses
- **REQ-API-005**: Implement proper HTTP status codes (200, 201, 400, 401, 403, 404, 500)
- **REQ-API-006**: Support CORS for React frontend communication
- **REQ-API-007**: Implement session-based authentication using the `session` table and HTTP cookies
- **REQ-API-008**: Include input validation and sanitization for all endpoints
- **REQ-API-009**: Application data endpoints require authenticated sessions (only `/api/auth/register` and `/api/auth/login` are public)

### Frontend Integration Requirements
- **REQ-FE-001**: Maintain all existing React components without breaking changes
- **REQ-FE-002**: Replace localStorage operations with API calls using native `fetch()`
- **REQ-FE-003**: Implement loading states for async operations
- **REQ-FE-004**: Use `credentials: 'include'` in all fetch requests for session cookie handling
- **REQ-FE-005**: Add proper error handling for network failures
- **REQ-FE-006**: Support environment configuration for API URL (API_BASE_URL)

### Security Requirements
- **SEC-001**: Store passwords using `password_hash()` with `PASSWORD_BCRYPT`
- **SEC-002**: Implement authentication for protected routes
- **SEC-003**: Implement role-based authorization (Admin vs User)
- **SEC-004**: Prevent SQL injection through prepared statements exclusively
- **SEC-005**: Validate and sanitize all user inputs
- **SEC-006**: Set session cookie with `HttpOnly`, `SameSite=Lax` attributes
- **SEC-007**: Use HTTPS in production environment

### Data Migration Requirements
- **REQ-MIG-001**: Preserve existing seed data structure from storage.js
- **REQ-MIG-002**: Maintain data relationships (users, recipes, reviews, etc.)
- **REQ-MIG-003**: All recipe views must be associated with authenticated non-admin users only (no guest tracking, no admin view tracking)

### Constraints
- **CON-001**: Must work with XAMPP environment (Apache + MySQL + PHP)
- **CON-002**: Frontend build process should remain unchanged (Vite)
- **CON-003**: Must maintain backward compatibility with existing React components
- **CON-004**: Database server should handle concurrent user access
- **CON-005**: API response time should be under 200ms for simple queries
- **CON-006**: Support at minimum 100 concurrent users
- **CON-007**: No external PHP frameworks or Composer packages — plain PHP only

### Guidelines & Patterns
- **GUD-001**: Follow RESTful API design principles
- **GUD-002**: Use consistent naming conventions (snake_case for database columns/tables, camelCase for JavaScript, PascalCase for PHP classes)
- **GUD-003**: Implement comprehensive error logging
- **GUD-004**: Write self-documenting code with clear comments
- **GUD-005**: Follow PHP PSR standards for code style
- **GUD-006**: SQL keywords must be in UPPERCASE (SELECT, FROM, WHERE, INSERT, UPDATE, DELETE, CREATE, etc.)
- **GUD-007**: Use consistent indentation for nested SQL queries and conditions
- **GUD-008**: Include comments in SQL scripts to explain complex logic
- **GUD-009**: Break long SQL queries into multiple lines for readability
- **GUD-010**: Organize SQL clauses consistently (SELECT, FROM, JOIN, WHERE, GROUP BY, HAVING, ORDER BY)
- **GUD-011**: Use explicit column names in SELECT statements instead of SELECT *
- **GUD-012**: Qualify column names with table name or alias when using multiple tables
- **GUD-013**: Stored procedure names must use 'usp_' prefix and PascalCase (e.g., usp_CreateRecipe)
- **GUD-014**: Function names must use 'fn_' prefix and PascalCase (e.g., fn_CalculateAvgRating)
- **GUD-015**: View names must use 'vw_' prefix and snake_case (e.g., vw_recipe_with_stat)
- **GUD-016**: Trigger names must use 'trg_' prefix followed by TableName_Action (e.g., trg_Recipe_DeleteCleanup)
- **GUD-017**: Stored procedure parameters must use `p_` prefix with snake_case (e.g., `p_recipe_id`, `p_author_id`)
- **GUD-018**: Provide default values for optional stored procedure parameters
- **GUD-019**: Document stored procedures with header comment blocks including description, parameters, and return values
- **GUD-020**: Temporary tables must use 'tmp_' prefix
- **GUD-021**: Each PHP API file handles its own routing via `$_SERVER['REQUEST_METHOD']` and URL parsing
- **GUD-022**: Use `.htaccess` with `mod_rewrite` for clean API URLs

## 2. Implementation Steps

### Phase 1: Database Design & Schema Creation

**GOAL-001**: Design normalized database schema and create all SQL DDL scripts

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Create conceptual ER diagram showing entities and relationships | | |
| TASK-002 | Create logical ER diagram with attributes and cardinalities | | |
| TASK-003 | Normalize schema to 3NF (identify functional dependencies) | | |
| TASK-004 | Write `01_create_database.sql` - CREATE DATABASE `cookhub` with charset UTF8MB4 | ✅ | 2026-02-07 |
| TASK-005 | Write `02_create_tables.sql` - All 13 CREATE TABLE statements with PKs, FKs, constraints | ✅ | 2026-02-07 |
| TASK-006 | Design `user` table: id (PK INT AUTO_INCREMENT), username (VARCHAR 100), first_name (VARCHAR 50), last_name (VARCHAR 50), email (VARCHAR 100 UNIQUE NOT NULL), password_hash (VARCHAR 255 NOT NULL), birthday (DATE), role (ENUM: 'admin', 'user'), status (ENUM: 'active', 'inactive', 'pending', 'suspended'), joined_date (DATETIME), last_active (DATETIME), avatar_url (TEXT), bio (TEXT), location (VARCHAR 100), cooking_level (VARCHAR 50), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-007 | Design `recipe` table: id (PK INT AUTO_INCREMENT), title (VARCHAR 200 NOT NULL), description (TEXT), category (VARCHAR 50), difficulty (ENUM: 'Easy', 'Medium', 'Hard'), prep_time (INT), cook_time (INT), servings (INT), author_id (INT FK→user.id ON DELETE CASCADE), status (ENUM: 'published', 'pending', 'rejected' DEFAULT 'pending'), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-008 | Design `ingredient` table: id (PK INT AUTO_INCREMENT), recipe_id (INT FK→recipe.id ON DELETE CASCADE), name (VARCHAR 200 NOT NULL), quantity (VARCHAR 50), unit (VARCHAR 50), sort_order (INT DEFAULT 0), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-009 | Design `instruction` table: id (PK INT AUTO_INCREMENT), recipe_id (INT FK→recipe.id ON DELETE CASCADE), step_number (INT NOT NULL), instruction_text (TEXT NOT NULL), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-010 | Design `recipe_image` table: id (PK INT AUTO_INCREMENT), recipe_id (INT FK→recipe.id ON DELETE CASCADE), image_url (TEXT NOT NULL), display_order (INT DEFAULT 0), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-011 | Design `review` table: id (PK INT AUTO_INCREMENT), user_id (INT FK→user.id ON DELETE CASCADE), recipe_id (INT FK→recipe.id ON DELETE CASCADE), rating (INT CHECK 1-5), comment (TEXT), created_at (TIMESTAMP), updated_at (TIMESTAMP), UNIQUE KEY (user_id, recipe_id) | ✅ | 2026-02-07 |
| TASK-012 | Design `favorite` table: id (PK INT AUTO_INCREMENT), user_id (INT FK→user.id ON DELETE CASCADE), recipe_id (INT FK→recipe.id ON DELETE CASCADE), created_at (TIMESTAMP), updated_at (TIMESTAMP), UNIQUE KEY (user_id, recipe_id) | ✅ | 2026-02-07 |
| TASK-013 | Design `like_record` table: id (PK INT AUTO_INCREMENT), user_id (INT FK→user.id ON DELETE CASCADE), recipe_id (INT FK→recipe.id ON DELETE CASCADE), created_at (TIMESTAMP), updated_at (TIMESTAMP), UNIQUE KEY (user_id, recipe_id) | ✅ | 2026-02-07 |
| TASK-014 | Design `recipe_view` table: id (PK INT AUTO_INCREMENT), recipe_id (INT FK→recipe.id ON DELETE CASCADE), user_id (INT NOT NULL FK→user.id ON DELETE CASCADE), viewed_at (TIMESTAMP), created_at (TIMESTAMP), updated_at (TIMESTAMP), INDEX idx_recipe_viewed, INDEX idx_user_viewed | ✅ | 2026-02-07 |
| TASK-015 | Design `search_history` table: id (PK INT AUTO_INCREMENT), user_id (INT FK→user.id ON DELETE CASCADE), query (TEXT NOT NULL), searched_at (TIMESTAMP), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-016 | Design `daily_stat` table: id (PK INT AUTO_INCREMENT), stat_date (DATE UNIQUE NOT NULL), page_view_count (INT DEFAULT 0), active_user_count (INT DEFAULT 0), new_user_count (INT DEFAULT 0), recipe_view_count (INT DEFAULT 0), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-017 | Design `activity_log` table: id (PK INT AUTO_INCREMENT), admin_id (INT FK→user.id ON DELETE SET NULL), action_type (ENUM: 'user_create', 'user_update', 'user_delete', 'recipe_approve', 'recipe_reject', 'recipe_delete'), target_type (VARCHAR 50), target_id (INT), description (TEXT), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-018 | Design `session` table: id (PK INT AUTO_INCREMENT), user_id (INT FK→user.id ON DELETE CASCADE), session_token (VARCHAR 255 UNIQUE NOT NULL), expires_at (DATETIME NOT NULL), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-019 | Write `03_create_indexes.sql` - CREATE INDEX statements for: user(email), recipe(author_id, status, category), review(recipe_id, user_id), recipe_view(recipe_id, viewed_at), search_history(user_id, searched_at), daily_stat(stat_date), activity_log(admin_id, created_at) | ✅ | 2026-02-07 |
| TASK-020 | Write `04_create_views.sql` - Create view `vw_recipe_with_stat`: joins recipe with like_count, view_count, avg_rating, author info using aggregation | ✅ | 2026-02-07 |
| TASK-021 | Write `04_create_views.sql` - Create view `vw_user_dashboard_stat`: aggregates user's recipe count, favorite count, review count for dashboard display | ✅ | 2026-02-07 |

### Phase 2: SQL Data Scripts & Queries

**GOAL-002**: Create comprehensive DML scripts for data seeding and demonstrate SQL query proficiency

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-022 | Write `05_seed_users.sql` - INSERT statements for 3 admin users (admin=1, matching current seed data) | ✅ | 2026-02-07 |
| TASK-023 | Write `05_seed_users.sql` - INSERT statements for 9 user accounts with varying statuses (olivia=2, marcus=3, john=4, maria=5, tom=6, amy=7, kevin=8, sarah=9, daniel=10, lina=11, omar=12) | ✅ | 2026-02-07 |
| TASK-024 | Write `06_seed_recipes.sql` - INSERT statements for 10+ sample recipes with varying statuses | ✅ | 2026-02-07 |
| TASK-025 | Write `06_seed_recipes.sql` - INSERT corresponding ingredients for each recipe (3-10 per recipe) | ✅ | 2026-02-07 |
| TASK-026 | Write `06_seed_recipes.sql` - INSERT corresponding instructions for each recipe (4-8 steps each) | ✅ | 2026-02-07 |
| TASK-027 | Write `06_seed_recipes.sql` - INSERT recipe images (1-3 images per recipe) | ✅ | 2026-02-07 |
| TASK-028 | Write `07_seed_reviews.sql` - INSERT sample reviews (20+ reviews across recipes) | ✅ | 2026-02-07 |
| TASK-029 | Write `07_seed_reviews.sql` - INSERT likes and favorites data | ✅ | 2026-02-07 |
| TASK-030 | Write `08_seed_stats.sql` - INSERT historical daily stats (last 30 days) | ✅ | 2026-02-07 |
| TASK-031 | Write `08_seed_stats.sql` - INSERT activity logs for admin actions | ✅ | 2026-02-07 |
| TASK-032 | Write `09_common_queries.sql` - SELECT query: Get all published recipes with author info (JOIN) | ✅ | 2026-02-07 |
| TASK-033 | Write `09_common_queries.sql` - SELECT query: Get recipe details with ingredients, instructions, images (multiple JOINs) | ✅ | 2026-02-07 |
| TASK-034 | Write `09_common_queries.sql` - SELECT query: Get user's favorite recipes with stats | ✅ | 2026-02-07 |
| TASK-035 | Write `09_common_queries.sql` - SELECT query: Search recipes by title/description (LIKE with full-text search) | ✅ | 2026-02-07 |
| TASK-036 | Write `09_common_queries.sql` - SELECT query: Get recipe reviews with user info ordered by date | ✅ | 2026-02-07 |
| TASK-037 | Write `10_admin_queries.sql` - SELECT query: Count users by status (GROUP BY, COUNT) | ✅ | 2026-02-07 |
| TASK-038 | Write `10_admin_queries.sql` - SELECT query: Count recipes by status and author | ✅ | 2026-02-07 |
| TASK-039 | Write `10_admin_queries.sql` - SELECT query: Get pending recipes with author details for approval queue | ✅ | 2026-02-07 |
| TASK-040 | Write `11_analytics_queries.sql` - SELECT query: Top 10 recipes by views/likes/ratings (ORDER BY, LIMIT) | ✅ | 2026-02-07 |
| TASK-041 | Write `11_analytics_queries.sql` - SELECT query: User engagement metrics (subqueries for recipe count, review count, favorite count) | ✅ | 2026-02-07 |
| TASK-042 | Write `11_analytics_queries.sql` - SELECT query: Daily/weekly/monthly growth trends (DATE functions, aggregation) | ✅ | 2026-02-07 |
| TASK-043 | Write `11_analytics_queries.sql` - SELECT query: Recipe category distribution and popularity | ✅ | 2026-02-07 |

### Phase 3: Advanced SQL Features

**GOAL-003**: Implement stored procedures, triggers, and advanced SQL features

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-044 | Write `12_stored_procedures.sql` - CREATE PROCEDURE `usp_CreateRecipe` (handles transaction for recipe + ingredient + instruction inserts with proper error handling) | ✅ | 2026-02-07 |
| TASK-045 | Write `12_stored_procedures.sql` - CREATE PROCEDURE `usp_DeleteRecipe` (cascading deletes with cleanup, logs activity) | ✅ | 2026-02-07 |
| TASK-046 | Write `12_stored_procedures.sql` - CREATE PROCEDURE `usp_ApproveRecipe` (updates status to 'published' + logs activity) | ✅ | 2026-02-07 |
| TASK-047 | Write `12_stored_procedures.sql` - CREATE PROCEDURE `usp_GetRecipeStat` (returns aggregated statistics for a recipe: likes, views, avg_rating) | ✅ | 2026-02-07 |
| TASK-048 | Write `12_stored_procedures.sql` - CREATE FUNCTION `fn_CalculateAvgRating` (returns DECIMAL average rating for recipe_id parameter) | ✅ | 2026-02-07 |
| TASK-049 | Write `13_triggers.sql` - CREATE TRIGGER `trg_RecipeView_UpdateStat` - AFTER INSERT on recipe_view, increment daily_stat.recipe_view_count | ✅ | 2026-02-07 |
| TASK-050 | Write `13_triggers.sql` - CREATE TRIGGER `trg_User_UpdateLastActive` - BEFORE UPDATE on session, update user.last_active timestamp | ✅ | 2026-02-07 |
| TASK-051 | Write `13_triggers.sql` - CREATE TRIGGER `trg_Recipe_DeleteCleanup` - BEFORE DELETE on recipe, log activity_log entry | ✅ | 2026-02-07 |
| TASK-052 | Write `13_triggers.sql` - CREATE TRIGGER `trg_User_NewUserStat` - AFTER INSERT on user, increment daily_stat.new_user_count for today | ✅ | 2026-02-07 |
| TASK-053 | Write `13_triggers.sql` - CREATE TRIGGER `trg_Recipe_SetTimestamp` - BEFORE INSERT on recipe, set created_at and updated_at if NULL | ✅ | 2026-02-07 |
| TASK-054 | Write `13_triggers.sql` - CREATE TRIGGER `trg_User_SetTimestamp` - BEFORE INSERT on user, set created_at and updated_at if NULL | ✅ | 2026-02-07 |
| TASK-055 | Write `14_backup_restore.sql` - Document BACKUP DATABASE using mysqldump command with examples | ✅ | 2026-02-07 |
| TASK-056 | Write `14_backup_restore.sql` - Document RESTORE DATABASE using mysql command with examples | ✅ | 2026-02-07 |

### Phase 4: PHP Backend API Development

**GOAL-004**: Develop complete PHP RESTful API with secure database access using plain PHP (no frameworks)

**Backend Structure:**

```
backend/
├── .htaccess                    # URL rewriting for clean API routes
├── config/
│   └── database.php             # PDO connection (singleton pattern)
├── helpers/
│   ├── cors.php                 # CORS headers for localhost:5173
│   ├── auth.php                 # Session validation & getCurrentUser
│   └── response.php             # JSON response helpers
└── api/
    ├── auth.php                 # POST register/login/logout, GET me
    ├── recipes.php              # CRUD + like/favorite/view
    ├── reviews.php              # CRUD for reviews
    ├── users.php                # CRUD + status (admin)
    ├── search.php               # Search + history
    ├── stats.php                # Dashboard + daily stats
    └── activity.php             # Admin activity logs
```

**Setup & Configuration:**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-057 | Create backend folder structure: `backend/` with subdirs: `config/`, `helpers/`, `api/` | ✅ | 2026-02-14 |
| TASK-058 | Create `backend/config/database.php` - PDO connection class using singleton pattern, charset utf8mb4, error mode EXCEPTION, default fetch ASSOC | ✅ | 2026-02-14 |
| TASK-059 | Create `backend/.htaccess` - mod_rewrite rules to route `/api/{resource}` to `api/{resource}.php`, pass path info via query string | ✅ | 2026-02-14 |
| TASK-060 | Create `backend/helpers/cors.php` - Set CORS headers: `Access-Control-Allow-Origin: http://localhost:5173`, `Access-Control-Allow-Credentials: true`, `Access-Control-Allow-Methods`, `Access-Control-Allow-Headers`, handle OPTIONS preflight | ✅ | 2026-02-14 |
| TASK-061 | Create `backend/helpers/auth.php` - `getCurrentUser($pdo)` function: read session token from cookie, validate against `session` table, check `expires_at`, return user row or null; `requireAuth($pdo)` function: call getCurrentUser, return 401 if null | ✅ | 2026-02-14 |
| TASK-062 | Create `backend/helpers/response.php` - Helper functions: `jsonResponse($data, $status)`, `errorResponse($message, $status)`, `paginatedResponse($data, $total, $page, $limit)` | ✅ | 2026-02-14 |

**Auth API Endpoints (`api/auth.php`):**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-063 | `POST /api/auth/register` - Validate required fields (username, email, password, first_name, last_name), check email uniqueness, `password_hash()` with BCRYPT, INSERT into user table, create session, set HttpOnly cookie, return user data | ✅ | 2026-02-14 |
| TASK-064 | `POST /api/auth/login` - Validate email + password, `password_verify()`, create session row with `bin2hex(random_bytes(32))` token, set HttpOnly/SameSite=Lax cookie, update user.last_active, return user data | ✅ | 2026-02-14 |
| TASK-065 | `POST /api/auth/logout` - Read session token from cookie, DELETE from session table, clear cookie | ✅ | 2026-02-14 |
| TASK-066 | `GET /api/auth/me` - Call `requireAuth()`, return current user data from session (exclude password_hash) | ✅ | 2026-02-14 |

**Recipe API Endpoints (`api/recipes.php`):**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-067 | `GET /api/recipes` - requireAuth, return published recipes with optional filters: `?category=`, `?difficulty=`, `?search=`, `?sort=`, `?page=`, `?limit=`. JOIN with user for author info, include like_count/view_count/avg_rating from aggregation | ✅ | 2026-02-14 |
| TASK-068 | `GET /api/recipes/{id}` - requireAuth, return full recipe with nested: ingredients (ORDER BY sort_order), instructions (ORDER BY step_number), images (ORDER BY display_order), author info, stats (likes, views, avg_rating), user-specific flags (isLiked, isFavorited) | ✅ | 2026-02-14 |
| TASK-069 | `POST /api/recipes` - requireAuth, validate fields, INSERT recipe with status='pending', INSERT ingredients array, INSERT instructions array with step_numbers, return created recipe with ID | ✅ | 2026-02-14 |
| TASK-070 | `PUT /api/recipes/{id}` - requireAuth, verify ownership (author_id = current user OR admin), UPDATE recipe fields, replace ingredients (DELETE old + INSERT new), replace instructions, return updated recipe | ✅ | 2026-02-14 |
| TASK-071 | `DELETE /api/recipes/{id}` - requireAuth, verify ownership or admin role, DELETE recipe (CASCADE handles related data), return success | ✅ | 2026-02-14 |
| TASK-072 | `PUT /api/recipes/{id}/status` - requireAuth + requireAdmin, validate status ('published'/'rejected'), UPDATE recipe.status, INSERT activity_log entry, return updated recipe | ✅ | 2026-02-14 |
| TASK-073 | `POST /api/recipes/{id}/like` - requireAuth, toggle: check if like_record exists for user+recipe → DELETE if yes, INSERT if no. Return { liked: bool, likeCount: int } | ✅ | 2026-02-14 |
| TASK-074 | `POST /api/recipes/{id}/favorite` - requireAuth, toggle: check if favorite exists for user+recipe → DELETE if yes, INSERT if no. Return { favorited: bool } | ✅ | 2026-02-14 |
| TASK-075 | `POST /api/recipes/{id}/view` - requireAuth, INSERT into recipe_view (user_id, recipe_id) only when current user role = 'user'. Skip tracking for admin role and return success. Triggers handle daily_stat update. | ✅ | 2026-02-14 |

**Review API Endpoints (`api/reviews.php`):**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-076 | `GET /api/reviews?recipe_id={id}` - requireAuth, return all reviews for recipe, JOIN with user for reviewer info (username, avatar_url), ORDER BY created_at DESC | ✅ | 2026-02-14 |
| TASK-077 | `POST /api/reviews` - requireAuth, validate rating (1-5) and recipe_id, enforce unique constraint (one review per user per recipe), INSERT review, return created review with user info | ✅ | 2026-02-14 |
| TASK-078 | `PUT /api/reviews/{id}` - requireAuth, verify ownership (review.user_id = current user), UPDATE rating and/or comment, return updated review | ✅ | 2026-02-14 |
| TASK-079 | `DELETE /api/reviews/{id}` - requireAuth, verify ownership or admin role, DELETE review, return success | ✅ | 2026-02-14 |

**User API Endpoints (`api/users.php`):**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-080 | `GET /api/users` - requireAuth + requireAdmin, return all users with pagination (?page=, ?limit=), exclude password_hash from response, include user counts by status | ✅ | 2026-02-14 |
| TASK-081 | `GET /api/users/{id}` - requireAuth, return user profile (exclude password_hash), include recipe count, review count, favorite count from aggregation | ✅ | 2026-02-14 |
| TASK-082 | `PUT /api/users/{id}` - requireAuth, verify ownership or admin, UPDATE allowed fields (first_name, last_name, bio, location, cooking_level, avatar_url, birthday), return updated user | ✅ | 2026-02-14 |
| TASK-083 | `DELETE /api/users/{id}` - requireAuth + requireAdmin, DELETE user (CASCADE handles recipes/reviews), INSERT activity_log entry, return success | ✅ | 2026-02-14 |
| TASK-084 | `PUT /api/users/{id}/status` - requireAuth + requireAdmin, validate status ENUM, UPDATE user.status, INSERT activity_log entry, return updated user | ✅ | 2026-02-14 |

**Search API Endpoints (`api/search.php`):**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-085 | `GET /api/search?q={query}` - requireAuth, search published recipes by title and description using LIKE or FULLTEXT, return matching recipes with author info and stats | ✅ | 2026-02-14 |
| TASK-086 | `POST /api/search/history` - requireAuth, INSERT search query into search_history table with user_id and current timestamp | ✅ | 2026-02-14 |
| TASK-087 | `GET /api/search/history` - requireAuth, return current user's search history ordered by searched_at DESC, limit 20 | ✅ | 2026-02-14 |
| TASK-088 | `DELETE /api/search/history` - requireAuth, DELETE all search_history rows for current user | ✅ | 2026-02-14 |

**Stats & Activity API Endpoints (`api/stats.php`, `api/activity.php`):**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-089 | `GET /api/stats/dashboard` - requireAuth + requireAdmin, return aggregated dashboard: total users (by status), total recipes (by status), total reviews, total views, recent daily_stat rows (last 30 days) | ✅ | 2026-02-14 |
| TASK-090 | `GET /api/stats/daily` - requireAuth, return daily_stat rows for charting (last 30 days default, configurable via ?days= param) | ✅ | 2026-02-14 |
| TASK-091 | `GET /api/activity` - requireAuth + requireAdmin, return activity_log rows with admin username, ordered by created_at DESC, with pagination | ✅ | 2026-02-14 |

**API Testing:**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-092 | Test all API endpoints with Postman/curl, document request/response formats for each endpoint | ⏳ | |

### Phase 5: Frontend Integration

**GOAL-005**: Replace localStorage with API calls using native `fetch()` while maintaining all existing functionality

**API Service Layer (`src/lib/api.js`):**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-093 | Create `src/lib/api.js` - Base fetch wrapper: configure API_BASE_URL (default `http://localhost/recipe-sharing-system/backend`), create `apiFetch(endpoint, options)` function with `credentials: 'include'`, default headers `Content-Type: application/json`, automatic JSON parsing, error handling (throw on non-ok response with parsed error message) | ✅ | 2026-02-14 |
| TASK-094 | `api.js` - Implement auth methods: `api.auth.register(data)`, `api.auth.login(email, password)`, `api.auth.logout()`, `api.auth.getCurrentUser()` | ✅ | 2026-02-14 |
| TASK-095 | `api.js` - Implement recipe CRUD methods: `api.recipes.getAll(filters)`, `api.recipes.getById(id)`, `api.recipes.create(data)`, `api.recipes.update(id, data)`, `api.recipes.delete(id)` | ✅ | 2026-02-14 |
| TASK-096 | `api.js` - Implement recipe action methods: `api.recipes.updateStatus(id, status)`, `api.recipes.like(id)`, `api.recipes.favorite(id)`, `api.recipes.recordView(id)` | ✅ | 2026-02-14 |
| TASK-097 | `api.js` - Implement review methods: `api.reviews.getByRecipe(recipeId)`, `api.reviews.create(recipeId, data)`, `api.reviews.update(id, data)`, `api.reviews.delete(id)` | ✅ | 2026-02-14 |
| TASK-098 | `api.js` - Implement user methods: `api.users.getAll(params)`, `api.users.getById(id)`, `api.users.update(id, data)`, `api.users.delete(id)`, `api.users.updateStatus(id, status)` | ✅ | 2026-02-14 |
| TASK-099 | `api.js` - Implement search methods: `api.search.search(query, filters)`, `api.search.saveHistory(query)`, `api.search.getHistory()`, `api.search.clearHistory()` | ✅ | 2026-02-14 |
| TASK-100 | `api.js` - Implement stats/activity methods: `api.stats.getDashboard()`, `api.stats.getDaily(days)`, `api.activity.getRecent(params)` | ✅ | 2026-02-14 |

**Auth Integration:**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-101 | Update `src/context/AuthContext.jsx` - Replace `storage.login()`/`storage.logout()` with `api.auth.login()`/`api.auth.logout()`, on mount call `api.auth.getCurrentUser()` to restore session from cookie, remove localStorage user references | ✅ | 2026-02-14 |
| TASK-102 | Update `src/pages/Auth/Login.jsx` - Replace storage call with `api.auth.login()`, add loading state during API call, add error display for failed login, handle network errors | ✅ | 2026-02-14 |
| TASK-103 | Update `src/pages/Auth/Signup.jsx` - Replace storage call with `api.auth.register()`, add loading state, add error display for validation failures, handle duplicate email error | ✅ | 2026-02-14 |

**Recipe Pages:**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-104 | Update `src/pages/Recipe/Home.jsx` - Replace `storage.getRecipes()` with `api.recipes.getAll()`, add loading spinner while fetching, add error state for failed fetch | ✅ | 2026-02-14 |
| TASK-105 | Update `src/pages/Recipe/RecipeDetail.jsx` - Replace all storage calls with API: `api.recipes.getById()`, `api.recipes.like()`, `api.recipes.favorite()`, `api.recipes.recordView()`, `api.reviews.getByRecipe()`, `api.reviews.create()`. Remove guest view tracking code. Require authentication for viewing | ✅ | 2026-02-14 |
| TASK-106 | Update `src/pages/Recipe/CreateRecipe.jsx` - Replace `storage.saveRecipe()` with `api.recipes.create()`, add loading state during submission, handle validation errors from API | ✅ | 2026-02-14 |
| TASK-107 | Update `src/pages/Recipe/Search.jsx` - Replace `storage.search*` methods with `api.search.search()`, `api.search.saveHistory()`, `api.search.getHistory()`, `api.search.clearHistory()`. Remove `storage.getOrCreateGuestId()` calls | ✅ | 2026-02-14 |
| TASK-108 | Update `src/pages/Recipe/Profile.jsx` - Replace `storage.saveUser()` with `api.users.update()`, replace `storage.deleteRecipe()` with `api.recipes.delete()`, replace `storage.getUsers()` with `api.users.getById()` | ✅ | 2026-02-14 |

**Admin Pages:**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-109 | Update `src/pages/Admin/UserList.jsx` - Replace `storage.getUsers()` with `api.users.getAll()`, replace `storage.saveUser()` with `api.users.update()`/`api.users.updateStatus()`, replace `storage.deleteUser()` with `api.users.delete()`. Remove `storage.addActivity()` calls (auto-logged via backend) | ✅ | 2026-02-14 |
| TASK-110 | Update `src/pages/Admin/AdminStats.jsx` - Replace all `storage.get*` methods with `api.stats.getDashboard()`, replace `storage.getRecentActivity()` with `api.activity.getRecent()` | ✅ | 2026-02-14 |
| TASK-111 | Update `src/pages/Admin/AdminRecipes.jsx` - Replace `storage.getRecipes()` with `api.recipes.getAll()`, replace `storage.saveRecipe()` status changes with `api.recipes.updateStatus()`, replace `storage.deleteRecipe()` with `api.recipes.delete()`. Remove `storage.addActivity()` calls | ✅ | 2026-02-14 |

**UI Components & Cleanup:**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-112 | Create `src/components/ui/LoadingSpinner.jsx` - Reusable loading component with Tailwind styling, support sizes (sm/md/lg) | ✅ | 2026-02-14 |
| TASK-113 | Create `src/components/ui/ErrorMessage.jsx` - Reusable error display component with retry button, Tailwind styling | ✅ | 2026-02-14 |
| TASK-114 | Remove `src/lib/storage.js` entirely — all localStorage calls replaced by API. Remove all guest-related code (`getOrCreateGuestId`, `cookhub_guest_id` references) | ⏳ | |
| TASK-115 | Add React error boundary component to catch unhandled API errors gracefully | ⏳ | |

### Phase 6: Testing & Deployment

**GOAL-006**: Comprehensive testing and deployment documentation

**Database Setup:**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-116 | Create `database/README.md` - Database setup instructions for XAMPP (start MySQL, open phpMyAdmin, import scripts) | | |
| TASK-117 | Create `database/run_all_scripts.sql` - Master script that sources all 14 SQL files in dependency order | | |
| TASK-118 | Test database installation: Run all SQL scripts on fresh MySQL instance, verify 13 tables, 2 views, 5 procedures, 6 triggers created | | |

**API & Integration Testing:**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-119 | Create Postman collection for all endpoints with sample requests and expected responses | | |
| TASK-120 | Test user registration flow: Register → verify DB row → login → verify session row → logout → verify session deleted | | |
| TASK-121 | Test recipe creation flow: Login → create recipe (pending) → verify recipe + ingredients + instructions in DB | | |
| TASK-122 | Test admin approval flow: Create recipe (pending) → admin approves → verify status = 'published', activity_log entry | | |
| TASK-123 | Test review system: Add review → verify unique constraint → update review → delete review → verify CASCADE | | |
| TASK-124 | Test likes/favorites: Toggle like → verify like_record row → toggle again → verify removed. Same for favorites | | |
| TASK-125 | Test search functionality: Search by keyword → verify LIKE/FULLTEXT results → save history → retrieve history | | |
| TASK-126 | Test admin dashboard: Verify all stats calculations match actual data aggregations | | |
| TASK-127 | Test authorization: Verify user cannot access admin endpoints (403), unauthenticated gets 401 | | |
| TASK-128 | Test concurrent users: Simulate 10+ concurrent requests to verify no race conditions | | |
| TASK-129 | Test data integrity: Attempt SQL injection via form inputs, verify prepared statements prevent it | | |
| TASK-130 | Test cascading deletes: Delete recipe → verify reviews, likes, favorites, views, ingredients, instructions, images all deleted | | |
| TASK-131 | Load test: Insert 1000 recipes and measure query performance against CON-005 (< 200ms) | | |

**Documentation:**

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-132 | Create `docs/API_DOCUMENTATION.md` - Complete API reference with request/response examples for all endpoints | | |
| TASK-133 | Create `docs/DATABASE_SCHEMA.md` - ER diagrams and table structure documentation with relationships | | |
| TASK-134 | Create `docs/DEPLOYMENT_GUIDE.md` - Step-by-step XAMPP deployment: folder placement, Apache config, phpMyAdmin import, Vite proxy | | |
| TASK-135 | Create `docs/TESTING_GUIDE.md` - Testing procedures, test cases, Postman collection usage | | |
| TASK-136 | Create `CHANGELOG.md` - Document all changes from localStorage version to database-backed version | | |
| TASK-137 | Update main `README.md` - Add database setup section, architecture diagram, API documentation reference | | |
| TASK-138 | Record video demo: Show registration → recipe creation → admin approval → search → profile management | | |

## 3. Alternatives

**ALT-001**: **Node.js + Express Backend Instead of PHP**
- *Why considered:* JavaScript full-stack, easier for React developers, modern ecosystem
- *Why not chosen:* Course uses PHPWebApp.pdf suggesting PHP requirement, XAMPP is PHP-focused

**ALT-002**: **MongoDB NoSQL Database Instead of MySQL**
- *Why considered:* Flexible schema, easier to map from localStorage JSON structure
- *Why not chosen:* Course focuses on relational database design, SQL scripting requirements

**ALT-003**: **Keep LocalStorage + Add Backend Sync**
- *Why considered:* Gradual migration, offline-first capability
- *Why not chosen:* Doesn't demonstrate full database integration, adds complexity

**ALT-004**: **Firebase/Supabase Backend-as-a-Service**
- *Why considered:* Quick setup, built-in auth, real-time features
- *Why not chosen:* Course requires custom SQL scripting and database design understanding

**ALT-005**: **PostgreSQL Instead of MySQL**
- *Why considered:* More advanced features, better standards compliance
- *Why not chosen:* XAMPP default is MySQL/MariaDB, wider PHP documentation

**ALT-006**: **GraphQL API Instead of REST**
- *Why considered:* More flexible queries, single endpoint, matches React patterns
- *Why not chosen:* REST is more standard for course learning, simpler to implement

**ALT-007**: **Axios HTTP Client Instead of Native Fetch**
- *Why considered:* Convenient interceptors, automatic JSON, request cancellation
- *Why not chosen:* Native `fetch()` has no additional dependency, sufficient for this project, simpler setup with `credentials: 'include'`

**ALT-008**: **PHP MVC Framework (Laravel/Slim) Instead of Plain PHP**
- *Why considered:* Built-in routing, ORM, middleware, testing tools
- *Why not chosen:* Requires Composer, adds complexity, course focuses on understanding raw PHP/SQL concepts

## 4. Dependencies

**DEP-001**: **XAMPP** (v8.0+)
- Components needed: Apache web server, MySQL/MariaDB, PHP 8.0+, phpMyAdmin
- Required for local development and testing
- Download: https://www.apachefriends.org/

**DEP-002**: **PHP 8.0 or higher**
- Required for modern PHP features (typed properties, named arguments, `str_contains()`)
- Included with XAMPP

**DEP-003**: **MySQL 8.0+ or MariaDB 10.4+**
- Required for database features (CHECK constraints, triggers, stored procedures)
- Included with XAMPP

**DEP-004**: **Node.js 16+ and npm**
- Already installed for existing React project
- Required for frontend build process (Vite)

**DEP-005**: **PHP PDO MySQL Extension**
- Required for database connectivity via PDO
- Usually enabled by default in XAMPP

**DEP-006**: **Apache mod_rewrite**
- Required for clean API URLs via `.htaccess`
- Enable in httpd.conf: `LoadModule rewrite_module modules/mod_rewrite.so`

**DEP-007**: **PHP OpenSSL Extension**
- Required for `random_bytes()` (session token generation) and `password_hash()`
- Usually enabled by default in XAMPP

**DEP-008**: **Postman or similar API testing tool** (optional)
- Recommended for API endpoint testing during development
- Alternative: curl command-line tool, browser DevTools

**DEP-009**: **Git** (optional)
- For version control during development

## 5. Files

### Database SQL Scripts (14 files — all exist ✅)

| File ID | Path | Task(s) | Lines (est.) | Status |
|---------|------|---------|-------------|--------|
| FILE-001 | `database/01_create_database.sql` | TASK-004 | ~20 | ✅ EXISTS |
| FILE-002 | `database/02_create_tables.sql` | TASK-005 to TASK-018 | ~400 | ✅ EXISTS |
| FILE-003 | `database/03_create_indexes.sql` | TASK-019 | ~50 | ✅ EXISTS |
| FILE-004 | `database/04_create_views.sql` | TASK-020, TASK-021 | ~100 | ✅ EXISTS |
| FILE-005 | `database/05_seed_users.sql` | TASK-022, TASK-023 | ~150 | ✅ EXISTS |
| FILE-006 | `database/06_seed_recipes.sql` | TASK-024 to TASK-027 | ~600 | ✅ EXISTS |
| FILE-007 | `database/07_seed_reviews.sql` | TASK-028, TASK-029 | ~200 | ✅ EXISTS |
| FILE-008 | `database/08_seed_stats.sql` | TASK-030, TASK-031 | ~100 | ✅ EXISTS |
| FILE-009 | `database/09_common_queries.sql` | TASK-032 to TASK-036 | ~200 | ✅ EXISTS |
| FILE-010 | `database/10_admin_queries.sql` | TASK-037 to TASK-039 | ~100 | ✅ EXISTS |
| FILE-011 | `database/11_analytics_queries.sql` | TASK-040 to TASK-043 | ~150 | ✅ EXISTS |
| FILE-012 | `database/12_stored_procedures.sql` | TASK-044 to TASK-048 | ~300 | ✅ EXISTS |
| FILE-013 | `database/13_triggers.sql` | TASK-049 to TASK-054 | ~200 | ✅ EXISTS |
| FILE-014 | `database/14_backup_restore.sql` | TASK-055, TASK-056 | ~50 | ✅ EXISTS |
| FILE-015 | `database/run_all_scripts.sql` | TASK-117 | ~50 | TO CREATE |
| FILE-016 | `database/README.md` | TASK-116 | ~100 | TO CREATE |

### PHP Backend Files (12 files — all created ✅)

| File ID | Path | Task(s) | Lines (est.) | Status |
|---------|------|---------|-------------|--------|
| FILE-017 | `backend/config/database.php` | TASK-058 | ~60 | ✅ CREATED |
| FILE-018 | `backend/.htaccess` | TASK-059 | ~20 | ✅ CREATED |
| FILE-019 | `backend/helpers/cors.php` | TASK-060 | ~25 | ✅ CREATED |
| FILE-020 | `backend/helpers/auth.php` | TASK-061 | ~60 | ✅ CREATED |
| FILE-021 | `backend/helpers/response.php` | TASK-062 | ~40 | ✅ CREATED |
| FILE-022 | `backend/api/auth.php` | TASK-063 to TASK-066 | ~200 | ✅ CREATED |
| FILE-023 | `backend/api/recipes.php` | TASK-067 to TASK-075 | ~400 | ✅ CREATED |
| FILE-024 | `backend/api/reviews.php` | TASK-076 to TASK-079 | ~150 | ✅ CREATED |
| FILE-025 | `backend/api/users.php` | TASK-080 to TASK-084 | ~200 | ✅ CREATED |
| FILE-026 | `backend/api/search.php` | TASK-085 to TASK-088 | ~120 | ✅ CREATED |
| FILE-027 | `backend/api/stats.php` | TASK-089, TASK-090 | ~100 | ✅ CREATED |
| FILE-028 | `backend/api/activity.php` | TASK-091 | ~60 | ✅ CREATED |

### Frontend Files — New (4 files)

| File ID | Path | Task(s) | Lines (est.) | Status |
|---------|------|---------|-------------|--------|
| FILE-029 | `src/lib/api.js` | TASK-093 to TASK-100 | ~220 | ✅ CREATED |
| FILE-030 | `src/components/ui/LoadingSpinner.jsx` | TASK-112 | ~30 | ✅ CREATED |
| FILE-031 | `src/components/ui/ErrorMessage.jsx` | TASK-113 | ~35 | ✅ CREATED |
| FILE-032 | `src/components/ui/ErrorBoundary.jsx` | TASK-115 | ~40 | ⏳ PENDING |

### Frontend Files — Modified (11 files)

| File ID | Path | Task(s) | Status |
|---------|------|---------|--------|
| FILE-033 | `src/context/AuthContext.jsx` | TASK-101 | ✅ MODIFIED |
| FILE-034 | `src/pages/Auth/Login.jsx` | TASK-102 | ✅ MODIFIED |
| FILE-035 | `src/pages/Auth/Signup.jsx` | TASK-103 | ✅ MODIFIED |
| FILE-036 | `src/pages/Recipe/Home.jsx` | TASK-104 | ✅ MODIFIED |
| FILE-037 | `src/pages/Recipe/RecipeDetail.jsx` | TASK-105 | ✅ MODIFIED |
| FILE-038 | `src/pages/Recipe/CreateRecipe.jsx` | TASK-106 | ✅ MODIFIED |
| FILE-039 | `src/pages/Recipe/Search.jsx` | TASK-107 | ✅ MODIFIED |
| FILE-040 | `src/pages/Recipe/Profile.jsx` | TASK-108 | ✅ MODIFIED |
| FILE-041 | `src/pages/Admin/UserList.jsx` | TASK-109 | ✅ MODIFIED |
| FILE-042 | `src/pages/Admin/AdminStats.jsx` | TASK-110 | ✅ MODIFIED |
| FILE-043 | `src/pages/Admin/AdminRecipes.jsx` | TASK-111 | ✅ MODIFIED |

### Frontend Files — Deleted (1 file)

| File ID | Path | Task(s) | Status |
|---------|------|---------|--------|
| FILE-044 | `src/lib/storage.js` | TASK-114 | ⏳ DEAD CODE (0 imports, pending deletion) |

### Documentation Files (7 files — to be created)

| File ID | Path | Task(s) | Lines (est.) | Status |
|---------|------|---------|-------------|--------|
| FILE-045 | `docs/API_DOCUMENTATION.md` | TASK-132 | ~500 | TO CREATE |
| FILE-046 | `docs/DATABASE_SCHEMA.md` | TASK-133 | ~300 | TO CREATE |
| FILE-047 | `docs/DEPLOYMENT_GUIDE.md` | TASK-134 | ~200 | TO CREATE |
| FILE-048 | `docs/TESTING_GUIDE.md` | TASK-135 | ~200 | TO CREATE |
| FILE-049 | `CHANGELOG.md` | TASK-136 | ~100 | TO CREATE |
| FILE-050 | `README.md` | TASK-137 | ~800 | TO MODIFY |
| FILE-051 | `postman/recipe_api_collection.json` | TASK-119 | ~500 | TO CREATE |

### Configuration Files — Modified

| File ID | Path | Task(s) | Status |
|---------|------|---------|--------|
| FILE-052 | `vite.config.js` | Phase 5 | ✅ MODIFIED (proxy `/api` → `http://localhost`) |

**File Summary:** 52 tracked files total (14 existing SQL + 2 new DB files + 12 new PHP + 4 new frontend + 11 modified frontend + 1 dead code + 1 config modified + 7 docs pending)

## 6. Testing

### Authentication & Authorization Tests

| Test | Description | Validates |
|------|-------------|-----------|
| TEST-001 | User Registration - Verify new user created with hashed password, status=pending, role=user | SEC-001, REQ-API-008 |
| TEST-002 | User Login - Verify credentials validated, session row created, HttpOnly cookie set, user data returned | REQ-API-007, SEC-006 |
| TEST-003 | Invalid Login - Verify proper error message for wrong password/non-existent email (no info leak) | SEC-002, REQ-API-005 |
| TEST-004 | Logout - Verify session row deleted, cookie cleared | REQ-API-007 |
| TEST-005 | Protected Route Access - Verify unauthenticated request returns 401 | SEC-002, REQ-API-005 |
| TEST-006 | Admin Authorization - Verify non-admin user cannot access admin endpoints (403) | SEC-003, REQ-API-005 |
| TEST-007 | Session Expiration - Verify expired session returns 401 and requires re-login | REQ-API-007 |

### Recipe Management Tests

| Test | Description | Validates |
|------|-------------|-----------|
| TEST-008 | Create Recipe - Verify recipe created with ingredients, instructions, status=pending | REQ-API-001, REQ-API-008 |
| TEST-009 | Get Published Recipes - Verify only published recipes returned to non-admin users | REQ-FE-001 |
| TEST-010 | Get Recipe Details - Verify full recipe data with nested ingredients/instructions/images/stats | REQ-API-004 |
| TEST-011 | Update Recipe - Verify owner can update, non-owner gets 403 | SEC-003 |
| TEST-012 | Delete Recipe - Verify owner/admin can delete, CASCADE removes related data | REQ-DB-005 |
| TEST-013 | Recipe Search - Verify LIKE/FULLTEXT search returns relevant results | REQ-SQL-003 |
| TEST-014 | Recipe Filters - Verify category, difficulty, sort filters work correctly | REQ-API-001 |
| TEST-015 | Recipe Pagination - Verify page/limit parameters work correctly | REQ-API-004 |

### Admin Functions Tests

| Test | Description | Validates |
|------|-------------|-----------|
| TEST-016 | Approve Recipe - Verify admin can approve pending recipe, status='published', activity logged | SEC-003, REQ-SQL-006 |
| TEST-017 | Reject Recipe - Verify admin can reject recipe, status='rejected', activity logged | SEC-003 |
| TEST-018 | User Status Update - Verify admin can change user status (active/inactive/suspended) | SEC-003 |
| TEST-019 | Delete User - Verify admin can delete user, CASCADE to recipes/reviews | REQ-DB-005 |
| TEST-020 | Admin Dashboard Stats - Verify correct aggregation of user counts, recipe counts, views | REQ-SQL-003 |

### Review System Tests

| Test | Description | Validates |
|------|-------------|-----------|
| TEST-021 | Add Review - Verify review created with rating (1-5), associated with user and recipe | REQ-DB-007 |
| TEST-022 | Duplicate Review Prevention - Verify unique constraint prevents double review | REQ-DB-004 |
| TEST-023 | Update Review - Verify user can update own review, cannot update others (403) | SEC-003 |
| TEST-024 | Delete Review - Verify user can delete own review, admin can delete any | SEC-003 |
| TEST-025 | Recipe Rating Calculation - Verify average rating calculated correctly via fn_CalculateAvgRating | REQ-SQL-005 |

### Engagement Features Tests

| Test | Description | Validates |
|------|-------------|-----------|
| TEST-026 | Toggle Like - Verify like added if not exists, removed if exists (idempotent toggle) | REQ-DB-003 |
| TEST-027 | Toggle Favorite - Verify favorite added/removed correctly | REQ-DB-003 |
| TEST-028 | Recipe View Tracking - Verify view recorded only for authenticated non-admin users with user_id FK | REQ-MIG-003 |
| TEST-029 | Multiple Views Tracking - Verify same user viewing same recipe creates multiple view records | REQ-DB-010 |
| TEST-030 | Daily Stats Update - Verify trg_RecipeView_UpdateStat trigger increments daily_stat | REQ-SQL-006 |

### Search & History Tests

| Test | Description | Validates |
|------|-------------|-----------|
| TEST-031 | Full-Text Search - Verify search across recipe title and description returns relevant results | REQ-SQL-003 |
| TEST-032 | Search History Save - Verify user search queries saved with timestamp | REQ-DB-010 |
| TEST-033 | Search History Retrieve - Verify user can retrieve their search history, not others' | SEC-002 |

### Data Integrity Tests

| Test | Description | Validates |
|------|-------------|-----------|
| TEST-034 | SQL Injection Prevention - Verify prepared statements prevent SQL injection via form inputs | SEC-004 |
| TEST-035 | XSS Prevention - Verify user input sanitized (htmlspecialchars) to prevent XSS | SEC-005 |
| TEST-036 | Foreign Key Constraints - Verify CASCADE deletes work correctly across all tables | REQ-DB-005 |
| TEST-037 | Unique Constraints - Verify email uniqueness, duplicate review prevention | REQ-DB-004 |
| TEST-038 | Data Type Validation - Verify invalid data types rejected (string for rating, etc.) | REQ-API-008 |

### Performance Tests

| Test | Description | Validates |
|------|-------------|-----------|
| TEST-039 | Query Performance - Verify indexed queries execute under 50ms for typical datasets | REQ-DB-006, CON-005 |
| TEST-040 | Large Dataset - Verify application performs with 1000+ recipes, 10000+ reviews | CON-004 |
| TEST-041 | Concurrent Users - Verify 100 concurrent requests handled without errors | CON-006 |
| TEST-042 | API Response Time - Verify average API response time under 200ms | CON-005 |

### Integration Tests

| Test | Description | Validates |
|------|-------------|-----------|
| TEST-043 | End-to-End Registration Flow - Browser → fetch API → PHP → MySQL → JSON → React UI update | REQ-FE-001 to REQ-FE-006 |
| TEST-044 | End-to-End Recipe Creation Flow - Form → API → DB → Admin approval → Published → Visible on Home | REQ-FE-001, REQ-API-001 |
| TEST-045 | End-to-End Search Flow - User types search → fetch → PHP → MySQL LIKE → Results displayed | REQ-FE-002, REQ-SQL-003 |

## 7. Risks & Assumptions

### Risks

| Risk | Description | Impact | Mitigation |
|------|-------------|--------|------------|
| RISK-001 | **PHP Version Compatibility** - Different XAMPP versions may have different PHP versions | Medium | Target PHP 8.0+ features, document minimum version, test on multiple versions |
| RISK-002 | **CORS Issues** - React on port 5173 calling PHP on port 80/8080 may face CORS blocking | High | Implement CORS headers in helpers/cors.php early, test cross-origin requests on day 1 |
| RISK-003 | **Session Cookie Issues** - `credentials: 'include'` + CORS cookie handling can be tricky | High | Set `Access-Control-Allow-Credentials: true`, use `SameSite=Lax`, test cookie flow early |
| RISK-004 | **SQL Performance Degradation** - Unoptimized queries may slow with large datasets | Medium | Indexes on FK columns (already created), use EXPLAIN to analyze, monitor query times |
| RISK-005 | **Security Vulnerabilities** - Inexperienced backend may introduce flaws | High | Use prepared statements exclusively, validate all input, sanitize output, follow SEC-001 to SEC-007 |
| RISK-006 | **API Breaking Changes** - Changing data structure may break React components | Medium | Keep API response format similar to localStorage structure, gradual migration per component |
| RISK-007 | **Time Estimation** - Project may take longer than expected (138 tasks) | Medium | Prioritize core features (auth, recipes, reviews), Phase 3 already complete as bonus |

### Assumptions

| ID | Assumption |
|----|------------|
| ASSUMPTION-001 | Student has XAMPP installed or can install it successfully |
| ASSUMPTION-002 | Student has basic knowledge of SQL (SELECT, INSERT, UPDATE, DELETE) |
| ASSUMPTION-003 | Student has access to course materials (PHPWebApp.pdf) for PHP reference |
| ASSUMPTION-004 | Development on Windows with XAMPP (alternative: LAMP on Linux, MAMP on macOS) |
| ASSUMPTION-005 | MySQL 8.0+ or MariaDB 10.4+ features available in target XAMPP environment (CTEs, CHECK constraints behavior) |
| ASSUMPTION-006 | Frontend React code structure is familiar (existing project) |
| ASSUMPTION-007 | Application tested locally before any production deployment |
| ASSUMPTION-008 | Database handles typical usage (100 users, 1000 recipes, 5000 reviews) |
| ASSUMPTION-009 | No Composer or external PHP packages needed (plain PHP only) |
| ASSUMPTION-010 | Instructor accepts PHP backend as fulfillment of course requirements |

## 8. API Endpoint Reference

Quick reference of all RESTful endpoints:

| Method | Endpoint | Auth | Admin | Description | Task |
|--------|----------|------|-------|-------------|------|
| POST | `/api/auth/register` | No | No | Register new user | TASK-063 |
| POST | `/api/auth/login` | No | No | Login, create session | TASK-064 |
| POST | `/api/auth/logout` | Yes | No | Logout, destroy session | TASK-065 |
| GET | `/api/auth/me` | Yes | No | Get current user | TASK-066 |
| GET | `/api/recipes` | Yes | No | List published recipes (filters) | TASK-067 |
| GET | `/api/recipes/{id}` | Yes | No | Get recipe details | TASK-068 |
| POST | `/api/recipes` | Yes | No | Create recipe (pending) | TASK-069 |
| PUT | `/api/recipes/{id}` | Yes | No | Update recipe (owner) | TASK-070 |
| DELETE | `/api/recipes/{id}` | Yes | No | Delete recipe (owner/admin) | TASK-071 |
| PUT | `/api/recipes/{id}/status` | Yes | Yes | Approve/reject recipe | TASK-072 |
| POST | `/api/recipes/{id}/like` | Yes | No | Toggle like | TASK-073 |
| POST | `/api/recipes/{id}/favorite` | Yes | No | Toggle favorite | TASK-074 |
| POST | `/api/recipes/{id}/view` | Yes | No | Record view | TASK-075 |
| GET | `/api/reviews?recipe_id={id}` | Yes | No | Get recipe reviews | TASK-076 |
| POST | `/api/reviews` | Yes | No | Create review | TASK-077 |
| PUT | `/api/reviews/{id}` | Yes | No | Update review (owner) | TASK-078 |
| DELETE | `/api/reviews/{id}` | Yes | No | Delete review (owner/admin) | TASK-079 |
| GET | `/api/users` | Yes | Yes | List all users (paginated) | TASK-080 |
| GET | `/api/users/{id}` | Yes | No | Get user profile | TASK-081 |
| PUT | `/api/users/{id}` | Yes | No | Update user (owner/admin) | TASK-082 |
| DELETE | `/api/users/{id}` | Yes | Yes | Delete user | TASK-083 |
| PUT | `/api/users/{id}/status` | Yes | Yes | Update user status | TASK-084 |
| GET | `/api/search?q={query}` | Yes | No | Search recipes | TASK-085 |
| POST | `/api/search/history` | Yes | No | Save search query | TASK-086 |
| GET | `/api/search/history` | Yes | No | Get search history | TASK-087 |
| DELETE | `/api/search/history` | Yes | No | Clear search history | TASK-088 |
| GET | `/api/stats/dashboard` | Yes | Yes | Dashboard statistics | TASK-089 |
| GET | `/api/stats/daily` | Yes | No | Daily stats for charts | TASK-090 |
| GET | `/api/activity` | Yes | Yes | Activity logs | TASK-091 |

**Total: 29 endpoints across 7 API files**

## 9. Database Reference

### Tables (13)

| Table | PK | Key FKs | Description |
|-------|----|---------|-------------|
| `user` | id | — | User accounts (admin=1, olivia=2, ..., omar=12) |
| `session` | id | user_id → user | Server-side session tokens |
| `recipe` | id | author_id → user | Recipe metadata, publication status |
| `ingredient` | id | recipe_id → recipe | Recipe ingredients with quantity/unit |
| `instruction` | id | recipe_id → recipe | Step-by-step cooking instructions |
| `recipe_image` | id | recipe_id → recipe | Multiple images per recipe |
| `review` | id | user_id → user, recipe_id → recipe | Star ratings + comments (1 per user per recipe) |
| `favorite` | id | user_id → user, recipe_id → recipe | Saved/bookmarked recipes |
| `like_record` | id | user_id → user, recipe_id → recipe | Recipe likes |
| `recipe_view` | id | recipe_id → recipe, user_id → user | View tracking (authenticated only) |
| `search_history` | id | user_id → user | Search query history |
| `daily_stat` | id | — | Pre-aggregated daily statistics |
| `activity_log` | id | admin_id → user (SET NULL) | Admin action audit trail |

### Views (2)

| View | Description |
|------|-------------|
| `vw_recipe_with_stat` | Recipe + like_count + view_count + avg_rating + author info |
| `vw_user_dashboard_stat` | User's recipe count + favorite count + review count |

### Stored Procedures & Functions (5+1)

| Name | Type | Description |
|------|------|-------------|
| `usp_CreateRecipe` | Procedure | Transaction: recipe + ingredients + instructions |
| `usp_DeleteRecipe` | Procedure | Delete recipe + log activity |
| `usp_ApproveRecipe` | Procedure | Set status='published' + log |
| `usp_GetRecipeStat` | Procedure | Aggregated likes/views/avg_rating |
| `fn_CalculateAvgRating` | Function | Returns DECIMAL avg rating for recipe |

### Triggers (6)

| Name | Table | Event | Description |
|------|-------|-------|-------------|
| `trg_RecipeView_UpdateStat` | recipe_view | AFTER INSERT | Increment daily_stat.recipe_view_count |
| `trg_User_UpdateLastActive` | session | BEFORE UPDATE | Update user.last_active |
| `trg_Recipe_DeleteCleanup` | recipe | BEFORE DELETE | Log activity_log entry |
| `trg_User_NewUserStat` | user | AFTER INSERT | Increment daily_stat.new_user_count |
| `trg_Recipe_SetTimestamp` | recipe | BEFORE INSERT | Set timestamps if NULL |
| `trg_User_SetTimestamp` | user | BEFORE INSERT | Set timestamps if NULL |

## 10. Related Specifications / Further Reading

### Course Materials
- **PHPWebApp.pdf** - Course reference material on PHP web application development
- **DB_Xampp_install.pdf** - XAMPP installation and configuration guide
- **CSX3006 Course Syllabus** - Database Systems course requirements and objectives

### Database Design Resources
- [MySQL Documentation](https://dev.mysql.com/doc/) - Official MySQL reference manual
- [Database Normalization Guide](https://www.guru99.com/database-normalization.html) - 1NF, 2NF, 3NF explained
- [ER Diagram Tutorial](https://www.lucidchart.com/pages/er-diagrams) - Entity-Relationship diagram best practices

### PHP & Backend Development
- [PHP Manual](https://www.php.net/manual/en/) - Official PHP documentation
- [PDO Tutorial](https://phpdelusions.net/pdo) - PHP Data Objects best practices
- [RESTful API Design](https://restfulapi.net/) - REST API design principles
- [PHP: The Right Way](https://phptherightway.com/) - PHP best practices guide

### Security
- [OWASP Top 10](https://owasp.org/www-project-top-ten/) - Top 10 web application security risks
- [PHP Security Guide](https://www.php.net/manual/en/security.php) - PHP security considerations
- [SQL Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html) - OWASP guidelines

### React & Frontend
- [Fetch API (MDN)](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) - Native fetch documentation
- [React Error Boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary) - Error handling in React

### Project Resources
- [Existing Project README](../README.md) - Current project documentation
- [Database Implementation Logic](../guides/database_implementation_logic_explanation.md) - SQL scripts explanation
- [SQL Scripts Guide](../guides/SQL_SCRIPTS.md) - Consolidated SQL reference
- [Setup Guide (phpMyAdmin)](../guides/SETUP_GUIDE_PHPMYADMIN.md) - Database setup instructions

---

## Progress Summary

| Phase | Tasks | Completed | Remaining | Status |
|-------|-------|-----------|-----------|--------|
| Phase 1: Database Design | 21 (TASK-001 → TASK-021) | 18 | 3 (ER diagrams) | ✅ SQL Complete |
| Phase 2: SQL Data Scripts | 22 (TASK-022 → TASK-043) | 22 | 0 | ✅ Complete |
| Phase 3: Advanced SQL | 13 (TASK-044 → TASK-056) | 13 | 0 | ✅ Complete |
| Phase 4: PHP Backend | 36 (TASK-057 → TASK-092) | 0 | 36 | ⏳ Not Started |
| Phase 5: Frontend Integration | 23 (TASK-093 → TASK-115) | 0 | 23 | ⏳ Not Started |
| Phase 6: Testing & Docs | 23 (TASK-116 → TASK-138) | 0 | 23 | ⏳ Not Started |
| **Total** | **138** | **53** | **85** | **38% Complete** |

**Priority Levels:**
- **Critical (Must Have):** Phase 1 (TASK-004 to TASK-021), Phase 2, Phase 4 (TASK-057 to TASK-092), Phase 5 (TASK-093 to TASK-115)
- **Important (Should Have):** Phase 6 Testing (TASK-118 to TASK-131), Phase 6 Documentation (TASK-132 to TASK-137)
- **Nice to Have (Optional):** Phase 1 ER Diagrams (TASK-001 to TASK-003), Phase 3 Advanced SQL (already complete)

---

*Document Version History:*
- **v1.0** (2026-02-04): Initial plan with 170 tasks, MVC backend structure, axios dependency
- **v2.0** (2026-02-08): Merged plan — simplified backend (flat PHP, no frameworks), native fetch(), session-based auth only, fixed task numbering (138 tasks), added API reference table, database reference section

