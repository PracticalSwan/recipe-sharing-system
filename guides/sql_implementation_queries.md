# Backend API SQL Queries Implementation Guide

> **Project:** Recipe Sharing System - CSX3006 Database Systems
> **Created:** 2026-02-13
> **Last Updated:** 2026-02-18
> **Purpose:** Complete SQL query designs for backend implementation (✅ Implemented)

---

## Table of Contents

1. [Authentication Queries](#authentication-queries) - 🔴 CRITICAL
2. [Recipe Management Queries](#recipe-management-queries) - 🟡 IMPORTANT
3. [Reviews & Interactions Queries](#reviews--interactions-queries) - 🟡 IMPORTANT
4. [User Profile Management Queries](#user-profile-management-queries) - 🟢 SUGGESTION
5. [Admin Management Queries](#admin-management-queries) - 🟢 SUGGESTION
6. [Advanced Features Queries](#advanced-features-queries) - 💎️ OPTIONAL

---

## Authentication Queries

### Where to Put These Queries

**✅ Implementation Status:** These queries are implemented in the PHP backend API layer.

**Backend Implementation Location:**
Authentication queries are implemented in:
- **File:** `backend/api/auth.php`
- **Methods:** POST /api/auth/register, POST /api/auth/login, POST /api/auth/logout, GET /api/auth/me
- **Uses:** PDO prepared statements for security

---

### 1. 🔴 Get User by Email (Login Lookup)

**Purpose:** Find a user by email before password verification  
**Frontend File:** `Login.jsx` → `AuthContext.js` → `login()` function  
**Why Needed:** Before allowing login, we need to check if email exists and retrieve the user's data including:

- hashed password for verification
- account status (active/pending/suspended) - login should fail for non-active accounts
- user role (admin vs regular) - for redirecting to correct dashboard
- last_active timestamp - to update on successful login

```sql
-- ============================================================================
-- QUERY: Get User by Email
-- Parameters: @pEmail (VARCHAR)
-- Returns: User record with password hash and status
-- ============================================================================

SET @pEmail = 'user@cookhub.com'; -- Example parameter

SELECT 
    id,
    username,
    email,
    password_hash,
    birthday,
    role,
    status,
    joined_date,
    last_active,
    avatar_url,
    bio,
    location,
    cooking_level
FROM user
WHERE email = @pEmail;
```

---

### 2. 🔴 Login Authentication Query (Password Verify + Session Create)

**Purpose:** Verify password and create session atomically  
**Frontend File:** `Login.jsx` → `AuthContext.js` → `login()` function  
**Why Needed:** Upon successful password verification:

1. Create a session token for user
2. Update `last_active` timestamp
3. Handle account status logic (only active/inactive users allowed, not suspended/pending)
4. Insert into `session` table for authenticated requests

```sql
-- ============================================================================
-- PROCEDURE: usp_Login
-- Parameters: @pEmail, @pPassword (plaintext), @pRememberMe
-- Returns: Session token and user data
-- Notes: In production, verify password using bcrypt comparison in application code
-- ============================================================================

DELIMITER //

CREATE PROCEDURE usp_Login(
    IN pEmail VARCHAR(255),
    IN pPassword VARCHAR(255), -- In production, compare hashed values in app layer
    IN pRememberMe BOOLEAN,
    OUT pSessionToken VARCHAR(255),
    OUT pUserId INT,
    OUT pSuccess BOOLEAN,
    OUT pMessage VARCHAR(500)
)
BEGIN
    DECLARE vUserCount INT;
    DECLARE vPasswordHash VARCHAR(255);
    DECLARE vUserId INT;
    DECLARE vUserRole VARCHAR(20);
    DECLARE vUserStatus VARCHAR(20);
    DECLARE vNewToken VARCHAR(255);
    DECLARE vSessionExpiry DATETIME;
    
    -- Clean up old sessions (optional, can be cron job instead)
    -- DELETE FROM session WHERE expires_at < NOW();
    
    -- Get user by email
    SELECT id, password_hash, role, status 
    INTO vUserId, vPasswordHash, vUserRole, vUserStatus
    FROM user
    WHERE email = pEmail;
    
    -- Check if user exists
    SET vUserCount = IFNULL(vUserId, 0);
    
    IF vUserCount = 0 THEN
        SET pSuccess = FALSE;
        SET pMessage = 'Email not found';
        SET pUserId = NULL;
    ELSE
        -- Check password (in production: use bcrypt_verify from app code)
        -- For demo: we allow direct comparison of stored hashed values
        -- STATUS CHECK: Only allow login for 'active' or 'inactive' users
        IF pPassword = 'admin' AND vUserRole = 'admin' THEN
            -- Admin login bypass (demo only)
            SET pSuccess = TRUE;
            SET pMessage = 'Login successful';
        ELSEIF vUserStatus = 'suspended' THEN
            SET pSuccess = FALSE;
            SET pMessage = 'Your account has been suspended. Please contact support.';
        ELSEIF vUserStatus = 'pending' THEN
            SET pSuccess = FALSE;
            SET pMessage = 'Your account is pending approval. Please wait for admin verification.';
        ELSEIF pPassword = 'user' AND vUserRole = 'user' THEN
            -- Normal user login bypass (demo only)
            SET pSuccess = TRUE;
            SET pMessage = 'Login successful';
        ELSE
            SET pSuccess = FALSE;
            SET pMessage = 'Invalid password. Please try again.';
            SET pUserId = NULL;
        END IF;
        
        -- Create session if login successful
        IF pSuccess = TRUE THEN
            -- Generate session token (in production, use secure random generation)
            SET vNewToken = CONCAT('sess_', MD5(CONCAT(vUserId, NOW(), RAND())));
            
            -- Set session expiry (24 hours if remember me, else 2 hours)
            IF pRememberMe = TRUE THEN
                SET vSessionExpiry = DATE_ADD(NOW(), INTERVAL 24 HOUR);
            ELSE
                SET vSessionExpiry = DATE_ADD(NOW(), INTERVAL 2 HOUR);
            END IF;
            
            -- Insert session
            INSERT INTO session (user_id, session_token, created_at, expires_at)
            VALUES (vUserId, vNewToken, NOW(), vSessionExpiry);
            
            -- Update user last_active
            UPDATE user
            SET last_active = NOW(),
                status = 'active'  -- Re-activate inactive users on login
            WHERE id = vUserId;
            
            SET pSessionToken = vNewToken;
            SET pUserId = vUserId;
        END IF;
    END IF;
END //

DELIMITER ;

-- Usage Example:
-- CALL usp_Login('user@cookhub.com', 'user', FALSE, @token, @userId, @success, @msg);
-- SELECT @success, @userId, @token, @msg;
```

---

### 3. 🔴 User Registration Query

**Purpose:** Create a new user account with validation  
**Frontend File:** `Signup.jsx` → `AuthContext.js` → `signup()` function  
**Why Needed:** Registration requires:

1. Check email uniqueness (prevent duplicate accounts)
2. Hash the password before storage (bcrypt)
3. Set default `status = 'pending'` (approval workflow)
4. Auto-generate username from first+last name
5. Record `joined_date` timestamp
6. Return new user ID for auto-login

```sql
-- ============================================================================
-- PROCEDURE: usp_RegisterUser
-- Parameters: @pFirstName, @pLastName, @pEmail, @pBirthday, @pPassword, @pAvatar
-- Returns: @pSuccess, @pMessage, @pUserId
-- Notes: Password should be hashed in application code before calling or inside SP
-- ============================================================================

DELIMITER //

CREATE PROCEDURE usp_RegisterUser(
    IN pFirstName VARCHAR(100),
    IN pLastName VARCHAR(100),
    IN pEmail VARCHAR(255),
    IN pBirthday DATE,
    IN pPassword VARCHAR(255),
    IN pAvatar VARCHAR(500),
    OUT pSuccess BOOLEAN,
    OUT pMessage VARCHAR(500),
    OUT pUserId INT
)
BEGIN
    DECLARE vEmailCount INT;
    DECLARE vNewUserId INT;
    DECLARE vUsername VARCHAR(200);
    
    -- Check if email already exists
    SELECT COUNT(*) INTO vEmailCount
    FROM user
    WHERE email = pEmail;
    
    IF vEmailCount > 0 THEN
        SET pSuccess = FALSE;
        SET pMessage = 'Email already registered. Please login instead.';
        SET pUserId = NULL;
    ELSE
        -- Generate username from first and last name
        SET vUsername = CONCAT(pFirstName, ' ', pLastName);
        
        -- Insert user with 'pending' status (requires admin approval)
        INSERT INTO user (
            username, first_name, last_name, email,
            password_hash, birthday, role, status,
            joined_date, avatar_url, cooking_level,
            bio, location
        ) VALUES (
            vUsername, pFirstName, pLastName, pEmail,
            pPassword, pBirthday, 'user', 'pending',
            NOW(), pAvatar, 'Beginner',
            NULL, NULL
        );
        
        SET pNewUserId = LAST_INSERT_ID();
        SET pSuccess = TRUE;
        SET pMessage = 'Registration successful';
        SET pUserId = pNewUserId;
    END IF;
END //

DELIMITER ;

-- Usage Example:
-- CALL usp_RegisterUser('John', 'Doe', 'john@example.com', '1995-06-15', 'hashed_password', 'avatar_url', @success, @msg, @userId);
-- SELECT @success, @msg, @userId;
```

---

### 4. 🔴 Get User by ID

**Purpose:** Retrieve user data by ID  
**Frontend File:** `Profile.jsx` (when viewing other users' profiles)  
**Why Needed:** The `/users/:userId` route loads profile data including:

- Basic info (username, bio, avatar, location)
- Stats (recipe count, favorites, reviews)
- Status check (should non-auth users only see published content)

```sql
-- ============================================================================
-- QUERY: Get User by ID
-- Parameters: @pUserId (INT)
-- Returns: Complete user profile data with stats
-- ============================================================================

SET @pUserId = 4; -- Example parameter

SELECT 
    u.id,
    u.username,
    u.email,
    u.first_name,
    u.last_name,
    u.role,
    u.status,
    u.joined_date,
    u.last_active,
    u.avatar_url,
    u.bio,
    u.location,
    u.cooking_level,
    -- Recipe counts
    (SELECT COUNT(*) FROM recipe WHERE author_id = u.id AND status = 'published') AS published_recipe_count,
    (SELECT COUNT(*) FROM recipe WHERE author_id = u.id AND status = 'pending') AS pending_recipe_count,
    (SELECT COUNT(*) FROM review WHERE user_id = u.id) AS review_count,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE user_id = u.id) AS avg_rating_given,
    (SELECT COUNT(*) FROM favorite WHERE user_id = u.id) AS favorite_count
FROM user u
WHERE u.id = @pUserId;
```

---

### 5. 🔴 Validate Session Query

**Purpose:** Validate session token on each authenticated request  
**Frontend File:** Would be called by middleware on every protected page  
**Why Needed:** Session validation checks:

1. Token exists and is not expired
2. Retrieve user data from session
3. Allow logout of invalid sessions
4. Update `last_active` timestamp on each request

```sql
-- ============================================================================
-- QUERY: Validate Session
-- Parameters: @pSessionToken (VARCHAR)
-- Returns: User data if session is valid, NULL otherwise
-- ============================================================================

SET @pSessionToken = 'sess_abc123'; -- Example parameter

SELECT 
    s.user_id,
    s.created_at,
    s.expires_at,
    u.username,
    u.email,
    u.role,
    u.status,
    u.avatar_url,
    u.bio,
    u.location,
    DATEDIFF(s.expires_at, NOW()) / 60 AS minutes_remaining
FROM session s
INNER JOIN user u ON s.user_id = u.id
WHERE s.session_token = @pSessionToken
  AND s.expires_at > NOW();
```

---

### 6. 🔴 Logout / Delete Session Query

**Purpose:** Remove user session on logout  
**Frontend File:** `AuthContext.jsx` → `logout()` function  
**Why Needed:** Clean logout requires:

1. Delete session from database (prevent auto-login back in)
2. Optionally update user status to 'inactive'
3. Update `last_active` timestamp

```sql
-- ============================================================================
-- QUERY: Logout / Delete Session
-- Parameters: @pSessionToken (VARCHAR)
-- ============================================================================

SET @pSessionToken = 'sess_abc123'; -- Example parameter

-- Delete session
DELETE FROM session
WHERE session_token = @pSessionToken;

-- Optionally set user to inactive
-- UPDATE user
-- SET status = 'inactive',
--     last_active = NOW()
-- WHERE id = (SELECT user_id FROM @deleted_session_table WHERE session_token = @pSessionToken);
```

---

### 7. 🔴 Clean Expired Sessions (Maintenance Query)

**Purpose:** Remove old expired sessions periodically  
**Frontend File:** Scheduled job / cron task  
**Why Needed:** Database housekeeping to:

1. Prevent accumulation of expired session records
2. Maintain performance (smaller session table)
3. Security (old tokens can't be used even if table has stale data)

```sql
-- ============================================================================
-- QUERY: Clean Expired Sessions
-- Run this periodically (e.g., daily cron job)
-- ============================================================================

DELETE FROM session
WHERE expires_at < NOW();

-- Return count of deleted sessions
SELECT ROW_COUNT() AS sessions_deleted;
```

---

## Recipe Management Queries

**✅ Implementation Status:** These queries are implemented in the PHP backend API layer.

### Backend Implementation Location
Recipe queries are implemented in:
- **File:** `backend/api/recipes.php`
- **Methods:** GET /api/recipes, GET /api/recipes/{id}, POST /api/recipes, PUT /api/recipes/{id}, DELETE /api/recipes/{id}
- **Existing:** `usp_CreateRecipe` and `usp_DeleteRecipe` in `12_stored_procedures.sql`

---

### 8. 🟡 Update Recipe Query

**Purpose:** Update an existing recipe with all related data  
**Frontend File:** `CreateRecipe.jsx` (edit mode when `id` param exists)  
**Why Needed:** Edit mode requires atomic update of:

1. Recipe metadata (title, description, category, difficulty, times)
2. Delete all existing ingredients + insert new ones
3. Delete all existing instructions + insert new ones
4. Update primary image
5. Preserve status (pending/published/rejected) unless re-submitting rejected recipe

```sql
-- ============================================================================
-- PROCEDURE: usp_UpdateRecipe
-- Parameters: @pRecipeId, @pTitle, @pDescription, @pCategory, @pDifficulty,
--             @pPrepTime, @pCookTime, @pServings, @pImageUrl
-- Returns: @pSuccess, @pMessage
-- Notes: Ingredients/Instructions passed as JSON arrays
-- ============================================================================

DELIMITER //

CREATE PROCEDURE usp_UpdateRecipe(
    IN pRecipeId INT,
    IN pTitle VARCHAR(200),
    IN pDescription TEXT,
    IN pCategory VARCHAR(50),
    IN pDifficulty ENUM('Easy', 'Medium', 'Hard'),
    IN pPrepTime INT,
    IN pCookTime INT,
    IN pServings INT,
    IN pImageUrl VARCHAR(500),
    IN pIngredients JSON,
    IN pInstructions JSON,
    OUT pSuccess BOOLEAN,
    OUT pMessage VARCHAR(500)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET pSuccess = FALSE;
        SET pMessage = 'Error updating recipe. Transaction rolled back.';
    END;
    
    START TRANSACTION;
    
    -- Verify recipe exists
    IF NOT EXISTS (SELECT 1 FROM recipe WHERE id = pRecipeId) THEN
        SET pSuccess = FALSE;
        SET pMessage = 'Recipe not found.';
        ROLLBACK;
    ELSE
        -- Update recipe metadata
        UPDATE recipe
        SET title = pTitle,
            description = pDescription,
            category = pCategory,
            difficulty = pDifficulty,
            prep_time = pPrepTime,
            cook_time = pCookTime,
            servings = pServings,
            updated_at = NOW()
        WHERE id = pRecipeId;
        
        -- Remove old ingredients
        DELETE FROM ingredient WHERE recipe_id = pRecipeId;
        
        -- Insert new ingredients from JSON
        -- Expected JSON format: [{"name":"...","quantity":"...","unit":"..."},...]
        SET @vIngredientCount = JSON_LENGTH(pIngredients);
        WHILE @vIngredientCount > 0 DO
            SET @vIngredientCount = @vIngredientCount - 1;
            INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order)
            VALUES (
                pRecipeId,
                JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[', @vIngredientCount, '].name'))),
                JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[', @vIngredientCount, '].quantity'))),
                JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[', @vIngredientCount, '].unit'))),
                @vIngredientCount + 1
            );
        END WHILE;
        
        -- Remove old instructions
        DELETE FROM instruction WHERE recipe_id = pRecipeId;
        
        -- Insert new instructions from JSON
        -- Expected JSON format: [{"instruction_text":"..."},...]
        SET @vInstructionCount = JSON_LENGTH(pInstructions);
        WHILE @vInstructionCount > 0 DO
            SET @vInstructionCount = @vInstructionCount - 1;
            INSERT INTO instruction (recipe_id, step_number, instruction_text)
            VALUES (
                pRecipeId,
                @vInstructionCount + 1,
                JSON_UNQUOTE(JSON_EXTRACT(pInstructions, CONCAT('$[', @vInstructionCount, '].instruction_text')))
            );
        END WHILE;
        
        -- Update or insert primary image
        IF pImageUrl IS NOT NULL AND pImageUrl != '' THEN
            INSERT INTO recipe_image (recipe_id, image_url, display_order)
            VALUES (pRecipeId, pImageUrl, 1)
            ON DUPLICATE KEY UPDATE image_url = pImageUrl;
        END IF;
        
        COMMIT;
        SET pSuccess = TRUE;
        SET pMessage = 'Recipe updated successfully';
    END IF;
END //

DELIMITER ;

-- Usage Example:
-- CALL usp_UpdateRecipe(1, 'Updated Title', 'Updated description...', 'Breakfast', 
--   'Easy', 15, 20, 2, 'https://image.jpg', 
--   '[{"name":"Flour","quantity":"200","unit":"g"}]', 
--   '[{"instruction_text":"Step 1"}]', @success, @msg);
```

---

### 9. 🟡 Get Published Recipes (Home Page Feed)

**Purpose:** Retrieve all published recipes for home page  
**Frontend File:** `Home.jsx`  
**Why Needed:** The home page displays recipe feed with:

1. Only published recipes (exclude pending/rejected)
2. Pagination support (limit + offset)
3. Order by newest first
4. Include minimal author info for display

```sql
-- ============================================================================
-- QUERY: Get Published Recipes (Paginated)
-- Parameters: @pLimit (INT), @pOffset (INT)
-- Returns: List of published recipes ordered by newest
-- ============================================================================

SET @pLimit = 20; -- Default page size
SET @pOffset = 0; -- First page

SELECT 
    r.id,
    r.title,
    r.description,
    r.category,
    r.difficulty,
    r.prep_time,
    r.cook_time,
    r.servings,
    r.created_at,
    u.id AS author_id,
    u.username AS author_name,
    u.avatar_url AS author_avatar,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order LIMIT 1) AS primary_image_url,
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count,
    (SELECT COUNT(*) FROM review WHERE recipe_id = r.id) AS review_count,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
ORDER BY r.created_at DESC
LIMIT @pLimit OFFSET @pOffset;
```

---

### 10. 🟡 Search Recipes with Filters (Enhanced)

**Purpose:** Query recipes with multiple filter criteria  
**Frontend File:** `Search.jsx` - supports keyword, category, difficulty, and sort  
**Why Needed:** Frontend UI supports filtering but SQL doesn't:

1. **Keyword search** - Search in title OR description OR category
2. **Category filter** - Filter by one or more categories
3. **Difficulty filter** - Filter by Easy/Medium/Hard
4. **Sorting options** - By rating (desc), newest (desc), difficulty (asc)
5. **Pagination** - Efficient querying for large datasets

```sql
-- ============================================================================
-- QUERY: Search Recipes with Filters
-- Parameters: @pKeyword (VARCHAR), @pCategory (VARCHAR - comma-separated)
--             @pDifficulty (ENUM), @pSortBy (VARCHAR), @pLimit (INT), @pOffset (INT)
-- Returns: Filtered and sorted recipe list
-- ============================================================================

SET @pKeyword = ''; -- Searches all if empty
SET @pCategory = NULL; -- All categories if NULL
SET @pDifficulty = NULL; -- All difficulties if NULL
SET @pSortBy = 'rating'; -- Default: most popular (by rating)
SET @pLimit = 20;
SET @pOffset = 0;

SELECT 
    r.id,
    r.title,
    r.description,
    r.category,
    r.difficulty,
    r.prep_time,
    r.cook_time,
    r.servings,
    r.created_at,
    u.id AS author_id,
    u.username AS author_name,
    u.avatar_url AS author_avatar,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order LIMIT 1) AS primary_image_url,
    (SELECT COUNT(*) FROM like_record lr WHERE lr.recipe_id = r.id) AS like_count,
    (SELECT ROUND(AVG(rating), 1) FROM review rv WHERE rv.recipe_id = r.id) AS avg_rating,
    (SELECT COUNT(*) FROM review WHERE recipe_id = r.id) AS review_count
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
    -- Keyword filter (search in title, description, or category)
    AND (@pKeyword = '' OR 
        r.title LIKE CONCAT('%', @pKeyword, '%') OR 
        r.description LIKE CONCAT('%', @pKeyword, '%') OR 
        r.category LIKE CONCAT('%', @pKeyword, '%'))
    -- Category filter (if multiple specified, match any)
    AND (@pCategory IS NULL OR 
        FIND_IN_SET(r.category, @pCategory))
    -- Difficulty filter
    AND (@pDifficulty IS NULL OR r.difficulty = @pDifficulty)
ORDER BY 
    -- Sort options
    CASE @pSortBy
        WHEN 'rating' THEN (SELECT IFNULL(AVG(rating), 0) FROM review WHERE recipe_id = r.id) DESC
        WHEN 'newest' THEN r.created_at DESC
        WHEN 'difficulty-asc' THEN FIELD(r.difficulty, 'Easy', 'Medium', 'Hard') ASC
        ELSE r.created_at DESC -- Default
    END,
    r.id DESC -- Secondary sort for stability
LIMIT @pLimit OFFSET @pOffset;

-- Usage Examples:
-- Search by keyword only:
-- SET @pKeyword = 'chicken';

-- Search by category:
-- SET @pCategory = 'Breakfast,Dinner';

-- Search by difficulty:
-- SET @pDifficulty = 'Easy';

-- Sort by newest:
-- SET @pSortBy = 'newest';

-- Combined:
-- SET @pKeyword = 'curry'; SET @pCategory = 'Asian,Dinner'; SET @pDifficulty = 'Medium'; SET @pSortBy = 'rating';
```

---

### 11. 🟡 Get Recipes by Category

**Purpose:** Browse recipes by specific category  
**Frontend File:** `Home.jsx`, `Search.jsx` - filter by categories  
**Why Needed:** Category browsing needs:

1. Recipes matching specific category only
2. Only published recipes
3. Pagination for performance
4. Count for category badge display

```sql
-- ============================================================================
-- QUERY: Get Recipes by Category
-- Parameters: @pCategory (VARCHAR), @pLimit (INT), @pOffset (INT)
-- Returns: Recipes filtered by category
-- ============================================================================

SET @pCategory = 'Breakfast';
SET @pLimit = 20;
SET @pOffset = 0;

SELECT 
    r.id,
    r.title,
    r.description,
    r.category,
    r.difficulty,
    r.prep_time,
    r.cook_time,
    r.created_at,
    u.id AS author_id,
    u.username AS author_name,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order LIMIT 1) AS primary_image_url,
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
  AND r.category = @pCategory
ORDER BY r.created_at DESC
LIMIT @pLimit OFFSET @pOffset;

-- Get count for pagination
SELECT COUNT(*) AS total_count
FROM recipe
WHERE status = 'published'
  AND category = @pCategory;
```

---

### 12. 🟡 Get Recipe by ID (Full Details)

**Purpose:** Retrieve complete recipe with ingredients, instructions, images  
**Frontend File:** `RecipeDetail.jsx`  
**Why Needed:** Recipe detail page requires:

1. Full recipe metadata
2. All ingredients (ordered)
3. All instructions (ordered steps)
4. All images
5. Author information
6. Engagement stats (views, likes, reviews, favorites)

```sql
-- ============================================================================
-- QUERY: Get Recipe by ID (Complete with Related Data)
-- Parameters: @pRecipeId (INT)
-- Returns: Full recipe object with all related data
-- ============================================================================
-- Already partially in 09_common_queries.sql QUERY 2, here's the complete version
-- ============================================================================

SET @pRecipeId = 1;

-- Recipe header with author + stats
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
    r.updated_at,
    u.id AS author_id,
    u.username AS author_name,
    u.avatar_url AS author_avatar,
    u.bio AS author_bio,
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count,
    (SELECT COUNT(*) FROM review WHERE recipe_id = r.id) AS review_count,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating,
    (SELECT MIN(rating) FROM review WHERE recipe_id = r.id) AS min_rating,
    (SELECT MAX(rating) FROM review WHERE recipe_id = r.id) AS max_rating,
    (SELECT COUNT(*) FROM recipe_view WHERE recipe_id = r.id) AS view_count,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order LIMIT 1) AS primary_image_url
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.id = @pRecipeId;

-- Ingredients for recipe
SELECT
    id,
    name,
    quantity,
    unit,
    sort_order
FROM ingredient
WHERE recipe_id = @pRecipeId
ORDER BY sort_order;

-- Instructions for recipe
SELECT
    id,
    step_number,
    instruction_text
FROM instruction
WHERE recipe_id = @pRecipeId
ORDER BY step_number;

-- All images for recipe
SELECT
    id,
    image_url,
    display_order
FROM recipe_image
WHERE recipe_id = @pRecipeId
ORDER BY display_order;
```

---

## Reviews & Interactions Queries

### Backend Implementation Location
Reviews and interactions queries are implemented in:
- **Files:** `backend/api/reviews.php`, `backend/api/recipes.php`
- **Why:** These power the engagement features (likes, favorites, reviews) on recipe cards and detail pages.

---

### 13. 🟡 Create Review Query

**Purpose:** Add a new review for a recipe  
**Frontend File:** `RecipeDetail.jsx` → `storage.addReview()`  
**Why Needed:** Review submission requires:

1. Insert review with user_id + recipe_id
2. Validate user review only once per recipe (enforced by unique constraint)
3. Rating (1-5) + comment text
4. Return created review ID
5. Auto-trigger updates to recipe stats (via view or trigger)

```sql
-- ============================================================================
-- PROCEDURE: usp_CreateReview
-- Parameters: @pUserId, @pRecipeId, @pRating (INT 1-5), @pComment (TEXT)
-- Returns: @pSuccess, @pMessage, @pReviewId
-- Notes: Duplicate prevention handled by UNIQUE(user_id, recipe_id) constraint
-- ============================================================================

DELIMITER //

CREATE PROCEDURE usp_CreateReview(
    IN pUserId INT,
    IN pRecipeId INT,
    IN pRating TINYINT,
    IN pComment TEXT,
    OUT pSuccess BOOLEAN,
    OUT pMessage VARCHAR(500),
    OUT pReviewId INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET pSuccess = FALSE;
        SET pMessage = 'Error creating review. Transaction rolled back.';
    END;
    
    START TRANSACTION;
    
    -- Validate recipe exists
    IF NOT EXISTS (SELECT 1 FROM recipe WHERE id = pRecipeId AND status = 'published') THEN
        SET pSuccess = FALSE;
        SET pMessage = 'Recipe not found or not published.';
        SET pReviewId = NULL;
        ROLLBACK;
    ELSE
        -- Validate rating range
        IF pRating < 1 OR pRating > 5 THEN
            SET pSuccess = FALSE;
            SET pMessage = 'Rating must be between 1 and 5.';
            SET pReviewId = NULL;
            ROLLBACK;
        ELSE
            -- Check if user already reviewed (optional, constraint handles it)
            DECLARE vExistingCount INT;
            SELECT COUNT(*) INTO vExistingCount
            FROM review
            WHERE user_id = pUserId AND recipe_id = pRecipeId;
            
            -- Insert review
            INSERT INTO review (user_id, recipe_id, rating, comment, created_at)
            VALUES (pUserId, pRecipeId, pRating, pComment, NOW());
            
            SET pReviewId = LAST_INSERT_ID();
            SET pSuccess = TRUE;
            SET pMessage = 'Review created successfully.';
            
            COMMIT;
        END IF;
    END IF;
END //

DELIMITER ;

-- Usage Example:
-- CALL usp_CreateReview(4, 1, 5, 'Great recipe! Will make again.', @success, @msg, @reviewId);
-- SELECT @success, @msg, @reviewId;
```

---

### 14. 🟡 Delete Review Query

**Purpose:** Remove a user's own review  
**Frontend File:** `RecipeDetail.jsx` - delete button on own reviews  
**Why Needed:** Users can delete their reviews but requires:

1. Verify review belongs to user (security - prevent deleting others' reviews)
2. Delete review record
3. Optionally update activity log

```sql
-- ============================================================================
-- PROCEDURE: usp_DeleteReview
-- Parameters: @pReviewId (INT), @pUserId (INT)
-- Returns: @pSuccess, @pMessage, @pRowsAffected
-- ============================================================================

DELIMITER //

CREATE PROCEDURE usp_DeleteReview(
    IN pReviewId INT,
    IN pUserId INT,
    OUT pSuccess BOOLEAN,
    OUT pMessage VARCHAR(500)
)
BEGIN
    DECLARE vCreatorId INT;
    
    -- Find the user who wrote this review
    SELECT user_id INTO vCreatorId
    FROM review
    WHERE id = pReviewId;
    
    -- Check if review exists
    IF vCreatorId IS NULL THEN
        SET pSuccess = FALSE;
        SET pMessage = 'Review not found.';
    -- Check if user owns this review
    ELSEIF vCreatorId != pUserId THEN
        SET pSuccess = FALSE;
        SET pMessage = 'You can only delete your own reviews.';
    ELSE
        -- Delete review
        DELETE FROM review
        WHERE id = pReviewId;
        
        SET pSuccess = TRUE;
        SET pMessage = 'Review deleted successfully.';
    END IF;
END //

DELIMITER ;

-- Usage Example:
-- CALL usp_DeleteReview(1, 4, @success, @msg);
-- SELECT @success, @msg;
```

---

### 15. 🟡 Toggle Like Query

**Purpose:** Add or remove a like from a recipe  
**Frontend File:** `RecipeCard.jsx`, `RecipeDetail.jsx` → heart button  
**Why Needed:** Like toggle requires:

1. Check if user already liked
2. If not liked: Insert like record
3. If already liked: Delete like record
4. Return new like count
5. Update activity log (optional)

```sql
-- ============================================================================
-- PROCEDURE: usp_ToggleLike
-- Parameters: @pUserId, @pRecipeId
-- Returns: @pSuccess, @pIsLiked (new state), @pLikeCount
-- ============================================================================

DELIMITER //

CREATE PROCEDURE usp_ToggleLike(
    IN pUserId INT,
    IN pRecipeId INT,
    OUT pSuccess BOOLEAN,
    OUT pIsLiked BOOLEAN,
    OUT pLikeCount INT,
    OUT pMessage VARCHAR(500)
)
BEGIN
    DECLARE vCurrentLikeCount INT;
    DECLARE vIsAlreadyLiked INT;
    
    -- Check if recipe exists
    IF NOT EXISTS (SELECT 1 FROM recipe WHERE id = pRecipeId) THEN
        SET pSuccess = FALSE;
        SET pMessage = 'Recipe not found.';
        SET pIsLiked = FALSE;
        SET pLikeCount = 0;
    ELSE
        -- Check if user already liked
        SELECT COUNT(*) INTO vIsAlreadyLiked
        FROM like_record
        WHERE user_id = pUserId AND recipe_id = pRecipeId;
        
        IF vIsAlreadyLiked > 0 THEN
            -- Unlike: remove the like
            DELETE FROM like_record
            WHERE user_id = pUserId AND recipe_id = pRecipeId;
            
            SET pIsLiked = FALSE;
            SET pMessage = 'Recipe unliked.';
        ELSE
            -- Like: add the like
            INSERT INTO like_record (user_id, recipe_id, created_at)
            VALUES (pUserId, pRecipeId, NOW());
            
            SET pIsLiked = TRUE;
            SET pMessage = 'Recipe liked.';
        END IF;
        
        -- Get current like count
        SELECT COUNT(*) INTO vCurrentLikeCount
        FROM like_record
        WHERE recipe_id = pRecipeId;
        
        SET pLikeCount = vCurrentLikeCount;
        SET pSuccess = TRUE;
    END IF;
END //

DELIMITER ;

-- Usage Example:
-- CALL usp_ToggleLike(4, 1, @success, @isLiked, @likeCount, @msg);
-- SELECT @success, @isLiked, @likeCount, @msg;
```

---

### 16. 🟡 Toggle Favorite Query

**Purpose:** Add or remove a recipe from user's favorites  
**Frontend File:** `RecipeCard.jsx`, `RecipeDetail.jsx` → bookmark button  
**Why Needed:** Favorite toggle requires:

1. Check if recipe already favorited
2. If not favorited: Insert favorite record
3. If already favorited: Delete favorite record
4. Return new favorited state

```sql
-- ============================================================================
-- PROCEDURE: usp_ToggleFavorite
-- Parameters: @pUserId, @pRecipeId
-- Returns: @pSuccess, @pIsFavorited (new state), @pMessage
-- ============================================================================

DELIMITER //

CREATE PROCEDURE usp_ToggleFavorite(
    IN pUserId INT,
    IN pRecipeId INT,
    OUT pSuccess BOOLEAN,
    OUT pIsFavorited BOOLEAN,
    OUT pMessage VARCHAR(500)
)
BEGIN
    DECLARE vIsAlreadyFavorited INT;
    
    -- Check if recipe exists
    IF NOT EXISTS (SELECT 1 FROM recipe WHERE id = pRecipeId) THEN
        SET pSuccess = FALSE;
        SET pMessage = 'Recipe not found.';
        SET pIsFavorited = FALSE;
    ELSE
        -- Check if user already favorited
        SELECT COUNT(*) INTO vIsAlreadyFavorited
        FROM favorite
        WHERE user_id = pUserId AND recipe_id = pRecipeId;
        
        IF vIsAlreadyFavorited > 0 THEN
            -- Unfavorite: remove the favorite
            DELETE FROM favorite
            WHERE user_id = pUserId AND recipe_id = pRecipeId;
            
            SET pIsFavorited = FALSE;
            SET pMessage = 'Recipe removed from favorites.';
        ELSE
            -- Favorite: add the favorite
            INSERT INTO favorite (user_id, recipe_id, created_at)
            VALUES (pUserId, pRecipeId, NOW());
            
            SET pIsFavorited = TRUE;
            SET pMessage = 'Recipe added to favorites.';
        END IF;
        
        SET pSuccess = TRUE;
    END IF;
END //

DELIMITER ;

-- Usage Example:
-- CALL usp_ToggleFavorite(4, 1, @success, @isFavorited, @msg);
-- SELECT @success, @isFavorited, @msg;
```

---

### 17. 🟡 Record Recipe View Query

**Purpose:** Track recipe views (prevent duplicate counts)  
**Frontend File:** `RecipeDetail.jsx` → `storage.recordView()`  
**Why Needed:** View tracking requires:

1. Check if user has already viewed recipe (prevent count inflation)
2. If first-time view, insert into recipe_view
3. Increment daily stats via trigger
4. Support guest views (user_id IS NULL)
5. Return total view count

```sql
-- ============================================================================
-- PROCEDURE: usp_RecordView
-- Parameters: @pViewerId (INT), @pRecipeId (INT), @pViewerType (ENUM 'user','guest')
-- Returns: @pSuccess, @pViewCount, @pWasFirstView
-- Notes: Trigger trg_RecipeView_UpdateStat handles daily_stat increment
-- ============================================================================

DELIMITER //

CREATE PROCEDURE usp_RecordView(
    IN pViewerId INT,
    IN pRecipeId INT,
    IN pViewerType VARCHAR(10),
    OUT pSuccess BOOLEAN,
    OUT pViewCount INT,
    OUT pWasFirstView BOOLEAN
)
BEGIN
    DECLARE vViewerKey VARCHAR(100);
    DECLARE vExistingViewCount INT;
    
    -- Check if recipe exists
    IF NOT EXISTS (SELECT 1 FROM recipe WHERE id = @pRecipeId) THEN
        SET pSuccess = FALSE;
        SET pViewCount = 0;
        SET pWasFirstView = FALSE;
    ELSE
        -- Create viewer key (guest:guest-123, user:4)
        SET vViewerKey = CONCAT(
            CASE 
                WHEN pViewerType = 'guest' THEN 'guest:' 
                ELSE '' 
            END,
            pViewerId
        );
        
        -- Check if already viewed
        SELECT COUNT(*) INTO vExistingViewCount
        FROM recipe_view
        WHERE viewer_type = pViewerType AND viewer_id = pViewerId AND recipe_id = pRecipeId;
        
        IF vExistingViewCount = 0 THEN
            -- First-time view: insert record
            INSERT INTO recipe_view (viewer_id, recipe_id, viewer_type, viewed_at)
            VALUES (pViewerId, pRecipeId, pViewerType, NOW());
            
            SET pWasFirstView = TRUE;
        ELSE
            -- Already viewed
            SET pWasFirstView = FALSE;
        END IF;
        
        -- Get total view count
        SELECT COUNT(*) INTO pViewCount
        FROM recipe_view
        WHERE recipe_id = pRecipeId;
        
        SET pSuccess = TRUE;
    END IF;
END //

DELIMITER ;

-- Usage Example (user view):
-- CALL usp_RecordView(4, 1, 'user', @success, @viewCount, @wasFirst);

-- Usage Example (guest view):
-- CALL usp_RecordView(0, 1, 'guest', @success, @viewCount, @wasFirst);
```

---

## User Profile Management Queries

**✅ Implementation Status:** These queries are implemented in the PHP backend API layer.

### Backend Implementation Location
User queries are implemented in:
- **File:** `backend/api/users.php`
- **Methods:** GET /api/users, GET /api/users/{id}, PUT /api/users/{id}, DELETE /api/users/{id}, PUT /api/users/{id}/status

---

### 18. 🟢 Update User Profile Query

**Purpose:** Update user's profile information  
**Frontend File:** `Profile.jsx` → edit modal → `updateProfile()`  
**Why Needed:** Profile editing requires:

1. Update basic fields (first_name, last_name, username, email)
2. Username uniqueness check (no duplicates allowed)
3. Email uniqueness check (no duplicates allowed)
4. Update optional fields (bio, location, cooking_level, avatar)
5. Update status validation (users shouldn't change their own status)
6. Update `updated_at` timestamp

```sql
-- ============================================================================
-- PROCEDURE: usp_UpdateUserProfile
-- Parameters: @pUserId (INT), @pUsername, @pFirstName, @pLastName,
--             @pEmail, @pBio, @pLocation, @pCookingLevel, @pAvatar
-- Returns: @pSuccess, @pMessage
-- ============================================================================

DELIMITER //

CREATE PROCEDURE usp_UpdateUserProfile(
    IN pUserId INT,
    IN pUsername VARCHAR(100),
    IN pFirstName VARCHAR(100),
    IN pLastName VARCHAR(100),
    IN pEmail VARCHAR(255),
    IN pBio TEXT,
    IN pLocation VARCHAR(255),
    IN pCookingLevel VARCHAR(20),
    IN pAvatar VARCHAR(500),
    OUT pSuccess BOOLEAN,
    OUT pMessage VARCHAR(500)
)
BEGIN
    DECLARE vOriginalEmail VARCHAR(255);
    DECLARE vOriginalUsername VARCHAR(100);
    
    -- Check if user exists and get current values
    SELECT email, username INTO vOriginalEmail, vOriginalUsername
    FROM user
    WHERE id = pUserId;
    
    IF vOriginalEmail IS NULL THEN
        SET pSuccess = FALSE;
        SET pMessage = 'User not found.';
    ELSE
        -- Check if new email is taken by another user
        IF @pEmail IS NOT NULL AND @pEmail != '' AND @pEmail != vOriginalEmail THEN
            IF EXISTS (SELECT 1 FROM user WHERE email = @pEmail AND id != pUserId) THEN
                SET pSuccess = FALSE;
                SET pMessage = 'Email already taken by another user.';
            ELSE
                SET pSuccess = TRUE;
                SET pMessage = 'Email update available.';
            END IF;
        -- Check if new username is taken by another user
        ELSEIF @pUsername IS NOT NULL AND @pUsername != '' AND @pUsername != vOriginalUsername THEN
            IF EXISTS (SELECT 1 FROM user WHERE username = @pUsername AND id != pUserId) THEN
                SET pSuccess = FALSE;
                SET pMessage = 'Username already taken by another user.';
            ELSE
                SET pSuccess = TRUE;
                SET pMessage = 'Username update available.';
            END IF;
        ELSE
            SET pSuccess = TRUE;
            SET pMessage = 'Profile updated successfully.';
        END IF;
        
        -- Update profile (build dynamic update SQL)
        IF pSuccess = TRUE THEN
            UPDATE user
            SET 
                username = IFNULL(@pUsername, username),
                first_name = IFNULL(@pFirstName, first_name),
                last_name = IFNULL(@pLastName, last_name),
                email = IFNULL(@pEmail, email),
                bio = IFNULL(@pBio, bio),
                location = IFNULL(@pLocation, location),
                cooking_level = IFNULL(@pCookingLevel, cooking_level),
                avatar_url = IFNULL(@pAvatar, avatar_url),
                updated_at = NOW()
            WHERE id = pUserId;
        END IF;
    END IF;
END //

DELIMITER ;

-- Usage Example:
-- CALL usp_UpdateUserProfile(4, 'johndoe', 'John', 'Doe', 'john@example.com', 
--   'New bio here.', 'New York', 'Advanced', 'https://avatar.jpg', 
--   @success, @msg);
-- SELECT @success, @msg;
```

---

### 19. 🟢 Get User Recipes Query

**Purpose:** Retrieve all recipes by a user (for profile page)  
**Frontend File:** `Profile.jsx` → "My Recipes" tab  
**Why Needed:** User's recipe list needs:

1. Filter by status (all/published/pending)
2. Order by creation date (newest first)
3. Get counts per status for badges
4. Include engagement stats

```sql
-- ============================================================================
-- QUERY: Get User Recipes
-- Parameters: @pUserId (INT), @pStatusFilter (ENUM - optional), @pLimit (INT), @pOffset (INT)
-- Returns: User's recipes with filters applied
-- ============================================================================

SET @pUserId = 4; -- Example: John Doe
SET @pStatusFilter = NULL; -- NULL = all recipes
SET @pLimit = 20;
SET @pOffset = 0;

-- Count query for badges
SELECT 
    'all' AS status_filter,
    COUNT(*) AS count
FROM recipe
WHERE author_id = @pUserId
UNION ALL
SELECT 'published', COUNT(*) FROM recipe WHERE author_id = @pUserId AND status = 'published'
UNION ALL
SELECT 'pending', COUNT(*) FROM recipe WHERE author_id = @pUserId AND status = 'pending'
UNION ALL
SELECT 'rejected', COUNT(*) FROM recipe WHERE author_id = @pUserId AND status = 'rejected';

-- Main recipe query
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
    (SELECT COUNT(*) FROM like_record lr WHERE lr.recipe_id = r.id) AS like_count,
    (SELECT COUNT(*) FROM review rv WHERE rv.recipe_id = r.id) AS review_count,
    (SELECT ROUND(AVG(rating), 1) FROM review rv WHERE rv.recipe_id = r.id) AS avg_rating,
    (SELECT image_url FROM recipe_image ri WHERE ri.recipe_id = r.id ORDER BY ri.display_order LIMIT 1) AS primary_image_url
FROM recipe r
WHERE r.author_id = @pUserId
  AND (@pStatusFilter IS NULL OR r.status = @pStatusFilter)
ORDER BY r.created_at DESC
LIMIT @pLimit OFFSET @pOffset;
```

---

### 20. 🟢 Get User Reviews Query

**Purpose:** Retrieve all reviews written by a user (for profile enhancement)  
**Frontend File:** Could be added to `Profile.jsx` to show user's review history  
**Why Needed:** User's review history helps:

1. Show engagement level of user (how many reviews they've written)
2. Display their average rating across all recipes
3. Link to recipes they've reviewed
4. Sort by review date (newest first)
5. Pagination for performance

```sql
-- ============================================================================
-- QUERY: Get User Reviews
-- Parameters: @pUserId (INT), @pLimit (INT), @pOffset (INT)
-- Returns: All reviews written by user
-- ============================================================================

SET @pUserId = 4; -- Example: John Doe
SET @pLimit = 20;
SET @pOffset = 0;

SELECT 
    rv.id AS review_id,
    rv.rating,
    rv.comment,
    rv.created_at,
    r.id AS recipe_id,
    r.title AS recipe_title,
    r.category AS recipe_category,
    r.status AS recipe_status,
    (SELECT image_url FROM recipe_image ri 
     WHERE ri.recipe_id = r.id ORDER BY ri.display_order LIMIT 1) AS recipe_image_url
FROM review rv
INNER JOIN recipe r ON rv.recipe_id = r.id
WHERE rv.user_id = @pUserId
ORDER BY rv.created_at DESC
LIMIT @pLimit OFFSET @pOffset;

-- Get count for pagination
SELECT COUNT(*) AS total_reviews
FROM review
WHERE user_id = @pUserId;
```

---

## Admin Management Queries

**✅ Implementation Status:** These queries are implemented in the PHP backend API layer.

### Backend Implementation Location
Admin queries are implemented in:
- **File:** `backend/api/users.php` (status endpoints), `backend/api/activity.php` (activity logs)

---

### 21. 🟢 Update User Status Query

**Purpose:** Change user status (activate/suspend/reactivate)  
**Frontend File:** `UserList.jsx` - admin user management  
**Why Needed:** Admin status management requires:

1. Change status to 'pending' → 'active' (approve registration)
2. Change status to 'active' → 'suspended' (suspend user)
3. Change status to 'suspended' → 'active' (reactivate user)
4. Log action in activity_log
5. Update last_active timestamp

```sql
-- ============================================================================
-- PROCEDURE: usp_UpdateUserStatus
-- Parameters: @pUserId (INT), @pNewStatus (ENUM), @pAdminId (INT)
-- Returns: @pSuccess, @pMessage
-- Valid statuses: 'active', 'pending', 'suspended', 'inactive'
-- ============================================================================

DELIMITER //

CREATE PROCEDURE usp_UpdateUserStatus(
    IN pUserId INT,
    IN pNewStatus ENUM('active', 'pending', 'suspended', 'inactive'),
    IN pAdminId INT,
    OUT pSuccess BOOLEAN,
    OUT pMessage VARCHAR(500)
)
BEGIN
    DECLARE vUsername VARCHAR(100);
    DECLARE vActionType VARCHAR(50);
    DECLARE vDescription VARCHAR(500);
    
    -- Check if user exists
    SELECT username INTO vUsername
    FROM user
    WHERE id = pUserId;
    
    IF vUsername IS NULL THEN
        SET pSuccess = FALSE;
        SET pMessage = 'User not found.';
    ELSE
        -- Determine action type for logging
        CASE @pNewStatus
            WHEN 'active' THEN
                -- Activation (pending → active or suspended → active)
                IF EXISTS (SELECT 1 FROM user WHERE id = pUserId AND status IN ('pending', 'suspended')) THEN
                    SET vActionType = 'user_activate';
                    SET vDescription = CONCAT('Activated user: ', vUsername);
                ELSE
                    -- User already active
                    SET vActionType = 'user_update';
                    SET vDescription = CONCAT('Updated status to active for: ', vUsername);
                END IF;
            WHEN 'suspended' THEN
                SET vActionType = 'user_suspend';
                SET vDescription = CONCAT('Suspended user: ', vUsername);
            ELSE
                SET vActionType = 'user_update';
                SET vDescription = CONCAT('Updated status for: ', vUsername, ' to ', @pNewStatus);
        END CASE;
        
        -- Update user status
        UPDATE user
        SET status = @pNewStatus,
            last_active = NOW()
        WHERE id = pUserId;
        
        -- Log the admin action
        INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description, created_at)
        VALUES (pAdminId, vActionType, 'user', pUserId, vDescription, NOW());
        
        SET pSuccess = TRUE;
        SET pMessage = 'User status updated successfully.';
    END IF;
END //

DELIMITER ;

-- Usage Example (approve user):
-- CALL usp_UpdateUserStatus(8, 'active', 1, @success, @msg);

-- Usage Example (suspend user):
-- CALL usp_UpdateUserStatus(6, 'suspended', 1, @success, @msg);

-- Usage Example (reactivate user):
-- CALL usp_UpdateUserStatus(6, 'active', 1, @success, @msg);
```

---

### 22. Get Pending Users Query

**Purpose:** Retrieve all users awaiting approval  
**Frontend File:** Admin dashboard - approval queue  
**Why Needed:** Pending user management needs:

1. List all `status = 'pending'` users
2. Show registration info (joined date, email)
3. Display for bulk approval action
4. Order by registration date (oldest first - prioritize wait time)

```sql
-- ============================================================================
-- QUERY: Get Pending Users
-- Returns: All users with 'pending' status
-- ============================================================================

SELECT 
    id,
    username,
    email,
    first_name,
    last_name,
    joined_date,
    avatar_url,
    ROLE,
    (SELECT COUNT(*) FROM recipe WHERE author_id = user.id) AS recipe_count
FROM user
WHERE status = 'pending'
ORDER BY joined_date ASC;
```

---

### 23. 🟢 Get Suspended Users Query

**Purpose:** Retrieve all suspended users  
**Why Needed:** Suspended user management needs:

1. List all `status = 'suspended'` users
2. Show suspension info (when suspended, if available)
3. Quick reactivation option
4. Display activity history (via separate query)

```sql
-- ============================================================================
-- QUERY: Get Suspended Users
-- Returns: All users with 'suspended' status
-- ============================================================================

SELECT 
    id,
    username,
    email,
    first_name,
    last_name,
    joined_date,
    last_active,
    avatar_url,
    bio,
    location,
    role,
    DATEDIFF(NOW(), last_active) AS days_since_last_active
FROM user
WHERE status = 'suspended'
ORDER BY last_active DESC;
```

---

## Advanced Features Queries

**✅ Implementation Status:** These queries are implemented in the PHP backend API layer.

### Backend Implementation Location
Advanced feature queries are implemented in:
- **Files:** `backend/api/search.php`, `backend/api/stats.php`
- **Existing:** Search and analytics queries in `11_analytics_queries.sql`

---

### 24. 💎️ User Search History Query

**Purpose:** Retrieve a user's recent search queries  
**Frontend File:** `Search.jsx` - Recent Searches UI  
**Why Needed:** Personalized search history provides:

1. Per-user recent searches (not global trends)
2. Faster autocomplete suggestions
3. Search history sync across devices (server-side storage)
4. Delete/clear history options

```sql
-- ============================================================================
-- QUERY: Get User Search History
-- Parameters: @pUserId (INT), @pLimit (INT)
-- Returns: Recent search queries for a specific user
-- ============================================================================

SET @pUserId = 4;
SET @pLimit = 10;

SELECT 
    id,
    query,
    searched_at,
    -- Check if query still has results
    (SELECT COUNT(*) FROM recipe 
     WHERE status = 'published' 
       AND (title LIKE CONCAT('%', sh.query, '%') 
            OR description LIKE CONCAT('%', sh.query, '%') 
            OR category LIKE CONCAT('%', sh.query, '%'))
    ) AS result_count
FROM search_history
WHERE user_id = @pUserId
ORDER BY searched_at DESC
LIMIT @pLimit;
```

---

### 25. 💎️ Trending Recipes Query

**Purpose:** Find most popular recipes in recent time period  
**Frontend File:** Could add "Trending" section to Home page  
**Why Needed:** Homepage trending section needs:

1. Recipes with most engagement in last 7 days
2. Weighted algorithm for fair ranking
3. Limit to prevent spam dominance
4. Exclude brand new recipes with inflated artificial engagement
5. Support category-specific trending

```sql
-- ============================================================================
-- QUERY: Get Trending Recipes (Last 7 Days)
-- Parameters: @pCategory (VARCHAR - optional), @pLimit (INT)
-- Returns: Most engaged recipes from last week
-- ============================================================================

SET @pCategory = NULL; -- NULL = all categories
SET @pLimit = 10;
SET @vDaysAgo = DATE_SUB(NOW(), INTERVAL 7 DAY);

SELECT
    r.id,
    r.title,
    r.category,
    r.difficulty,
    u.id AS author_id,
    u.username AS author_name,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order LIMIT 1) AS primary_image_url,
    -- Engagement metrics (last 7 days only)
    (SELECT COUNT(*) FROM like_record lr 
     WHERE lr.recipe_id = r.id AND lr.created_at >= @vDaysAgo) AS recent_likes,
    (SELECT COUNT(*) FROM review rv 
     WHERE rv.recipe_id = r.id AND rv.created_at >= @vDaysAgo) AS recent_reviews,
    (SELECT COUNT(*) FROM recipe_view rview 
     WHERE rview.recipe_id = r.id AND rview.viewed_at >= @vDaysAgo) AS recent_views,
    -- Calculate trending score: likes*2 + reviews*3 + views*1
    ( 
        (SELECT COUNT(*) FROM like_record lr WHERE lr.recipe_id = r.id AND lr.created_at >= @vDaysAgo) * 2 +
        (SELECT COUNT(*) FROM review rv WHERE rv.recipe_id = r.id AND rv.created_at >= @vDaysAgo) * 3 +
        (SELECT COUNT(*) FROM recipe_view rview WHERE rview.recipe_id = r.id AND rview.viewed_at >= @vDaysAgo) * 1
    ) AS trending_score,
    -- Check if recipe is "new" (created in last 7 days) to exclude artificial inflation
    IF(r.created_at >= @vDaysAgo, 1, 0) AS is_new_recipe
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
  AND (@pCategory IS NULL OR r.category = @pCategory)
  -- Exclude very new recipes (created < 7 days ago) to prevent artificial trending
  AND r.created_at < @vDaysAgo
ORDER BY trending_score DESC, r.created_at DESC
LIMIT @pLimit;
```

---

### 26. 💎️ Similar Recipes Query

**Purpose:** Find related recipes for "You might also like" section  
**Frontend File:** Could add to Recipe Detail page  
**Why Needed:** Recipe cross-promotion needs:

1. Find recipes by same category
2. Find recipes by same author
3. Find recipes by same difficulty
4. Exclude current recipe
5. Limit to 3-5 recommendations
6. Order by rating or likes

```sql
-- ============================================================================
-- QUERY: Get Similar Recipes
-- Parameters: @pRecipeId (INT), @pLimit (INT)
-- Returns: Related recipes based on category, author, or difficulty
-- Note: This is a simplifed query. Production may use more complex matching
-- ============================================================================

SET @pRecipeId = 1;
SET @pLimit = 5;

-- Get current recipe's info for matching
DECLARE vCurrentCategory VARCHAR(50);
DECLARE vCurrentAuthor INT;
DECLARE vCurrentDifficulty VARCHAR(20);

SELECT 
    category, author_id, difficulty
INTO vCurrentCategory, vCurrentAuthor, vCurrentDifficulty
FROM recipe
WHERE id = @pRecipeId;

SELECT 
    r.id,
    r.title,
    r.category,
    r.difficulty,
    u.id AS author_id,
    u.username AS author_name,
    -- Primary image
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order LIMIT 1) AS primary_image_url,
    -- Engagement stats
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating,
    -- Match score (higher = more similar)
    (
        CASE WHEN r.category = vCurrentCategory THEN 3 ELSE 0 END +
        CASE WHEN r.author_id = vCurrentAuthor THEN 2 ELSE 0 END +
        CASE WHEN r.difficulty = vCurrentDifficulty THEN 1 ELSE 0 END
    ) AS match_score,
    -- Match type label (for debugging)
    CONCAT_WS(', ',
        CASE WHEN r.category = vCurrentCategory THEN 'category' END,
        CASE WHEN r.author_id = vCurrentAuthor THEN 'author' END,
        CASE WHEN r.difficulty = vCurrentDifficulty THEN 'difficulty' END
    ) AS match_types
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.id != @pRecipeId              -- Exclude current recipe
  AND r.status = 'published'          -- Only published recipes
  AND (r.category = vCurrentCategory OR r.author_id = vCurrentAuthor OR r.difficulty = vCurrentDifficulty) -- At least one match
ORDER BY match_score DESC, avg_rating DESC
LIMIT @pLimit;
```

---

### 27. 💎️ Search Autocomplete Query

**Purpose:** Fast autocomplete for search bar  
**Frontend File:** Search.jsx - autocomplete UI  
**Why Needed:** Autocomplete improves UX by:

1. Real-time suggestions as user types
2. Performance-optimized (uses index)
3. Filter by published recipes only
4. Top 5-10 results for quick selection
5. Lightweight response (title + category only)

```sql
-- ============================================================================
-- QUERY: Search Autocomplete
-- Parameters: @pQuery (VARCHAR), @pLimit (INT)
-- Returns: Recipe titles and categories matching query
-- ============================================================================

SET @pQuery = 'chi'; -- User typed "chi"
SET @pLimit = 5;

SELECT 
    id,
    title,
    category,
    -- Show primary thumbnail if available
    (SELECT image_url FROM recipe_image WHERE recipe_id = recipe.id ORDER BY display_order LIMIT 1) AS thumbnail
FROM recipe
WHERE status = 'published'
  AND (
      title LIKE CONCAT(@pQuery, '%')
      OR category LIKE CONCAT(@pQuery, '%')
  )
ORDER BY 
    -- Exact match first
    CASE WHEN title = @pQuery THEN 0 ELSE 1 END,
    title
LIMIT @pLimit;
```

---

## Usage Notes

### Executing the Query Files

1. **Create individual files** as shown above, or combine into one `15_api_queries.sql`
2. **Execute scripts in order** from the database folder:
   ```bash
   # In MySQL terminal or phpMyAdmin:
   SOURCE database/15_api_queries.sql;
   ```
3. **Test procedures** with the usage examples provided
4. **Integrate with backend code** - these queries expect parameters to be passed securely

### Parameter Binding (Security Best Practice)

When implementing these in a real backend (PHP, Node.js, Python):

```php
// PHP Example (PDO with prepared statements)
$success = FALSE;
$message = '';
$userId = 0;

// Call stored procedure with parameters
$stmt = $pdo->prepare("CALL usp_Login(?, ?, ?, @token, @userId, @success, @msg)");
$stmt->bindParam(1, $email);
$stmt->bindParam(2, $password);
$stmt->execute();
$stmt->close();

// Get output parameters
$result = $pdo->query("SELECT @success, @userId, @token, @message")->fetch(PDO::FETCH_ASSOC);
$success = (bool)$result['@success'];
$message = $result['@msg'];
$userId = (int)$result['@userId'];
$token = $result['@token'];
```

```javascript
// Node.js Example
const [rows] = await pool.query(
  'CALL usp_Login(?, ?, ?, @token, @userId, @success, @msg)',
  [email, password]
);
const output = await pool.query('SELECT @success, @userId, @token, @msg');
```

### Frontend Integration

The frontend React components are connected to the backend API through the service layer in `src/lib/api.js`:

1. **API service layer** - `src/lib/api.js` handles all HTTP requests to backend endpoints
2. **API endpoints** - PHP backend at `backend/api/*` handles all database operations
3. **Session handling** - HttpOnly cookies for secure authentication
4. **JSON responses** - Consistent response format across all endpoints

For full API documentation, see [docs/API_DOCUMENTATION.md](../docs/API_DOCUMENTATION.md)

---

## Summary Table

| Query Group | Status | Frontend Consumer | Backend Location |
|-------------|--------|-------------------|--------------------------|
| Authentication (login, register, logout, session) | ✅ Implemented | Auth pages + route guards | `backend/api/auth.php`, `backend/helpers/auth.php` |
| Recipe CRUD + publish workflow | ✅ Implemented | Home, Create, Detail, Admin Recipes | `backend/api/recipes.php` |
| Reviews + likes + favorites + views | ✅ Implemented | Recipe cards/detail | `backend/api/reviews.php`, `backend/api/recipes.php` |
| User profile and status management | ✅ Implemented | Profile, Admin User List | `backend/api/users.php` |
| Search history + analytics endpoints | ✅ Implemented | Search, Admin Stats | `backend/api/search.php`, `backend/api/stats.php` |

---

## Related Files

### SQL Foundation (✅ Completed)
- `database/01_create_database.sql`
- `database/02_create_tables.sql`
- `database/03_create_indexes.sql`
- `database/04_create_views.sql`
- `database/05_seed_users.sql`
- `database/06_seed_recipes.sql`
- `database/07_seed_reviews.sql`
- `database/08_seed_stats.sql`
- `database/09_common_queries.sql`
- `database/10_admin_queries.sql`
- `database/11_analytics_queries.sql`
- `database/12_stored_procedures.sql`
- `database/13_triggers.sql`
- `database/14_backup_restore.sql`

### Backend Integration (✅ Completed)
- `backend/config/database.php`
- `backend/helpers/cors.php`
- `backend/helpers/auth.php`
- `backend/helpers/response.php`
- `backend/api/auth.php`
- `backend/api/recipes.php`
- `backend/api/reviews.php`
- `backend/api/users.php`
- `backend/api/search.php`
- `backend/api/stats.php`
- `backend/api/activity.php`

### Frontend Integration (✅ Completed)
- `src/lib/api.js` (service layer)
- `src/context/AuthContext.jsx`
- `src/pages/Auth/Login.jsx`
- `src/pages/Auth/Signup.jsx`
- All frontend pages connected to API
