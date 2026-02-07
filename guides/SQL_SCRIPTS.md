# CookHub - Complete SQL Scripts Reference

> **Project:** Recipe Sharing System - CSX3006 Database Systems  
> **Generated:** 2026-02-07  
> **Database:** MySQL / MariaDB (XAMPP)  
> **Character Set:** UTF8MB4 with `utf8mb4_unicode_ci` collation

---

## Table of Contents

1. [01 - Create Database](#01---create-database)
2. [02 - Create Tables](#02---create-tables)
3. [03 - Create Indexes](#03---create-indexes)
4. [04 - Create Views](#04---create-views)
5. [05 - Seed Users](#05---seed-users)
6. [06 - Seed Recipes](#06---seed-recipes)
7. [07 - Seed Reviews, Likes & Favorites](#07---seed-reviews-likes--favorites)
8. [08 - Seed Stats & Activity Logs](#08---seed-stats--activity-logs)
9. [09 - Common Queries](#09---common-queries)
10. [10 - Admin Queries](#10---admin-queries)
11. [11 - Analytics Queries](#11---analytics-queries)
12. [12 - Stored Procedures](#12---stored-procedures)
13. [13 - Triggers](#13---triggers)
14. [14 - Backup & Restore](#14---backup--restore)

---

## Execution Order

Run the scripts in the following order to build the complete database:

| Step | Script | Description |
|------|--------|-------------|
| 1 | `01_create_database.sql` | Create the database |
| 2 | `02_create_tables.sql` | Create all 13 tables |
| 3 | `03_create_indexes.sql` | Add performance indexes |
| 4 | `04_create_views.sql` | Create 2 views |
| 5 | `12_stored_procedures.sql` | Create 4 SPs + 1 function |
| 6 | `13_triggers.sql` | Create 6 triggers |
| 7 | `SET @DISABLE_TRIGGERS = 1;` | Disable triggers for seeding |
| 8 | `05_seed_users.sql` | Seed 12 users |
| 9 | `06_seed_recipes.sql` | Seed 13 recipes + ingredients + instructions + images |
| 10 | `07_seed_reviews.sql` | Seed reviews, likes, favorites |
| 11 | `08_seed_stats.sql` | Seed views, stats, search history, activity logs |
| 12 | `SET @DISABLE_TRIGGERS = NULL;` | Re-enable triggers |
| 13 | `14_backup_restore.sql` | Health check verification |

---

## Database Schema Summary

| Table | Description | Key Relationships |
|-------|-------------|-------------------|
| `user` | User accounts (admin & regular) | — |
| `session` | Authentication sessions | FK → user |
| `recipe` | Recipe metadata | FK → user (author) |
| `ingredient` | Recipe ingredients | FK → recipe |
| `instruction` | Cooking steps | FK → recipe |
| `recipe_image` | Recipe images | FK → recipe |
| `review` | Star ratings & comments | FK → user, recipe |
| `favorite` | Saved recipes (N:M) | FK → user, recipe |
| `like_record` | Recipe likes (N:M) | FK → user, recipe |
| `recipe_view` | View tracking | FK → user, recipe |
| `search_history` | User search queries | FK → user |
| `daily_stat` | Aggregated daily stats | — |
| `activity_log` | Admin audit trail | FK → user (admin) |

---

## 01 - Create Database

```sql
-- ============================================================================
-- Script:      01_create_database.sql
-- Description: Creates the CookHub Recipe Sharing System database
-- ============================================================================

DROP DATABASE IF EXISTS cookhub;

CREATE DATABASE cookhub
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cookhub;

SELECT SCHEMA_NAME, DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME
FROM INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'cookhub';
```

---

## 02 - Create Tables

```sql
-- ============================================================================
-- Script:      02_create_tables.sql
-- Description: Creates all 13 core tables for the CookHub Recipe Sharing System
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

SET FOREIGN_KEY_CHECKS = 0;

-- 1. USER TABLE
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

-- 2. SESSION TABLE
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

-- 3. RECIPE TABLE
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

-- 4. INGREDIENT TABLE
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

-- 5. INSTRUCTION TABLE
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

-- 6. RECIPE_IMAGE TABLE
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

-- 7. REVIEW TABLE
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

-- 8. FAVORITE TABLE
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

-- 9. LIKE_RECORD TABLE
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

-- 10. RECIPE_VIEW TABLE
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

-- 11. SEARCH_HISTORY TABLE
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

-- 12. DAILY_STAT TABLE
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

-- 13. ACTIVITY_LOG TABLE
DROP TABLE IF EXISTS activity_log;
CREATE TABLE activity_log (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    admin_id        INT DEFAULT NULL,
    action_type     ENUM(
                        'user_create', 'user_update', 'user_delete',
                        'recipe_approve', 'recipe_reject', 'recipe_delete'
                    ) NOT NULL,
    target_type     VARCHAR(50) DEFAULT NULL,
    target_id       INT DEFAULT NULL,
    description     TEXT DEFAULT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_activity_log_admin
        FOREIGN KEY (admin_id) REFERENCES user(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

SELECT TABLE_NAME, ENGINE, TABLE_ROWS, TABLE_COLLATION
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'cookhub'
ORDER BY TABLE_NAME;
```

---

## 03 - Create Indexes

```sql
-- ============================================================================
-- Script:      03_create_indexes.sql
-- Description: Creates additional indexes for query performance optimization
-- ============================================================================

USE cookhub;

-- USER TABLE INDEXES
CREATE INDEX idx_user_email ON user (email);
CREATE INDEX idx_user_role_status ON user (role, status);
CREATE INDEX idx_user_joined_date ON user (joined_date);

-- RECIPE TABLE INDEXES
CREATE INDEX idx_recipe_author_id ON recipe (author_id);
CREATE INDEX idx_recipe_status ON recipe (status);
CREATE INDEX idx_recipe_category ON recipe (category);
CREATE INDEX idx_recipe_author_status ON recipe (author_id, status);
CREATE INDEX idx_recipe_created_at ON recipe (created_at);

-- REVIEW TABLE INDEXES
CREATE INDEX idx_review_recipe_id ON review (recipe_id);
CREATE INDEX idx_review_user_id ON review (user_id);

-- FAVORITE TABLE INDEXES
CREATE INDEX idx_favorite_user_id ON favorite (user_id);
CREATE INDEX idx_favorite_recipe_id ON favorite (recipe_id);

-- LIKE_RECORD TABLE INDEXES
CREATE INDEX idx_like_record_recipe_id ON like_record (recipe_id);
CREATE INDEX idx_like_record_user_id ON like_record (user_id);

-- SEARCH_HISTORY TABLE INDEXES
CREATE INDEX idx_search_history_user_id ON search_history (user_id);
CREATE INDEX idx_search_history_searched_at ON search_history (user_id, searched_at);

-- DAILY_STAT TABLE INDEXES
CREATE INDEX idx_daily_stat_date ON daily_stat (stat_date);

-- ACTIVITY_LOG TABLE INDEXES
CREATE INDEX idx_activity_log_admin_id ON activity_log (admin_id);
CREATE INDEX idx_activity_log_created_at ON activity_log (created_at);
CREATE INDEX idx_activity_log_admin_created ON activity_log (admin_id, created_at);

-- SESSION TABLE INDEXES
CREATE INDEX idx_session_token ON session (session_token);
CREATE INDEX idx_session_user_id ON session (user_id);
CREATE INDEX idx_session_expires_at ON session (expires_at);

-- INGREDIENT TABLE INDEXES
CREATE INDEX idx_ingredient_recipe_order ON ingredient (recipe_id, sort_order);

-- INSTRUCTION TABLE INDEXES
CREATE INDEX idx_instruction_recipe_step ON instruction (recipe_id, step_number);

SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'cookhub'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
```

---

## 04 - Create Views

```sql
-- ============================================================================
-- Script:      04_create_views.sql
-- Description: Creates database views for commonly accessed aggregated data
-- ============================================================================

USE cookhub;

-- VIEW 1: vw_recipe_with_stat
DROP VIEW IF EXISTS vw_recipe_with_stat;

CREATE VIEW vw_recipe_with_stat AS
SELECT
    r.id                AS recipe_id,
    r.title             AS recipe_title,
    r.description       AS recipe_description,
    r.category          AS recipe_category,
    r.difficulty        AS recipe_difficulty,
    r.prep_time, r.cook_time, r.servings,
    r.status            AS recipe_status,
    r.created_at        AS recipe_created_at,
    r.updated_at        AS recipe_updated_at,
    u.id                AS author_id,
    u.username          AS author_username,
    u.first_name        AS author_first_name,
    u.last_name         AS author_last_name,
    u.avatar_url        AS author_avatar_url,
    COALESCE(lk.like_count, 0)      AS like_count,
    COALESCE(vw.view_count, 0)      AS view_count,
    COALESCE(rv.review_count, 0)    AS review_count,
    COALESCE(rv.avg_rating, 0)      AS avg_rating,
    COALESCE(fv.favorite_count, 0)  AS favorite_count,
    (SELECT ri.image_url FROM recipe_image ri
     WHERE ri.recipe_id = r.id ORDER BY ri.display_order ASC LIMIT 1) AS primary_image_url
FROM recipe r
    INNER JOIN user u ON r.author_id = u.id
    LEFT JOIN (SELECT recipe_id, COUNT(*) AS like_count FROM like_record GROUP BY recipe_id) lk ON lk.recipe_id = r.id
    LEFT JOIN (SELECT recipe_id, COUNT(*) AS view_count FROM recipe_view GROUP BY recipe_id) vw ON vw.recipe_id = r.id
    LEFT JOIN (SELECT recipe_id, COUNT(*) AS review_count, ROUND(AVG(rating), 1) AS avg_rating FROM review GROUP BY recipe_id) rv ON rv.recipe_id = r.id
    LEFT JOIN (SELECT recipe_id, COUNT(*) AS favorite_count FROM favorite GROUP BY recipe_id) fv ON fv.recipe_id = r.id;

-- VIEW 2: vw_user_dashboard_stat
DROP VIEW IF EXISTS vw_user_dashboard_stat;

CREATE VIEW vw_user_dashboard_stat AS
SELECT
    u.id AS user_id, u.username, u.email, u.role, u.status,
    u.joined_date, u.last_active, u.avatar_url,
    COALESCE(rc.recipe_count, 0)           AS recipe_count,
    COALESCE(rc.published_recipe_count, 0) AS published_recipe_count,
    COALESCE(rc.pending_recipe_count, 0)   AS pending_recipe_count,
    COALESCE(fv.favorite_count, 0)         AS favorite_count,
    COALESCE(rv.review_count, 0)           AS review_count,
    COALESCE(lk.like_given_count, 0)       AS like_given_count,
    COALESCE(lk_rcv.like_received_count, 0) AS like_received_count
FROM user u
    LEFT JOIN (
        SELECT author_id, COUNT(*) AS recipe_count,
               SUM(CASE WHEN status = 'published' THEN 1 ELSE 0 END) AS published_recipe_count,
               SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_recipe_count
        FROM recipe GROUP BY author_id
    ) rc ON rc.author_id = u.id
    LEFT JOIN (SELECT user_id, COUNT(*) AS favorite_count FROM favorite GROUP BY user_id) fv ON fv.user_id = u.id
    LEFT JOIN (SELECT user_id, COUNT(*) AS review_count FROM review GROUP BY user_id) rv ON rv.user_id = u.id
    LEFT JOIN (SELECT user_id, COUNT(*) AS like_given_count FROM like_record GROUP BY user_id) lk ON lk.user_id = u.id
    LEFT JOIN (
        SELECT r.author_id, COUNT(lr.id) AS like_received_count
        FROM like_record lr INNER JOIN recipe r ON lr.recipe_id = r.id
        GROUP BY r.author_id
    ) lk_rcv ON lk_rcv.author_id = u.id;

SELECT TABLE_NAME, VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'cookhub';
```

---

## 05 - Seed Users

```sql
-- ============================================================================
-- Script:      05_seed_users.sql
-- Description: Seed data for user table (3 admins + 9 regular users)
-- ============================================================================
-- Password reference (for testing only):
--   admin@cookhub.com    → admin       olivia@cookhub.com   → admin
--   marcus@cookhub.com   → admin       user@cookhub.com     → user
--   maria@cookhub.com    → maria123    tom@cookhub.com      → tom123
--   amy@cookhub.com      → amy123      kevin@cookhub.com    → kevin123
--   sarah@cookhub.com    → sarah123    daniel@cookhub.com   → daniel123
--   lina@cookhub.com     → lina123     omar@cookhub.com     → omar123
-- ============================================================================

USE cookhub;

SET @DISABLE_TRIGGERS = 1;

-- ADMIN USERS (3 accounts)
INSERT INTO user (
    username, first_name, last_name, email, password_hash,
    birthday, role, status, joined_date, last_active,
    avatar_url, bio, location, cooking_level
) VALUES
('Admin User', 'Admin', 'User', 'admin@cookhub.com',
 '$2y$12$LJ3m4ys3Gz8y/nKBk9MQY.7pLDVKx.G3rXMqp1FLzH5b4vE8VujaW',
 '1990-01-01', 'admin', 'active', '2025-06-01 00:00:00', NOW(),
 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin',
 'System Administrator', 'Server Room', 'Professional'),
('Olivia Admin', 'Olivia', 'Nguyen', 'olivia@cookhub.com',
 '$2y$12$LJ3m4ys3Gz8y/nKBk9MQY.7pLDVKx.G3rXMqp1FLzH5b4vE8VujaW',
 '1986-04-12', 'admin', 'active', '2025-09-01 00:00:00', DATE_SUB(NOW(), INTERVAL 2 HOUR),
 'https://api.dicebear.com/7.x/avataaars/svg?seed=olivia-admin',
 'Content moderation lead.', 'Boston', 'Advanced'),
('Marcus Admin', 'Marcus', 'Lee', 'marcus@cookhub.com',
 '$2y$12$LJ3m4ys3Gz8y/nKBk9MQY.7pLDVKx.G3rXMqp1FLzH5b4vE8VujaW',
 '1983-11-22', 'admin', 'active', '2025-10-05 00:00:00', DATE_SUB(NOW(), INTERVAL 90 MINUTE),
 'https://api.dicebear.com/7.x/avataaars/svg?seed=marcus-admin',
 'Operations admin.', 'Seattle', 'Intermediate');

-- REGULAR USERS (9 accounts)
INSERT INTO user (
    username, first_name, last_name, email, password_hash,
    birthday, role, status, joined_date, last_active,
    avatar_url, bio, location, cooking_level
) VALUES
('John Doe', 'John', 'Doe', 'user@cookhub.com',
 '$2y$12$wG9bF3v2Rk4Qx8L1mN5pYuH7jD0eA6iC3oP2sT9vX4w1zB8kM5nR',
 '1995-06-15', 'user', 'active', '2025-06-15 00:00:00', DATE_SUB(NOW(), INTERVAL 1 HOUR),
 'https://api.dicebear.com/7.x/avataaars/svg?seed=john',
 'Love cooking italian food!', 'New York', 'Intermediate'),
('Maria Garcia', 'Maria', 'Garcia', 'maria@cookhub.com',
 '$2y$12$aR3kL7xP9nQ2wE5tY8uI0oBf4gH6jM1dC3vS7pZ0rN9mX2wK5lAy',
 '1988-03-20', 'user', 'inactive', '2025-03-20 00:00:00', DATE_SUB(NOW(), INTERVAL 7 DAY),
 'https://api.dicebear.com/7.x/avataaars/svg?seed=maria',
 'Professional chef specializing in Mediterranean cuisine.', 'Los Angeles', 'Professional'),
('Tom Baker', 'Tom', 'Baker', 'tom@cookhub.com',
 '$2y$12$bD4mN8yR0oS3xF6uZ9vJ1pCg5hI7kO2eA4wT8qB1sP0nL3rM6jXz',
 '1992-08-01', 'user', 'suspended', '2025-08-01 00:00:00', DATE_SUB(NOW(), INTERVAL 30 DAY),
 'https://api.dicebear.com/7.x/avataaars/svg?seed=tom',
 'Passionate about baking and desserts!', 'Chicago', 'Intermediate'),
('Amy Wilson', 'Amy', 'Wilson', 'amy@cookhub.com',
 '$2y$12$cE5nO9zS1pT4yG7vA0wK2qDh6iJ8lP3fB5xU9rC2tQ1oM4sN7kYa',
 '1998-11-10', 'user', 'pending', '2025-11-10 00:00:00', NULL,
 'https://api.dicebear.com/7.x/avataaars/svg?seed=amy',
 'New to the platform.', 'Denver', 'Beginner'),
('Kevin Tran', 'Kevin', 'Tran', 'kevin@cookhub.com',
 '$2y$12$dF6oP0aT2qU5zH8wB1xL3rEi7jK9mQ4gC6yV0sD3uR2pN5tO8lZb',
 '1996-02-18', 'user', 'pending', '2026-01-20 00:00:00', NULL,
 'https://api.dicebear.com/7.x/avataaars/svg?seed=kevin',
 'Here to learn quick meals.', 'Austin', 'Beginner'),
('Sarah Kim', 'Sarah', 'Kim', 'sarah@cookhub.com',
 '$2y$12$eG7pQ1bU3rV6aI9xC2yM4sFj8kL0nR5hD7zW1tE4vS3qO6uP9mAc',
 '1991-07-09', 'user', 'active', '2025-12-28 00:00:00', DATE_SUB(NOW(), INTERVAL 30 MINUTE),
 'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
 'Healthy meal prep enthusiast.', 'San Diego', 'Intermediate'),
('Daniel Rivera', 'Daniel', 'Rivera', 'daniel@cookhub.com',
 '$2y$12$fH8qR2cV4sW7bJ0yD3zN5tGk9lM1oS6iE8aX2uF5wT4rP7vQ0nBd',
 '1989-05-30', 'user', 'active', '2025-12-05 00:00:00', DATE_SUB(NOW(), INTERVAL 67 MINUTE),
 'https://api.dicebear.com/7.x/avataaars/svg?seed=daniel',
 'Street food lover.', 'Miami', 'Advanced'),
('Lina Patel', 'Lina', 'Patel', 'lina@cookhub.com',
 '$2y$12$gI9rS3dW5tX8cK1zE4aO6uHl0mN2pT7jF9bY3vG6xU5sQ8wR1oCe',
 '2000-09-14', 'user', 'inactive', '2025-11-01 00:00:00', DATE_SUB(NOW(), INTERVAL 10 DAY),
 'https://api.dicebear.com/7.x/avataaars/svg?seed=lina',
 'Baking beginner.', 'Portland', 'Beginner'),
('Omar Hassan', 'Omar', 'Hassan', 'omar@cookhub.com',
 '$2y$12$hJ0sT4eX6uY9dL2aF5bP7vIm1nO3qU8kG0cZ4wH7yV6tR9xS2pDf',
 '1993-03-03', 'user', 'pending', '2026-01-21 00:00:00', NULL,
 'https://api.dicebear.com/7.x/avataaars/svg?seed=omar',
 'Trying new cuisines.', 'Phoenix', 'Beginner');

SET @DISABLE_TRIGGERS = NULL;

SELECT id, username, email, role, status, joined_date FROM user ORDER BY id;
```

---

## 06 - Seed Recipes

```sql
-- ============================================================================
-- Script:      06_seed_recipes.sql
-- Description: Seed data for recipe, ingredient, instruction, recipe_image tables
-- ============================================================================
-- User ID mapping:
--   1=Admin, 2=Olivia, 3=Marcus, 4=John, 5=Maria, 6=Tom,
--   7=Amy, 8=Kevin, 9=Sarah, 10=Daniel, 11=Lina, 12=Omar
-- ============================================================================

USE cookhub;

-- RECIPES (13 recipes)
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

-- INGREDIENTS (4 per recipe)
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(1, 'Spaghetti', '400', 'g', 1), (1, 'Eggs', '4', '', 2),
(1, 'Pancetta', '200', 'g', 3), (1, 'Parmesan', '100', 'g', 4),
(2, 'Flour', '200', 'g', 1), (2, 'Milk', '250', 'ml', 2),
(2, 'Eggs', '2', '', 3), (2, 'Sugar', '2', 'tbsp', 4),
(3, 'Green curry paste', '3', 'tbsp', 1), (3, 'Coconut milk', '400', 'ml', 2),
(3, 'Chicken breast', '500', 'g', 3), (3, 'Thai basil', '1', 'bunch', 4),
(4, 'Avocado', '2', '', 1), (4, 'Sourdough bread', '4', 'slices', 2),
(4, 'Eggs', '4', '', 3), (4, 'Chili flakes', '1', 'tsp', 4),
(5, 'Dark chocolate', '200', 'g', 1), (5, 'Butter', '100', 'g', 2),
(5, 'Eggs', '4', '', 3), (5, 'Sugar', '100', 'g', 4),
(6, 'Ground beef', '500', 'g', 1), (6, 'Burger buns', '4', '', 2),
(6, 'Cheese slices', '4', '', 3), (6, 'Lettuce', '4', 'leaves', 4),
(7, 'Sticky rice', '300', 'g', 1), (7, 'Coconut milk', '400', 'ml', 2),
(7, 'Ripe mango', '2', '', 3), (7, 'Palm sugar', '100', 'g', 4),
(8, 'Salmon fillets', '2', '', 1), (8, 'Lemon', '1', '', 2),
(8, 'Garlic', '3', 'cloves', 3), (8, 'Olive oil', '2', 'tbsp', 4),
(9, 'Chickpeas', '200', 'g', 1), (9, 'Greek yogurt', '3', 'tbsp', 2),
(9, 'Celery', '2', 'stalks', 3), (9, 'Tortillas', '2', '', 4),
(10, 'Rolled oats', '50', 'g', 1), (10, 'Greek yogurt', '120', 'ml', 2),
(10, 'Blueberries', '80', 'g', 3), (10, 'Honey', '1', 'tsp', 4),
(11, 'Tofu', '400', 'g', 1), (11, 'Bell peppers', '2', '', 2),
(11, 'Soy sauce', '2', 'tbsp', 3), (11, 'Chili sauce', '1', 'tbsp', 4),
(12, 'Tomatoes', '800', 'g', 1), (12, 'Onion', '1', '', 2),
(12, 'Cream', '100', 'ml', 3), (12, 'Basil', '1', 'bunch', 4),
(13, 'White fish', '400', 'g', 1), (13, 'Tortillas', '6', '', 2),
(13, 'Cabbage', '150', 'g', 3), (13, 'Lime', '1', '', 4);

-- INSTRUCTIONS (3-5 steps per recipe)
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(1, 1, 'Boil water and cook pasta al dente'), (1, 2, 'Fry pancetta until crispy'),
(1, 3, 'Mix eggs with grated parmesan'), (1, 4, 'Combine hot pasta with egg mixture off heat'),
(1, 5, 'Add pancetta and serve immediately'),
(2, 1, 'Mix dry ingredients'), (2, 2, 'Add wet ingredients and whisk'),
(2, 3, 'Cook on medium heat until bubbles form'), (2, 4, 'Flip and cook other side'),
(3, 1, 'Fry curry paste in oil'), (3, 2, 'Add coconut milk and bring to simmer'),
(3, 3, 'Add chicken and vegetables'), (3, 4, 'Cook until chicken is done'),
(3, 5, 'Garnish with Thai basil'),
(4, 1, 'Toast the bread until golden'), (4, 2, 'Mash avocado and season'),
(4, 3, 'Poach eggs in simmering water'), (4, 4, 'Spread avocado on toast'),
(4, 5, 'Top with poached eggs and chili'),
(5, 1, 'Melt chocolate and butter together'), (5, 2, 'Whisk eggs and sugar until fluffy'),
(5, 3, 'Fold chocolate into egg mixture'), (5, 4, 'Pour into ramekins'),
(5, 5, 'Bake at 200C for 12 minutes'),
(6, 1, 'Form beef into patties'), (6, 2, 'Season with salt and pepper'),
(6, 3, 'Grill or pan-fry for 4-5 min per side'), (6, 4, 'Toast buns'),
(6, 5, 'Assemble with toppings'),
(7, 1, 'Soak sticky rice overnight'), (7, 2, 'Steam rice until tender'),
(7, 3, 'Heat coconut milk with sugar'), (7, 4, 'Pour half over rice'),
(7, 5, 'Serve with sliced mango and remaining sauce'),
(8, 1, 'Preheat oven to 200C'), (8, 2, 'Season salmon with garlic, lemon, and oil'),
(8, 3, 'Bake for 15-18 minutes'), (8, 4, 'Serve with herbs'),
(9, 1, 'Mash chickpeas lightly'), (9, 2, 'Mix with yogurt and chopped celery'),
(9, 3, 'Wrap in tortilla and serve'),
(10, 1, 'Mix oats and yogurt'), (10, 2, 'Top with blueberries'),
(10, 3, 'Chill overnight'), (10, 4, 'Drizzle honey before serving'),
(11, 1, 'Press and cube tofu'), (11, 2, 'Stir-fry tofu until golden'),
(11, 3, 'Add peppers and sauce'), (11, 4, 'Serve hot'),
(12, 1, 'Saute onion'), (12, 2, 'Add tomatoes and simmer'),
(12, 3, 'Blend and add cream'), (12, 4, 'Garnish with basil'),
(13, 1, 'Season and fry fish'), (13, 2, 'Prepare slaw'),
(13, 3, 'Assemble tacos'), (13, 4, 'Serve with lime crema');

-- RECIPE IMAGES (1 per recipe)
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

SELECT r.id, r.title, r.category, r.difficulty, r.status, u.username AS author,
       (SELECT COUNT(*) FROM ingredient i WHERE i.recipe_id = r.id) AS ingredient_count,
       (SELECT COUNT(*) FROM instruction ins WHERE ins.recipe_id = r.id) AS step_count
FROM recipe r INNER JOIN user u ON r.author_id = u.id ORDER BY r.id;
```

---

## 07 - Seed Reviews, Likes & Favorites

```sql
-- ============================================================================
-- Script:      07_seed_reviews.sql
-- Description: Seed data for review, like_record, and favorite tables
-- ============================================================================

USE cookhub;

-- REVIEWS (25 reviews)
INSERT INTO review (user_id, recipe_id, rating, comment, created_at) VALUES
(5,  1, 5, 'Absolutely authentic! Reminds me of the carbonara I had in Rome.', '2025-12-05 14:30:00'),
(6,  1, 4, 'Great recipe. I added a bit more parmesan than suggested.', '2025-12-08 18:45:00'),
(9,  1, 5, 'My family loved this! Simple ingredients but incredible flavor.', '2025-12-15 20:00:00'),
(10, 1, 4, 'Solid carbonara recipe. Take it off heat before mixing eggs.', '2025-12-20 12:15:00'),
(4,  3, 5, 'Best green curry recipe I have found online. Perfectly balanced!', '2025-11-25 19:30:00'),
(9,  3, 4, 'Very aromatic. I used tofu instead of chicken and it worked great.', '2025-12-01 17:00:00'),
(10, 3, 4, 'Good recipe but add more vegetables for a heartier meal.', '2025-12-10 13:45:00'),
(4,  4, 4, 'Simple but delicious. The poached eggs make all the difference.', '2025-10-20 08:30:00'),
(9,  4, 3, 'Good basic recipe. I added everything bagel seasoning on top.', '2025-11-05 09:15:00'),
(5,  5, 5, 'Decadent and divine! The molten center was perfect.', '2025-09-10 21:00:00'),
(4,  5, 4, 'Tricky timing but worth it. Slightly overcooked first time.', '2025-09-15 20:30:00'),
(9,  5, 5, 'Restaurant-quality dessert at home. Guests were impressed.', '2025-10-02 19:45:00'),
(4,  6, 5, 'Juicy and flavorful! Secret is not overworking the beef.', '2025-08-15 13:00:00'),
(5,  6, 4, 'Really good homemade burger. I added caramelized onions.', '2025-08-20 12:30:00'),
(9,  6, 5, 'Best burger recipe! Simple but the result is amazing.', '2025-09-01 18:00:00'),
(4,  7, 4, 'Beautiful Thai dessert. Use ripe mangoes for best results.', '2025-08-01 15:30:00'),
(10, 7, 5, 'Authentic and delicious! Soaking rice overnight is essential.', '2025-08-10 16:00:00'),
(4,  8, 5, 'Quick and healthy dinner. Lemon garlic combo is perfect.', '2026-01-08 19:00:00'),
(10, 8, 4, 'Easy to make. I served it with roasted asparagus.', '2026-01-12 18:30:00'),
(5,  9, 4, 'Fresh and filling! Great healthy lunch option.', '2025-12-15 12:00:00'),
(9,  9, 4, 'Love the crunch. Added red onion and it was even better.', '2025-12-20 12:45:00'),
(6,  12, 4, 'Comfort food at its best. Pairs perfectly with grilled cheese.', '2025-11-05 19:00:00'),
(9,  12, 5, 'Creamy and rich. Fresh basil makes a huge difference.', '2025-11-15 18:30:00'),
(5,  13, 5, 'Incredible tacos! The slaw and lime crema bring it together.', '2026-01-15 13:00:00'),
(9,  13, 4, 'Really tasty. I used cod and it worked perfectly.', '2026-01-20 12:30:00');

-- LIKES (14 records)
INSERT INTO like_record (user_id, recipe_id, created_at) VALUES
(5, 1, '2025-12-03 10:00:00'), (6, 1, '2025-12-07 14:00:00'),
(4, 3, '2025-11-22 16:00:00'), (6, 5, '2025-09-08 20:00:00'),
(4, 6, '2025-08-12 11:00:00'), (5, 6, '2025-08-18 13:00:00'),
(6, 6, '2025-08-25 15:00:00'), (5, 7, '2025-07-28 17:00:00'),
(4, 8, '2026-01-06 19:00:00'), (5, 9, '2025-12-14 11:00:00'),
(9, 9, '2025-12-18 14:00:00'), (6, 12, '2025-11-02 18:00:00'),
(5, 13, '2026-01-12 12:00:00'), (9, 13, '2026-01-18 15:00:00');

-- FAVORITES (7 records)
INSERT INTO favorite (user_id, recipe_id, created_at) VALUES
(4, 3, '2025-11-23 10:00:00'), (5, 1, '2025-12-02 09:00:00'),
(6, 1, '2025-12-06 11:00:00'), (6, 5, '2025-09-07 15:00:00'),
(9, 1, '2025-12-10 08:00:00'), (9, 3, '2025-12-05 14:00:00'),
(10, 5, '2025-09-10 20:00:00');

SELECT 'Reviews' AS data_type, COUNT(*) AS count FROM review
UNION ALL SELECT 'Likes', COUNT(*) FROM like_record
UNION ALL SELECT 'Favorites', COUNT(*) FROM favorite;
```

---

## 08 - Seed Stats & Activity Logs

```sql
-- ============================================================================
-- Script:      08_seed_stats.sql
-- Description: Seed data for daily_stat, recipe_view, search_history, activity_log
-- ============================================================================

USE cookhub;

-- RECIPE VIEWS
INSERT INTO recipe_view (recipe_id, user_id, viewed_at) VALUES
(1, 4, '2025-12-01 10:00:00'), (1, 5, '2025-12-03 14:00:00'),
(1, 6, '2025-12-07 16:00:00'), (3, 4, '2025-11-21 18:00:00'),
(4, 5, '2025-10-16 09:00:00'), (5, 6, '2025-09-06 20:00:00'),
(6, 4, '2025-08-11 12:00:00'), (6, 5, '2025-08-18 13:30:00'),
(6, 6, '2025-08-22 15:00:00'), (7, 5, '2025-07-26 17:00:00'),
(8, 4, '2026-01-06 19:00:00'), (8, 9, '2026-01-07 10:00:00'),
(9, 5, '2025-12-13 11:00:00'), (9, 9, '2025-12-17 14:00:00'),
(9, 10, '2025-12-12 16:00:00'), (11, 10, '2025-11-23 13:00:00'),
(12, 4, '2025-10-31 18:00:00'), (12, 6, '2025-11-03 19:00:00'),
(12, 9, '2025-11-14 17:00:00'), (13, 5, '2026-01-11 12:00:00'),
(13, 9, '2026-01-16 14:00:00'), (13, 10, '2026-01-10 16:00:00'),
(2, 11, '2026-01-16 08:00:00');

-- DAILY STATS (last 30 days)
INSERT INTO daily_stat (stat_date, page_view_count, active_user_count, new_user_count, recipe_view_count) VALUES
('2026-01-08', 145, 8, 0, 32), ('2026-01-09', 132, 7, 0, 28),
('2026-01-10', 156, 9, 0, 35), ('2026-01-11', 168, 10, 0, 40),
('2026-01-12', 142, 7, 0, 30), ('2026-01-13', 98, 5, 0, 18),
('2026-01-14', 110, 6, 0, 22), ('2026-01-15', 175, 11, 0, 42),
('2026-01-16', 160, 9, 0, 38), ('2026-01-17', 148, 8, 0, 33),
('2026-01-18', 190, 12, 0, 45), ('2026-01-19', 135, 7, 0, 29),
('2026-01-20', 205, 13, 1, 48), ('2026-01-21', 180, 10, 1, 42),
('2026-01-22', 165, 9, 0, 37), ('2026-01-23', 152, 8, 0, 34),
('2026-01-24', 140, 7, 0, 30), ('2026-01-25', 118, 6, 0, 25),
('2026-01-26', 105, 5, 0, 20), ('2026-01-27', 172, 10, 0, 40),
('2026-01-28', 185, 11, 0, 43), ('2026-01-29', 195, 12, 0, 46),
('2026-01-30', 160, 9, 0, 36), ('2026-01-31', 148, 8, 0, 33),
('2026-02-01', 210, 14, 0, 50), ('2026-02-02', 178, 10, 0, 41),
('2026-02-03', 192, 12, 0, 45), ('2026-02-04', 165, 9, 0, 38),
('2026-02-05', 188, 11, 0, 44), ('2026-02-06', 200, 13, 0, 47);

-- SEARCH HISTORY
INSERT INTO search_history (user_id, query, searched_at) VALUES
(4, 'carbonara', '2025-12-01 09:30:00'), (4, 'italian pasta', '2025-12-01 09:32:00'),
(4, 'quick dinner', '2026-01-05 18:00:00'), (5, 'green curry', '2025-11-20 17:00:00'),
(5, 'dessert chocolate', '2025-09-10 20:00:00'), (5, 'fish tacos', '2026-01-11 12:00:00'),
(9, 'healthy breakfast', '2026-01-18 07:00:00'), (9, 'salmon recipe', '2026-01-07 09:30:00'),
(9, 'meal prep', '2025-12-28 10:00:00'), (10, 'tofu stir fry', '2025-11-22 12:00:00'),
(10, 'street food', '2025-12-05 14:00:00'), (10, 'wrap recipes', '2025-12-12 11:00:00'),
(6, 'burger recipe', '2025-08-10 12:00:00'), (6, 'chocolate cake', '2025-09-05 19:00:00'),
(11, 'pancakes easy', '2026-01-15 08:00:00');

-- ACTIVITY LOG (admin actions)
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
(3, 'recipe_reject', 'recipe', 11, 'Rejected recipe: Spicy Tofu Stir-Fry', '2025-11-23 10:00:00'),
(1, 'user_create', 'user', 7,  'New user registration: Amy Wilson', '2025-11-10 00:00:00'),
(1, 'user_create', 'user', 8,  'New user registration: Kevin Tran', '2026-01-20 00:00:00'),
(1, 'user_create', 'user', 12, 'New user registration: Omar Hassan', '2026-01-21 00:00:00'),
(2, 'user_update', 'user', 6,  'Suspended user: Tom Baker', '2025-10-15 14:00:00'),
(1, 'recipe_approve', 'recipe', 8,  'Approved recipe: Lemon Garlic Salmon', '2026-02-01 10:00:00'),
(2, 'user_update', 'user', 11, 'Updated user status: Lina Patel set to inactive', '2026-02-02 14:00:00'),
(3, 'recipe_reject', 'recipe', 11, 'Re-reviewed: Spicy Tofu Stir-Fry', '2026-02-03 09:00:00');

SELECT 'Recipe Views' AS data_type, COUNT(*) AS count FROM recipe_view
UNION ALL SELECT 'Daily Stats', COUNT(*) FROM daily_stat
UNION ALL SELECT 'Search History', COUNT(*) FROM search_history
UNION ALL SELECT 'Activity Logs', COUNT(*) FROM activity_log;
```

---

## 09 - Common Queries

```sql
-- ============================================================================
-- Script:      09_common_queries.sql
-- Description: Common SELECT queries for the Recipe Sharing System
-- ============================================================================
-- Demonstrates: JOIN, LEFT JOIN, subquery, GROUP BY, ORDER BY,
--               HAVING, LIKE, LIMIT, COUNT, AVG
-- ============================================================================

USE cookhub;

-- QUERY 1: Get all published recipes with author info
SELECT r.id, r.title, r.description, r.category, r.difficulty,
       r.prep_time, r.cook_time, r.servings,
       u.username AS author_name, u.avatar_url AS author_avatar,
       DATE_FORMAT(r.created_at, '%M %d, %Y') AS published_date
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
ORDER BY r.created_at DESC;

-- QUERY 2: Get full recipe detail with aggregated stats
SET @recipe_id = 1;

SELECT r.id, r.title, r.description, r.category, r.difficulty,
       r.prep_time, r.cook_time, r.servings, r.status,
       u.username AS author_name, u.avatar_url AS author_avatar,
       (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count,
       (SELECT COUNT(*) FROM recipe_view WHERE recipe_id = r.id) AS view_count,
       (SELECT COUNT(*) FROM review WHERE recipe_id = r.id) AS review_count,
       (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating,
       (SELECT COUNT(*) FROM favorite WHERE recipe_id = r.id) AS favorite_count
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.id = @recipe_id;

SELECT id, name, quantity, unit, sort_order
FROM ingredient WHERE recipe_id = @recipe_id ORDER BY sort_order;

SELECT id, step_number, instruction_text
FROM instruction WHERE recipe_id = @recipe_id ORDER BY step_number;

SELECT id, image_url, display_order
FROM recipe_image WHERE recipe_id = @recipe_id ORDER BY display_order;

-- QUERY 3: Get user favorites list with recipe stats
SET @user_id = 4;

SELECT f.id AS favorite_id, r.id AS recipe_id, r.title, r.category, r.difficulty,
       u.username AS author_name,
       (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order LIMIT 1) AS image_url,
       (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating,
       (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count,
       DATE_FORMAT(f.created_at, '%M %d, %Y') AS favorited_date
FROM favorite f
INNER JOIN recipe r ON f.recipe_id = r.id
INNER JOIN user u ON r.author_id = u.id
WHERE f.user_id = @user_id
ORDER BY f.created_at DESC;

-- QUERY 4: Search recipes by keyword
SET @search_term = 'chicken';

SELECT r.id, r.title, r.description, r.category, r.difficulty,
       r.prep_time, r.cook_time, u.username AS author_name,
       (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order LIMIT 1) AS image_url,
       COUNT(DISTINCT rv.id) AS view_count,
       COUNT(DISTINCT lr.id) AS like_count,
       (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
LEFT JOIN recipe_view rv ON r.id = rv.recipe_id
LEFT JOIN like_record lr ON r.id = lr.recipe_id
WHERE r.status = 'published'
  AND (r.title LIKE CONCAT('%', @search_term, '%')
    OR r.description LIKE CONCAT('%', @search_term, '%')
    OR r.category LIKE CONCAT('%', @search_term, '%'))
GROUP BY r.id, r.title, r.description, r.category, r.difficulty,
         r.prep_time, r.cook_time, u.username
ORDER BY like_count DESC, view_count DESC;

-- QUERY 5: Get recipe reviews with user info
SET @recipe_id = 1;

SELECT rv.id, rv.rating, rv.comment,
       DATE_FORMAT(rv.created_at, '%M %d, %Y') AS review_date,
       u.id AS user_id, u.username AS reviewer_name, u.avatar_url AS reviewer_avatar,
       (SELECT COUNT(*) FROM review WHERE user_id = u.id) AS total_reviews_by_user
FROM review rv
INNER JOIN user u ON rv.user_id = u.id
WHERE rv.recipe_id = @recipe_id
ORDER BY rv.created_at DESC;
```

---

## 10 - Admin Queries

```sql
-- ============================================================================
-- Script:      10_admin_queries.sql
-- Description: Admin dashboard and management queries
-- ============================================================================

USE cookhub;

-- QUERY 1: Users summary by role and status
SELECT role, status, COUNT(*) AS user_count
FROM user GROUP BY role, status ORDER BY role, status;

-- Full user list (paginated)
SELECT u.id, u.username, u.email, u.role, u.status,
       DATE_FORMAT(u.joined_date, '%Y-%m-%d') AS joined_date,
       DATE_FORMAT(u.last_active, '%Y-%m-%d %H:%i') AS last_active,
       (SELECT COUNT(*) FROM recipe WHERE author_id = u.id) AS recipe_count,
       (SELECT COUNT(*) FROM review WHERE user_id = u.id) AS review_count
FROM user u ORDER BY u.created_at DESC LIMIT 20 OFFSET 0;

-- QUERY 2: Recipe status summary
SELECT status, COUNT(*) AS recipe_count, COUNT(DISTINCT author_id) AS unique_authors
FROM recipe GROUP BY status
ORDER BY FIELD(status, 'pending', 'published', 'rejected');

-- Full recipe list for admin
SELECT r.id, r.title, r.status, r.category, r.difficulty,
       u.username AS author_name, u.email AS author_email,
       DATE_FORMAT(r.created_at, '%Y-%m-%d') AS created_date,
       (SELECT COUNT(*) FROM review WHERE recipe_id = r.id) AS review_count,
       (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count,
       (SELECT COUNT(*) FROM recipe_view WHERE recipe_id = r.id) AS view_count
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
ORDER BY CASE r.status WHEN 'pending' THEN 1 WHEN 'published' THEN 2
         WHEN 'rejected' THEN 3 END, r.created_at DESC;

-- QUERY 3: Pending recipes queue
SELECT r.id, r.title, r.description, r.category, r.difficulty,
       r.prep_time, r.cook_time, r.servings,
       u.id AS author_id, u.username AS author_name, u.email AS author_email,
       DATE_FORMAT(r.created_at, '%Y-%m-%d %H:%i') AS submitted_date,
       DATEDIFF(NOW(), r.created_at) AS days_pending,
       (SELECT COUNT(*) FROM ingredient WHERE recipe_id = r.id) AS ingredient_count,
       (SELECT COUNT(*) FROM instruction WHERE recipe_id = r.id) AS instruction_count,
       (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order LIMIT 1) AS image_url
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'pending'
ORDER BY r.created_at ASC;

-- QUERY 4: Dashboard overview statistics
SELECT
    (SELECT COUNT(*) FROM user WHERE role = 'user') AS total_users,
    (SELECT COUNT(*) FROM user WHERE role = 'user' AND status = 'active') AS active_users,
    (SELECT COUNT(*) FROM user WHERE role = 'user' AND status = 'pending') AS pending_users,
    (SELECT COUNT(*) FROM recipe) AS total_recipes,
    (SELECT COUNT(*) FROM recipe WHERE status = 'published') AS published_recipes,
    (SELECT COUNT(*) FROM recipe WHERE status = 'pending') AS pending_recipes,
    (SELECT COUNT(*) FROM review) AS total_reviews,
    (SELECT COUNT(*) FROM recipe_view) AS total_views;

-- QUERY 5: Recent admin activity log
SELECT al.id, al.action_type, al.target_type, al.target_id, al.description,
       DATE_FORMAT(al.created_at, '%Y-%m-%d %H:%i') AS action_date,
       u.username AS admin_name,
       CASE al.target_type
           WHEN 'recipe' THEN (SELECT title FROM recipe WHERE id = al.target_id)
           WHEN 'user' THEN (SELECT username FROM user WHERE id = al.target_id)
           ELSE NULL
       END AS target_name
FROM activity_log al
INNER JOIN user u ON al.admin_id = u.id
ORDER BY al.created_at DESC LIMIT 50;
```

---

## 11 - Analytics Queries

```sql
-- ============================================================================
-- Script:      11_analytics_queries.sql
-- Description: Analytics, trending, and engagement queries
-- ============================================================================

USE cookhub;

-- QUERY 1: Top 10 by views
SELECT r.id, r.title, r.category, u.username AS author_name,
       COUNT(rv.id) AS total_views,
       (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count,
       (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
LEFT JOIN recipe_view rv ON r.id = rv.recipe_id
WHERE r.status = 'published'
GROUP BY r.id, r.title, r.category, u.username
ORDER BY total_views DESC LIMIT 10;

-- Top 10 by likes
SELECT r.id, r.title, r.category, u.username AS author_name,
       COUNT(lr.id) AS total_likes,
       (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
LEFT JOIN like_record lr ON r.id = lr.recipe_id
WHERE r.status = 'published'
GROUP BY r.id, r.title, r.category, u.username
ORDER BY total_likes DESC LIMIT 10;

-- Top 10 by average rating (minimum 2 reviews)
SELECT r.id, r.title, r.category, u.username AS author_name,
       COUNT(rv.id) AS review_count, ROUND(AVG(rv.rating), 2) AS avg_rating
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
INNER JOIN review rv ON r.id = rv.recipe_id
WHERE r.status = 'published'
GROUP BY r.id, r.title, r.category, u.username
HAVING review_count >= 2
ORDER BY avg_rating DESC, review_count DESC LIMIT 10;

-- QUERY 2: User engagement metrics
SELECT u.id, u.username, u.status,
       DATE_FORMAT(u.joined_date, '%Y-%m-%d') AS joined_date,
       (SELECT COUNT(*) FROM recipe WHERE author_id = u.id AND status = 'published') AS published,
       (SELECT COUNT(*) FROM review WHERE user_id = u.id) AS reviews_written,
       (SELECT COUNT(*) FROM like_record WHERE user_id = u.id) AS likes_given,
       (SELECT COUNT(*) FROM like_record lr INNER JOIN recipe r ON lr.recipe_id = r.id WHERE r.author_id = u.id) AS likes_received,
       (SELECT COUNT(*) FROM favorite WHERE user_id = u.id) AS favorites,
       (SELECT COUNT(*) FROM recipe_view WHERE user_id = u.id) AS recipes_viewed
FROM user u WHERE u.role = 'user'
ORDER BY published DESC, likes_received DESC;

-- QUERY 3: Daily stats (last 30 days)
SELECT stat_date, page_view_count, active_user_count, new_user_count, recipe_view_count
FROM daily_stat WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY stat_date DESC;

-- Weekly aggregation
SELECT YEARWEEK(stat_date, 1) AS year_week, MIN(stat_date) AS week_start, MAX(stat_date) AS week_end,
       SUM(page_view_count) AS total_page_views, ROUND(AVG(active_user_count)) AS avg_daily_active,
       SUM(new_user_count) AS total_new_users, SUM(recipe_view_count) AS total_recipe_views
FROM daily_stat WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 12 WEEK)
GROUP BY YEARWEEK(stat_date, 1) ORDER BY year_week DESC;

-- QUERY 4: Cuisine distribution
SELECT r.category, COUNT(*) AS recipe_count,
       COUNT(CASE WHEN r.status = 'published' THEN 1 END) AS published_count,
       (SELECT COUNT(*) FROM recipe_view rv INNER JOIN recipe r2 ON rv.recipe_id = r2.id WHERE r2.category = r.category) AS total_views,
       (SELECT COUNT(*) FROM like_record lr INNER JOIN recipe r2 ON lr.recipe_id = r2.id WHERE r2.category = r.category) AS total_likes
FROM recipe r GROUP BY r.category ORDER BY recipe_count DESC;

-- QUERY 5: Popular search terms
SELECT LOWER(query) AS search_term, COUNT(*) AS search_count,
       COUNT(DISTINCT user_id) AS unique_users, MAX(searched_at) AS last_searched
FROM search_history GROUP BY LOWER(query) ORDER BY search_count DESC LIMIT 20;

-- QUERY 6: Difficulty distribution
SELECT r.difficulty, COUNT(*) AS recipe_count,
       ROUND(AVG(r.prep_time)) AS avg_prep_min, ROUND(AVG(r.cook_time)) AS avg_cook_min,
       ROUND(AVG(r.prep_time + r.cook_time)) AS avg_total_min
FROM recipe r WHERE r.status = 'published'
GROUP BY r.difficulty ORDER BY FIELD(r.difficulty, 'Easy', 'Medium', 'Hard');
```

---

## 12 - Stored Procedures

```sql
-- ============================================================================
-- Script:      12_stored_procedures.sql
-- Description: Stored procedures and functions
-- ============================================================================
-- Naming: usp_ prefix for stored procedures, fn_ prefix for functions
-- All SPs use transaction handling with ROLLBACK on error
-- ============================================================================

USE cookhub;

DELIMITER //

-- usp_CreateRecipe: Create recipe with ingredients & instructions in one transaction
CREATE PROCEDURE usp_CreateRecipe(
    IN pAuthorId INT, IN pTitle VARCHAR(200), IN pDescription TEXT,
    IN pCategory VARCHAR(50), IN pDifficulty ENUM('Easy','Medium','Hard'),
    IN pPrepTime INT, IN pCookTime INT, IN pServings INT,
    IN pImageUrl VARCHAR(500), IN pIngredients JSON, IN pInstructions JSON,
    OUT pRecipeId INT
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_index INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET pRecipeId = NULL;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error creating recipe.';
    END;

    START TRANSACTION;

    INSERT INTO recipe (author_id, title, description, category, difficulty,
                        prep_time, cook_time, servings, status)
    VALUES (pAuthorId, pTitle, pDescription, pCategory, pDifficulty,
            pPrepTime, pCookTime, pServings, 'pending');
    SET pRecipeId = LAST_INSERT_ID();

    IF pImageUrl IS NOT NULL AND pImageUrl != '' THEN
        INSERT INTO recipe_image (recipe_id, image_url, display_order)
        VALUES (pRecipeId, pImageUrl, 1);
    END IF;

    SET v_count = JSON_LENGTH(pIngredients);
    SET v_index = 0;
    WHILE v_index < v_count DO
        INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order)
        VALUES (pRecipeId,
            JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[',v_index,'].name'))),
            JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[',v_index,'].quantity'))),
            JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[',v_index,'].unit'))),
            v_index + 1);
        SET v_index = v_index + 1;
    END WHILE;

    SET v_count = JSON_LENGTH(pInstructions);
    SET v_index = 0;
    WHILE v_index < v_count DO
        INSERT INTO instruction (recipe_id, step_number, instruction_text)
        VALUES (pRecipeId, v_index + 1,
            JSON_UNQUOTE(JSON_EXTRACT(pInstructions, CONCAT('$[',v_index,'].description'))));
        SET v_index = v_index + 1;
    END WHILE;

    COMMIT;
END //


-- usp_DeleteRecipe: Delete recipe + children with audit logging
CREATE PROCEDURE usp_DeleteRecipe(IN pRecipeId INT, IN pAdminId INT)
BEGIN
    DECLARE v_title VARCHAR(200);
    DECLARE v_authorId INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error deleting recipe.'; END;

    SELECT title, author_id INTO v_title, v_authorId FROM recipe WHERE id = pRecipeId;
    IF v_title IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recipe not found.';
    END IF;

    START TRANSACTION;
    DELETE FROM recipe_view WHERE recipe_id = pRecipeId;
    DELETE FROM review WHERE recipe_id = pRecipeId;
    DELETE FROM like_record WHERE recipe_id = pRecipeId;
    DELETE FROM favorite WHERE recipe_id = pRecipeId;
    DELETE FROM recipe_image WHERE recipe_id = pRecipeId;
    DELETE FROM instruction WHERE recipe_id = pRecipeId;
    DELETE FROM ingredient WHERE recipe_id = pRecipeId;
    DELETE FROM recipe WHERE id = pRecipeId;

    INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
    VALUES (pAdminId, 'recipe_delete', 'recipe', pRecipeId,
            CONCAT('Deleted recipe: ', v_title, ' (author_id: ', v_authorId, ')'));
    COMMIT;
END //


-- usp_ApproveRecipe: Approve or reject pending recipe with logging
CREATE PROCEDURE usp_ApproveRecipe(
    IN pRecipeId INT, IN pAdminId INT,
    IN pAction VARCHAR(10), IN pReason VARCHAR(500)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_title VARCHAR(200);
    DECLARE v_newStatus VARCHAR(20);
    DECLARE v_actionType VARCHAR(50);
    DECLARE v_desc VARCHAR(500);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error processing approval.'; END;

    SELECT status, title INTO v_status, v_title FROM recipe WHERE id = pRecipeId;
    IF v_status IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recipe not found.'; END IF;
    IF v_status != 'pending' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recipe is not pending.'; END IF;

    IF pAction = 'approve' THEN
        SET v_newStatus = 'published'; SET v_actionType = 'recipe_approve';
        SET v_desc = CONCAT('Approved recipe: ', v_title);
    ELSEIF pAction = 'reject' THEN
        SET v_newStatus = 'rejected'; SET v_actionType = 'recipe_reject';
        SET v_desc = CONCAT('Rejected recipe: ', v_title);
        IF pReason IS NOT NULL AND pReason != '' THEN SET v_desc = CONCAT(v_desc, ' - ', pReason); END IF;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid action.';
    END IF;

    START TRANSACTION;
    UPDATE recipe SET status = v_newStatus, updated_at = NOW() WHERE id = pRecipeId;
    INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
    VALUES (pAdminId, v_actionType, 'recipe', pRecipeId, v_desc);
    COMMIT;
END //


-- usp_GetRecipeStat: Get aggregated stats for a recipe
CREATE PROCEDURE usp_GetRecipeStat(IN pRecipeId INT)
BEGIN
    SELECT r.id, r.title, r.status, u.username AS author_name,
        DATE_FORMAT(r.created_at, '%Y-%m-%d') AS created_date,
        (SELECT COUNT(*) FROM recipe_view WHERE recipe_id = pRecipeId) AS total_views,
        (SELECT COUNT(*) FROM like_record WHERE recipe_id = pRecipeId) AS total_likes,
        (SELECT COUNT(*) FROM favorite WHERE recipe_id = pRecipeId) AS total_favorites,
        (SELECT COUNT(*) FROM review WHERE recipe_id = pRecipeId) AS total_reviews,
        (SELECT ROUND(AVG(rating), 2) FROM review WHERE recipe_id = pRecipeId) AS avg_rating
    FROM recipe r INNER JOIN user u ON r.author_id = u.id WHERE r.id = pRecipeId;
END //


-- fn_CalculateAvgRating: Returns DECIMAL avg rating for a recipe
CREATE FUNCTION fn_CalculateAvgRating(pRecipeId INT)
RETURNS DECIMAL(3, 2) DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(3, 2);
    SELECT ROUND(AVG(rating), 2) INTO v_avg FROM review WHERE recipe_id = pRecipeId;
    RETURN COALESCE(v_avg, 0.00);
END //

DELIMITER ;

-- Usage examples:
-- CALL usp_ApproveRecipe(2, 1, 'approve', NULL);
-- CALL usp_GetRecipeStat(1);
-- SELECT fn_CalculateAvgRating(1) AS avg_rating;
```

---

## 13 - Triggers

```sql
-- ============================================================================
-- Script:      13_triggers.sql
-- Description: Database triggers for automated operations
-- ============================================================================
-- Safety: All triggers check @DISABLE_TRIGGERS to allow safe seeding
-- ============================================================================

USE cookhub;

DELIMITER //

-- trg_RecipeView_UpdateStat: Increment daily stats on new recipe view
CREATE TRIGGER trg_RecipeView_UpdateStat
AFTER INSERT ON recipe_view FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        INSERT INTO daily_stat (stat_date, page_view_count, active_user_count, new_user_count, recipe_view_count)
        VALUES (CURDATE(), 1, 0, 0, 1)
        ON DUPLICATE KEY UPDATE recipe_view_count = recipe_view_count + 1, page_view_count = page_view_count + 1;
    END IF;
END //

-- trg_User_UpdateLastActive: Update user.last_active on session update
CREATE TRIGGER trg_User_UpdateLastActive
BEFORE UPDATE ON session FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        UPDATE user SET last_active = NOW() WHERE id = NEW.user_id;
    END IF;
END //

-- trg_Recipe_DeleteCleanup: Log recipe deletion to activity_log
CREATE TRIGGER trg_Recipe_DeleteCleanup
BEFORE DELETE ON recipe FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        IF NOT EXISTS (
            SELECT 1 FROM activity_log
            WHERE target_type = 'recipe' AND target_id = OLD.id
              AND action_type = 'recipe_delete'
              AND created_at >= DATE_SUB(NOW(), INTERVAL 5 SECOND)
        ) THEN
            INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
            VALUES (COALESCE(@current_admin_id, 1), 'recipe_delete', 'recipe', OLD.id,
                    CONCAT('Trigger-logged deletion of recipe: ', OLD.title));
        END IF;
    END IF;
END //

-- trg_User_NewUserStat: Increment daily stats on new user registration
CREATE TRIGGER trg_User_NewUserStat
AFTER INSERT ON user FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        INSERT INTO daily_stat (stat_date, page_view_count, active_user_count, new_user_count, recipe_view_count)
        VALUES (CURDATE(), 0, 1, 1, 0)
        ON DUPLICATE KEY UPDATE new_user_count = new_user_count + 1, active_user_count = active_user_count + 1;
    END IF;
END //

-- trg_Recipe_SetTimestamp: Auto-update recipe.updated_at
CREATE TRIGGER trg_Recipe_SetTimestamp
BEFORE UPDATE ON recipe FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        SET NEW.updated_at = NOW();
    END IF;
END //

-- trg_User_SetTimestamp: Auto-update user.updated_at
CREATE TRIGGER trg_User_SetTimestamp
BEFORE UPDATE ON user FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        SET NEW.updated_at = NOW();
    END IF;
END //

DELIMITER ;

SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE, ACTION_TIMING
FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA = 'cookhub'
ORDER BY EVENT_OBJECT_TABLE, ACTION_TIMING;
```

---

## 14 - Backup & Restore

```sql
-- ============================================================================
-- Script:      14_backup_restore.sql
-- Description: Database backup and restore documentation with utility scripts
-- ============================================================================

USE cookhub;

-- SECTION 1: FULL DATABASE BACKUP (run from terminal, NOT phpMyAdmin)
-- Windows (XAMPP):
--   C:\xampp\mysql\bin\mysqldump -u root cookhub > C:\backup\cookhub_full_YYYYMMDD.sql
--
-- With routines and triggers:
--   C:\xampp\mysql\bin\mysqldump -u root --routines --triggers cookhub > C:\backup\cookhub_complete_YYYYMMDD.sql
--
-- Structure only:
--   C:\xampp\mysql\bin\mysqldump -u root --no-data cookhub > C:\backup\cookhub_schema_YYYYMMDD.sql
--
-- Data only:
--   C:\xampp\mysql\bin\mysqldump -u root --no-create-info cookhub > C:\backup\cookhub_data_YYYYMMDD.sql

-- SECTION 2: RESTORE
--   C:\xampp\mysql\bin\mysql -u root cookhub < C:\backup\cookhub_full_YYYYMMDD.sql
--
-- Via phpMyAdmin: Database → Import tab → Choose File → Go

-- SECTION 3: DATABASE HEALTH CHECK
SELECT TABLE_NAME, TABLE_ROWS AS estimated_rows,
       ROUND(DATA_LENGTH/1024, 2) AS data_kb, ROUND(INDEX_LENGTH/1024, 2) AS index_kb
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'cookhub' AND TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME;

SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'cookhub';

SELECT ROUTINE_NAME, ROUTINE_TYPE FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'cookhub' ORDER BY ROUTINE_TYPE, ROUTINE_NAME;

SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE FROM INFORMATION_SCHEMA.TRIGGERS
WHERE TRIGGER_SCHEMA = 'cookhub' ORDER BY EVENT_OBJECT_TABLE;

-- Row counts
SELECT 'user' AS tbl, COUNT(*) AS cnt FROM user
UNION ALL SELECT 'recipe', COUNT(*) FROM recipe
UNION ALL SELECT 'ingredient', COUNT(*) FROM ingredient
UNION ALL SELECT 'instruction', COUNT(*) FROM instruction
UNION ALL SELECT 'recipe_image', COUNT(*) FROM recipe_image
UNION ALL SELECT 'review', COUNT(*) FROM review
UNION ALL SELECT 'like_record', COUNT(*) FROM like_record
UNION ALL SELECT 'favorite', COUNT(*) FROM favorite
UNION ALL SELECT 'recipe_view', COUNT(*) FROM recipe_view
UNION ALL SELECT 'search_history', COUNT(*) FROM search_history
UNION ALL SELECT 'daily_stat', COUNT(*) FROM daily_stat
UNION ALL SELECT 'activity_log', COUNT(*) FROM activity_log
UNION ALL SELECT 'session', COUNT(*) FROM session;

-- SECTION 4: COMPLETE REBUILD SEQUENCE
-- 1.  SOURCE database/01_create_database.sql;
-- 2.  SOURCE database/02_create_tables.sql;
-- 3.  SOURCE database/03_create_indexes.sql;
-- 4.  SOURCE database/04_create_views.sql;
-- 5.  SOURCE database/12_stored_procedures.sql;
-- 6.  SOURCE database/13_triggers.sql;
-- 7.  SET @DISABLE_TRIGGERS = 1;
-- 8.  SOURCE database/05_seed_users.sql;
-- 9.  SOURCE database/06_seed_recipes.sql;
-- 10. SOURCE database/07_seed_reviews.sql;
-- 11. SOURCE database/08_seed_stats.sql;
-- 12. SET @DISABLE_TRIGGERS = NULL;
-- 13. SOURCE database/14_backup_restore.sql;
```
