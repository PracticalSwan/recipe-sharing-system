# SQL Queries - Missing/Incomplete Analysis Report
# File -- database folder
> **Project:** CookHub Recipe Sharing System - CSX3006 Database Systems  
> **Date Generated:** 2026-02-12  
> **Review Scope:** SQL scripts in `database/` folder against schema in `02_create_tables.sql`
> **Purpose:** Identify missing/incomplete SQL queries and schema mismatches

---

## Executive Summary

**Total Issues Found:** **8 Issues** (4 Critical, 3 High, 1 Low)  
**Files Analyzed:** 14 SQL files  
**Status:** Several critical mismatches will cause execution failures

---

## Table of Contents

1. [Critical Issues](#critical-issues)
2. [High Priority Issues](#high-priority-issues)
3. [Low Priority Issues](#low-priority-issues)
4. [Missing Query Categories](#missing-query-categories)
5. [Detailed Fix Instructions](#detailed-fix-instructions)

---

## Critical Issues

These issues will cause **SQL execution errors** when queries are run against the database.

---

### Issue #1: ENUM Value Case Mismatch in Stored Procedure - Difficulty

**Severity:** 🔴 **CRITICAL** - Execution will FAIL  
**Files Affected:** `12_stored_procedures.sql`  
**Impact:** Recipe creation via stored procedure will fail with SQL error

#### Problem Description

The `usp_CreateRecipe` stored procedure has an ENUM type mismatch:

**Schema Definition (`02_create_tables.sql`):**
```sql
difficulty ENUM('Easy', 'Medium', 'Hard') NOT NULL DEFAULT 'Easy'
```

**Stored Procedure Definition (`12_stored_procedures.sql`):**
```sql
IN pDifficulty  ENUM('easy', 'medium', 'hard')  -- ❌ WRONG CASE
```

**Expected ENUM values:** `'Easy', 'Medium', 'Hard'` (Title Case, Capitalized)  
**Actual ENUM values in SP:** `'easy', 'medium', 'hard'` (lowercase)

#### Why This Fails

MySQL ENUM values are **case-sensitive**. Values `'Easy'` and `'easy'` are treated as completely different. When the stored procedure tries to insert with lowercase enum values, MySQL will reject the data with:

```
Error: Data truncated for column 'difficulty' at row 1
```

#### What to Fix

**File:** `12_stored_procedures.sql`  
**Line:** ~48 (PROCEDURE parameter definition)

**Change:**
```sql
-- ❌ BEFORE (INCORRECT)
CREATE PROCEDURE usp_CreateRecipe(
    IN pDifficulty  ENUM('easy', 'medium', 'hard'),
    ...
)

-- ✅ AFTER (CORRECT)
CREATE PROCEDURE usp_CreateRecipe(
    IN pDifficulty  ENUM('Easy', 'Medium', 'Hard'),
    ...
)
```

---

### Issue #2: JSON Extraction Mismatch in Stored Procedure

**Severity:** 🔴 **CRITICAL** - Execution will FAIL  
**Files Affected:** `12_stored_procedures.sql`  
**Impact:** Ingredients and instructions won't be inserted from JSON

#### Problem Description

The stored procedure uses JSON extraction patterns that expect different field names than what would typically be provided:

**Current Code (`12_stored_procedures.sql`):**
```sql
-- For ingredients
JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[', v_index, '].name')))
JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[', v_index, '].amount')))
JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[', v_index, '].unit')))

-- For instructions  
JSON_UNQUOTE(JSON_EXTRACT(pInstructions, CONCAT('$[', v_index, '].description')))
```

**Expected JSON Format (inferred):**
```json
{
  "ingredients": [
    {"name": "Flour", "amount": "200", "unit": "g"},
    {"name": "Milk", "amount": "250", "unit": "ml"}
  ]
}
```

#### Schema Mismatch

| Expected JSON Field | Sp's JSON Path | Issue |
|-------------------|-------------------|--------|
| `name` | `name` | ✅ Matches |
| `amount` | `amount` | ❌ Schema has `quantity` |
| `unit` | `unit` | ✅ Matches |
| `text` | `description` | ❌ Uses wrong field name for instruction |
| `caption` | `caption` | ❌ `is_primary` and `caption` columns don't exist in schema |

The schema uses `quantity` for ingredients, but the SP extracts `amount`. Similarly, instruction extraction may not match expected JSON structure.

#### What to Fix

**File:** `12_stored_procedures.sql`  
**Procedure:** `usp_CreateRecipe`

**Change ingredient extraction (around line 70):**
```sql
-- ❌ BEFORE
JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[', v_index, '].amount')))

-- ✅ AFTER - or ensure frontend sends 'amount' field
JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[', v_index, '].quantity')))
```

**Option A - Fix SQL to match frontend:** Change SP to extract `amount` if frontend sends `amount`  
**Option B - Fix frontend to match SQL:** Update frontend to send `quantity` field  
**Option C - Support both:** Add conditional logic to handle both field names

---

### Issue #3: Difficulty ENUM Mismatch in View Definition

**Severity:** 🔴 **CRITICAL** - Execution will FAIL  
**Files Affected:** `04_create_views.sql`  
**Impact:** Views won't create or will return incorrect results

#### Problem Description

The `vw_recipe_with_stat` view references recipe difficulty with potential inconsistencies.

**Query Analysis:**
```sql
-- From 04_create_views.sql
SELECT
    r.difficulty AS recipe_difficulty,
    ...
FROM recipe r
```

The view definition itself doesn't have explicit difficulty filtering, **BUT** if any queries using this view add filters based on difficulty, they need to use correct case.

**Also:** If comparing difficulty in WHERE clauses later:
```sql
-- ❌ WRONG CASE
SELECT * FROM vw_recipe_with_stat WHERE recipe_difficulty = 'easy'

-- ✅ CORRECT CASE
SELECT * FROM vw_recipe_with_stat WHERE recipe_difficulty = 'Easy'
```

#### What to Fix

Ensure all queries and application code use **Title Case** for difficulty values:
- ✅ `'Easy'` - not `'easy'`
- ✅ `'Medium'` - not `'medium'`
- ✅ `'Hard'` - not `'hard'`

---

### Issue #4: Missing is_primary and caption Columns in recipe_image

**Severity:** 🔴 **CRITICAL** - Queries will FAIL  
**Files Affected:** `09_common_queries.sql`, `10_admin_queries.sql` (indirectly via admin references)  
**Impact:** Image queries referencing non-existent columns

#### Problem Description

The schema uses:
```sql
CREATE TABLE recipe_image (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id       INT NOT NULL,
    image_url       TEXT NOT NULL,
    display_order   INT DEFAULT 0,  -- ✅ Exists in schema
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

But stored procedure inserts reference:
```sql
-- From 12_stored_procedures.sql
INSERT INTO recipe_image (recipe_id, image_url, is_primary, caption)
VALUES (pRecipeId, pImageUrl, 1, CONCAT('Primary image for ', pTitle));
--                                                   ^^^^^^^^^ ^^^^^^ - THESE DON'T EXIST
```

#### Why This Fails

Columns `is_primary` and `caption` don't exist in `recipe_image` table. Attempting to INSERT into them will cause:

```
Error: Unknown column 'is_primary' in 'field list'
Error: Unknown column 'caption' in 'field list'
```

#### What to Fix

**Option A - Add columns to schema** (Recommended):
```sql
-- File: 02_create_tables.sql
-- Modify recipe_image table definition:

DROP TABLE IF EXISTS recipe_image;
CREATE TABLE recipe_image (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id       INT NOT NULL,
    image_url       TEXT NOT NULL,
    display_order   INT DEFAULT 0,
    is_primary      TINYINT(1) DEFAULT 0,     -- ✅ ADD THIS
    caption         VARCHAR(200) DEFAULT NULL,    -- ✅ ADD THIS
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_recipe_image_recipe
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add index for primary image lookup
CREATE INDEX idx_recipe_image_primary ON recipe_image(recipe_id, is_primary);
```

**Option B - Remove references from stored procedure:**
```sql
-- File: 12_stored_procedures.sql
-- Simplify image insertion:

-- ❌ BEFORE
IF pImageUrl IS NOT NULL AND pImageUrl != '' THEN
    INSERT INTO recipe_image (recipe_id, image_url, is_primary, caption)
    VALUES (pRecipeId, pImageUrl, 1, CONCAT('Primary image for ', pTitle));
END IF;

-- ✅ AFTER
IF pImageUrl IS NOT NULL AND pImageUrl != '' THEN
    INSERT INTO recipe_image (recipe_id, image_url, display_order)
    VALUES (pRecipeId, pImageUrl, 1);
END IF;
```

**Recommendation:** Choose Option A (`is_primary` flag) if you want to implement "primary image" functionality. This is useful for:
- Quick lookup of main image in views
- Image management UI
- Consistent display of recipe thumbnails

---

## High Priority Issues

These issues won't cause immediate failures but indicate incomplete functionality or potential performance problems.

---

### Issue #5: Missing Image Management Queries

**Severity:** 🟡 **HIGH** - Incomplete functionality  
**Files Affected:** None - **MISSING**  
**Impact:** No SQL queries for image operations

#### Problem Description

The system has these image-related capabilities but **no dedicated queries**:
- Uploading multiple images per recipe
- Setting primary image for a recipe
- Deleting specific images
- Reordering images (display_order)

**Current State:**
- Schema supports multiple images via `recipe_image` table ✓
- Seed data has 1 image per recipe ✓
- No public queries for image management ✗

#### Missing Queries Needed

| Query Purpose | SQL Location | Description |
|--------------|----------------|-------------|
| Get all images for a recipe | New file or append to existing | `SELECT * FROM recipe_image WHERE recipe_id = ? ORDER BY display_order` |
| Set primary image | New file or append | `UPDATE recipe_image SET is_primary = 0 WHERE recipe_id = ?; UPDATE recipe_image SET is_primary = 1 WHERE id = ?` |
| Delete image | New file or append | `DELETE FROM recipe_image WHERE id = ? AND recipe_id = ?` |
| Reorder images | New file or append | Update display_order for multiple images |
| Delete orphaned images | New file or append | Cleanup images when recipe is deleted (CASCADE handles this) |

#### What to Add

Create a new file: `15_image_management_queries.sql` or add to `09_common_queries.sql`

```sql
-- ============================================================================
-- QUERY: Get Images for Recipe
-- ============================================================================
SELECT 
    ri.id,
    ri.recipe_id,
    ri.image_url,
    ri.display_order,
    ri.is_primary,
    ri.caption
FROM recipe_image ri
WHERE ri.recipe_id = @recipe_id
ORDER BY ri.display_order ASC;

-- ============================================================================
-- QUERY: Set Primary Image
-- ============================================================================
-- Parameters: @image_id (ID to set as primary), @recipe_id (owner verification)
UPDATE recipe_image
SET is_primary = 0
WHERE recipe_id = @recipe_id;

UPDATE recipe_image
SET is_primary = 1
WHERE id = @image_id AND recipe_id = @recipe_id;

-- ============================================================================
-- QUERY: Delete Image
-- ============================================================================
DELETE FROM recipe_image
WHERE id = @image_id AND recipe_id = @recipe_id;

-- After deletion, update display_order for remaining images
SET @counter = 0;
UPDATE recipe_image
SET display_order = (@counter := @counter + 1)
WHERE recipe_id = @recipe_id
ORDER BY display_order ASC;
```

---

### Issue #6: User Management Queries Inconsistencies

**Severity:** 🟡 **HIGH** - Incomplete admin functionality  
**Files Affected:** `10_admin_queries.sql`  
**Impact:** Admin panel may have inconsistent user data display

#### Problem Description

**Query 1 in `10_admin_queries.sql`:**
```sql
SELECT
    u.user_id,
    u.username,
    u.email,
    u.display_name,   -- ❌ Column doesn't exist
    u.role,
    u.status,
    ...
FROM user u
```

The query references `display_name` but the schema has:
```sql
CREATE TABLE user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    ...
);
```

#### Missing Derived Columns

The admin panel likely expects these derived/invented columns:
- `display_name` - Should be `CONCAT(first_name, ' ', last_name)`
- `full_name` - Same as above
- `user_id` - Should be just `id`

#### What to Fix

**File:** `10_admin_queries.sql`  
**Query 1 (Users List)** - Replace incorrect columns:

```sql
-- ❌ BEFORE (INCORRECT)
SELECT
    u.user_id,
    u.username,
    u.email,
    u.display_name,   -- ❌ Doesn't exist
    ...

-- ✅ AFTER (CORRECT)
SELECT
    u.id AS user_id,
    u.username,
    u.email,
    CONCAT(u.first_name, ' ', u.last_name) AS display_name,
    u.role,
    u.status,
    DATE_FORMAT(u.joined_date, '%Y-%m-%d') AS joined_date,
    DATE_FORMAT(u.last_active, '%Y-%m-%d %H:%i') AS last_active,
    (SELECT COUNT(*) FROM recipe WHERE author_id = u.id) AS recipe_count,
    (SELECT COUNT(*) FROM review WHERE user_id = u.id) AS review_count
FROM user u
ORDER BY u.created_at DESC
LIMIT 20 OFFSET 0;
```

**Update all references to `user_id` in WHERE/JOIN clauses:**
```sql
-- ❌ WRONG
WHERE u.user_id = 10

-- ✅ CORRECT
WHERE u.id = 10
```

---

### Issue #7: No Advanced Search Queries

**Severity:** 🟡 **HIGH** - Limited search functionality  
**Files Affected:** `09_common_queries.sql` (incomplete)  
**Impact:** Basic keyword search only, no advanced filtering

#### Problem Description

**Current Search Query (`09_common_queries.sql` - Query 4):**
```sql
SELECT ...
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
  AND (
      r.title LIKE CONCAT('%', @search_term, '%')
   OR r.description LIKE CONCAT('%', @search_term, '%')
   OR r.category LIKE CONCAT('%', @search_term, '%')
  )
```

This provides only basic full-text search. Missing advanced search features:

#### Missing Advanced Search Capabilities

| Feature | Current State | Needed Implementation |
|----------|--------------|----------------------|
| **Difficulty Filter** | ❌ Not in search query | Add `AND r.difficulty = ?` parameter |
| **Category Filter** | ❌ Only via LIKE | Add `AND r.category = ?` parameter |
| **Time Range Filter (Total Prep+Cook)** | ❌ Not available | Add `AND (r.prep_time + r.cook_time) <= ?` |
| **Prep Time Only** | ❌ Not available | Add min/max prep time filters |
| **Cook Time Only** | ❌ Not available | Add min/max cook time filters |
| **Servings Filter** | ❌ Not available | Add exact or range filter on servings |
| **Multiple Categories** | ❌ Only single category via LIKE | Add `AND r.category IN (?, ?, ?)` |
| **Exact Title Match** | ❌ Only LIKE wildcard | Add option for `r.title = ? vs r.title LIKE ?` |
| **Ingredient Search** | ❌ Not available | JOIN with `ingredient` table for ingredient lookup |

#### What to Add

**File:** New `16_advanced_search_queries.sql` or extend `09_common_queries.sql`

```sql
-- ============================================================================
-- QUERY 1: Advanced Search Recipe
-- Supports: keyword, category, difficulty, time range, servings
-- ============================================================================
SELECT
    r.id,
    r.title,
    r.description,
    r.category,
    r.difficulty,
    r.prep_time,
    r.cook_time,
    r.servings,
    (r.prep_time + r.cook_time) AS total_time,
    u.username AS author_name,
    u.avatar_url AS author_avatar,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating,
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count,
    (SELECT COUNT(*) FROM recipe_view WHERE recipe_id = r.id) AS view_count,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order LIMIT 1) AS image_url
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
LEFT JOIN ingredient i ON r.id = i.recipe_id
WHERE r.status = 'published'
  
  -- Keyword search (title OR description)
  AND (@search_term IS NULL 
       OR r.title LIKE CONCAT('%', @search_term, '%')
       OR r.description LIKE CONCAT('%', @search_term, '%'))
  
  -- Category filter
  AND (@category IS NULL OR r.category = @category)
  
  -- Difficulty filter
  AND (@difficulty IS NULL OR r.difficulty = @difficulty)
  
  -- Servings filter
  AND (@servings IS NULL OR r.servings = @servings)
  
  -- Total time filter (prep + cook <= max_time)
  AND (@max_total_time IS NULL OR (r.prep_time + r.cook_time) <= @max_total_time)
  
  -- Ingredient search
  AND (@ingredient IS NULL OR i.name LIKE CONCAT('%', @ingredient, '%'))

GROUP BY r.id, r.title, r.description, r.category, r.difficulty,
         r.prep_time, r.cook_time, r.servings, u.username, u.avatar_url
ORDER BY 
    CASE @sort_by
        WHEN 'views' THEN (SELECT COUNT(*) FROM recipe_view WHERE recipe_id = r.id)
        WHEN 'likes' THEN (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id)
        WHEN 'rating' THEN (SELECT AVG(rating) FROM review WHERE recipe_id = r.id)
        WHEN 'date' THEN r.created_at
        ELSE (SELECT COUNT(*) FROM recipe_view WHERE recipe_id = r.id)
    END DESC;

-- ============================================================================
-- QUERY 2: Search by Ingredients Only
-- ============================================================================
SELECT
    r.id,
    r.title,
    r.category,
    r.difficulty,
    COUNT(DISTINCT i.id) AS matched_ingredients
FROM recipe r
INNER JOIN ingredient i ON r.id = i.recipe_id
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
  AND (
      @ingredient_1 IS NULL OR EXISTS (
          SELECT 1 FROM ingredient WHERE recipe_id = r.id AND name LIKE CONCAT('%', @ingredient_1, '%')
      )
  )
  AND (
      @ingredient_2 IS NULL OR EXISTS (
          SELECT 1 FROM ingredient WHERE recipe_id = r.id AND name LIKE CONCAT('%', @ingredient_2, '%')
      )
  )
  AND (
      @ingredient_3 IS NULL OR EXISTS (
          SELECT 1 FROM ingredient WHERE recipe_id = r.id AND name LIKE CONCAT('%', @ingredient_3, '%')
      )
  )
GROUP BY r.id, r.title, r.category, r.difficulty
HAVING matched_ingredients > 0
ORDER BY matched_ingredients DESC;

-- ============================================================================
-- QUERY 3: Get Popular Categories for Search Filters
-- ============================================================================
SELECT
    category,
    COUNT(*) AS recipe_count
FROM recipe
WHERE status = 'published'
GROUP BY category
ORDER BY recipe_count DESC;
```

---

### Issue #8: No User Profile Related Queries

**Severity:** 🟡 **HIGH** - Incomplete user operations  
**Files Affected:** None - **MISSING**  
**Impact:** Cannot display user profile pages or user contributions properly

#### Problem Description

The database has comprehensive user tables but **no queries for**:
- User profile display (with stats)
- User's published recipes list
- User's reviews list
- User's activity/recent actions

#### Missing User Profile Queries

| Query Purpose | Description | SQL Needed |
|--------------|-------------|------------|
| **Get User Profile** | Fetch user details + aggregated stats | `SELECT ... FROM user LEFT JOIN aggregates WHERE id = ?` |
| **User's Recipes** | List all recipes by a user | `SELECT * FROM recipe WHERE author_id = ?` |
| **User's Reviews** | List all reviews by a user | `SELECT * FROM review WHERE user_id = ?` |
| **User's Favorites** | List favorites with recipe details | `JOIN favorite + recipe WHERE user.id = ?` |
| **User's Activity Log** | Show user's recent actions | `SELECT * FROM (recipe + review + favorite) WHERE user_id = ?` |
| **Update User Profile** | Change avatar, bio, etc. | `UPDATE user SET avatar_url = ?, bio = ? WHERE id = ?` |
| **Change Password** | Password update query | `UPDATE user SET password_hash = ? WHERE id = ?` |

#### What to Add

**File:** New `17_user_profile_queries.sql` or extend `09_common_queries.sql`

```sql
-- ============================================================================
-- QUERY 1: Get User Profile with Stats
-- ============================================================================
SELECT
    u.id,
    u.username,
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
    u.email,
    u.bio,
    u.location,
    u.cooking_level,
    u.avatar_url,
    u.role,
    u.status,
    u.joined_date,
    u.last_active,
    -- Aggregated stats
    (SELECT COUNT(*) FROM recipe WHERE author_id = u.id AND status = 'published') AS published_recipes,
    (SELECT COUNT(*) FROM recipe WHERE author_id = u.id AND status = 'pending') AS pending_recipes,
    (SELECT COUNT(*) FROM review WHERE user_id = u.id) AS reviews_written,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE user_id = u.id) AS avg_rating_given,
    (SELECT COUNT(*) FROM like_record lr INNER JOIN recipe r ON lr.recipe_id = r.id WHERE r.author_id = u.id) AS likes_received,
    (SELECT COUNT(*) FROM favorite WHERE user_id = u.id) AS favorites_count,
    (SELECT COUNT(*) FROM recipe_view WHERE user_id = u.id) AS recipes_viewed
FROM user u
WHERE u.id = @user_id;

-- ============================================================================
-- QUERY 2: Get User's Recipes
-- ============================================================================
SELECT
    r.id,
    r.title,
    r.description,
    r.category,
    r.difficulty,
    r.prep_time,
    r.cook_time,
    r.servings,
    r.status,
    r.created_at,
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count,
    (SELECT COUNT(*) FROM review WHERE recipe_id = r.id) AS review_count,
    (SELECT COUNT(*) FROM recipe_view WHERE recipe_id = r.id) AS view_count,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id AND is_primary = 1 LIMIT 1) AS image_url
FROM recipe r
WHERE r.author_id = @user_id
ORDER BY r.created_at DESC;

-- ============================================================================
-- QUERY 3: Get User's Reviews
-- ============================================================================
SELECT
    rv.id AS review_id,
    rv.rating,
    rv.comment,
    rv.created_at,
    r.id AS recipe_id,
    r.title AS recipe_title,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id AND is_primary = 1 LIMIT 1) AS recipe_image
FROM review rv
INNER JOIN recipe r ON rv.recipe_id = r.id
WHERE rv.user_id = @user_id
ORDER BY rv.created_at DESC;

-- ============================================================================
-- QUERY 4: Get User's Favorites with Recipe Details
-- ============================================================================
SELECT
    f.id AS favorite_id,
    f.created_at AS favorited_at,
    r.id AS recipe_id,
    r.title,
    r.category,
    r.difficulty,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id AND is_primary = 1 LIMIT 1) AS image_url,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating,
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count
FROM favorite f
INNER JOIN recipe r ON f.recipe_id = r.id
WHERE f.user_id = @user_id
ORDER BY f.created_at DESC;

