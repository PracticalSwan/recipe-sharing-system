-- ============================================================================
-- Script:      11_analytics_queries.sql
-- Description: Analytics, trending, and engagement queries
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Queries demonstrate: Window functions, DATE functions, GROUP BY with ROLLUP,
--                      CTEs, UNION, complex aggregation, ranking
-- ============================================================================

USE cookhub;

-- ============================================================================
-- QUERY 1: Top 10 recipes by views / likes / average rating
-- Demonstrates: LEFT JOIN, GROUP BY, ORDER BY aggregate, LIMIT
-- ============================================================================

-- Top 10 by views
SELECT
    r.recipe_id,
    r.title,
    r.cuisine,
    u.display_name AS author_name,
    COUNT(rv.view_id) AS total_views,
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.recipe_id)            AS like_count,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.recipe_id)   AS avg_rating
FROM recipe r
INNER JOIN user u        ON r.author_id = u.user_id
LEFT JOIN recipe_view rv ON r.recipe_id = rv.recipe_id
WHERE r.status = 'published'
GROUP BY r.recipe_id, r.title, r.cuisine, u.display_name
ORDER BY total_views DESC
LIMIT 10;

-- Top 10 by likes
SELECT
    r.recipe_id,
    r.title,
    r.cuisine,
    u.display_name AS author_name,
    COUNT(lr.like_id) AS total_likes,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.recipe_id) AS avg_rating
FROM recipe r
INNER JOIN user u       ON r.author_id = u.user_id
LEFT JOIN like_record lr ON r.recipe_id = lr.recipe_id
WHERE r.status = 'published'
GROUP BY r.recipe_id, r.title, r.cuisine, u.display_name
ORDER BY total_likes DESC
LIMIT 10;

-- Top 10 by average rating (minimum 2 reviews)
SELECT
    r.recipe_id,
    r.title,
    r.cuisine,
    u.display_name AS author_name,
    COUNT(rv.review_id)         AS review_count,
    ROUND(AVG(rv.rating), 2)    AS avg_rating
FROM recipe r
INNER JOIN user u   ON r.author_id = u.user_id
INNER JOIN review rv ON r.recipe_id = rv.recipe_id
WHERE r.status = 'published'
GROUP BY r.recipe_id, r.title, r.cuisine, u.display_name
HAVING review_count >= 2
ORDER BY avg_rating DESC, review_count DESC
LIMIT 10;


-- ============================================================================
-- QUERY 2: User engagement metrics (recipes, reviews, likes given/received)
-- Demonstrates: Subqueries, LEFT JOIN, complex aggregation
-- ============================================================================
SELECT
    u.user_id,
    u.display_name,
    u.status,
    DATE_FORMAT(u.created_at, '%Y-%m-%d') AS joined_date,
    (SELECT COUNT(*) FROM recipe WHERE author_id = u.user_id AND status = 'published') AS published_recipes,
    (SELECT COUNT(*) FROM review WHERE user_id = u.user_id)                            AS reviews_written,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE user_id = u.user_id)               AS avg_rating_given,
    (SELECT COUNT(*) FROM like_record WHERE user_id = u.user_id)                       AS likes_given,
    (SELECT COUNT(*) FROM like_record lr
       INNER JOIN recipe r ON lr.recipe_id = r.recipe_id
       WHERE r.author_id = u.user_id)                                                  AS likes_received,
    (SELECT COUNT(*) FROM favorite WHERE user_id = u.user_id)                          AS favorites_count,
    (SELECT COUNT(*) FROM recipe_view WHERE user_id = u.user_id)                       AS recipes_viewed,
    (SELECT COUNT(*) FROM search_history WHERE user_id = u.user_id)                    AS searches_made
FROM user u
WHERE u.role = 'user'
ORDER BY published_recipes DESC, likes_received DESC;


-- ============================================================================
-- QUERY 3: Daily/weekly/monthly growth trends
-- Demonstrates: DATE functions, GROUP BY date, subqueries for period comparison
-- ============================================================================

-- Daily stats for the last 30 days
SELECT
    stat_date,
    page_view_count,
    active_user_count,
    new_user_count,
    recipe_view_count
FROM daily_stat
WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY stat_date DESC;

