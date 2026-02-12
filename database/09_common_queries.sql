-- ============================================================================
-- Script:      09_common_queries.sql
-- Description: Common SELECT queries for the Recipe Sharing System
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Queries demonstrate: JOIN, LEFT JOIN, subquery, GROUP BY, ORDER BY,
--                      HAVING, LIKE, LIMIT, COUNT, AVG, aggregate functions
-- ============================================================================

USE cookhub;

-- ============================================================================
-- QUERY 1: Get all published recipes with author info (JOIN)
-- Demonstrates: INNER JOIN, WHERE, ORDER BY, DATE_FORMAT
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
    u.username        AS author_name,
    u.avatar_url      AS author_avatar,
    DATE_FORMAT(r.created_at, '%M %d, %Y') AS published_date
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
ORDER BY r.created_at DESC;


-- ============================================================================
-- QUERY 2: Get full recipe detail with ingredients, instructions, and images (multi-JOIN)
-- Demonstrates: LEFT JOIN, multiple table joins, subquery for aggregates
-- Parameter: @recipe_id = 1 (Classic Spaghetti Carbonara)
-- ============================================================================
SET @recipe_id = 1;

-- Recipe header with author + aggregated stats
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
    u.username        AS author_name,
    u.avatar_url      AS author_avatar,
    (SELECT COUNT(*) FROM like_record   WHERE recipe_id = r.id)  AS like_count,
    (SELECT COUNT(*) FROM recipe_view   WHERE recipe_id = r.id)  AS view_count,
    (SELECT COUNT(*) FROM review        WHERE recipe_id = r.id)  AS review_count,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating,
    (SELECT COUNT(*) FROM favorite      WHERE recipe_id = r.id)  AS favorite_count
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.id = @recipe_id;

-- Ingredients for the recipe
SELECT
    id,
    name,
    quantity,
    unit,
    sort_order
FROM ingredient
WHERE recipe_id = @recipe_id
ORDER BY sort_order;

-- Instructions for the recipe
SELECT
    id,
    step_number,
    instruction_text
FROM instruction
WHERE recipe_id = @recipe_id
ORDER BY step_number;

-- Images for the recipe
SELECT
    id,
    image_url,
    display_order
FROM recipe_image
WHERE recipe_id = @recipe_id
ORDER BY display_order ASC;


-- ============================================================================
-- QUERY 3: Get user favorites list with recipe stats (LEFT JOIN + subqueries)
-- Demonstrates: LEFT JOIN, subquery in SELECT, ORDER BY
-- Parameter: @user_id = 4 (John Smith)
-- ============================================================================
SET @user_id = 4;

SELECT
    f.id              AS favorite_id,
    r.id              AS recipe_id,
    r.title,
    r.category,
    r.difficulty,
    u.username        AS author_name,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order ASC LIMIT 1) AS image_url,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating,
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count,
    DATE_FORMAT(f.created_at, '%M %d, %Y') AS favorited_date
FROM favorite f
INNER JOIN recipe r ON f.recipe_id = r.id
INNER JOIN user u   ON r.author_id = u.id
WHERE f.user_id = @user_id
ORDER BY f.created_at DESC;


-- ============================================================================
-- QUERY 4: Search recipes by keyword (LIKE + JOIN + GROUP BY aggregation)
-- Demonstrates: LIKE, OR, GROUP BY, HAVING, LEFT JOIN aggregation
-- Parameter: @search_term = 'chicken'
-- ============================================================================
SET @search_term = 'chicken';

SELECT
    r.id,
    r.title,
    r.description,
    r.category,
    r.difficulty,
    r.prep_time,
    r.cook_time,
    u.username        AS author_name,
    (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order ASC LIMIT 1) AS image_url,
    COUNT(DISTINCT rv.id) AS view_count,
    COUNT(DISTINCT lr.id) AS like_count,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating
FROM recipe r
INNER JOIN user u        ON r.author_id = u.id
LEFT JOIN recipe_view rv ON r.id = rv.recipe_id
LEFT JOIN like_record lr ON r.id = lr.recipe_id
WHERE r.status = 'published'
  AND (
      r.title       LIKE CONCAT('%', @search_term, '%')
   OR r.description LIKE CONCAT('%', @search_term, '%')
   OR r.category    LIKE CONCAT('%', @search_term, '%')
  )
GROUP BY r.id, r.title, r.description, r.category, r.difficulty,
         r.prep_time, r.cook_time, u.username
ORDER BY like_count DESC, view_count DESC;


-- ============================================================================
-- QUERY 5: Get recipe reviews with user info and helpfulness
-- Demonstrates: INNER JOIN, ORDER BY, DATE_FORMAT, aggregate in subquery
-- Parameter: @recipe_id = 1
-- ============================================================================
SET @recipe_id = 1;

SELECT
    rv.id             AS review_id,
    rv.rating,
    rv.comment,
    DATE_FORMAT(rv.created_at, '%M %d, %Y') AS review_date,
    u.id              AS user_id,
    u.username        AS reviewer_name,
    u.avatar_url      AS reviewer_avatar,
    (SELECT COUNT(*) FROM review WHERE user_id = u.id) AS total_reviews_by_user
FROM review rv
INNER JOIN user u ON rv.user_id = u.id
WHERE rv.recipe_id = @recipe_id
ORDER BY rv.created_at DESC;
