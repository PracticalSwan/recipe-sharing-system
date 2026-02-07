---
goal: Integrate MySQL Database Backend into Recipe Sharing System
version: 1.0
date_created: 2026-02-04
last_updated: 2026-02-07
owner: CSX3006 Database Systems Course Project
status: 'In Progress'
tags: [database, backend, php, mysql, api, migration, architecture]
---

# Introduction

![Status: In Progress](https://img.shields.io/badge/status-In%20Progress-yellow)

This implementation plan outlines the complete migration of the Recipe Sharing System from a localStorage-based frontend-only application to a full-stack web application with MySQL database backend and PHP RESTful API. The plan maintains all existing frontend functionality while demonstrating comprehensive database design, SQL scripting, and backend development skills required for the CSX3006 Database Systems course.

The migration will transform the current React+Vite application into a three-tier architecture (Presentation Layer → Application Layer → Data Layer) while preserving all features including authentication, recipe management, reviews, favorites, search, and admin dashboard functionality.

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
- **REQ-API-001**: Implement RESTful API using PHP (compatible with XAMPP environment)
- **REQ-API-002**: Use PDO (PHP Data Objects) for secure database access
- **REQ-API-003**: Implement prepared statements to prevent SQL injection
- **REQ-API-004**: All endpoints must return JSON responses
- **REQ-API-005**: Implement proper HTTP status codes (200, 201, 400, 401, 403, 404, 500)
- **REQ-API-006**: Support CORS for React frontend communication
- **REQ-API-007**: Implement session-based or JWT authentication
- **REQ-API-008**: Include input validation and sanitization for all endpoints

### Frontend Integration Requirements
- **REQ-FE-001**: Maintain all existing React components without breaking changes
- **REQ-FE-002**: Replace localStorage operations with API calls
- **REQ-FE-003**: Implement loading states for async operations
- **REQ-FE-004**: Add proper error handling for network failures
- **REQ-FE-005**: Maintain existing UI/UX functionality
- **REQ-FE-006**: Support environment configuration for API URL

### Security Requirements
- **SEC-001**: Store passwords using secure hashing (bcrypt or password_hash)
- **SEC-002**: Implement authentication for protected routes
- **SEC-003**: Implement role-based authorization (Admin vs User)
- **SEC-004**: Prevent SQL injection through prepared statements
- **SEC-005**: Validate and sanitize all user inputs
- **SEC-006**: Implement CSRF protection for state-changing operations
- **SEC-007**: Use HTTPS in production environment

### Data Migration Requirements
- **REQ-MIG-001**: Preserve existing seed data structure from storage.js
- **REQ-MIG-002**: Maintain data relationships (users, recipes, reviews, etc.)
- **REQ-MIG-003**: All recipe views must be associated with authenticated users only (no guest tracking)

### Constraints
- **CON-001**: Must work with XAMPP environment (Apache + MySQL + PHP)
- **CON-002**: Frontend build process should remain unchanged (Vite)
- **CON-003**: Must maintain backward compatibility with existing React components
- **CON-004**: Database server should handle concurrent user access
- **CON-005**: API response time should be under 200ms for simple queries
- **CON-006**: Support at minimum 100 concurrent users

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
- **GUD-017**: Stored procedure parameters must use '@' prefix with camelCase (e.g., @recipeId, @authorId)
- **GUD-018**: Provide default values for optional stored procedure parameters
- **GUD-019**: Document stored procedures with header comment blocks including description, parameters, and return values
- **GUD-020**: Temporary tables must use 'tmp_' prefix
- **PAT-001**: Use Repository Pattern for data access in PHP models
- **PAT-002**: Implement DTO (Data Transfer Objects) for API responses
- **PAT-003**: Use Factory Pattern for database connection management
- **PAT-004**: Use Transaction Pattern for multi-step database operations in stored procedures

## 2. Implementation Steps

### Phase 1: Database Design & Schema Creation

**GOAL-001**: Design normalized database schema and create all SQL DDL scripts

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Create conceptual ER diagram showing entities and relationships | | |
| TASK-002 | Create logical ER diagram with attributes and cardinalities | | |
| TASK-003 | Normalize schema to 3NF (identify functional dependencies) | | |
| TASK-004 | Write `01_create_database.sql` - CREATE DATABASE with charset UTF8MB4 | ✅ | 2026-02-07 |
| TASK-005 | Write `02_create_tables.sql` - All CREATE TABLE statements with PKs, FKs, constraints | ✅ | 2026-02-07 |
| TASK-006 | Design `user` table: id (PK INT AUTO_INCREMENT), username (VARCHAR 100), first_name (VARCHAR 50), last_name (VARCHAR 50), email (VARCHAR 100 UNIQUE NOT NULL), password_hash (VARCHAR 255 NOT NULL), birthday (DATE), role (ENUM: 'admin', 'user'), status (ENUM: 'active', 'inactive', 'pending', 'suspended'), joined_date (DATETIME), last_active (DATETIME), avatar_url (TEXT), bio (TEXT), location (VARCHAR 100), cooking_level (VARCHAR 50), created_at (TIMESTAMP DEFAULT CURRENT_TIMESTAMP), updated_at (TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-007 | Design `recipe` table: id (PK INT AUTO_INCREMENT), title (VARCHAR 200 NOT NULL), description (TEXT), category (VARCHAR 50), difficulty (ENUM: 'Easy', 'Medium', 'Hard'), prep_time (INT), cook_time (INT), servings (INT), author_id (INT FK→user.id ON DELETE CASCADE), status (ENUM: 'published', 'pending', 'rejected' DEFAULT 'pending'), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-008 | Design `ingredient` table: id (PK INT AUTO_INCREMENT), recipe_id (INT FK→recipe.id ON DELETE CASCADE), name (VARCHAR 200 NOT NULL), quantity (VARCHAR 50), unit (VARCHAR 50), sort_order (INT DEFAULT 0), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-009 | Design `instruction` table: id (PK INT AUTO_INCREMENT), recipe_id (INT FK→recipe.id ON DELETE CASCADE), step_number (INT NOT NULL), instruction_text (TEXT NOT NULL), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-010 | Design `recipe_image` table: id (PK INT AUTO_INCREMENT), recipe_id (INT FK→recipe.id ON DELETE CASCADE), image_url (TEXT NOT NULL), display_order (INT DEFAULT 0), created_at (TIMESTAMP), updated_at (TIMESTAMP) | ✅ | 2026-02-07 |
| TASK-011 | Design `review` table: id (PK INT AUTO_INCREMENT), user_id (INT FK→user.id ON DELETE CASCADE), recipe_id (INT FK→recipe.id ON DELETE CASCADE), rating (INT CHECK rating BETWEEN 1 AND 5), comment (TEXT), created_at (TIMESTAMP), updated_at (TIMESTAMP), UNIQUE KEY unique_user_recipe (user_id, recipe_id) | ✅ | 2026-02-07 |
| TASK-012 | Design `favorite` table: id (PK INT AUTO_INCREMENT), user_id (INT FK→user.id ON DELETE CASCADE), recipe_id (INT FK→recipe.id ON DELETE CASCADE), created_at (TIMESTAMP), updated_at (TIMESTAMP), UNIQUE KEY unique_user_recipe_favorite (user_id, recipe_id) | ✅ | 2026-02-07 |
| TASK-013 | Design `like_record` table: id (PK INT AUTO_INCREMENT), user_id (INT FK→user.id ON DELETE CASCADE), recipe_id (INT FK→recipe.id ON DELETE CASCADE), created_at (TIMESTAMP), updated_at (TIMESTAMP), UNIQUE KEY unique_user_recipe_like (user_id, recipe_id) | ✅ | 2026-02-07 |
| TASK-014 | Design `recipe_view` table: id (PK INT AUTO_INCREMENT), recipe_id (INT FK→recipe.id ON DELETE CASCADE), user_id (INT NOT NULL FK→user.id ON DELETE CASCADE), viewed_at (TIMESTAMP DEFAULT CURRENT_TIMESTAMP), created_at (TIMESTAMP DEFAULT CURRENT_TIMESTAMP), updated_at (TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP), INDEX idx_recipe_viewed (recipe_id, viewed_at), INDEX idx_user_viewed (user_id, viewed_at) | ✅ | 2026-02-07 |
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
| TASK-021 | Write `05_seed_users.sql` - INSERT statements for 3 admin users (matching current seed data) | ✅ | 2026-02-07 |
| TASK-022 | Write `05_seed_users.sql` - INSERT statements for 7 user accounts (active, inactive, pending, suspended) | ✅ | 2026-02-07 |
| TASK-023 | Write `06_seed_recipes.sql` - INSERT statements for 10+ sample recipes with varying statuses | ✅ | 2026-02-07 |
| TASK-024 | Write `06_seed_recipes.sql` - INSERT corresponding ingredients for each recipe (3-10 per recipe) | ✅ | 2026-02-07 |
| TASK-025 | Write `06_seed_recipes.sql` - INSERT corresponding instructions for each recipe (4-8 steps each) | ✅ | 2026-02-07 |
| TASK-026 | Write `06_seed_recipes.sql` - INSERT recipe images (1-3 images per recipe) | ✅ | 2026-02-07 |
| TASK-027 | Write `07_seed_reviews.sql` - INSERT sample reviews (20+ reviews across recipes) | ✅ | 2026-02-07 |
| TASK-028 | Write `07_seed_reviews.sql` - INSERT likes and favorites data | ✅ | 2026-02-07 |
| TASK-029 | Write `08_seed_stats.sql` - INSERT historical daily stats (last 30 days) | ✅ | 2026-02-07 |
| TASK-030 | Write `08_seed_stats.sql` - INSERT activity logs for admin actions | ✅ | 2026-02-07 |
| TASK-031 | Write `09_common_queries.sql` - SELECT query: Get all published recipes with author info (JOIN) | ✅ | 2026-02-07 |
| TASK-032 | Write `09_common_queries.sql` - SELECT query: Get recipe details with ingredients, instructions, images (multiple JOINs) | ✅ | 2026-02-07 |
| TASK-033 | Write `09_common_queries.sql` - SELECT query: Get user's favorite recipes with stats | ✅ | 2026-02-07 |
| TASK-034 | Write `09_common_queries.sql` - SELECT query: Search recipes by title/description (LIKE with full-text search) | ✅ | 2026-02-07 |
| TASK-035 | Write `09_common_queries.sql` - SELECT query: Get recipe reviews with user info ordered by date | ✅ | 2026-02-07 |
| TASK-036 | Write `10_admin_queries.sql` - SELECT query: Count users by status (GROUP BY, COUNT) | ✅ | 2026-02-07 |
| TASK-037 | Write `10_admin_queries.sql` - SELECT query: Count recipes by status and author | ✅ | 2026-02-07 |
| TASK-038 | Write `10_admin_queries.sql` - SELECT query: Get pending recipes with author details for approval queue | ✅ | 2026-02-07 |
| TASK-039 | Write `11_analytics_queries.sql` - SELECT query: Top 10 recipes by views/likes/ratings (ORDER BY, LIMIT) | ✅ | 2026-02-07 |
| TASK-040 | Write `11_analytics_queries.sql` - SELECT query: User engagement metrics (subqueries for recipe count, review count, favorite count) | ✅ | 2026-02-07 |
| TASK-041 | Write `11_analytics_queries.sql` - SELECT query: Daily/weekly/monthly growth trends (DATE functions, aggregation) | ✅ | 2026-02-07 |
| TASK-042 | Write `11_analytics_queries.sql` - SELECT query: Recipe category distribution and popularity | ✅ | 2026-02-07 |

### Phase 3: Advanced SQL Features

**GOAL-003**: Implement stored procedures, triggers, and advanced SQL features

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-043 | Write `12_stored_procedures.sql` - CREATE PROCEDURE `usp_CreateRecipe` (handles transaction for recipe + ingredient + instruction inserts with proper error handling) | ✅ | 2026-02-07 |
| TASK-044 | Write `12_stored_procedures.sql` - CREATE PROCEDURE `usp_DeleteRecipe` (cascading deletes with cleanup, logs activity) | ✅ | 2026-02-07 |
| TASK-045 | Write `12_stored_procedures.sql` - CREATE PROCEDURE `usp_ApproveRecipe` (updates status to 'published' + logs activity) | ✅ | 2026-02-07 |
| TASK-046 | Write `12_stored_procedures.sql` - CREATE PROCEDURE `usp_GetRecipeStat` (returns aggregated statistics for a recipe: likes, views, avg_rating) | ✅ | 2026-02-07 |
| TASK-047 | Write `12_stored_procedures.sql` - CREATE FUNCTION `fn_CalculateAvgRating` (returns DECIMAL average rating for recipe_id parameter) | ✅ | 2026-02-07 |
| TASK-048 | Write `13_triggers.sql` - CREATE TRIGGER `trg_RecipeView_UpdateStat` - AFTER INSERT on recipe_view, increment daily_stat.recipe_view_count | ✅ | 2026-02-07 |
| TASK-049 | Write `13_triggers.sql` - CREATE TRIGGER `trg_User_UpdateLastActive` - BEFORE UPDATE on session, update user.last_active timestamp | ✅ | 2026-02-07 |
| TASK-050 | Write `13_triggers.sql` - CREATE TRIGGER `trg_Recipe_DeleteCleanup` - BEFORE DELETE on recipe, log activity_log entry | ✅ | 2026-02-07 |
| TASK-051 | Write `13_triggers.sql` - CREATE TRIGGER `trg_User_NewUserStat` - AFTER INSERT on user, increment daily_stat.new_user_count for today | ✅ | 2026-02-07 |
| TASK-052 | Write `13_triggers.sql` - CREATE TRIGGER `trg_Recipe_SetTimestamp` - BEFORE INSERT on recipe, set created_at and updated_at if NULL | ✅ | 2026-02-07 |
| TASK-053 | Write `13_triggers.sql` - CREATE TRIGGER `trg_User_SetTimestamp` - BEFORE INSERT on user, set created_at and updated_at if NULL | ✅ | 2026-02-07 |
| TASK-054 | Write `14_backup_restore.sql` - Document BACKUP DATABASE using mysqldump command with examples | ✅ | 2026-02-07 |
| TASK-055 | Write `14_backup_restore.sql` - Document RESTORE DATABASE using mysql command with examples | ✅ | 2026-02-07 |

### Phase 4: PHP Backend API Development

**GOAL-004**: Develop complete PHP RESTful API with secure database access

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-056 | Create backend folder structure: `backend/` with subdirs: `api/`, `config/`, `models/`, `controllers/`, `middleware/`, `utils/` | | |
| TASK-057 | Create `config/database.php` - Database connection class using PDO with error handling | | |
| TASK-058 | Create `config/config.php` - Application configuration (DB credentials, JWT secret, CORS settings) | | |
| TASK-059 | Create `.htaccess` for URL rewriting to enable clean API routes | | |
| TASK-060 | Create `middleware/cors.php` - CORS middleware to allow React frontend access | | |
| TASK-061 | Create `middleware/auth.php` - Authentication middleware to verify session/JWT token | | |
| TASK-062 | Create `middleware/admin.php` - Authorization middleware to verify admin role | | |
| TASK-063 | Create `utils/response.php` - Helper functions for JSON responses (success, error, validation) | | |
| TASK-064 | Create `utils/validator.php` - Input validation functions (email, password strength, required fields) | | |
| TASK-065 | Create `models/User.php` - User model with methods: create(), findById(), findByEmail(), update(), delete(), authenticate(), updateLastActive() | | |
| TASK-066 | Create `models/Recipe.php` - Recipe model with methods: create(), findById(), findAll(), update(), delete(), updateStatus(), getWithDetails() | | |
| TASK-067 | Create `models/Review.php` - Review model with methods: create(), update(), delete(), findByRecipe(), findByUserAndRecipe() | | |
| TASK-068 | Create `models/Favorite.php` - Favorite model with methods: toggle(), getUserFavorites(), isRecipeFavorited() | | |
| TASK-069 | Create `models/Like.php` - Like model with methods: toggle(), getRecipeLikes(), isRecipeLiked() | | |
| TASK-070 | Create `models/Stats.php` - Stats model with methods: getDailyStats(), updateStats(), getAnalytics() | | |
| TASK-071 | Create `models/Activity.php` - Activity model with methods: log(), getRecentActivity() | | |
| TASK-072 | Create `controllers/AuthController.php` - POST /api/auth/register endpoint (validate, hash password, create user, return token) | | |
| TASK-073 | Create `controllers/AuthController.php` - POST /api/auth/login endpoint (validate credentials, create session, return user + token) | | |
| TASK-074 | Create `controllers/AuthController.php` - POST /api/auth/logout endpoint (destroy session, clear token) | | |
| TASK-075 | Create `controllers/UserController.php` - GET /api/users endpoint (admin only, return all users with pagination) | | |
| TASK-076 | Create `controllers/UserController.php` - GET /api/users/:id endpoint (return user profile) | | |
| TASK-077 | Create `controllers/UserController.php` - PUT /api/users/:id endpoint (update user profile, validate ownership/admin) | | |
| TASK-078 | Create `controllers/UserController.php` - DELETE /api/users/:id endpoint (admin only, soft delete) | | |
| TASK-079 | Create `controllers/UserController.php` - PUT /api/users/:id/status endpoint (admin only, update status) | | |
| TASK-080 | Create `controllers/RecipeController.php` - GET /api/recipes endpoint (return published recipes with filters: category, difficulty, search, sort) | | |
| TASK-081 | Create `controllers/RecipeController.php` - GET /api/recipes/:id endpoint (return full recipe with ingredients, instructions, images, stats) | | |
| TASK-082 | Create `controllers/RecipeController.php` - POST /api/recipes endpoint (create recipe with nested ingredients/instructions, set status=pending) | | |
| TASK-083 | Create `controllers/RecipeController.php` - PUT /api/recipes/:id endpoint (update recipe, validate ownership) | | |
| TASK-084 | Create `controllers/RecipeController.php` - DELETE /api/recipes/:id endpoint (validate ownership or admin, cascade delete) | | |
| TASK-085 | Create `controllers/RecipeController.php` - PUT /api/recipes/:id/status endpoint (admin only, approve/reject recipe) | | |
| TASK-086 | Create `controllers/RecipeController.php` - POST /api/recipes/:id/like endpoint (toggle like) | | |
| TASK-087 | Create `controllers/RecipeController.php` - POST /api/recipes/:id/favorite endpoint (toggle favorite) | | |
| TASK-088 | Create `controllers/RecipeController.php` - POST /api/recipes/:id/view endpoint (record view, update stats) | | |
| TASK-089 | Create `controllers/ReviewController.php` - GET /api/recipes/:id/reviews endpoint (get all reviews for recipe) | | |
| TASK-090 | Create `controllers/ReviewController.php` - POST /api/recipes/:id/reviews endpoint (create review, enforce one per user) | | |
| TASK-091 | Create `controllers/ReviewController.php` - PUT /api/reviews/:id endpoint (update review, validate ownership) | | |
| TASK-092 | Create `controllers/ReviewController.php` - DELETE /api/reviews/:id endpoint (delete review, validate ownership or admin) | | |
| TASK-093 | Create `controllers/StatsController.php` - GET /api/stats/dashboard endpoint (admin only, return aggregated dashboard stats) | | |
| TASK-094 | Create `controllers/StatsController.php` - GET /api/stats/daily endpoint (return daily stats) | | |
| TASK-095 | Create `controllers/ActivityController.php` - GET /api/activity endpoint (admin only, return recent activity logs with pagination) | | |
| TASK-096 | Create `controllers/SearchController.php` - GET /api/search endpoint (full-text search recipes) | | |
| TASK-097 | Create `controllers/SearchController.php` - POST /api/search/history endpoint (save search query) | | |
| TASK-098 | Create `controllers/SearchController.php` - GET /api/search/history/:userId endpoint (retrieve user search history) | | |
| TASK-099 | Create `controllers/SearchController.php` - DELETE /api/search/history/:userId endpoint (clear user search history) | | |
| TASK-100 | Create `api/index.php` - Main router file that routes requests to appropriate controllers | | |
| TASK-101 | Test all API endpoints with Postman/curl and document response formats | | |

### Phase 5: Frontend Integration

**GOAL-005**: Replace localStorage with API calls while maintaining existing functionality

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-102 | Install axios in React project: `npm install axios` | | |
| TASK-103 | Create `src/lib/api.js` - Base axios instance with API_BASE_URL config and interceptors | | |
| TASK-104 | Create `src/config/environment.js` - Environment configuration for API URL (localhost:8080 for dev) | | |
| TASK-105 | Implement api.auth.register() method - POST /api/auth/register | | |
| TASK-106 | Implement api.auth.login() method - POST /api/auth/login, store token in localStorage | | |
| TASK-107 | Implement api.auth.logout() method - POST /api/auth/logout, clear token | | |
| TASK-108 | Implement api.auth.getCurrentUser() method - GET /api/auth/me with token | | |
| TASK-109 | Implement api.users.getAll() method - GET /api/users | | |
| TASK-110 | Implement api.users.getById(id) method - GET /api/users/:id | | |
| TASK-111 | Implement api.users.update(id, data) method - PUT /api/users/:id | | |
| TASK-112 | Implement api.users.delete(id) method - DELETE /api/users/:id | | |
| TASK-113 | Implement api.users.updateStatus(id, status) method - PUT /api/users/:id/status | | |
| TASK-114 | Implement api.recipes.getAll(filters) method - GET /api/recipes with query params | | |
| TASK-115 | Implement api.recipes.getById(id) method - GET /api/recipes/:id | | |
| TASK-116 | Implement api.recipes.create(data) method - POST /api/recipes | | |
| TASK-117 | Implement api.recipes.update(id, data) method - PUT /api/recipes/:id | | |
| TASK-118 | Implement api.recipes.delete(id) method - DELETE /api/recipes/:id | | |
| TASK-119 | Implement api.recipes.updateStatus(id, status) method - PUT /api/recipes/:id/status | | |
| TASK-120 | Implement api.recipes.like(id) method - POST /api/recipes/:id/like | | |
| TASK-121 | Implement api.recipes.favorite(id) method - POST /api/recipes/:id/favorite | | |
| TASK-122 | Implement api.recipes.recordView(id) method - POST /api/recipes/:id/view | | |
| TASK-123 | Implement api.reviews.getByRecipe(recipeId) method - GET /api/recipes/:id/reviews | | |
| TASK-124 | Implement api.reviews.create(recipeId, data) method - POST /api/recipes/:id/reviews | | |
| TASK-125 | Implement api.reviews.update(id, data) method - PUT /api/reviews/:id | | |
| TASK-126 | Implement api.reviews.delete(id) method - DELETE /api/reviews/:id | | |
| TASK-127 | Implement api.stats.getDashboard() method - GET /api/stats/dashboard | | |
| TASK-128 | Implement api.stats.getDaily() method - GET /api/stats/daily | | |
| TASK-129 | Implement api.activity.getRecent() method - GET /api/activity | | |
| TASK-130 | Implement api.search.search(query, filters) method - GET /api/search | | |
| TASK-131 | Implement api.search.saveHistory(query) method - POST /api/search/history | | |
| TASK-132 | Implement api.search.getHistory(userId) method - GET /api/search/history/:userId | | |
| TASK-133 | Implement api.search.clearHistory(userId) method - DELETE /api/search/history/:userId | | |
| TASK-134 | Update `src/context/AuthContext.jsx` - Replace storage.login() with api.auth.login() | | |
| TASK-135 | Update `src/context/AuthContext.jsx` - Replace storage.logout() with api.auth.logout() | | |
| TASK-136 | Update `src/context/AuthContext.jsx` - Add token management and auto-refresh | | |
| TASK-137 | Update `src/pages/Auth/Login.jsx` - Add loading state and error handling for login | | |
| TASK-138 | Update `src/pages/Auth/Signup.jsx` - Add loading state and error handling for registration | | |
| TASK-139 | Update `src/pages/Recipe/Home.jsx` - Replace storage.getRecipes() with api.recipes.getAll(), add loading spinner | | |
| TASK-140 | Update `src/pages/Recipe/RecipeDetail.jsx` - Replace storage calls with api calls, remove guest view tracking, require authentication for views | | |
| TASK-141 | Update `src/pages/Recipe/CreateRecipe.jsx` - Replace storage.saveRecipe() with api.recipes.create() | | |
| TASK-142 | Update `src/pages/Recipe/Search.jsx` - Replace storage.search with api.search.search(), remove storage.getOrCreateGuestId() calls | | |
| TASK-143 | Update `src/pages/Recipe/Profile.jsx` - Replace storage.saveUser() with api.users.update() | | |
| TASK-144 | Update `src/pages/Recipe/Profile.jsx` - Replace storage.deleteRecipe() with api.recipes.delete() | | |
| TASK-145 | Update `src/pages/Recipe/Profile.jsx` - Replace storage.getUsers() with api.users.getById() for fetching user data | | |
| TASK-146 | Update `src/pages/Admin/UserList.jsx` - Replace storage.getUsers() with api.users.getAll() | | |
| TASK-147 | Update `src/pages/Admin/UserList.jsx` - Replace storage.saveUser() and storage.deleteUser() with API methods | | |
| TASK-148 | Update `src/pages/Admin/UserList.jsx` - Remove storage.addActivity() calls (auto-logged via backend triggers) | | |
| TASK-149 | Update `src/pages/Admin/AdminStats.jsx` - Replace all storage.get* methods with api.stats.getDashboard() | | |
| TASK-150 | Update `src/pages/Admin/AdminStats.jsx` - Replace storage.getRecentActivity() with api.activity.getRecent() | | |
| TASK-151 | Update `src/pages/Admin/AdminRecipes.jsx` - Replace storage.getRecipes() with api.recipes.getAll() | | |
| TASK-152 | Update `src/pages/Admin/AdminRecipes.jsx` - Replace storage.saveRecipe() with api.recipes.updateStatus() for approval/rejection | | |
| TASK-153 | Update `src/pages/Admin/AdminRecipes.jsx` - Replace storage.deleteRecipe() and storage.addActivity() with API methods | | |
| TASK-154 | Create `src/components/ui/LoadingSpinner.jsx` - Reusable loading component | | |
| TASK-155 | Create `src/components/ui/ErrorMessage.jsx` - Reusable error display component | | |
| TASK-156 | Update `src/lib/storage.js` - Remove completely or keep only as fallback (optional, recommend removal) | | |
| TASK-157 | Add error boundaries for React components to catch API errors | | |

### Phase 6: Testing & Deployment

**GOAL-006**: Comprehensive testing and deployment documentation

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-158 | Create `database/README.md` - Database setup instructions for XAMPP | | |
| TASK-159 | Create `database/run_all_scripts.sql` - Master script that executes all SQL files in order | | |
| TASK-149 | Test database installation: Run all SQL scripts on fresh MySQL instance | | |
| TASK-150 | Test API endpoints: Create Postman collection for all endpoints with sample requests | | |
| TASK-151 | Test user registration flow: Create account → verify DB entry → login → verify session | | |
| TASK-152 | Test recipe creation flow: Login → create recipe → verify ingredients/instructions in DB | | |
| TASK-153 | Test admin approval flow: Create recipe (pending) → admin approves → verify status change | | |
| TASK-154 | Test review system: Add review → verify unique constraint → update review → delete review | | |
| TASK-155 | Test likes/favorites: Toggle like → verify DB → check recipe stats update | | |
| TASK-156 | Test search functionality: Search by keyword → verify full-text search results | | |
| TASK-157 | Test admin dashboard: Verify all stats calculations and aggregations | | |
| TASK-158 | Test authorization: Verify role-based access (user cannot access admin endpoints) | | |
| TASK-159 | Test concurrent users: Simulate 10+ concurrent requests to same recipe | | |
| TASK-160 | Test data integrity: Attempt SQL injection, verify prepared statements protection | | |
| TASK-161 | Test cascading deletes: Delete recipe → verify reviews/likes/views also deleted | | |
| TASK-162 | Load test: Insert 1000 recipes and measure query performance | | |
| TASK-163 | Create `docs/API_DOCUMENTATION.md` - Complete API reference with request/response examples | | |
| TASK-164 | Create `docs/DATABASE_SCHEMA.md` - ER diagrams and table structure documentation | | |
| TASK-165 | Create `docs/SQL_QUERIES.md` - Common SQL query examples with explanations | | |
| TASK-166 | Create `docs/DEPLOYMENT_GUIDE.md` - Step-by-step XAMPP deployment instructions | | |
| TASK-167 | Create `docs/TESTING_GUIDE.md` - Testing procedures and test cases | | |
| TASK-168 | Create `CHANGELOG.md` - Document all changes from localStorage to database version | | |
| TASK-169 | Update main `README.md` - Add database setup section and architecture updates | | |
| TASK-170 | Record video demo: Show registration → recipe creation → admin approval → search | | |

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

## 4. Dependencies

**DEP-001**: **XAMPP** (v8.0+)  
- Components needed: Apache web server, MySQL/MariaDB, PHP 8.0+, phpMyAdmin
- Required for local development and testing
- Download: https://www.apachefriends.org/

**DEP-002**: **PHP 8.0 or higher**  
- Required for modern PHP features (typed properties, named arguments)
- Included with XAMPP

**DEP-003**: **MySQL 5.7+ or MariaDB 10.3+**  
- Required for database features (JSON columns, triggers, stored procedures)
- Included with XAMPP

**DEP-004**: **Node.js 16+ and npm**  
- Already installed for existing React project
- Required for frontend build process

**DEP-005**: **Axios** (^1.6.0)  
- HTTP client for React frontend API calls
- Install: `npm install axios`

**DEP-006**: **PHP PDO MySQL Extension**  
- Required for database connectivity
- Usually enabled by default in XAMPP

**DEP-007**: **Apache mod_rewrite**  
- Required for clean API URLs
- Enable in httpd.conf: `LoadModule rewrite_module modules/mod_rewrite.so`

**DEP-008**: **PHP OpenSSL Extension**  
- Required for password hashing and JWT tokens
- Usually enabled by default in XAMPP

**DEP-009**: **Postman or similar API testing tool** (optional)  
- Recommended for API endpoint testing
- Alternative: curl command-line tool

**DEP-010**: **Git** (optional)  
- For version control during development

## 5. Files

**Database SQL Scripts:**

- **FILE-001**: `database/01_create_database.sql` - Database creation with charset and collation
- **FILE-002**: `database/02_create_tables.sql` - All table definitions (~400 lines)
- **FILE-003**: `database/03_create_indexes.sql` - Performance indexes (~50 lines)
- **FILE-004**: `database/04_create_views.sql` - Useful views (~100 lines)
- **FILE-005**: `database/05_seed_users.sql` - User seed data (~150 lines)
- **FILE-006**: `database/06_seed_recipes.sql` - Recipe seed data with ingredients/instructions (~600 lines)
- **FILE-007**: `database/07_seed_reviews.sql` - Reviews, likes, favorites seed data (~200 lines)
- **FILE-008**: `database/08_seed_stats.sql` - Daily stats and activity logs seed data (~100 lines)
- **FILE-009**: `database/09_common_queries.sql` - Common SELECT queries (~200 lines)
- **FILE-010**: `database/10_admin_queries.sql` - Admin dashboard queries (~100 lines)
- **FILE-011**: `database/11_analytics_queries.sql` - Analytics and reporting queries (~150 lines)
- **FILE-012**: `database/12_stored_procedures.sql` - Stored procedures and functions (~300 lines)
- **FILE-013**: `database/13_triggers.sql` - Database triggers (~200 lines)
- **FILE-014**: `database/14_backup_restore.sql` - Backup/restore documentation and scripts (~50 lines)
- **FILE-015**: `database/run_all_scripts.sql` - Master execution script (~50 lines)
- **FILE-016**: `database/README.md` - Database setup instructions

**PHP Backend Files:**

- **FILE-017**: `backend/config/database.php` - PDO database connection class (~100 lines)
- **FILE-018**: `backend/config/config.php` - Application configuration (~50 lines)
- **FILE-019**: `backend/.htaccess` - URL rewriting rules (~20 lines)
- **FILE-020**: `backend/middleware/cors.php` - CORS middleware (~30 lines)
- **FILE-021**: `backend/middleware/auth.php` - Authentication middleware (~80 lines)
- **FILE-022**: `backend/middleware/admin.php` - Admin authorization middleware (~40 lines)
- **FILE-023**: `backend/utils/response.php` - Response helper functions (~60 lines)
- **FILE-024**: `backend/utils/validator.php` - Input validation helpers (~150 lines)
- **FILE-025**: `backend/models/User.php` - User model (~400 lines)
- **FILE-026**: `backend/models/Recipe.php` - Recipe model (~500 lines)
- **FILE-027**: `backend/models/Review.php` - Review model (~200 lines)
- **FILE-028**: `backend/models/Favorite.php` - Favorite model (~100 lines)
- **FILE-029**: `backend/models/Like.php` - Like model (~100 lines)
- **FILE-030**: `backend/models/Stats.php` - Stats model (~200 lines)
- **FILE-031**: `backend/models/Activity.php` - Activity model (~100 lines)
- **FILE-032**: `backend/controllers/AuthController.php` - Auth endpoints (~300 lines)
- **FILE-033**: `backend/controllers/UserController.php` - User endpoints (~400 lines)
- **FILE-034**: `backend/controllers/RecipeController.php` - Recipe endpoints (~600 lines)
- **FILE-035**: `backend/controllers/ReviewController.php` - Review endpoints (~250 lines)
- **FILE-036**: `backend/controllers/StatsController.php` - Stats endpoints (~200 lines)
- **FILE-037**: `backend/controllers/ActivityController.php` - Activity endpoints (~100 lines)
- **FILE-038**: `backend/controllers/SearchController.php` - Search endpoints (~150 lines)
- **FILE-039**: `backend/api/index.php` - Main router (~200 lines)

**Frontend Files (New/Modified):**

- **FILE-040**: `src/lib/api.js` - API service layer (~600 lines) - NEW
- **FILE-041**: `src/config/environment.js` - Environment configuration (~20 lines) - NEW
- **FILE-042**: `src/components/ui/LoadingSpinner.jsx` - Loading component (~40 lines) - NEW
- **FILE-043**: `src/components/ui/ErrorMessage.jsx` - Error component (~40 lines) - NEW
- **FILE-044**: `src/context/AuthContext.jsx` - Updated for API authentication (~300 lines) - MODIFIED
- **FILE-045**: `src/pages/Auth/Login.jsx` - Updated with API calls (~200 lines) - MODIFIED
- **FILE-046**: `src/pages/Auth/Signup.jsx` - Updated with API calls (~250 lines) - MODIFIED
- **FILE-047**: `src/pages/Recipe/Home.jsx` - Updated with API calls (~400 lines) - MODIFIED
- **FILE-048**: `src/pages/Recipe/RecipeDetail.jsx` - Updated with API calls (~500 lines) - MODIFIED
- **FILE-049**: `src/pages/Recipe/CreateRecipe.jsx` - Updated with API calls (~400 lines) - MODIFIED
- **FILE-050**: `src/pages/Recipe/Search.jsx` - Updated with API calls (~350 lines) - MODIFIED
- **FILE-051**: `src/pages/Recipe/Profile.jsx` - Updated with API calls (~300 lines) - MODIFIED
- **FILE-052**: `src/pages/Admin/UserList.jsx` - Updated with API calls (~400 lines) - MODIFIED
- **FILE-053**: `src/pages/Admin/AdminRecipes.jsx` - Updated with API calls (~400 lines) - MODIFIED
- **FILE-054**: `src/pages/Admin/AdminStats.jsx` - Updated with API calls (~300 lines) - MODIFIED

**Documentation Files:**

- **FILE-055**: `docs/API_DOCUMENTATION.md` - Complete API reference (~500 lines) - NEW
- **FILE-056**: `docs/DATABASE_SCHEMA.md` - ER diagrams and schema documentation (~300 lines) - NEW
- **FILE-057**: `docs/SQL_QUERIES.md` - SQL query examples and explanations (~400 lines) - NEW
- **FILE-058**: `docs/DEPLOYMENT_GUIDE.md` - XAMPP deployment instructions (~200 lines) - NEW
- **FILE-059**: `docs/TESTING_GUIDE.md` - Testing procedures (~200 lines) - NEW
- **FILE-060**: `CHANGELOG.md` - Version history and changes (~100 lines) - NEW
- **FILE-061**: `README.md` - Updated with database setup section (~800 lines) - MODIFIED
- **FILE-062**: `postman/recipe_api_collection.json` - Postman API test collection - NEW

## 6. Testing

**Authentication & Authorization Tests:**

- **TEST-001**: User Registration - Verify new user created with hashed password, status=pending, appropriate role
- **TEST-002**: User Login - Verify credentials validated, session/token created, user data returned
- **TEST-003**: Invalid Login - Verify proper error message for wrong password/non-existent email
- **TEST-004**: Logout - Verify session destroyed, token invalidated
- **TEST-005**: Protected Route Access - Verify unauthorized user cannot access protected endpoints (401)
- **TEST-006**: Admin Authorization - Verify non-admin user cannot access admin endpoints (403)
- **TEST-007**: Token Expiration - Verify expired token returns 401 and requires re-login

**Recipe Management Tests:**

- **TEST-008**: Create Recipe - Verify recipe created with ingredients, instructions, images, status=pending
- **TEST-009**: Get Published Recipes - Verify only published recipes returned to non-admin users
- **TEST-010**: Get Recipe Details - Verify full recipe data with nested ingredients/instructions/images
- **TEST-011**: Update Recipe - Verify owner can update, non-owner cannot (403)
- **TEST-012**: Delete Recipe - Verify owner can delete, cascading delete removes ingredients/instructions/reviews
- **TEST-013**: Recipe Search - Verify full-text search returns relevant results
- **TEST-014**: Recipe Filters - Verify category, difficulty, sort filters work correctly
- **TEST-015**: Recipe Pagination - Verify pagination parameters work correctly

**Admin Functions Tests:**

- **TEST-016**: Approve Recipe - Verify admin can approve pending recipe, status changes to published
- **TEST-017**: Reject Recipe - Verify admin can reject recipe, status changes to rejected
- **TEST-018**: User Status Update - Verify admin can change user status (active, inactive, suspended)
- **TEST-019**: Delete User - Verify admin can delete user, cascading to user's recipes/reviews
- **TEST-020**: Admin Dashboard Stats - Verify correct aggregation of user counts, recipe counts, views

**Review System Tests:**

- **TEST-021**: Add Review - Verify review created with rating (1-5), associated with user and recipe
- **TEST-022**: Duplicate Review Prevention - Verify unique constraint prevents user from reviewing same recipe twice
- **TEST-023**: Update Review - Verify user can update their own review, cannot update others
- **TEST-024**: Delete Review - Verify user can delete own review, admin can delete any review
- **TEST-025**: Recipe Rating Calculation - Verify average rating calculated correctly from all reviews

**Engagement Features Tests:**

- **TEST-026**: Toggle Like - Verify like added if not exists, removed if exists (idempotent)
- **TEST-027**: Toggle Favorite - Verify favorite added/removed correctly
- **TEST-028**: Recipe View Tracking - Verify view recorded for authenticated user with proper user_id FK
- **TEST-029**: Multiple Views Tracking - Verify same user viewing same recipe multiple times creates multiple view records
- **TEST-030**: Daily Stats Update - Verify daily_stats table updated correctly on user activity

**Search & History Tests:**

- **TEST-031**: Full-Text Search - Verify search across recipe title and description
- **TEST-032**: Search History Save - Verify user search queries saved with timestamp
- **TEST-033**: Search History Retrieve - Verify user can retrieve their search history

**Data Integrity Tests:**

- **TEST-034**: SQL Injection Prevention - Verify prepared statements prevent SQL injection attacks
- **TEST-035**: XSS Prevention - Verify user input sanitized to prevent cross-site scripting
- **TEST-036**: Foreign Key Constraints - Verify cannot delete user with existing recipes (or cascades correctly)
- **TEST-037**: Unique Constraints - Verify email uniqueness enforced, duplicate emails rejected
- **TEST-038**: Data Type Validation - Verify invalid data types rejected (string for integer field, etc.)

**Performance Tests:**

- **TEST-039**: Query Performance - Verify indexed queries execute under 50ms for typical datasets
- **TEST-040**: Large Dataset - Verify application performs well with 1000+ recipes, 10000+ reviews
- **TEST-041**: Concurrent Users - Verify 100 concurrent requests handled without errors
- **TEST-042**: API Response Time - Verify average API response time under 200ms

**Integration Tests:**

- **TEST-043**: End-to-End Registration Flow - Browser → API → Database → Response → UI update
- **TEST-044**: End-to-End Recipe Creation Flow - Form submit → API → Database → Admin approval → Published
- **TEST-045**: End-to-End Search Flow - User types search → API → Database query → Results displayed

## 7. Risks & Assumptions

**Risks:**

- **RISK-001**: **PHP Version Compatibility** - Different XAMPP versions may have different PHP versions, affecting code compatibility
  - *Mitigation:* Target PHP 8.0+ features, document minimum version requirement, test on multiple versions

- **RISK-002**: **Database Migration Data Loss** - Converting from localStorage to database could lose existing user data
  - *Mitigation:* Provide migration script to export localStorage to SQL, test thoroughly before production

- **RISK-003**: **CORS Issues** - React frontend on port 5173 calling PHP backend on port 8080 may face CORS blocking
  - *Mitigation:* Implement proper CORS headers in PHP middleware, test cross-origin requests early

- **RISK-004**: **Session Management Complexity** - PHP sessions vs JWT tokens decision affects security and scalability
  - *Mitigation:* Document both approaches, implement JWT for stateless API, easier for future mobile apps

- **RISK-005**: **SQL Performance Degradation** - Unoptimized queries may slow down with large datasets
  - *Mitigation:* Create indexes on foreign keys and frequently queried columns, use EXPLAIN to analyze queries

- **RISK-006**: **Learning Curve** - Student may not be familiar with PHP/PDO/MySQL
  - *Mitigation:* Provide extensive code comments, reference documentation, incremental implementation approach

- **RISK-007**: **Security Vulnerabilities** - Inexperienced backend development may introduce security flaws
  - *Mitigation:* Use prepared statements exclusively, implement input validation, follow security best practices

- **RISK-008**: **API Breaking Changes** - Changing data structure may break existing frontend components
  - *Mitigation:* Keep API response format similar to localStorage structure, gradual migration strategy

- **RISK-009**: **Time Estimation** - Project may take longer than expected (168 tasks)
  - *Mitigation:* Prioritize core features (auth, recipes, reviews), mark advanced features (triggers, procedures) as optional

**Assumptions:**

- **ASSUMPTION-001**: Student has XAMPP installed or can install it successfully
- **ASSUMPTION-002**: Student has basic knowledge of SQL (SELECT, INSERT, UPDATE, DELETE)
- **ASSUMPTION-003**: Student has access to course materials in PHPWebApp.pdf for PHP reference
- **ASSUMPTION-004**: Development will be done on Windows with XAMPP (alternative: LAMP on Linux)
- **ASSUMPTION-005**: MySQL 5.7+ or MariaDB 10.3+ features are available (JSON columns, CTEs)
- **ASSUMPTION-006**: Frontend React code structure is familiar to student (existing project)
- **ASSUMPTION-007**: Application will be tested locally before any production deployment
- **ASSUMPTION-008**: Database will handle typical usage (100 users, 1000 recipes, 5000 reviews) adequately
- **ASSUMPTION-009**: Student has time to complete project incrementally (2-4 weeks estimated)
- **ASSUMPTION-010**: Instructor accepts PHP backend as fulfillment of course requirements

## 8. Related Specifications / Further Reading

### Course Materials
- **PHPWebApp.pdf** - Course reference material on PHP web application development
- **DB_Xampp_install.pdf** - XAMPP installation and configuration guide
- **CSX3006 Course Syllabus** - Database Systems course requirements and objectives

### Database Design Resources
- [MySQL Documentation](https://dev.mysql.com/doc/) - Official MySQL reference manual
- [Database Normalization Guide](https://www.guru99.com/database-normalization.html) - 1NF, 2NF, 3NF explained
- [ER Diagram Tutorial](https://www.lucidchart.com/pages/er-diagrams) - Entity-Relationship diagram best practices
- [SQL Tutorial](https://www.w3schools.com/sql/) - W3Schools SQL reference

### PHP & Backend Development
- [PHP Manual](https://www.php.net/manual/en/) - Official PHP documentation
- [PDO Tutorial](https://phpdelusions.net/pdo) - PHP Data Objects best practices
- [RESTful API Design](https://restfulapi.net/) - REST API design principles
- [PHP: The Right Way](https://phptherightway.com/) - PHP best practices guide

### Security
- [OWASP Top 10](https://owasp.org/www-project-top-ten/) - Top 10 web application security risks
- [PHP Security Guide](https://www.php.net/manual/en/security.php) - PHP security considerations
- [SQL Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html) - OWASP SQL injection prevention

### React Integration
- [Axios Documentation](https://axios-http.com/docs/intro) - HTTP client library
- [React Error Boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary) - Error handling in React
- [React Query](https://tanstack.com/query/latest) - Optional: Advanced data fetching library

### Project Management
- [Existing Project README](../README.md) - Current project documentation
- [Serena Project Memories](./.serena/memories/) - Project context and patterns
- [Database Diagrams](./python_diagrams/) - Existing data flow diagrams

### Tools & Testing
- [Postman Learning Center](https://learning.postman.com/) - API testing with Postman
- [phpMyAdmin Documentation](https://docs.phpmyadmin.net/) - Database administration tool
- [MySQL Workbench](https://www.mysql.com/products/workbench/) - Alternative database design tool

---

**Implementation Timeline Estimate:**
- Phase 1 (Database Design): 3-5 days
- Phase 2 (SQL Scripts): 3-4 days
- Phase 3 (Advanced SQL): 2-3 days
- Phase 4 (PHP Backend): 7-10 days
- Phase 5 (Frontend Integration): 5-7 days
- Phase 6 (Testing & Documentation): 3-4 days

**Total Estimated Time:** 23-33 days (full-time) or 4-7 weeks (part-time course work)

**Priority Levels:**
- **Critical (Must Have):** Phase 1, Phase 2 (TASK-001 to TASK-042), Phase 4 (TASK-054 to TASK-097), Phase 5 (TASK-098 to TASK-144)
- **Important (Should Have):** Phase 6 Testing (TASK-145 to TASK-160)
- **Nice to Have (Optional):** Phase 3 Advanced SQL (TASK-043 to TASK-053), Phase 6 Documentation (TASK-161 to TASK-168)

The implementation should be approached incrementally - get core database and API working first (authentication, recipes, reviews), then add advanced features (stored procedures, triggers) if time permits.