-- Weekly aggregation
SELECT
    YEARWEEK(stat_date, 1)         AS year_week,
    MIN(stat_date)                  AS week_start,
    MAX(stat_date)                  AS week_end,
    SUM(page_view_count)            AS total_page_views,
    ROUND(AVG(active_user_count))   AS avg_daily_active_users,
    SUM(new_user_count)             AS total_new_users,
    SUM(recipe_view_count)          AS total_recipe_views
FROM daily_stat
WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 12 WEEK)
GROUP BY YEARWEEK(stat_date, 1)
ORDER BY year_week DESC;

-- Monthly aggregation
SELECT
    DATE_FORMAT(stat_date, '%Y-%m') AS month,
    SUM(page_view_count)            AS total_page_views,
    ROUND(AVG(active_user_count))   AS avg_daily_active_users,
    SUM(new_user_count)             AS total_new_users,
    SUM(recipe_view_count)          AS total_recipe_views
FROM daily_stat
GROUP BY DATE_FORMAT(stat_date, '%Y-%m')
ORDER BY month DESC;


-- ============================================================================
-- QUERY 4: Cuisine distribution and popularity analysis
-- Demonstrates: GROUP BY, COUNT, SUM with CASE, LEFT JOIN multi-aggregate
-- ============================================================================
SELECT
    r.cuisine,
    COUNT(*)                                                  AS recipe_count,
    COUNT(CASE WHEN r.status = 'published' THEN 1 END)       AS published_count,
    SUM(CASE WHEN r.status = 'published' THEN 1 ELSE 0 END)
        / COUNT(*) * 100                                      AS publish_rate_pct,
    (SELECT COUNT(*) FROM recipe_view rv
       INNER JOIN recipe r2 ON rv.recipe_id = r2.recipe_id
       WHERE r2.cuisine = r.cuisine)                          AS total_views,
    (SELECT COUNT(*) FROM like_record lr
       INNER JOIN recipe r2 ON lr.recipe_id = r2.recipe_id
       WHERE r2.cuisine = r.cuisine)                          AS total_likes,
    (SELECT ROUND(AVG(rev.rating), 2) FROM review rev
       INNER JOIN recipe r2 ON rev.recipe_id = r2.recipe_id
       WHERE r2.cuisine = r.cuisine)                          AS avg_rating
FROM recipe r
GROUP BY r.cuisine
ORDER BY recipe_count DESC;


-- ============================================================================
-- QUERY 5: Popular search terms analysis
-- Demonstrates: GROUP BY, COUNT, DATE functions, ORDER BY aggregate
-- ============================================================================

-- Most searched terms (all time)
SELECT
    LOWER(query) AS search_term,
    COUNT(*)     AS search_count,
    COUNT(DISTINCT user_id) AS unique_users,
    MAX(searched_at) AS last_searched
FROM search_history
GROUP BY LOWER(query)
ORDER BY search_count DESC
LIMIT 20;

-- Search trends in the last 7 days
SELECT
    DATE(searched_at) AS search_date,
    COUNT(*)          AS total_searches,
    COUNT(DISTINCT user_id) AS unique_searchers
FROM search_history
WHERE searched_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(searched_at)
ORDER BY search_date DESC;


-- ============================================================================
-- QUERY 6: Difficulty and time distribution analysis
-- Demonstrates: CASE grouping, AVG, GROUP BY with expressions
-- ============================================================================
SELECT
    r.difficulty,
    COUNT(*) AS recipe_count,
    ROUND(AVG(r.prep_time)) AS avg_prep_min,
    ROUND(AVG(r.cook_time)) AS avg_cook_min,
    ROUND(AVG(r.prep_time + r.cook_time)) AS avg_total_min,
    ROUND(AVG(
        (SELECT AVG(rating) FROM review WHERE recipe_id = r.recipe_id)
    ), 2) AS avg_rating,
    CASE
        WHEN AVG(r.prep_time + r.cook_time) <= 30 THEN 'Quick (<=30 min)'
        WHEN AVG(r.prep_time + r.cook_time) <= 60 THEN 'Medium (31-60 min)'
        ELSE 'Long (>60 min)'
    END AS time_category
FROM recipe r
WHERE r.status = 'published'
GROUP BY r.difficulty
ORDER BY FIELD(r.difficulty, 'easy', 'medium', 'hard');