-- ============================================================================
-- QUERY 5: Update User Profile
-- ============================================================================
UPDATE user
SET
    avatar_url = @avatar_url,
    bio = @bio,
    location = @location,
    cooking_level = @cooking_level
WHERE id = @user_id;

-- ============================================================================
-- QUERY 6: Change User Password
-- ============================================================================
UPDATE user
SET password_hash = @new_password_hash,
    updated_at = NOW()
WHERE id = @user_id AND password_hash = @current_password_hash;
```

---

## Low Priority Issues

These are optional enhancements that could improve functionality but aren't critical.

---

### Issue #9: No Pagination Support Queries

**Severity:** 🟢 **LOW** - Performance optimization  
**Files Affected:** `09_common_queries.sql`  
**Impact:** Large datasets will cause performance issues

#### Problem Description

Current queries return all matching rows. For production scalability, queries should support:
- Pagination (LIMIT + OFFSET)
- Cursor-based pagination for large datasets

#### Enhancement Suggestion

Add pagination helper queries:

```sql
-- ============================================================================
-- QUERY: Paginated Recipe List
-- ============================================================================
-- Parameters: @page_number, @page_size
-- ============================================================================
SET @offset = (@page_number - 1) * @page_size;

SELECT
    r.id,
    r.title,
    r.category,
    r.difficulty,
    u.username AS author_name,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating,
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
ORDER BY r.created_at DESC
LIMIT @page_size OFFSET @offset;

