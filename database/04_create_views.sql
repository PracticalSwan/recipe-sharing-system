-- ============================================================================
-- Script:      04_create_views.sql
-- Description: Creates database views for commonly accessed aggregated data
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Views:
--   1. vw_recipe_with_stat  - Recipe listing with aggregated engagement stats
--   2. vw_user_dashboard_stat - User dashboard summary statistics
-- ============================================================================

USE cookhub;

-- ============================================================================
-- VIEW 1: vw_recipe_with_stat
-- Joins recipe with author info and aggregated engagement statistics
-- Used by: Home page, Search page, Recipe listings
-- ============================================================================
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
    COALESCE(lk.like_count, 0)      AS like_count,
    COALESCE(vw.view_count, 0)      AS view_count,
    COALESCE(rv.review_count, 0)    AS review_count,
    COALESCE(rv.avg_rating, 0)      AS avg_rating,
    COALESCE(fv.favorite_count, 0)  AS favorite_count,
    (
        SELECT ri.image_url
        FROM recipe_image ri
        WHERE ri.recipe_id = r.id
        ORDER BY ri.display_order ASC
        LIMIT 1
    ) AS primary_image_url
FROM recipe r
    INNER JOIN user u
        ON r.author_id = u.id
    LEFT JOIN (
        SELECT
            recipe_id,
            COUNT(*) AS like_count
        FROM like_record
        GROUP BY recipe_id
    ) lk ON lk.recipe_id = r.id
    LEFT JOIN (
        SELECT
            recipe_id,
            COUNT(*) AS view_count
        FROM recipe_view
        GROUP BY recipe_id
    ) vw ON vw.recipe_id = r.id
    LEFT JOIN (
        SELECT
            recipe_id,
            COUNT(*)            AS review_count,
            ROUND(AVG(rating), 1) AS avg_rating
        FROM review
        GROUP BY recipe_id
    ) rv ON rv.recipe_id = r.id
    LEFT JOIN (
        SELECT
            recipe_id,
            COUNT(*) AS favorite_count
        FROM favorite
        GROUP BY recipe_id
    ) fv ON fv.recipe_id = r.id;

-- ============================================================================
-- VIEW 2: vw_user_dashboard_stat
-- Aggregates per-user statistics for the user profile/dashboard
-- Used by: Profile page, User dashboard
-- ============================================================================
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
    COALESCE(rc.recipe_count, 0)           AS recipe_count,
    COALESCE(rc.published_recipe_count, 0) AS published_recipe_count,
    COALESCE(rc.pending_recipe_count, 0)   AS pending_recipe_count,
    COALESCE(fv.favorite_count, 0)         AS favorite_count,
    COALESCE(rv.review_count, 0)           AS review_count,
    COALESCE(lk.like_given_count, 0)       AS like_given_count,
    COALESCE(lk_rcv.like_received_count, 0) AS like_received_count
FROM user u
    LEFT JOIN (
        SELECT
            author_id,
            COUNT(*)                                            AS recipe_count,
            SUM(CASE WHEN status = 'published' THEN 1 ELSE 0 END) AS published_recipe_count,
            SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END)   AS pending_recipe_count
        FROM recipe
        GROUP BY author_id
    ) rc ON rc.author_id = u.id
    LEFT JOIN (
        SELECT
            user_id,
            COUNT(*) AS favorite_count
        FROM favorite
        GROUP BY user_id
    ) fv ON fv.user_id = u.id
    LEFT JOIN (
        SELECT
            user_id,
            COUNT(*) AS review_count
        FROM review
        GROUP BY user_id
    ) rv ON rv.user_id = u.id
    LEFT JOIN (
        SELECT
            user_id,
            COUNT(*) AS like_given_count
        FROM like_record
        GROUP BY user_id
    ) lk ON lk.user_id = u.id
    LEFT JOIN (
        SELECT
            r.author_id,
            COUNT(lr.id) AS like_received_count
        FROM like_record lr
            INNER JOIN recipe r ON lr.recipe_id = r.id
        GROUP BY r.author_id
    ) lk_rcv ON lk_rcv.author_id = u.id;

-- Verify views were created
SELECT TABLE_NAME, VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'cookhub';
