-- =============================================================================
-- CookHub Recipe Sharing System — Consolidated Database Script
-- =============================================================================
-- This file consolidates all DDL, DML, and programmatic SQL commands from
-- scripts 01 through 13 (excluding read-only query scripts 09, 10, 11).
--
-- Each command is numbered (e.g., CMD-01, CMD-02, ...) to associate it with
-- the corresponding section and to trace which UI feature or backend API
-- endpoint relies on the underlying database object.
--
-- Sections:
--   01 — Create Database          (CMD-001 to CMD-003)
--   02 — Create Tables            (CMD-004 to CMD-019)
--   03 — Create Indexes           (CMD-020 to CMD-043)
--   04 — Create Views             (CMD-044 to CMD-045)
--   05 — Seed Users               (CMD-046 to CMD-050)
--   06 — Seed Recipes             (CMD-051 to CMD-068)
--   07 — Seed Reviews             (CMD-069 to CMD-071)
--   08 — Seed Stats & Logs        (CMD-072 to CMD-078)
--   12 — Stored Procedures        (CMD-079 to CMD-083)
--   13 — Triggers                 (CMD-084 to CMD-089)
-- =============================================================================


-- =============================================================================
-- SECTION 01 — CREATE DATABASE
-- Source: 01_create_database.sql
-- Purpose: Initialize the cookhub database with UTF-8 support for
--          multilingual recipe content (accented characters, emojis, etc.)
-- UI Link: Entire application depends on this database existing.
-- =============================================================================

-- CMD-001: Drop existing database to allow a clean rebuild
DROP DATABASE IF EXISTS cookhub;

-- CMD-002: Create the cookhub database with full Unicode support (utf8mb4)
CREATE DATABASE cookhub
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- CMD-003: Select the cookhub database for all subsequent commands
USE cookhub;


-- =============================================================================
-- SECTION 02 — CREATE TABLES
-- Source: 02_create_tables.sql
-- Purpose: Define all 13 tables that store users, recipes, reviews,
--          interactions, and analytics data.
-- UI Link: Every page in the application reads from or writes to these tables.
-- =============================================================================

-- CMD-004: Disable foreign key checks to allow dropping tables in any order
SET FOREIGN_KEY_CHECKS = 0;

-- CMD-005: Drop all existing tables (reverse dependency order) for idempotent re-runs
DROP TABLE IF EXISTS `activity_log`;
DROP TABLE IF EXISTS `daily_stat`;
DROP TABLE IF EXISTS `search_history`;
DROP TABLE IF EXISTS `recipe_view`;
DROP TABLE IF EXISTS `like_record`;
DROP TABLE IF EXISTS `favorite`;
DROP TABLE IF EXISTS `review`;
DROP TABLE IF EXISTS `recipe_image`;
DROP TABLE IF EXISTS `instruction`;
DROP TABLE IF EXISTS `ingredient`;
DROP TABLE IF EXISTS `recipe`;
DROP TABLE IF EXISTS `session`;
DROP TABLE IF EXISTS `user`;