-- ============================================================================
-- QUERY: Cursor-Based Pagination (for infinite scroll)
-- ============================================================================
-- Parameters: @last_recipe_id (null for first page), @page_size
-- ============================================================================
SELECT
    r.id,
    r.title,
    r.category,
    r.difficulty,
    u.username AS author_name,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id AND is_primary = 1 LIMIT 1) AS image_url
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
  AND (@last_recipe_id IS NULL OR r.id < @last_recipe_id)
ORDER BY r.id DESC
LIMIT @page_size;
```

---

### Issue #10: No Query for Email Exists Check

**Severity:** 🟢 **LOW** - Feature completeness  
**Files Affected:** None - **MISSING**  
**Impact:** Cannot check if email already exists during registration

#### Problem Description

Registration flow needs to verify email uniqueness before attempting to insert.

#### What to Add

```sql
-- ============================================================================
-- QUERY: Check Email Exists
-- ============================================================================
SELECT 
    id,
    email,
    username,
    status
FROM user
WHERE email = @email;
```

This query should be called before user registration to prevent duplicate emails.

---

## Missing Query Categories Summary

| Category | Status | Notes |
|----------|---------|-------|
| **Core CRUD** | ✅ Complete | Recipe, user, review basics OK |
| **Authentication** | ✅ Complete | Session queries OK |
| **Image Management** | ❌ **MISSING** | Need image-specific queries |
| **Advanced Search** | ⚠️ **INCOMPLETE** | Only basic keyword search |
| **User Profile** | ❌ **MISSING** | No user profile queries |
| **Admin Operations** | ✅ Mostly Complete | Some column issues in user list |
| **Analytics** | ✅ Complete | Good coverage |
| **Pagination** | ❌ **MISSING** | For scalability |
| **Validation** | ❌ **MISSING** | Email/username uniqueness checks |

---

## Detailed Fix Instructions

### Priority 1: Fix Critical Stored Procedure Issues

**Files:** `12_stored_procedures.sql`

**Step 1:** Fix ENUM case in `usp_CreateRecipe` parameter
```sql
IN pDifficulty ENUM('Easy', 'Medium', 'Hard')  -- ✅ Title Case
```

**Step 2:** Fix ingredient extraction OR add `is_primary`/`caption` columns to schema

**Recommended Approach:** Add `is_primary` and `caption` to schema, keep SP as-is.

**Migration for adding columns:**
```sql
-- Run in database/ folder as migration
ALTER TABLE recipe_image
ADD COLUMN is_primary TINYINT(1) DEFAULT 0 AFTER display_order,
ADD COLUMN caption VARCHAR(200) DEFAULT NULL AFTER is_primary;

