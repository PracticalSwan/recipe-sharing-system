-- ============================================================================
-- Script:      10_admin_queries.sql
-- Description: Admin dashboard and management queries
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Queries demonstrate: GROUP BY with CASE, COUNT, subqueries, pagination,
--                      complex JOINs, conditional aggregation
-- ============================================================================

USE cookhub;

-- ============================================================================
-- QUERY 1: Users list with status distribution and summary counts
-- Demonstrates: GROUP BY, COUNT, CASE, ORDER BY
-- ============================================================================

-- Summary counts by role and status
SELECT
    role,
    status,
    COUNT(*) AS user_count
FROM user
GROUP BY role, status
ORDER BY role, status;

-- Full user list for admin management (paginated)
SELECT
    u.user_id,
    u.username,
    u.email,
    u.display_name,
    u.role,
    u.status,
    DATE_FORMAT(u.created_at, '%Y-%m-%d') AS joined_date,
    DATE_FORMAT(u.last_active, '%Y-%m-%d %H:%i') AS last_active,
    (SELECT COUNT(*) FROM recipe WHERE author_id = u.user_id) AS recipe_count,
    (SELECT COUNT(*) FROM review WHERE user_id = u.user_id)   AS review_count
FROM user u
ORDER BY u.created_at DESC
LIMIT 20 OFFSET 0;


-- ============================================================================
-- QUERY 2: Recipes by status with author info (admin recipe management)
-- Demonstrates: INNER JOIN, GROUP BY, conditional aggregation, CASE
-- ============================================================================

-- Recipe status summary
SELECT
    status,
    COUNT(*) AS recipe_count,
    COUNT(DISTINCT author_id) AS unique_authors
FROM recipe
GROUP BY status
ORDER BY FIELD(status, 'pending', 'published', 'rejected', 'draft');

-- Full recipe list for admin management
SELECT
    r.recipe_id,
    r.title,
    r.status,
    r.cuisine,
    r.difficulty,
    u.display_name AS author_name,
    u.email        AS author_email,
    DATE_FORMAT(r.created_at, '%Y-%m-%d') AS created_date,
    DATE_FORMAT(r.updated_at, '%Y-%m-%d') AS updated_date,
    (SELECT COUNT(*) FROM review      WHERE recipe_id = r.recipe_id) AS review_count,
    (SELECT COUNT(*) FROM like_record  WHERE recipe_id = r.recipe_id) AS like_count,
    (SELECT COUNT(*) FROM recipe_view  WHERE recipe_id = r.recipe_id) AS view_count
FROM recipe r
INNER JOIN user u ON r.author_id = u.user_id
ORDER BY
    CASE r.status
        WHEN 'pending' THEN 1
        WHEN 'published' THEN 2
        WHEN 'rejected' THEN 3
        WHEN 'draft' THEN 4
    END,
    r.created_at DESC;


-- ============================================================================
-- QUERY 3: Pending recipes queue for admin approval
-- Demonstrates: INNER JOIN, WHERE, subquery, ORDER BY date
-- ============================================================================
SELECT
    r.recipe_id,
    r.title,
    r.description,
    r.cuisine,
    r.difficulty,
    r.prep_time,
    r.cook_time,
    r.servings,
    u.user_id      AS author_id,
    u.display_name AS author_name,
    u.email        AS author_email,
    u.status       AS author_status,
    DATE_FORMAT(r.created_at, '%Y-%m-%d %H:%i') AS submitted_date,
    DATEDIFF(NOW(), r.created_at) AS days_pending,
    (SELECT COUNT(*) FROM ingredient  WHERE recipe_id = r.recipe_id) AS ingredient_count,
    (SELECT COUNT(*) FROM instruction WHERE recipe_id = r.recipe_id) AS instruction_count,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.recipe_id AND is_primary = 1 LIMIT 1) AS image_url
FROM recipe r
INNER JOIN user u ON r.author_id = u.user_id
WHERE r.status = 'pending'
ORDER BY r.created_at ASC;


-- ============================================================================
-- QUERY 4: Admin dashboard overview statistics (single-row summary)
-- Demonstrates: Subqueries, COUNT with conditions, DATE arithmetic
-- ============================================================================
SELECT
    (SELECT COUNT(*) FROM user WHERE role = 'user')                                       AS total_users,
    (SELECT COUNT(*) FROM user WHERE role = 'user' AND status = 'active')                 AS active_users,
    (SELECT COUNT(*) FROM user WHERE role = 'user' AND status = 'pending')                AS pending_users,
    (SELECT COUNT(*) FROM user WHERE role = 'user' AND status = 'suspended')              AS suspended_users,
    (SELECT COUNT(*) FROM user WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY))       AS new_users_7d,
    (SELECT COUNT(*) FROM recipe)                                                          AS total_recipes,
    (SELECT COUNT(*) FROM recipe WHERE status = 'published')                               AS published_recipes,
    (SELECT COUNT(*) FROM recipe WHERE status = 'pending')                                 AS pending_recipes,
    (SELECT COUNT(*) FROM recipe WHERE status = 'rejected')                                AS rejected_recipes,
    (SELECT COUNT(*) FROM recipe WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY))     AS new_recipes_7d,
    (SELECT COUNT(*) FROM review)                                                          AS total_reviews,
    (SELECT COUNT(*) FROM review WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY))     AS new_reviews_7d,
    (SELECT COUNT(*) FROM recipe_view)                                                     AS total_views,
    (SELECT COUNT(*) FROM recipe_view WHERE viewed_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)) AS views_7d;


-- ============================================================================
-- QUERY 5: Recent admin activity log
-- Demonstrates: INNER JOIN, ORDER BY, DATE_FORMAT, LIMIT
-- ============================================================================
SELECT
    al.log_id,
    al.action_type,
    al.target_type,
    al.target_id,
    al.description,
    DATE_FORMAT(al.created_at, '%Y-%m-%d %H:%i') AS action_date,
    u.display_name AS admin_name,
    CASE al.target_type
        WHEN 'recipe' THEN (SELECT title FROM recipe WHERE recipe_id = al.target_id)
        WHEN 'user'   THEN (SELECT display_name FROM user WHERE user_id = al.target_id)
        ELSE NULL
    END AS target_name
FROM activity_log al
INNER JOIN user u ON al.admin_id = u.user_id
ORDER BY al.created_at DESC
LIMIT 50;