-- CMD-006: Create `user` table — stores all registered users (both regular users and admins)
-- UI Link: Login page, Signup page, Profile page, Admin > User List
CREATE TABLE `user` (
    id INT AUTO_INCREMENT PRIMARY KEY,              -- Unique user identifier
    username VARCHAR(100) NOT NULL,                  -- Display name shown on recipes and reviews
    first_name VARCHAR(50) NOT NULL,                 -- User's first name (Profile page)
    last_name VARCHAR(50) NOT NULL,                  -- User's last name (Profile page)
    email VARCHAR(100) NOT NULL,                     -- Login credential, must be unique
    password_hash VARCHAR(255) NOT NULL,             -- Bcrypt-hashed password (never stored plain)
    birthday DATE DEFAULT NULL,                      -- Optional birthday (Profile page)
    role ENUM('admin', 'user') NOT NULL DEFAULT 'user',         -- Determines access level
    status ENUM('active', 'inactive', 'pending', 'suspended')
        NOT NULL DEFAULT 'pending',                  -- Account status (Admin > User List)
    joined_date DATETIME DEFAULT CURRENT_TIMESTAMP,  -- Registration timestamp
    last_active DATETIME DEFAULT NULL,               -- Updated via session trigger
    avatar_url TEXT DEFAULT NULL,                     -- Profile picture URL
    bio TEXT DEFAULT NULL,                            -- Short biography (Profile page)
    location VARCHAR(100) DEFAULT NULL,               -- User location (Profile page)
    cooking_level VARCHAR(50) DEFAULT NULL,            -- Self-assessed skill level
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_email (email)                  -- Enforce unique email constraint
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-007: Create `session` table — manages authenticated user sessions
-- UI Link: Used by Auth API for login/logout; validates every authenticated request
CREATE TABLE `session` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,                            -- References the logged-in user
    session_token VARCHAR(255) NOT NULL,              -- Unique token sent in cookies/headers
    expires_at DATETIME NOT NULL,                     -- Session expiry timestamp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_session_token (session_token),
    CONSTRAINT fk_session_user FOREIGN KEY (user_id)
        REFERENCES `user`(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-008: Create `recipe` table — stores all recipes submitted by users
-- UI Link: Home page (recipe feed), Recipe Detail page, Create Recipe page,
--          Admin > Recipes (approval workflow)
CREATE TABLE `recipe` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,                     -- Recipe title (shown on cards and detail)
    description TEXT DEFAULT NULL,                    -- Recipe description/summary
    category VARCHAR(50) DEFAULT NULL,               -- Category filter (Italian, Asian, etc.)
    difficulty ENUM('Easy', 'Medium', 'Hard')
        NOT NULL DEFAULT 'Easy',                     -- Difficulty badge on recipe cards
    prep_time INT DEFAULT NULL COMMENT 'Preparation time in minutes',
    cook_time INT DEFAULT NULL COMMENT 'Cooking time in minutes',
    servings INT DEFAULT NULL,                       -- Number of servings
    author_id INT NOT NULL,                          -- Foreign key to user who created recipe
    status ENUM('published', 'pending', 'rejected')
        NOT NULL DEFAULT 'pending',                  -- Approval status (Admin workflow)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_recipe_author FOREIGN KEY (author_id)
        REFERENCES `user`(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-009: Create `ingredient` table — stores recipe ingredients with quantities
-- UI Link: Recipe Detail page (ingredients list), Create Recipe page
CREATE TABLE `ingredient` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id INT NOT NULL,                          -- Parent recipe
    name VARCHAR(200) NOT NULL,                      -- Ingredient name (e.g., "Eggs")
    quantity VARCHAR(50) DEFAULT NULL,               -- Amount (e.g., "4")
    unit VARCHAR(50) DEFAULT NULL,                   -- Unit of measure (e.g., "tbsp")
    sort_order INT DEFAULT 0,                        -- Display order in the list
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_ingredient_recipe FOREIGN KEY (recipe_id)
        REFERENCES `recipe`(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-010: Create `instruction` table — stores step-by-step cooking instructions
-- UI Link: Recipe Detail page (instructions list), Create Recipe page
CREATE TABLE `instruction` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id INT NOT NULL,                          -- Parent recipe
    step_number INT NOT NULL,                        -- Step sequence number (1, 2, 3...)
    instruction_text TEXT NOT NULL,                   -- Step description text
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_instruction_recipe FOREIGN KEY (recipe_id)
        REFERENCES `recipe`(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-011: Create `recipe_image` table — stores image URLs for recipes
-- UI Link: Recipe cards (thumbnail), Recipe Detail page (main image)
CREATE TABLE `recipe_image` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id INT NOT NULL,                          -- Parent recipe
    image_url TEXT NOT NULL,                          -- Full image URL
    display_order INT DEFAULT 0,                     -- Order for multiple images
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_recipe_image_recipe FOREIGN KEY (recipe_id)
        REFERENCES `recipe`(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-012: Create `review` table — stores user ratings and comments on recipes
-- UI Link: Recipe Detail page (reviews section), Profile page (review count)
CREATE TABLE `review` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,                            -- Reviewer
    recipe_id INT NOT NULL,                          -- Reviewed recipe
    rating INT NOT NULL,                             -- Star rating (1-5)
    comment TEXT DEFAULT NULL,                        -- Optional review comment
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_review_rating CHECK (rating BETWEEN 1 AND 5),
    UNIQUE KEY uk_user_recipe_review (user_id, recipe_id),  -- One review per user per recipe
    CONSTRAINT fk_review_user FOREIGN KEY (user_id)
        REFERENCES `user`(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_review_recipe FOREIGN KEY (recipe_id)
        REFERENCES `recipe`(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-013: Create `favorite` table — tracks which recipes users have bookmarked
-- UI Link: Recipe Detail page (favorite button), Profile page (favorites tab)
CREATE TABLE `favorite` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,                            -- User who favorited
    recipe_id INT NOT NULL,                          -- Favorited recipe
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_recipe_favorite (user_id, recipe_id),
    CONSTRAINT fk_favorite_user FOREIGN KEY (user_id)
        REFERENCES `user`(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_favorite_recipe FOREIGN KEY (recipe_id)
        REFERENCES `recipe`(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-014: Create `like_record` table — tracks which recipes users have liked
-- UI Link: Recipe cards (like count), Recipe Detail page (like button)
CREATE TABLE `like_record` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,                            -- User who liked
    recipe_id INT NOT NULL,                          -- Liked recipe
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_recipe_like (user_id, recipe_id),
    CONSTRAINT fk_like_record_user FOREIGN KEY (user_id)
        REFERENCES `user`(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_like_record_recipe FOREIGN KEY (recipe_id)
        REFERENCES `recipe`(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-015: Create `recipe_view` table — logs each time a user views a recipe
-- UI Link: Recipe Detail page increments view count; Admin Stats shows total views
CREATE TABLE `recipe_view` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id INT NOT NULL,                          -- Viewed recipe
    user_id INT NOT NULL,                            -- Viewing user
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,   -- When the view occurred
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_recipe_viewed (recipe_id, viewed_at),  -- Speeds up view-count queries
    INDEX idx_user_viewed (user_id, viewed_at),      -- Speeds up user-activity queries
    CONSTRAINT fk_recipe_view_recipe FOREIGN KEY (recipe_id)
        REFERENCES `recipe`(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_recipe_view_user FOREIGN KEY (user_id)
        REFERENCES `user`(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-016: Create `search_history` table — logs user search queries for analytics
-- UI Link: Search page records queries; Admin Stats shows popular searches
CREATE TABLE `search_history` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,                            -- User who searched
    query TEXT NOT NULL,                              -- Search term entered
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- When the search happened
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_search_history_user FOREIGN KEY (user_id)
        REFERENCES `user`(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-017: Create `daily_stat` table — aggregates daily platform-wide metrics
-- UI Link: Admin Stats page (charts and summary cards)
CREATE TABLE `daily_stat` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    stat_date DATE NOT NULL,                         -- The date these stats represent
    page_view_count INT DEFAULT 0,                   -- Total page views on this date
    active_user_count INT DEFAULT 0,                 -- Number of active users on this date
    new_user_count INT DEFAULT 0,                    -- New registrations on this date
    recipe_view_count INT DEFAULT 0,                 -- Recipe page views on this date
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_daily_stat_date (stat_date)         -- One row per date
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-018: Create `activity_log` table — audit trail for admin actions
-- UI Link: Admin Stats page (recent activity feed)
CREATE TABLE `activity_log` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT DEFAULT NULL,                       -- Admin who performed the action
    action_type ENUM(
        'user_create', 'user_update', 'user_delete',
        'recipe_approve', 'recipe_reject', 'recipe_delete'
    ) NOT NULL,                                      -- Type of admin action
    target_type VARCHAR(50) DEFAULT NULL,             -- Entity type affected ('user' or 'recipe')
    target_id INT DEFAULT NULL,                      -- ID of affected entity
    description TEXT DEFAULT NULL,                    -- Human-readable description
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_activity_log_admin FOREIGN KEY (admin_id)
        REFERENCES `user`(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- CMD-019: Re-enable foreign key checks after all tables are created
SET FOREIGN_KEY_CHECKS = 1;


-- =============================================================================
-- SECTION 03 — CREATE INDEXES
-- Source: 03_create_indexes.sql
-- Purpose: Accelerate common queries used by the API endpoints and views.
--          Each index targets a specific query pattern from the backend.
-- =============================================================================

-- CMD-020: Index on user.email — speeds up login lookups (Auth API)
CREATE INDEX idx_user_email
    ON `user` (email);

-- CMD-021: Composite index on user(role, status) — Admin > User List filtering
CREATE INDEX idx_user_role_status
    ON `user` (role, status);

-- CMD-022: Index on user.joined_date — sorting users by join date (Admin)
CREATE INDEX idx_user_joined_date
    ON `user` (joined_date);

-- CMD-023: Index on recipe.author_id — fetching recipes by author (Profile page)
CREATE INDEX idx_recipe_author_id
    ON recipe (author_id);

-- CMD-024: Index on recipe.status — filtering by publish status (Home, Admin)
CREATE INDEX idx_recipe_status
    ON recipe (status);

-- CMD-025: Index on recipe.category — category-based filtering (Search page)
CREATE INDEX idx_recipe_category
    ON recipe (category);

-- CMD-026: Composite index on recipe(author_id, status) — author's published recipes
CREATE INDEX idx_recipe_author_status
    ON recipe (author_id, status);

-- CMD-027: Index on recipe.created_at — sorting recipes by date (Home page feed)
CREATE INDEX idx_recipe_created_at
    ON recipe (created_at);

-- CMD-028: Index on review.recipe_id — fetching reviews for a recipe (Detail page)
CREATE INDEX idx_review_recipe_id
    ON review (recipe_id);

-- CMD-029: Index on review.user_id — fetching a user's reviews (Profile page)
CREATE INDEX idx_review_user_id
    ON review (user_id);

-- CMD-030: Index on favorite.user_id — fetching a user's favorites (Profile page)
CREATE INDEX idx_favorite_user_id
    ON favorite (user_id);

-- CMD-031: Index on favorite.recipe_id — counting favorites per recipe
CREATE INDEX idx_favorite_recipe_id
    ON favorite (recipe_id);

-- CMD-032: Index on like_record.recipe_id — counting likes per recipe (cards)
CREATE INDEX idx_like_record_recipe_id
    ON like_record (recipe_id);

-- CMD-033: Index on like_record.user_id — checking if user liked a recipe
CREATE INDEX idx_like_record_user_id
    ON like_record (user_id);

-- CMD-034: Index on search_history.user_id — user search history lookup
CREATE INDEX idx_search_history_user_id
    ON search_history (user_id);

-- CMD-035: Composite index on search_history(user_id, searched_at) — recent searches
CREATE INDEX idx_search_history_searched_at
    ON search_history (user_id, searched_at);

-- CMD-036: Index on daily_stat.stat_date — date-range queries (Admin Stats)
CREATE INDEX idx_daily_stat_date
    ON daily_stat (stat_date);

-- CMD-037: Index on activity_log.admin_id — filtering logs by admin
CREATE INDEX idx_activity_log_admin_id
    ON activity_log (admin_id);

-- CMD-038: Index on activity_log.created_at — sorting activity feed by date
CREATE INDEX idx_activity_log_created_at
    ON activity_log (created_at);

-- CMD-039: Composite index on activity_log(admin_id, created_at) — admin activity timeline
CREATE INDEX idx_activity_log_admin_created
    ON activity_log (admin_id, created_at);

-- CMD-040: Index on session.session_token — fast session validation on every API call
CREATE INDEX idx_session_token
    ON session (session_token);

-- CMD-041: Index on session.user_id — finding active sessions for a user
CREATE INDEX idx_session_user_id
    ON session (user_id);

-- CMD-042: Index on session.expires_at — cleanup of expired sessions
CREATE INDEX idx_session_expires_at
    ON session (expires_at);

-- CMD-043: Composite index on ingredient(recipe_id, sort_order) — ordered ingredient list
CREATE INDEX idx_ingredient_recipe_order
    ON ingredient (recipe_id, sort_order);

-- CMD-044: Composite index on instruction(recipe_id, step_number) — ordered steps
CREATE INDEX idx_instruction_recipe_step
    ON instruction (recipe_id, step_number);


-- =============================================================================
-- SECTION 04 — CREATE VIEWS
-- Source: 04_create_views.sql
-- Purpose: Pre-joined views that simplify complex queries in the API layer.
--          These views aggregate recipe stats and user dashboard data.
-- =============================================================================

-- CMD-045: Drop and recreate vw_recipe_with_stat — aggregated recipe data with stats
-- UI Link: Home page (recipe cards with like/view/rating counts), Search results
DROP VIEW IF EXISTS vw_recipe_with_stat;

CREATE VIEW vw_recipe_with_stat AS
SELECT
    r.id                AS recipe_id,
    r.title             AS recipe_title,
    r.description       AS recipe_description,
    r.category          AS recipe_category,
    r.difficulty        AS recipe_difficulty,
    r.prep_time         AS prep_time,
    r.cook_time         AS cook_time,
    r.servings          AS servings,
    r.status            AS recipe_status,
    r.created_at        AS recipe_created_at,
    r.updated_at        AS recipe_updated_at,
    u.id                AS author_id,
    u.username          AS author_username,
    u.first_name        AS author_first_name,
    u.last_name         AS author_last_name,
    u.avatar_url        AS author_avatar_url,
    COALESCE(lk.like_count, 0)      AS like_count,       -- Total likes
    COALESCE(vw.view_count, 0)      AS view_count,       -- Total views
    COALESCE(rv.review_count, 0)    AS review_count,     -- Total reviews
    COALESCE(rv.avg_rating, 0)      AS avg_rating,       -- Average star rating
    COALESCE(fv.favorite_count, 0)  AS favorite_count,   -- Total favorites
    (
        SELECT ri.image_url
        FROM recipe_image ri
        WHERE ri.recipe_id = r.id
        ORDER BY ri.display_order ASC
        LIMIT 1
    ) AS primary_image_url                                -- First image for the card thumbnail
FROM recipe r
    INNER JOIN `user` u
        ON r.author_id = u.id
    LEFT JOIN (
        SELECT recipe_id, COUNT(*) AS like_count
        FROM like_record
        GROUP BY recipe_id
    ) lk ON lk.recipe_id = r.id
    LEFT JOIN (
        SELECT recipe_id, COUNT(*) AS view_count
        FROM recipe_view
        GROUP BY recipe_id
    ) vw ON vw.recipe_id = r.id
    LEFT JOIN (
        SELECT recipe_id, COUNT(*) AS review_count, ROUND(AVG(rating), 1) AS avg_rating
        FROM review
        GROUP BY recipe_id
    ) rv ON rv.recipe_id = r.id
    LEFT JOIN (
        SELECT recipe_id, COUNT(*) AS favorite_count
        FROM favorite
        GROUP BY recipe_id
    ) fv ON fv.recipe_id = r.id;

-- CMD-046: Drop and recreate vw_user_dashboard_stat — aggregated user profile data
-- UI Link: Profile page (stats overview), Admin > User List (user metrics)
DROP VIEW IF EXISTS vw_user_dashboard_stat;

CREATE VIEW vw_user_dashboard_stat AS
SELECT
    u.id                AS user_id,
    u.username          AS username,
    u.email             AS email,
    u.role              AS role,
    u.status            AS status,
    u.joined_date       AS joined_date,
    u.last_active       AS last_active,
    u.avatar_url        AS avatar_url,
    COALESCE(rc.recipe_count, 0)           AS recipe_count,            -- Total recipes created
    COALESCE(rc.published_recipe_count, 0) AS published_recipe_count,  -- Published recipes
    COALESCE(rc.pending_recipe_count, 0)   AS pending_recipe_count,    -- Pending approval
    COALESCE(fv.favorite_count, 0)         AS favorite_count,          -- Recipes favorited
    COALESCE(rv.review_count, 0)           AS review_count,            -- Reviews written
    COALESCE(lk.like_given_count, 0)       AS like_given_count,        -- Likes given
    COALESCE(lk_rcv.like_received_count, 0) AS like_received_count     -- Likes received on own recipes
FROM `user` u
    LEFT JOIN (
        SELECT
            author_id,
            COUNT(*) AS recipe_count,
            SUM(CASE WHEN status = 'published' THEN 1 ELSE 0 END) AS published_recipe_count,
            SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END)   AS pending_recipe_count
        FROM recipe
        GROUP BY author_id
    ) rc ON rc.author_id = u.id
    LEFT JOIN (
        SELECT user_id, COUNT(*) AS favorite_count
        FROM favorite
        GROUP BY user_id
    ) fv ON fv.user_id = u.id
    LEFT JOIN (
        SELECT user_id, COUNT(*) AS review_count
        FROM review
        GROUP BY user_id
    ) rv ON rv.user_id = u.id
    LEFT JOIN (
        SELECT user_id, COUNT(*) AS like_given_count
        FROM like_record
        GROUP BY user_id
    ) lk ON lk.user_id = u.id
    LEFT JOIN (
        SELECT r.author_id, COUNT(lr.id) AS like_received_count
        FROM like_record lr
            INNER JOIN recipe r ON lr.recipe_id = r.id
        GROUP BY r.author_id
    ) lk_rcv ON lk_rcv.author_id = u.id;


-- =============================================================================
-- SECTION 05 — SEED USERS
-- Source: 05_seed_users.sql
-- Purpose: Insert demo admin and regular user accounts for testing.
-- UI Link: Login page (use these credentials), Admin > User List shows them.
-- Note: All passwords are bcrypt-hashed. See SETUP_GUIDE for plain-text values.
-- =============================================================================

-- CMD-047: Disable triggers during seeding to prevent side-effects on daily_stat
SET @PREV_DISABLE_TRIGGERS = @DISABLE_TRIGGERS;
SET @DISABLE_TRIGGERS = 1;

-- CMD-048: Insert 3 admin users — platform administrators
-- Admin credentials: admin@cookhub.com / olivia@cookhub.com / marcus@cookhub.com
INSERT INTO `user` (
    username, first_name, last_name, email, password_hash,
    birthday, role, status, joined_date, last_active,
    avatar_url, bio, location, cooking_level
) VALUES
(
    'Admin User', 'Admin', 'User', 'admin@cookhub.com',
    '$2y$10$mcxuNIpFb723w0ajx/qqmu1beF2vHilnDJV2nP4zJN./OJ4ZqxfK.',
    '1990-01-01', 'admin', 'active',
    '2025-06-01 00:00:00', NOW(),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=admin',
    'System Administrator', 'Server Room', 'Professional'
),
(
    'Olivia Admin', 'Olivia', 'Nguyen', 'olivia@cookhub.com',
    '$2y$10$mcxuNIpFb723w0ajx/qqmu1beF2vHilnDJV2nP4zJN./OJ4ZqxfK.',
    '1986-04-12', 'admin', 'active',
    '2025-09-01 00:00:00', DATE_SUB(NOW(), INTERVAL 2 HOUR),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=olivia-admin',
    'Content moderation lead.', 'Boston', 'Advanced'
),
(
    'Marcus Admin', 'Marcus', 'Lee', 'marcus@cookhub.com',
    '$2y$10$mcxuNIpFb723w0ajx/qqmu1beF2vHilnDJV2nP4zJN./OJ4ZqxfK.',
    '1983-11-22', 'admin', 'active',
    '2025-10-05 00:00:00', DATE_SUB(NOW(), INTERVAL 90 MINUTE),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=marcus-admin',
    'Operations admin.', 'Seattle', 'Intermediate'
);

-- CMD-049: Insert 9 regular users with varying statuses (active, inactive, pending, suspended)
-- Demonstrates all user states visible in Admin > User List
INSERT INTO `user` (
    username, first_name, last_name, email, password_hash,
    birthday, role, status, joined_date, last_active,
    avatar_url, bio, location, cooking_level
) VALUES
(
    'John Doe', 'John', 'Doe', 'user@cookhub.com',
    '$2y$10$0FkkS.pxqerygxx6sAoTS.h7xUSpR8Q5ylEl5m.Z2egmqvRgSF3tm',
    '1995-06-15', 'user', 'active',
    '2025-06-15 00:00:00', DATE_SUB(NOW(), INTERVAL 1 HOUR),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=john',
    'Love cooking italian food!', 'New York', 'Intermediate'
),
(
    'Maria Garcia', 'Maria', 'Garcia', 'maria@cookhub.com',
    '$2y$10$/krNSQraXnfh.w7pEX..qO05AnuI5b/ZZ7ztujYnYuQE4mQD0yHpu',
    '1988-03-20', 'user', 'inactive',
    '2025-03-20 00:00:00', DATE_SUB(NOW(), INTERVAL 7 DAY),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=maria',
    'Professional chef specializing in Mediterranean cuisine.', 'Los Angeles', 'Professional'
),
(
    'Tom Baker', 'Tom', 'Baker', 'tom@cookhub.com',
    '$2y$10$tPd/M7Lxwt0gdiMTv4CWZ.8a/Tnwg.O/mx6F2Qf6lO4tzaPvU9oAC',
    '1992-08-01', 'user', 'suspended',
    '2025-08-01 00:00:00', DATE_SUB(NOW(), INTERVAL 30 DAY),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=tom',
    'Passionate about baking and desserts!', 'Chicago', 'Intermediate'
),
(
    'Amy Wilson', 'Amy', 'Wilson', 'amy@cookhub.com',
    '$2y$10$FeWJR/4XiMBG5rY11HKqrOOn/VmM050gty3UcmZVXnQurYKabcitW',
    '1998-11-10', 'user', 'pending',
    '2025-11-10 00:00:00', NULL,
    'https://api.dicebear.com/7.x/avataaars/svg?seed=amy',
    'New to the platform.', 'Denver', 'Beginner'
),
(
    'Kevin Tran', 'Kevin', 'Tran', 'kevin@cookhub.com',
    '$2y$10$FFGPYQRBe.yVD6ijmn0iVucxrCTahAZ.V8mo.vG7z0n6sEDUOxLQe',
    '1996-02-18', 'user', 'pending',
    '2026-01-20 00:00:00', NULL,
    'https://api.dicebear.com/7.x/avataaars/svg?seed=kevin',
    'Here to learn quick meals.', 'Austin', 'Beginner'
),
(
    'Sarah Kim', 'Sarah', 'Kim', 'sarah@cookhub.com',
    '$2y$10$ODml9vH4OizBFVCANWhzsu7kZQean0aEfOQ2WcC70DM7TQyYa6yJa',
    '1991-07-09', 'user', 'active',
    '2025-12-28 00:00:00', DATE_SUB(NOW(), INTERVAL 30 MINUTE),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
    'Healthy meal prep enthusiast.', 'San Diego', 'Intermediate'
),
(
    'Daniel Rivera', 'Daniel', 'Rivera', 'daniel@cookhub.com',
    '$2y$10$LElRgwvLzgYmpTI/eR4TbukMq9lwPCAkq03xjgHSgPThoARpD7h/q',
    '1989-05-30', 'user', 'active',
    '2025-12-05 00:00:00', DATE_SUB(NOW(), INTERVAL 67 MINUTE),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=daniel',
    'Street food lover.', 'Miami', 'Advanced'
),
(
    'Lina Patel', 'Lina', 'Patel', 'lina@cookhub.com',
    '$2y$10$OrJ0UJZWdUcYvdDDVIrHa.JrZE1wIpZw6YQHLLzIORLwZ7KjGVYdq',
    '2000-09-14', 'user', 'inactive',
    '2025-11-01 00:00:00', DATE_SUB(NOW(), INTERVAL 10 DAY),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=lina',
    'Baking beginner.', 'Portland', 'Beginner'
),
(
    'Omar Hassan', 'Omar', 'Hassan', 'omar@cookhub.com',
    '$2y$10$lGIy0Zzzec/.stSuWDXk3eEJlVQMOHt2qY10nunlFPRJsLzllDZgq',
    '1993-03-03', 'user', 'pending',
    '2026-01-21 00:00:00', NULL,
    'https://api.dicebear.com/7.x/avataaars/svg?seed=omar',
    'Trying new cuisines.', 'Phoenix', 'Beginner'
);

-- CMD-050: Re-enable triggers after user seeding
SET @DISABLE_TRIGGERS = @PREV_DISABLE_TRIGGERS;
SET @PREV_DISABLE_TRIGGERS = NULL;


-- =============================================================================
-- SECTION 06 — SEED RECIPES
-- Source: 06_seed_recipes.sql
-- Purpose: Insert 13 sample recipes with ingredients, instructions, and images.
-- UI Link: Home page (recipe feed), Recipe Detail page, Search results
-- =============================================================================

-- CMD-051: Insert 13 recipes spanning multiple categories and difficulty levels
-- Recipes include published, pending, and rejected statuses for testing workflows
INSERT INTO recipe (id, title, description, category, difficulty, prep_time, cook_time, servings, author_id, status, created_at) VALUES
(1,  'Classic Spaghetti Carbonara', 'A traditional Italian pasta dish from Rome with creamy egg sauce and crispy pancetta.', 'Italian', 'Medium', 15, 20, 4, 4, 'published', '2025-12-01 00:00:00'),
(2,  'Fluffy Pancakes', 'Light and fluffy pancakes perfect for a weekend breakfast.', 'Breakfast', 'Easy', 10, 15, 2, 4, 'pending', '2026-01-15 00:00:00'),
(3,  'Thai Green Curry', 'Aromatic and spicy Thai green curry with vegetables and coconut milk.', 'Asian', 'Medium', 20, 25, 4, 5, 'published', '2025-11-20 00:00:00'),
(4,  'Avocado Toast', 'Simple yet delicious avocado toast with poached eggs and chili flakes.', 'Breakfast', 'Easy', 5, 10, 2, 5, 'published', '2025-10-15 00:00:00'),
(5,  'Chocolate Lava Cake', 'Decadent chocolate cake with a molten center. Perfect for dessert lovers.', 'Dessert', 'Hard', 15, 12, 4, 6, 'published', '2025-09-05 00:00:00'),
(6,  'Classic Beef Burger', 'Juicy homemade beef burger with all the fixings.', 'Dinner', 'Medium', 20, 15, 4, 6, 'published', '2025-08-10 00:00:00'),
(7,  'Mango Sticky Rice', 'Traditional Thai dessert with sweet coconut sticky rice and fresh mango.', 'Dessert', 'Medium', 30, 25, 4, 5, 'published', '2025-07-25 00:00:00'),
(8,  'Lemon Garlic Salmon', 'Oven-baked salmon with lemon, garlic, and fresh herbs.', 'Dinner', 'Easy', 10, 18, 2, 9, 'published', '2026-01-05 00:00:00'),
(9,  'Chickpea Salad Wrap', 'Fresh and crunchy chickpea salad wrapped in a tortilla.', 'Lunch', 'Easy', 12, 0, 2, 10, 'published', '2025-12-12 00:00:00'),
(10, 'Blueberry Overnight Oats', 'No-cook breakfast with oats, yogurt, and blueberries.', 'Breakfast', 'Easy', 8, 0, 1, 9, 'pending', '2026-01-18 00:00:00'),
(11, 'Spicy Tofu Stir-Fry', 'Quick stir-fry with tofu, bell peppers, and spicy sauce.', 'Asian', 'Medium', 15, 10, 3, 10, 'rejected', '2025-11-22 00:00:00'),
(12, 'Tomato Basil Soup', 'Creamy tomato soup with fresh basil and croutons.', 'Dinner', 'Easy', 10, 25, 4, 4, 'published', '2025-10-30 00:00:00'),
(13, 'Crispy Fish Tacos', 'Crispy fish with slaw and lime crema in warm tortillas.', 'Dinner', 'Medium', 20, 15, 3, 10, 'published', '2026-01-10 00:00:00');

-- CMD-052: Insert ingredients for Recipe 1 — Classic Spaghetti Carbonara
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(1, 'Spaghetti', '400', 'g', 1),
(1, 'Eggs', '4', '', 2),
(1, 'Pancetta', '200', 'g', 3),
(1, 'Parmesan', '100', 'g', 4);

-- CMD-053: Insert ingredients for Recipe 2 — Fluffy Pancakes
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(2, 'Flour', '200', 'g', 1),
(2, 'Milk', '250', 'ml', 2),
(2, 'Eggs', '2', '', 3),
(2, 'Sugar', '2', 'tbsp', 4);

-- CMD-054: Insert ingredients for Recipe 3 — Thai Green Curry
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(3, 'Green curry paste', '3', 'tbsp', 1),
(3, 'Coconut milk', '400', 'ml', 2),
(3, 'Chicken breast', '500', 'g', 3),
(3, 'Thai basil', '1', 'bunch', 4);

-- CMD-055: Insert ingredients for Recipes 4-7
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(4, 'Avocado', '2', '', 1),
(4, 'Sourdough bread', '4', 'slices', 2),
(4, 'Eggs', '4', '', 3),
(4, 'Chili flakes', '1', 'tsp', 4);

INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(5, 'Dark chocolate', '200', 'g', 1),
(5, 'Butter', '100', 'g', 2),
(5, 'Eggs', '4', '', 3),
(5, 'Sugar', '100', 'g', 4);

INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(6, 'Ground beef', '500', 'g', 1),
(6, 'Burger buns', '4', '', 2),
(6, 'Cheese slices', '4', '', 3),
(6, 'Lettuce', '4', 'leaves', 4);

INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(7, 'Sticky rice', '300', 'g', 1),
(7, 'Coconut milk', '400', 'ml', 2),
(7, 'Ripe mango', '2', '', 3),
(7, 'Palm sugar', '100', 'g', 4);

-- CMD-056: Insert ingredients for Recipes 8-13
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(8, 'Salmon fillets', '2', '', 1),
(8, 'Lemon', '1', '', 2),
(8, 'Garlic', '3', 'cloves', 3),
(8, 'Olive oil', '2', 'tbsp', 4);

INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(9, 'Chickpeas', '200', 'g', 1),
(9, 'Greek yogurt', '3', 'tbsp', 2),
(9, 'Celery', '2', 'stalks', 3),
(9, 'Tortillas', '2', '', 4);

INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(10, 'Rolled oats', '50', 'g', 1),
(10, 'Greek yogurt', '120', 'ml', 2),
(10, 'Blueberries', '80', 'g', 3),
(10, 'Honey', '1', 'tsp', 4);

INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(11, 'Tofu', '400', 'g', 1),
(11, 'Bell peppers', '2', '', 2),
(11, 'Soy sauce', '2', 'tbsp', 3),
(11, 'Chili sauce', '1', 'tbsp', 4);

INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(12, 'Tomatoes', '800', 'g', 1),
(12, 'Onion', '1', '', 2),
(12, 'Cream', '100', 'ml', 3),
(12, 'Basil', '1', 'bunch', 4);

INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(13, 'White fish', '400', 'g', 1),
(13, 'Tortillas', '6', '', 2),
(13, 'Cabbage', '150', 'g', 3),
(13, 'Lime', '1', '', 4);

-- CMD-057: Insert cooking instructions for Recipe 1 — Carbonara (5 steps)
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(1, 1, 'Boil water and cook pasta al dente'),
(1, 2, 'Fry pancetta until crispy'),
(1, 3, 'Mix eggs with grated parmesan'),
(1, 4, 'Combine hot pasta with egg mixture off heat'),
(1, 5, 'Add pancetta and serve immediately');

-- CMD-058: Insert cooking instructions for Recipe 2 — Pancakes (4 steps)
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(2, 1, 'Mix dry ingredients'),
(2, 2, 'Add wet ingredients and whisk'),
(2, 3, 'Cook on medium heat until bubbles form'),
(2, 4, 'Flip and cook other side');

-- CMD-059: Insert cooking instructions for Recipe 3 — Thai Green Curry (5 steps)
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(3, 1, 'Fry curry paste in oil'),
(3, 2, 'Add coconut milk and bring to simmer'),
(3, 3, 'Add chicken and vegetables'),
(3, 4, 'Cook until chicken is done'),
(3, 5, 'Garnish with Thai basil');

-- CMD-060: Insert cooking instructions for Recipes 4-7
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(4, 1, 'Toast the bread until golden'),
(4, 2, 'Mash avocado and season'),
(4, 3, 'Poach eggs in simmering water'),
(4, 4, 'Spread avocado on toast'),
(4, 5, 'Top with poached eggs and chili');

INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(5, 1, 'Melt chocolate and butter together'),
(5, 2, 'Whisk eggs and sugar until fluffy'),
(5, 3, 'Fold chocolate into egg mixture'),
(5, 4, 'Pour into ramekins'),
(5, 5, 'Bake at 200°C for 12 minutes');

INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(6, 1, 'Form beef into patties'),
(6, 2, 'Season with salt and pepper'),
(6, 3, 'Grill or pan-fry for 4-5 min per side'),
(6, 4, 'Toast buns'),
(6, 5, 'Assemble with toppings');

INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(7, 1, 'Soak sticky rice overnight'),
(7, 2, 'Steam rice until tender'),
(7, 3, 'Heat coconut milk with sugar'),
(7, 4, 'Pour half over rice'),
(7, 5, 'Serve with sliced mango and remaining sauce');

-- CMD-061: Insert cooking instructions for Recipes 8-13
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(8, 1, 'Preheat oven to 200°C'),
(8, 2, 'Season salmon with garlic, lemon, and oil'),
(8, 3, 'Bake for 15-18 minutes'),
(8, 4, 'Serve with herbs');

INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(9, 1, 'Mash chickpeas lightly'),
(9, 2, 'Mix with yogurt and chopped celery'),
(9, 3, 'Wrap in tortilla and serve');

INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(10, 1, 'Mix oats and yogurt'),
(10, 2, 'Top with blueberries'),
(10, 3, 'Chill overnight'),
(10, 4, 'Drizzle honey before serving');

INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(11, 1, 'Press and cube tofu'),
(11, 2, 'Stir-fry tofu until golden'),
(11, 3, 'Add peppers and sauce'),
(11, 4, 'Serve hot');

INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(12, 1, 'Saute onion'),
(12, 2, 'Add tomatoes and simmer'),
(12, 3, 'Blend and add cream'),
(12, 4, 'Garnish with basil');

INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(13, 1, 'Season and fry fish'),
(13, 2, 'Prepare slaw'),
(13, 3, 'Assemble tacos'),
(13, 4, 'Serve with lime crema');

-- CMD-062: Insert primary image URLs for all 13 recipes (one image each)
-- UI Link: Recipe cards on Home page and Search results show these thumbnails
INSERT INTO recipe_image (recipe_id, image_url, display_order) VALUES
(1,  'https://images.unsplash.com/photo-1612874742237-6526221588e3?auto=format&fit=crop&q=80&w=800', 1),
(2,  'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&q=80&w=800', 1),
(3,  'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?auto=format&fit=crop&q=80&w=800', 1),
(4,  'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?auto=format&fit=crop&q=80&w=800', 1),
(5,  'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?auto=format&fit=crop&q=80&w=800', 1),
(6,  'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=800', 1),
(7,  'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&q=80&w=800', 1),
(8,  'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80&w=800', 1),
(9,  'https://images.unsplash.com/photo-1523986371872-9d3ba2e2f642?auto=format&fit=crop&q=80&w=800', 1),
(10, 'https://images.unsplash.com/photo-1502741126161-b048400dcca2?auto=format&fit=crop&q=80&w=800', 1),
(11, 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&q=80&w=800', 1),
(12, 'https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?auto=format&fit=crop&q=80&w=800', 1),
(13, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=800', 1);


-- =============================================================================
-- SECTION 07 — SEED REVIEWS, LIKES, AND FAVORITES
-- Source: 07_seed_reviews.sql
-- Purpose: Insert sample user interactions (reviews, likes, favorites) to
--          populate recipe stats visible on cards and detail pages.
-- UI Link: Recipe Detail (reviews section, like/favorite counts),
--          Home page (like counts on cards)
-- =============================================================================

-- CMD-063: Insert 24 reviews with ratings (1-5 stars) and comments across 10 recipes
INSERT INTO review (user_id, recipe_id, rating, comment, created_at) VALUES
(5,  1, 5, 'Absolutely authentic! Reminds me of the carbonara I had in Rome. The egg sauce was perfectly creamy.', '2025-12-05 14:30:00'),
(6,  1, 4, 'Great recipe. I added a bit more parmesan than suggested and it turned out amazing.', '2025-12-08 18:45:00'),
(9,  1, 5, 'My family loved this! Simple ingredients but incredible flavor.', '2025-12-15 20:00:00'),
(10, 1, 4, 'Solid carbonara recipe. The key is really taking it off the heat before mixing the eggs.', '2025-12-20 12:15:00'),

(4,  3, 5, 'Best green curry recipe I have found online. Perfectly balanced flavors!', '2025-11-25 19:30:00'),
(9,  3, 4, 'Very aromatic and flavorful. I used tofu instead of chicken and it worked great.', '2025-12-01 17:00:00'),
(10, 3, 4, 'Good recipe but I would recommend adding more vegetables for a heartier meal.', '2025-12-10 13:45:00'),

(4,  4, 4, 'Simple but delicious. The poached eggs make all the difference.', '2025-10-20 08:30:00'),
(9,  4, 3, 'Good basic recipe. I added some everything bagel seasoning on top.', '2025-11-05 09:15:00'),

(5,  5, 5, 'Decadent and absolutely divine! The molten center was perfect.', '2025-09-10 21:00:00'),
(4,  5, 4, 'Tricky timing but worth it. Mine came out slightly overcooked the first time.', '2025-09-15 20:30:00'),
(9,  5, 5, 'Restaurant-quality dessert at home. My guests were thoroughly impressed.', '2025-10-02 19:45:00'),

(4,  6, 5, 'Juicy and flavorful! The secret is not overworking the beef.', '2025-08-15 13:00:00'),
(5,  6, 4, 'Really good homemade burger. I added caramelized onions.', '2025-08-20 12:30:00'),
(9,  6, 5, 'Best burger recipe! Simple but the result is amazing.', '2025-09-01 18:00:00'),

(4,  7, 4, 'Beautiful Thai dessert. Make sure to use ripe mangoes for best results.', '2025-08-01 15:30:00'),
(10, 7, 5, 'Authentic and delicious! Soaking the rice overnight is essential.', '2025-08-10 16:00:00'),

(4,  8, 5, 'Quick and healthy dinner. The lemon garlic combo is perfect with salmon.', '2026-01-08 19:00:00'),
(10, 8, 4, 'Easy to make and tastes great. I served it with roasted asparagus.', '2026-01-12 18:30:00'),

(5,  9, 4, 'Fresh and filling! Great healthy lunch option.', '2025-12-15 12:00:00'),
(9,  9, 4, 'Love the crunch. I added some red onion and it was even better.', '2025-12-20 12:45:00'),

(6,  12, 4, 'Comfort food at its best. Pairs perfectly with grilled cheese.', '2025-11-05 19:00:00'),
(9,  12, 5, 'Creamy and rich. Fresh basil makes a huge difference over dried.', '2025-11-15 18:30:00'),

(5,  13, 5, 'Incredible tacos! The slaw and lime crema bring everything together.', '2026-01-15 13:00:00'),
(9,  13, 4, 'Really tasty. I used cod and it worked perfectly.', '2026-01-20 12:30:00');

-- CMD-064: Insert 14 like records — tracks which users liked which recipes
-- UI Link: Like button on Recipe Detail, like count on recipe cards
INSERT INTO like_record (user_id, recipe_id, created_at) VALUES
(5,  1, '2025-12-03 10:00:00'),
(6,  1, '2025-12-07 14:00:00'),
(4,  3, '2025-11-22 16:00:00'),
(6,  5, '2025-09-08 20:00:00'),
(4,  6, '2025-08-12 11:00:00'),
(5,  6, '2025-08-18 13:00:00'),
(6,  6, '2025-08-25 15:00:00'),
(5,  7, '2025-07-28 17:00:00'),
(4,  8, '2026-01-06 19:00:00'),
(5,  9, '2025-12-14 11:00:00'),
(9,  9, '2025-12-18 14:00:00'),
(6,  12, '2025-11-02 18:00:00'),
(5,  13, '2026-01-12 12:00:00'),
(9,  13, '2026-01-18 15:00:00');

-- CMD-065: Insert 7 favorite records — users bookmark recipes for later
-- UI Link: Favorite button on Recipe Detail, Profile page favorites tab
INSERT INTO favorite (user_id, recipe_id, created_at) VALUES
(4,  3, '2025-11-23 10:00:00'),
(5,  1, '2025-12-02 09:00:00'),
(6,  1, '2025-12-06 11:00:00'),
(6,  5, '2025-09-07 15:00:00'),
(9,  1, '2025-12-10 08:00:00'),
(9,  3, '2025-12-05 14:00:00'),
(10, 5, '2025-09-10 20:00:00');


-- =============================================================================
-- SECTION 08 — SEED STATS, VIEWS, SEARCH HISTORY, AND ACTIVITY LOGS
-- Source: 08_seed_stats.sql
-- Purpose: Insert analytics and tracking data used by the Admin Stats dashboard.
-- UI Link: Admin Stats page (charts, activity feed, search trends)
-- =============================================================================

-- CMD-066: Disable triggers during stats seeding (avoid double-counting)
SET @PREV_DISABLE_TRIGGERS = @DISABLE_TRIGGERS;
SET @DISABLE_TRIGGERS = 1;

-- CMD-067: Insert 23 recipe view records — tracks individual recipe page visits
-- UI Link: View count shown on recipe cards and detail pages
INSERT INTO recipe_view (recipe_id, user_id, viewed_at) VALUES
(1, 4, '2025-12-01 10:00:00'),
(1, 5, '2025-12-03 14:00:00'),
(1, 6, '2025-12-07 16:00:00'),
(3, 4, '2025-11-21 18:00:00'),
(4, 5, '2025-10-16 09:00:00'),
(5, 6, '2025-09-06 20:00:00'),
(6, 4, '2025-08-11 12:00:00'),
(6, 5, '2025-08-18 13:30:00'),
(6, 6, '2025-08-22 15:00:00'),
(7, 5, '2025-07-26 17:00:00'),
(8, 4, '2026-01-06 19:00:00'),
(8, 9, '2026-01-07 10:00:00'),
(9, 5, '2025-12-13 11:00:00'),
(9, 9, '2025-12-17 14:00:00'),
(9, 10, '2025-12-12 16:00:00'),
(11, 10, '2025-11-23 13:00:00'),
(12, 4, '2025-10-31 18:00:00'),
(12, 6, '2025-11-03 19:00:00'),
(12, 9, '2025-11-14 17:00:00'),
(13, 5, '2026-01-11 12:00:00'),
(13, 9, '2026-01-16 14:00:00'),
(13, 10, '2026-01-10 16:00:00'),
(2, 11, '2026-01-16 08:00:00');

-- CMD-068: Insert 30 days of daily_stat records — platform-wide analytics
-- UI Link: Admin Stats page (line charts, summary cards)
INSERT INTO daily_stat (stat_date, page_view_count, active_user_count, new_user_count, recipe_view_count) VALUES
('2026-01-08', 145, 8,  0, 32),
('2026-01-09', 132, 7,  0, 28),
('2026-01-10', 156, 9,  0, 35),
('2026-01-11', 168, 10, 0, 40),
('2026-01-12', 142, 7,  0, 30),
('2026-01-13', 98,  5,  0, 18),
('2026-01-14', 110, 6,  0, 22),
('2026-01-15', 175, 11, 0, 42),
('2026-01-16', 160, 9,  0, 38),
('2026-01-17', 148, 8,  0, 33),
('2026-01-18', 190, 12, 0, 45),
('2026-01-19', 135, 7,  0, 29),
('2026-01-20', 205, 13, 1, 48),
('2026-01-21', 180, 10, 1, 42),
('2026-01-22', 165, 9,  0, 37),
('2026-01-23', 152, 8,  0, 34),
('2026-01-24', 140, 7,  0, 30),
('2026-01-25', 118, 6,  0, 25),
('2026-01-26', 105, 5,  0, 20),
('2026-01-27', 172, 10, 0, 40),
('2026-01-28', 185, 11, 0, 43),
('2026-01-29', 195, 12, 0, 46),
('2026-01-30', 160, 9,  0, 36),
('2026-01-31', 148, 8,  0, 33),
('2026-02-01', 210, 14, 0, 50),
('2026-02-02', 178, 10, 0, 41),
('2026-02-03', 192, 12, 0, 45),
('2026-02-04', 165, 9,  0, 38),
('2026-02-05', 188, 11, 0, 44),
('2026-02-06', 200, 13, 0, 47);

-- CMD-069: Insert 15 search history records — tracks what users searched for
-- UI Link: Search page logs queries; Admin analytics shows popular search terms
INSERT INTO search_history (user_id, query, searched_at) VALUES
(4,  'carbonara', '2025-12-01 09:30:00'),
(4,  'italian pasta', '2025-12-01 09:32:00'),
(4,  'quick dinner', '2026-01-05 18:00:00'),
(5,  'green curry', '2025-11-20 17:00:00'),
(5,  'dessert chocolate', '2025-09-10 20:00:00'),
(5,  'fish tacos', '2026-01-11 12:00:00'),
(9,  'healthy breakfast', '2026-01-18 07:00:00'),
(9,  'salmon recipe', '2026-01-07 09:30:00'),
(9,  'meal prep', '2025-12-28 10:00:00'),
(10, 'tofu stir fry', '2025-11-22 12:00:00'),
(10, 'street food', '2025-12-05 14:00:00'),
(10, 'wrap recipes', '2025-12-12 11:00:00'),
(6,  'burger recipe', '2025-08-10 12:00:00'),
(6,  'chocolate cake', '2025-09-05 19:00:00'),
(11, 'pancakes easy', '2026-01-15 08:00:00');

-- CMD-070: Insert 18 activity log records — admin audit trail
-- Tracks recipe approvals, rejections, user management actions
-- UI Link: Admin Stats page (recent activity feed)
INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description, created_at) VALUES
(1, 'recipe_approve', 'recipe', 1,  'Approved recipe: Classic Spaghetti Carbonara', '2025-12-01 10:00:00'),
(1, 'recipe_approve', 'recipe', 3,  'Approved recipe: Thai Green Curry', '2025-11-20 11:00:00'),
(2, 'recipe_approve', 'recipe', 4,  'Approved recipe: Avocado Toast', '2025-10-15 09:00:00'),
(2, 'recipe_approve', 'recipe', 5,  'Approved recipe: Chocolate Lava Cake', '2025-09-05 14:00:00'),
(3, 'recipe_approve', 'recipe', 6,  'Approved recipe: Classic Beef Burger', '2025-08-10 15:00:00'),
(1, 'recipe_approve', 'recipe', 7,  'Approved recipe: Mango Sticky Rice', '2025-07-25 12:00:00'),
(2, 'recipe_approve', 'recipe', 8,  'Approved recipe: Lemon Garlic Salmon', '2026-01-05 16:00:00'),
(3, 'recipe_approve', 'recipe', 9,  'Approved recipe: Chickpea Salad Wrap', '2025-12-12 13:00:00'),
(1, 'recipe_approve', 'recipe', 12, 'Approved recipe: Tomato Basil Soup', '2025-10-30 11:00:00'),
(2, 'recipe_approve', 'recipe', 13, 'Approved recipe: Crispy Fish Tacos', '2026-01-10 14:00:00'),
(3, 'recipe_reject', 'recipe', 11, 'Rejected recipe: Spicy Tofu Stir-Fry - Missing detailed instructions', '2025-11-23 10:00:00'),
(1, 'user_create', 'user', 7,  'New user registration: Amy Wilson (pending)', '2025-11-10 00:00:00'),
(1, 'user_create', 'user', 8,  'New user registration: Kevin Tran (pending)', '2026-01-20 00:00:00'),
(1, 'user_create', 'user', 12, 'New user registration: Omar Hassan (pending)', '2026-01-21 00:00:00'),
(2, 'user_update', 'user', 6,  'Suspended user: Tom Baker - Violation of community guidelines', '2025-10-15 14:00:00'),
(1, 'recipe_approve', 'recipe', 8,  'Approved recipe: Lemon Garlic Salmon', '2026-02-01 10:00:00'),
(2, 'user_update', 'user', 11, 'Updated user status: Lina Patel set to inactive', '2026-02-02 14:00:00'),
(3, 'recipe_reject', 'recipe', 11, 'Re-reviewed and confirmed rejection: Spicy Tofu Stir-Fry', '2026-02-03 09:00:00');

-- CMD-071: Re-enable triggers after stats seeding
SET @DISABLE_TRIGGERS = @PREV_DISABLE_TRIGGERS;
SET @PREV_DISABLE_TRIGGERS = NULL;


-- =============================================================================
-- SECTION 12 — STORED PROCEDURES AND FUNCTIONS
-- Source: 12_stored_procedures.sql
-- Purpose: Encapsulate complex multi-table operations into reusable procedures.
--          Used by backend API endpoints to ensure transactional integrity.
-- =============================================================================

DELIMITER //

-- CMD-072: Stored Procedure — usp_CreateRecipe
-- Creates a new recipe with its ingredients, instructions, and optional image
-- in a single atomic transaction. Rolls back on any failure.
-- UI Link: Create Recipe page → calls POST /api/recipes.php
-- Parameters:
--   p_author_id    — ID of the user creating the recipe
--   p_title        — Recipe title
--   p_description  — Recipe description
--   p_category     — Recipe category (Italian, Asian, Breakfast, etc.)
--   p_difficulty   — Difficulty level (Easy, Medium, Hard)
--   p_prep_time    — Preparation time in minutes
--   p_cook_time    — Cooking time in minutes
--   p_servings     — Number of servings
--   p_image_url    — Optional image URL
--   p_ingredients  — JSON array of {name, quantity, unit} objects
--   p_instructions — JSON array of {instruction_text} objects
--   p_recipe_id    — OUT: returns the new recipe's ID
CREATE PROCEDURE usp_CreateRecipe(
    IN p_author_id    INT,
    IN p_title        VARCHAR(200),
    IN p_description  TEXT,
    IN p_category     VARCHAR(50),
    IN p_difficulty   ENUM('Easy', 'Medium', 'Hard'),
    IN p_prep_time    INT,
    IN p_cook_time    INT,
    IN p_servings     INT,
    IN p_image_url    VARCHAR(500),
    IN p_ingredients  JSON,
    IN p_instructions JSON,
    OUT p_recipe_id   INT
)
BEGIN
    DECLARE v_ingredientCount INT DEFAULT 0;
    DECLARE v_instructionCount INT DEFAULT 0;
    DECLARE v_index INT DEFAULT 0;

    -- Roll back the entire transaction if any error occurs
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_recipe_id = NULL;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error creating recipe. Transaction rolled back.';
    END;

    START TRANSACTION;

    -- Insert the main recipe record (defaults to 'pending' status)
    INSERT INTO recipe (author_id, title, description, category, difficulty,
                        prep_time, cook_time, servings, status)
    VALUES (p_author_id, p_title, p_description, p_category, p_difficulty,
            p_prep_time, p_cook_time, p_servings, 'pending');

    SET p_recipe_id = LAST_INSERT_ID();

    -- Insert the recipe's primary image if provided
    IF p_image_url IS NOT NULL AND p_image_url != '' THEN
        INSERT INTO recipe_image (recipe_id, image_url, display_order)
        VALUES (p_recipe_id, p_image_url, 1);
    END IF;

    -- Loop through the JSON ingredients array and insert each one
    SET v_ingredientCount = JSON_LENGTH(p_ingredients);
    SET v_index = 0;

    WHILE v_index < v_ingredientCount DO
        INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order)
        VALUES (
            p_recipe_id,
            JSON_UNQUOTE(JSON_EXTRACT(p_ingredients, CONCAT('$[', v_index, '].name'))),
            JSON_UNQUOTE(JSON_EXTRACT(p_ingredients, CONCAT('$[', v_index, '].quantity'))),
            JSON_UNQUOTE(JSON_EXTRACT(p_ingredients, CONCAT('$[', v_index, '].unit'))),
            v_index + 1
        );
        SET v_index = v_index + 1;
    END WHILE;

    -- Loop through the JSON instructions array and insert each step
    SET v_instructionCount = JSON_LENGTH(p_instructions);
    SET v_index = 0;

    WHILE v_index < v_instructionCount DO
        INSERT INTO instruction (recipe_id, step_number, instruction_text)
        VALUES (
            p_recipe_id,
            v_index + 1,
            JSON_UNQUOTE(JSON_EXTRACT(p_instructions, CONCAT('$[', v_index, '].instruction_text')))
        );
        SET v_index = v_index + 1;
    END WHILE;

    COMMIT;
END //

-- CMD-073: Stored Procedure — usp_DeleteRecipe
-- Safely deletes a recipe and all its related data (views, reviews, likes,
-- favorites, images, instructions, ingredients) in a single transaction.
-- Logs the deletion in activity_log for admin auditing.
-- UI Link: Admin > Recipes page → Delete button
-- Parameters:
--   p_recipe_id — ID of the recipe to delete
--   p_admin_id  — ID of the admin performing the deletion
CREATE PROCEDURE usp_DeleteRecipe(
    IN p_recipe_id INT,
    IN p_admin_id  INT
)
BEGIN
    DECLARE v_recipeTitle VARCHAR(200);
    DECLARE v_authorId INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error deleting recipe. Transaction rolled back.';
    END;

    -- Verify the recipe exists before attempting deletion
    SELECT title, author_id
    INTO v_recipeTitle, v_authorId
    FROM recipe
    WHERE id = p_recipe_id;

    IF v_recipeTitle IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipe not found.';
    END IF;

    START TRANSACTION;

    -- Delete all related records from child tables first (referential integrity)
    DELETE FROM recipe_view  WHERE recipe_id = p_recipe_id;
    DELETE FROM review       WHERE recipe_id = p_recipe_id;
    DELETE FROM like_record  WHERE recipe_id = p_recipe_id;
    DELETE FROM favorite     WHERE recipe_id = p_recipe_id;
    DELETE FROM recipe_image WHERE recipe_id = p_recipe_id;
    DELETE FROM instruction  WHERE recipe_id = p_recipe_id;
    DELETE FROM ingredient   WHERE recipe_id = p_recipe_id;

    -- Delete the recipe itself
    DELETE FROM recipe WHERE id = p_recipe_id;

    -- Log the admin action for audit trail
    INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
    VALUES (p_admin_id, 'recipe_delete', 'recipe', p_recipe_id,
            CONCAT('Deleted recipe: ', v_recipeTitle, ' (author_id: ', v_authorId, ')'));

    COMMIT;
END //

-- CMD-074: Stored Procedure — usp_ApproveRecipe
-- Approves or rejects a pending recipe and logs the action.
-- Only works on recipes with 'pending' status.
-- UI Link: Admin > Recipes page → Approve/Reject buttons
-- Parameters:
--   p_recipe_id — ID of the recipe to approve/reject
--   p_admin_id  — ID of the admin performing the action
--   p_action    — 'approve' or 'reject'
--   p_reason    — Optional rejection reason (appended to activity log)
CREATE PROCEDURE usp_ApproveRecipe(
    IN p_recipe_id INT,
    IN p_admin_id  INT,
    IN p_action    VARCHAR(10),
    IN p_reason    VARCHAR(500)
)
BEGIN
    DECLARE v_currentStatus VARCHAR(20);
    DECLARE v_recipeTitle VARCHAR(200);
    DECLARE v_newStatus VARCHAR(20);
    DECLARE v_actionType VARCHAR(50);
    DECLARE v_description VARCHAR(500);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error processing recipe approval. Transaction rolled back.';
    END;

    -- Fetch current status and title for validation
    SELECT status, title
    INTO v_currentStatus, v_recipeTitle
    FROM recipe
    WHERE id = p_recipe_id;

    IF v_currentStatus IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipe not found.';
    END IF;

    -- Only pending recipes can be approved or rejected
    IF v_currentStatus != 'pending' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipe is not in pending status.';
    END IF;

    IF p_action NOT IN ('approve', 'reject') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid action. Must be "approve" or "reject".';
    END IF;

    -- Determine new status and log description based on action
    IF p_action = 'approve' THEN
        SET v_newStatus = 'published';
        SET v_actionType = 'recipe_approve';
        SET v_description = CONCAT('Approved recipe: ', v_recipeTitle);
    ELSE
        SET v_newStatus = 'rejected';
        SET v_actionType = 'recipe_reject';
        SET v_description = CONCAT('Rejected recipe: ', v_recipeTitle);
        IF p_reason IS NOT NULL AND p_reason != '' THEN
            SET v_description = CONCAT(v_description, ' - ', p_reason);
        END IF;
    END IF;

    START TRANSACTION;

    -- Update the recipe status
    UPDATE recipe
    SET status = v_newStatus, updated_at = NOW()
    WHERE id = p_recipe_id;

    -- Log the admin action
    INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
    VALUES (p_admin_id, v_actionType, 'recipe', p_recipe_id, v_description);

    COMMIT;
END //

-- CMD-075: Stored Procedure — usp_GetRecipeStat
-- Retrieves comprehensive statistics for a single recipe.
-- UI Link: Recipe Detail page stats summary, Admin recipe analytics
-- Parameters:
--   p_recipe_id — ID of the recipe to get stats for
CREATE PROCEDURE usp_GetRecipeStat(
    IN p_recipe_id INT
)
BEGIN
    SELECT
        r.id AS recipe_id,
        r.title,
        r.status,
        u.username AS author_name,
        DATE_FORMAT(r.created_at, '%Y-%m-%d') AS created_date,
        (SELECT COUNT(*) FROM recipe_view WHERE recipe_id = p_recipe_id)                AS total_views,
        (SELECT COUNT(*) FROM like_record WHERE recipe_id = p_recipe_id)                AS total_likes,
        (SELECT COUNT(*) FROM favorite    WHERE recipe_id = p_recipe_id)                AS total_favorites,
        (SELECT COUNT(*) FROM review      WHERE recipe_id = p_recipe_id)                AS total_reviews,
        (SELECT ROUND(AVG(rating), 2) FROM review WHERE recipe_id = p_recipe_id)        AS avg_rating,
        (SELECT MIN(rating) FROM review WHERE recipe_id = p_recipe_id)                  AS min_rating,
        (SELECT MAX(rating) FROM review WHERE recipe_id = p_recipe_id)                  AS max_rating,
        (SELECT COUNT(DISTINCT user_id) FROM recipe_view WHERE recipe_id = p_recipe_id) AS unique_viewers
    FROM recipe r
    INNER JOIN `user` u ON r.author_id = u.id
    WHERE r.id = p_recipe_id;
END //

-- CMD-076: Function — fn_CalculateAvgRating
-- Calculates the average rating for a recipe, returning 0.00 if no reviews exist.
-- Used internally by views and other procedures.
CREATE FUNCTION fn_CalculateAvgRating(
    p_recipe_id INT
)
RETURNS DECIMAL(3, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avgRating DECIMAL(3, 2);

    SELECT ROUND(AVG(rating), 2)
    INTO v_avgRating
    FROM review
    WHERE recipe_id = p_recipe_id;

    -- Return 0.00 instead of NULL when no reviews exist
    IF v_avgRating IS NULL THEN
        SET v_avgRating = 0.00;
    END IF;

    RETURN v_avgRating;
END //

DELIMITER ;


-- =============================================================================
-- SECTION 13 — TRIGGERS
-- Source: 13_triggers.sql
-- Purpose: Automatically update related tables when data changes.
--          All triggers check @DISABLE_TRIGGERS to allow bulk seeding.
-- =============================================================================

DELIMITER //

-- CMD-077: Trigger — trg_RecipeView_UpdateStat
-- Fires AFTER INSERT on recipe_view: increments today's daily_stat counters.
-- UI Link: Every time a user opens a recipe detail page, this updates Admin Stats.
CREATE TRIGGER trg_RecipeView_UpdateStat
AFTER INSERT ON recipe_view
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        INSERT INTO daily_stat (stat_date, page_view_count, active_user_count, new_user_count, recipe_view_count)
        VALUES (CURDATE(), 1, 0, 0, 1)
        ON DUPLICATE KEY UPDATE
            recipe_view_count = recipe_view_count + 1,
            page_view_count   = page_view_count + 1;
    END IF;
END //

-- CMD-078: Trigger — trg_User_UpdateLastActive
-- Fires BEFORE UPDATE on session: updates the user's last_active timestamp.
-- UI Link: Keeps the "Last Active" field current in Admin > User List.
CREATE TRIGGER trg_User_UpdateLastActive
BEFORE UPDATE ON session
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        UPDATE `user`
        SET last_active = NOW()
        WHERE id = NEW.user_id;
    END IF;
END //

-- CMD-079: Trigger — trg_Recipe_DeleteCleanup
-- Fires BEFORE DELETE on recipe: logs the deletion in activity_log if not
-- already logged by a stored procedure (prevents duplicate audit entries).
-- UI Link: Safety net for any recipe deletion path.
CREATE TRIGGER trg_Recipe_DeleteCleanup
BEFORE DELETE ON recipe
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        IF NOT EXISTS (
            SELECT 1 FROM activity_log
            WHERE target_type = 'recipe'
              AND target_id = OLD.id
              AND action_type = 'recipe_delete'
              AND created_at >= DATE_SUB(NOW(), INTERVAL 5 SECOND)
        ) THEN
            INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
            VALUES (
                COALESCE(@current_admin_id, OLD.author_id),
                'recipe_delete',
                'recipe',
                OLD.id,
                CONCAT('Trigger-logged deletion of recipe: ', OLD.title)
            );
        END IF;
    END IF;
END //

-- CMD-080: Trigger — trg_User_NewUserStat
-- Fires AFTER INSERT on user: increments new_user_count and active_user_count
-- in today's daily_stat row.
-- UI Link: Admin Stats "New Users" card reflects real-time registrations.
CREATE TRIGGER trg_User_NewUserStat
AFTER INSERT ON `user`
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        INSERT INTO daily_stat (stat_date, page_view_count, active_user_count, new_user_count, recipe_view_count)
        VALUES (CURDATE(), 0, 1, 1, 0)
        ON DUPLICATE KEY UPDATE
            new_user_count    = new_user_count + 1,
            active_user_count = active_user_count + 1;
    END IF;
END //

-- CMD-081: Trigger — trg_Recipe_SetTimestamp
-- Fires BEFORE INSERT on recipe: ensures created_at and updated_at are set
-- even if the INSERT statement omits them.
CREATE TRIGGER trg_Recipe_SetTimestamp
BEFORE INSERT ON recipe
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        IF NEW.created_at IS NULL THEN
            SET NEW.created_at = NOW();
        END IF;
        IF NEW.updated_at IS NULL THEN
            SET NEW.updated_at = NOW();
        END IF;
    END IF;
END //

-- CMD-082: Trigger — trg_User_SetTimestamp
-- Fires BEFORE INSERT on user: ensures created_at and updated_at are set
-- even if the INSERT statement omits them.
CREATE TRIGGER trg_User_SetTimestamp
BEFORE INSERT ON `user`
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        IF NEW.created_at IS NULL THEN
            SET NEW.created_at = NOW();
        END IF;
        IF NEW.updated_at IS NULL THEN
            SET NEW.updated_at = NOW();
        END IF;
    END IF;
END //

DELIMITER ;


-- =============================================================================
-- END OF CONSOLIDATED SQL SCRIPT
-- =============================================================================
-- Total commands: CMD-001 through CMD-082
--
-- To run this script:
--   1. Open phpMyAdmin or MySQL CLI
--   2. Execute this entire file (it will drop and recreate everything)
--   3. Verify with: SELECT COUNT(*) FROM user; SELECT COUNT(*) FROM recipe;
--
-- Note: Query scripts (09_common_queries.sql, 10_admin_queries.sql,
--       11_analytics_queries.sql) are excluded — they contain SELECT-only
--       queries used for reference and testing, not schema/data commands.
-- =============================================================================