-- Update existing images (first image as primary)
UPDATE recipe_image ri1
SET ri1.is_primary = 1
WHERE ri1.id = (
    SELECT MIN(ri2.id)
    FROM recipe_image ri2
    WHERE ri2.recipe_id = ri1.recipe_id
);

-- Create index for primary image queries
CREATE INDEX idx_recipe_image_primary ON recipe_image(recipe_id, is_primary);
```

**Step 3:** Update views to handle new columns if added

---

### Priority 2: Fix Admin Query Column Mismatches

**File:** `10_admin_queries.sql`

**Find and Replace Tasks:**
1. `user_id` → `id` (in SELECT list)
2. `display_name` → `CONCAT(first_name, ' ', last_name)`
3. Join conditions using `u.id` not `u.user_id`

Test all admin queries after fixes.

---

### Priority 3: Add Missing Query Files

**Create these new files:**

1. `15_image_management_queries.sql` - Image operations
2. `16_advanced_search_queries.sql` - Advanced search
3. `17_user_profile_queries.sql` - User profile/management

**Execution Order:** These should be run LAST (after seeding) as they contain SELECT queries only.

---

## Summary Matrix

| Issue ID | Severity | File(s) | Lines | Impact | Effort |
|----------|-----------|------------|--------|----------|
| #1 | 🔴 CRITICAL | `12_stored_procedures.sql` | Line 48 | High | SP recipe creation fails |
| #2 | 🔴 CRITICAL | `12_stored_procedures.sql` | Lines 70-85 | High | Ingredients/instructions not saved |
| #3 | 🔴 CRITICAL | `02_create_tables.sql` + `12_stored_procedures.sql` | ENUM definitions | Medium | Inconsistent difficulty values |
| #4 | 🔴 CRITICAL | `02_create_tables.sql` or `12_stored_procedures.sql` | Columns referenced | Medium | Image management fails |
| #5 | 🟡 HIGH | None - MISSING | N/A | High | No image management UI |
| #6 | 🟡 HIGH | `10_admin_queries.sql` | Multiple | Medium | Admin panel shows errors |
| #7 | 🟡 HIGH | `09_common_queries.sql` | Query 4 | High | Limited search functionality |
| #8 | 🟡 HIGH | None - MISSING | N/A | High | No user profile pages |
| #9 | 🟢 LOW | None - MISSING | N/A | Low | Performance at scale |
| #10 | 🟢 LOW | None - MISSING | N/A | Low | D registration errors |

---

## Recommended Fix Order

**Phase 1: Critical Fixes (Do First)**
1. Fix `usp_CreateRecipe` ENUM case issue (#1)
2. Fix `is_primary`/`caption` schema mismatch (#4)
3. Fix ingredient JSON extraction or schema (#2)

**Phase 2: High Priority (Do Next)**
4. Fix admin query column mismatches (#6)
5. Create user profile queries (#8)
6. Enhance search with advanced filters (#7)
7. Create image management queries (#5)

**Phase 3: Low Priority (Do Last)**
8. Add pagination support (#9)
9. Add validation queries (#10)

---

## Testing Checklist

After fixes are applied, verify:

- [ ] Stored procedure `usp_CreateRecipe` executes without errors
- [ ] Created recipes have ingredients and instructions
- [ ] Created recipes have primary image set correctly
- [ ] Admin user list query displays correctly (no unknown column errors)
- [ ] Advanced search with filters works
- [ ] User profile page loads all data
- [ ] Image management operations succeed
- [ ] All queries return data within expected timeframes (<1 second for small datasets)
- [ ] Views in `04_create_views.sql` refresh successfully
- [ ] Analytics queries aggregate data correctly

---

**Report Generated:** 2026-02-12  
**Next Review Date:** After Phase 1 fixes completed  
**Status:** **READY FOR IMPLEMENTATION**
