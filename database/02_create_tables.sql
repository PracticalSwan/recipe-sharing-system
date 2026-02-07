-- ============================================================================
-- Script:      02_create_tables.sql
-- Description: Creates all 13 core tables for the CookHub Recipe Sharing System
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Tables (in dependency order):
--   1.  user           - User accounts and profiles
--   2.  session        - Server-side session management
--   3.  recipe         - Recipe metadata and publication status
--   4.  ingredient     - Recipe ingredients with quantities
--   5.  instruction    - Step-by-step cooking instructions
--   6.  recipe_image   - Multiple images per recipe
--   7.  review         - User reviews with star ratings
--   8.  favorite       - User-recipe favorites (N:M junction)
--   9.  like_record    - User-recipe likes (N:M junction)
--   10. recipe_view    - Authenticated user view tracking
--   11. search_history - User search query history
--   12. daily_stat     - Pre-aggregated daily statistics
--   13. activity_log   - Admin action audit trail
-- ============================================================================

USE cookhub;

-- Disable foreign key checks during table creation for flexibility
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- 1. USER TABLE
-- Stores all user accounts: admins, active users, pending, inactive, suspended
-- ============================================================================
DROP TABLE IF EXISTS user;
CREATE TABLE user (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(100) NOT NULL,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(100) NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    birthday        DATE DEFAULT NULL,
    role            ENUM('admin', 'user') NOT NULL DEFAULT 'user',
    status          ENUM('active', 'inactive', 'pending', 'suspended') NOT NULL DEFAULT 'pending',
    joined_date     DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_active     DATETIME DEFAULT NULL,
    avatar_url      TEXT DEFAULT NULL,
    bio             TEXT DEFAULT NULL,
    location        VARCHAR(100) DEFAULT NULL,
    cooking_level   VARCHAR(50) DEFAULT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_user_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. SESSION TABLE
-- Server-side session management for authentication
-- ============================================================================
DROP TABLE IF EXISTS session;
CREATE TABLE session (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    session_token   VARCHAR(255) NOT NULL,
    expires_at      DATETIME NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_session_token (session_token),
    CONSTRAINT fk_session_user
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 3. RECIPE TABLE
-- Recipe metadata with publication workflow (pending → published/rejected)
-- ============================================================================
DROP TABLE IF EXISTS recipe;
CREATE TABLE recipe (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(200) NOT NULL,
    description     TEXT DEFAULT NULL,
    category        VARCHAR(50) DEFAULT NULL,
    difficulty      ENUM('Easy', 'Medium', 'Hard') NOT NULL DEFAULT 'Easy',
    prep_time       INT DEFAULT NULL COMMENT 'Preparation time in minutes',
    cook_time       INT DEFAULT NULL COMMENT 'Cooking time in minutes',
    servings        INT DEFAULT NULL,
    author_id       INT NOT NULL,
    status          ENUM('published', 'pending', 'rejected') NOT NULL DEFAULT 'pending',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_recipe_author
        FOREIGN KEY (author_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 4. INGREDIENT TABLE
-- Individual ingredients linked to a recipe with quantity and unit
-- ============================================================================
DROP TABLE IF EXISTS ingredient;
CREATE TABLE ingredient (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id       INT NOT NULL,
    name            VARCHAR(200) NOT NULL,
    quantity        VARCHAR(50) DEFAULT NULL,
    unit            VARCHAR(50) DEFAULT NULL,
    sort_order      INT DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_ingredient_recipe
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 5. INSTRUCTION TABLE
-- Step-by-step cooking instructions for each recipe
-- ============================================================================
DROP TABLE IF EXISTS instruction;
CREATE TABLE instruction (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id       INT NOT NULL,
    step_number     INT NOT NULL,
    instruction_text TEXT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_instruction_recipe
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 6. RECIPE_IMAGE TABLE
-- Multiple images per recipe with display ordering
-- ============================================================================
DROP TABLE IF EXISTS recipe_image;
CREATE TABLE recipe_image (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id       INT NOT NULL,
    image_url       TEXT NOT NULL,
    display_order   INT DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_recipe_image_recipe
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 7. REVIEW TABLE
-- User reviews with 1-5 star ratings (one review per user per recipe)
-- ============================================================================
DROP TABLE IF EXISTS review;
CREATE TABLE review (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    recipe_id       INT NOT NULL,
    rating          INT NOT NULL,
    comment         TEXT DEFAULT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_review_rating CHECK (rating BETWEEN 1 AND 5),
    UNIQUE KEY uk_user_recipe_review (user_id, recipe_id),
    CONSTRAINT fk_review_user
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_review_recipe
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 8. FAVORITE TABLE
-- N:M junction table for saved/bookmarked recipes
-- ============================================================================
DROP TABLE IF EXISTS favorite;
CREATE TABLE favorite (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    recipe_id       INT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_user_recipe_favorite (user_id, recipe_id),
    CONSTRAINT fk_favorite_user
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_favorite_recipe
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 9. LIKE_RECORD TABLE
-- N:M junction table for recipe likes (one like per user per recipe)
-- ============================================================================
DROP TABLE IF EXISTS like_record;
CREATE TABLE like_record (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    recipe_id       INT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_user_recipe_like (user_id, recipe_id),
    CONSTRAINT fk_like_record_user
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_like_record_recipe
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 10. RECIPE_VIEW TABLE
-- Tracks recipe views by authenticated users only (no guest tracking)
-- ============================================================================
DROP TABLE IF EXISTS recipe_view;
CREATE TABLE recipe_view (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id       INT NOT NULL,
    user_id         INT NOT NULL,
    viewed_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_recipe_viewed (recipe_id, viewed_at),
    INDEX idx_user_viewed (user_id, viewed_at),
    CONSTRAINT fk_recipe_view_recipe
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_recipe_view_user
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 11. SEARCH_HISTORY TABLE
-- Stores user search queries for personalized suggestions
-- ============================================================================
DROP TABLE IF EXISTS search_history;
CREATE TABLE search_history (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    query           TEXT NOT NULL,
    searched_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_search_history_user
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 12. DAILY_STAT TABLE
-- Pre-aggregated daily statistics for fast dashboard queries
-- ============================================================================
DROP TABLE IF EXISTS daily_stat;
CREATE TABLE daily_stat (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    stat_date           DATE NOT NULL,
    page_view_count     INT DEFAULT 0,
    active_user_count   INT DEFAULT 0,
    new_user_count      INT DEFAULT 0,
    recipe_view_count   INT DEFAULT 0,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_daily_stat_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 13. ACTIVITY_LOG TABLE
-- Audit trail for admin actions (admin_id SET NULL on admin deletion)
-- ============================================================================
DROP TABLE IF EXISTS activity_log;
CREATE TABLE activity_log (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    admin_id        INT DEFAULT NULL,
    action_type     ENUM(
                        'user_create',
                        'user_update',
                        'user_delete',
                        'recipe_approve',
                        'recipe_reject',
                        'recipe_delete'
                    ) NOT NULL,
    target_type     VARCHAR(50) DEFAULT NULL,
    target_id       INT DEFAULT NULL,
    description     TEXT DEFAULT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_activity_log_admin
        FOREIGN KEY (admin_id) REFERENCES user(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Verify all tables were created
SELECT TABLE_NAME, ENGINE, TABLE_ROWS, TABLE_COLLATION
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'cookhub'
ORDER BY TABLE_NAME;
