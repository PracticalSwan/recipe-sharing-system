# CookHub Database Schema

Complete database schema documentation for the CookHub Recipe Sharing System.

## Database Information

- **Name**: `cookhub`
- **Engine**: InnoDB
- **Character Set**: utf8mb4
- **Collation**: utf8mb4_unicode_ci

> **Consolidated SQL Reference**: All DDL, DML, and programmatic SQL commands are also available as 89 numbered commands (CMD-001 to CMD-089) in [`database/1.sql`](../database/1.sql), with source tracing and UI/API linkage.

---

## Table Definitions

### `user`

Primary user accounts table.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | User ID |
| username | VARCHAR(100) | NOT NULL | Display name |
| first_name | VARCHAR(50) | NOT NULL | First name |
| last_name | VARCHAR(50) | NOT NULL | Last name |
| email | VARCHAR(100) | NOT NULL, UNIQUE | Email address |
| password_hash | VARCHAR(255) | NOT NULL | bcrypt hashed password |
| birthday | DATE | NULL | Date of birth |
| role | ENUM('admin','user') | DEFAULT 'user' | User role |
| status | ENUM('active','inactive','pending','suspended') | DEFAULT 'pending' | Account status |
| joined_date | DATETIME | DEFAULT CURRENT_TIMESTAMP | Registration date |
| last_active | DATETIME | NULL | Last activity timestamp |
| avatar_url | TEXT | NULL | Profile picture URL |
| bio | TEXT | NULL | User biography |
| location | VARCHAR(100) | NULL | User location |
| cooking_level | VARCHAR(50) | NULL | Skill level |
| created_at | TIMESTAMP | AUTO | Row creation time |
| updated_at | TIMESTAMP | AUTO UPDATE | Row update time |

### `session`

Session management for authentication.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Session ID |
| user_id | INT | FK → user(id) CASCADE | Session owner |
| session_token | VARCHAR(255) | UNIQUE | Session token (cookie value) |
| expires_at | DATETIME | NOT NULL | Expiration time (24h) |
| created_at | TIMESTAMP | AUTO | Row creation time |
| updated_at | TIMESTAMP | AUTO UPDATE | Row update time |

### `recipe`

Core recipe metadata.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Recipe ID |
| title | VARCHAR(200) | NOT NULL | Recipe title |
| description | TEXT | NULL | Recipe description |
| category | VARCHAR(50) | NULL | Categories (comma-separated) |
| difficulty | ENUM('Easy','Medium','Hard') | DEFAULT 'Easy' | Difficulty level |
| prep_time | INT | NULL | Preparation time (minutes) |
| cook_time | INT | NULL | Cooking time (minutes) |
| servings | INT | NULL | Number of servings |
| author_id | INT | FK → user(id) CASCADE | Recipe author |
| status | ENUM('published','pending','rejected') | DEFAULT 'pending' | Publication status |
| created_at | TIMESTAMP | AUTO | Row creation time |
| updated_at | TIMESTAMP | AUTO UPDATE | Row update time |

### `ingredient`

Recipe ingredients with ordering.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Ingredient ID |
| recipe_id | INT | FK → recipe(id) CASCADE | Parent recipe |
| name | VARCHAR(200) | NOT NULL | Ingredient name |
| quantity | VARCHAR(50) | NULL | Amount |
| unit | VARCHAR(50) | NULL | Unit of measure |
| sort_order | INT | DEFAULT 0 | Display order |

### `instruction`

Recipe cooking steps.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Instruction ID |
| recipe_id | INT | FK → recipe(id) CASCADE | Parent recipe |
| step_number | INT | NOT NULL | Step number |
| instruction_text | TEXT | NOT NULL | Step description |

### `recipe_image`

Recipe photos with ordering.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Image ID |
| recipe_id | INT | FK → recipe(id) CASCADE | Parent recipe |
| image_url | TEXT | NOT NULL | Image URL |
| display_order | INT | DEFAULT 0 | Display order |

### `review`

User reviews with rating (1 review per user per recipe).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Review ID |
| user_id | INT | FK → user(id) CASCADE | Reviewer |
| recipe_id | INT | FK → recipe(id) CASCADE | Reviewed recipe |
| rating | INT | CHECK (1-5) | Star rating |
| comment | TEXT | NULL | Review text |

**Unique Constraint**: `(user_id, recipe_id)` — one review per user per recipe.

### `like_record`

Recipe like tracking (toggle pattern).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Like ID |
| user_id | INT | FK → user(id) CASCADE | User who liked |
| recipe_id | INT | FK → recipe(id) CASCADE | Liked recipe |

**Unique Constraint**: `(user_id, recipe_id)`

### `favorite`

Bookmarked/saved recipes (toggle pattern).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Favorite ID |
| user_id | INT | FK → user(id) CASCADE | User who saved |
| recipe_id | INT | FK → recipe(id) CASCADE | Saved recipe |

**Unique Constraint**: `(user_id, recipe_id)`

### `recipe_view`

View tracking for analytics.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | View ID |
| recipe_id | INT | FK → recipe(id) CASCADE | Viewed recipe |
| user_id | INT | FK → user(id) CASCADE | Viewer |
| viewed_at | TIMESTAMP | AUTO | View timestamp |

### `search_history`

User search term history.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Entry ID |
| user_id | INT | FK → user(id) CASCADE | Searcher |
| query | TEXT | NOT NULL | Search term |
| searched_at | TIMESTAMP | AUTO | Search timestamp |

### `daily_stat`

Aggregated daily statistics.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Stat ID |
| stat_date | DATE | UNIQUE | Date |
| page_view_count | INT | DEFAULT 0 | Total page views |
| active_user_count | INT | DEFAULT 0 | Active users count |
| new_user_count | INT | DEFAULT 0 | New registrations |
| recipe_view_count | INT | DEFAULT 0 | Recipe views |

### `activity_log`

Admin action audit trail.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Log ID |
| admin_id | INT | FK → user(id) SET NULL | Admin who acted |
| action_type | ENUM | NOT NULL | Action type |
| target_type | VARCHAR(50) | NULL | Target entity type |
| target_id | INT | NULL | Target entity ID |
| description | TEXT | NULL | Human-readable description |

**Action Types**: `user_create`, `user_update`, `user_delete`, `recipe_approve`, `recipe_reject`, `recipe_delete`

---

## Views

### `vw_recipe_with_stat`

Recipes enriched with aggregated statistics.

**Columns**: recipe fields + `like_count`, `view_count`, `review_count`, `avg_rating`, `favorite_count`, `primary_image_url`

### `vw_user_dashboard_stat`

Users enriched with activity statistics.

**Columns**: user fields + `recipe_count`, `published_recipe_count`, `pending_recipe_count`, `favorite_count`, `review_count`, `like_given_count`, `like_received_count`

---

## Indexes

| Table | Index | Columns | Purpose |
|-------|-------|---------|---------|
| user | uk_user_email | email | Unique email lookup |
| user | idx_user_email | email | Fast email search |
| user | idx_user_role_status | role, status | Admin user filtering |
| user | idx_user_joined_date | joined_date | Date-based queries |
| session | uk_session_token | session_token | Unique token lookup |
| session | idx_session_token | session_token | Fast auth |
| session | idx_session_user_id | user_id | User's sessions |
| session | idx_session_expires_at | expires_at | Cleanup queries |
| recipe | idx_recipe_author_id | author_id | Author's recipes |
| recipe | idx_recipe_status | status | Status filtering |
| recipe | idx_recipe_category | category | Category filtering |
| recipe | idx_recipe_author_status | author_id, status | Author + status combo |
| recipe | idx_recipe_created_at | created_at | Chronological sort |
| review | idx_review_recipe_id | recipe_id | Recipe's reviews |
| review | idx_review_user_id | user_id | User's reviews |
| favorite | idx_favorite_user_id | user_id | User's favorites |
| favorite | idx_favorite_recipe_id | recipe_id | Recipe's favorites |
| like_record | idx_like_record_recipe_id | recipe_id | Recipe's likes |
| like_record | idx_like_record_user_id | user_id | User's likes |
| ingredient | idx_ingredient_recipe_order | recipe_id, sort_order | Ordered ingredients |
| instruction | idx_instruction_recipe_step | recipe_id, step_number | Ordered steps |
| search_history | idx_search_history_user_id | user_id | User's history |
| search_history | idx_search_history_searched_at | user_id, searched_at | Time-ordered history |
| daily_stat | idx_daily_stat_date | stat_date | Date lookup |
| activity_log | idx_activity_log_admin_id | admin_id | Admin's actions |
| activity_log | idx_activity_log_created_at | created_at | Chronological |
| activity_log | idx_activity_log_admin_created | admin_id, created_at | Admin + time combo |

---

## Stored Procedures

### `usp_CreateRecipe`

Creates a recipe with ingredients, instructions, and images in a single transaction.

```sql
CALL usp_CreateRecipe(
  @author_id, @title, @description, @category,
  @difficulty, @prep_time, @cook_time, @servings,
  @image_url, @ingredients_json, @instructions_json,
  @recipe_id
);
```

### `usp_DeleteRecipe`

Deletes a recipe and all related data with activity logging.

```sql
CALL usp_DeleteRecipe(@recipe_id, @admin_id);
```

### `usp_ApproveRecipe`

Approves or rejects a pending recipe with audit trail.

```sql
CALL usp_ApproveRecipe(@recipe_id, @admin_id, 'approve', NULL);
CALL usp_ApproveRecipe(@recipe_id, @admin_id, 'reject', 'Reason text');
```

### `usp_GetRecipeStat`

Returns comprehensive statistics for a single recipe.

```sql
CALL usp_GetRecipeStat(@recipe_id);
```

## Functions

### `fn_CalculateAvgRating`

Returns the average rating (DECIMAL 3,2) for a recipe.

```sql
SELECT fn_CalculateAvgRating(@recipe_id);
```

---

## Cascade Rules

All foreign keys use `ON DELETE CASCADE ON UPDATE CASCADE` except:
- `activity_log.admin_id` → `ON DELETE SET NULL` (preserves logs when admin is deleted)
