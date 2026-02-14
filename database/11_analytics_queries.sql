USE cookhub;

SELECT
    r.id,
    r.title,
    r.category,
    u.username AS author_name,
    COUNT(rv.id) AS total_views,
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id)            AS like_count,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id)   AS avg_rating
FROM recipe r
INNER JOIN `user` u        ON r.author_id = u.id
LEFT JOIN recipe_view rv ON r.id = rv.recipe_id
WHERE r.status = 'published'
GROUP BY r.id, r.title, r.category, u.username
ORDER BY total_views DESC
LIMIT 10;

SELECT
    r.id,
    r.title,
    r.category,
    u.username AS author_name,
    COUNT(lr.id) AS total_likes,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE recipe_id = r.id) AS avg_rating
FROM recipe r
INNER JOIN `user` u       ON r.author_id = u.id
LEFT JOIN like_record lr ON r.id = lr.recipe_id
WHERE r.status = 'published'
GROUP BY r.id, r.title, r.category, u.username
ORDER BY total_likes DESC
LIMIT 10;

SELECT
    r.id,
    r.title,
    r.category,
    u.username AS author_name,
    COUNT(rv.id)                AS review_count,
    ROUND(AVG(rv.rating), 2)    AS avg_rating
FROM recipe r
INNER JOIN `user` u   ON r.author_id = u.id
INNER JOIN review rv ON r.id = rv.recipe_id
WHERE r.status = 'published'
GROUP BY r.id, r.title, r.category, u.username
HAVING review_count >= 2
ORDER BY avg_rating DESC, review_count DESC
LIMIT 10;

SELECT
    u.id,
    u.username,
    u.status,
    DATE_FORMAT(u.joined_date, '%Y-%m-%d') AS joined_date,
    (SELECT COUNT(*) FROM recipe WHERE author_id = u.id AND status = 'published') AS published_recipes,
    (SELECT COUNT(*) FROM review WHERE user_id = u.id)                            AS reviews_written,
    (SELECT ROUND(AVG(rating), 1) FROM review WHERE user_id = u.id)               AS avg_rating_given,
    (SELECT COUNT(*) FROM like_record WHERE user_id = u.id)                       AS likes_given,
    (SELECT COUNT(*) FROM like_record lr
       INNER JOIN recipe r ON lr.recipe_id = r.id
       WHERE r.author_id = u.id)                                                  AS likes_received,
    (SELECT COUNT(*) FROM favorite WHERE user_id = u.id)                          AS favorites_count,
    (SELECT COUNT(*) FROM recipe_view WHERE user_id = u.id)                       AS recipes_viewed,
    (SELECT COUNT(*) FROM search_history WHERE user_id = u.id)                    AS searches_made
FROM `user` u
WHERE u.role = 'user'
ORDER BY published_recipes DESC, likes_received DESC;

SELECT
    stat_date,
    page_view_count,
    active_user_count,
    new_user_count,
    recipe_view_count
FROM daily_stat
WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY stat_date DESC;

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

SELECT
    DATE_FORMAT(stat_date, '%Y-%m') AS month,
    SUM(page_view_count)            AS total_page_views,
    ROUND(AVG(active_user_count))   AS avg_daily_active_users,
    SUM(new_user_count)             AS total_new_users,
    SUM(recipe_view_count)          AS total_recipe_views
FROM daily_stat
GROUP BY DATE_FORMAT(stat_date, '%Y-%m')
ORDER BY month DESC;

SELECT
    r.category,
    COUNT(*)                                                  AS recipe_count,
    COUNT(CASE WHEN r.status = 'published' THEN 1 END)       AS published_count,
    SUM(CASE WHEN r.status = 'published' THEN 1 ELSE 0 END)
        / COUNT(*) * 100                                      AS publish_rate_pct,
    (SELECT COUNT(*) FROM recipe_view rv
       INNER JOIN recipe r2 ON rv.recipe_id = r2.id
       WHERE r2.category = r.category)                        AS total_views,
    (SELECT COUNT(*) FROM like_record lr
       INNER JOIN recipe r2 ON lr.recipe_id = r2.id
       WHERE r2.category = r.category)                        AS total_likes,
    (SELECT ROUND(AVG(rev.rating), 2) FROM review rev
       INNER JOIN recipe r2 ON rev.recipe_id = r2.id
       WHERE r2.category = r.category)                        AS avg_rating
FROM recipe r
GROUP BY r.category
ORDER BY recipe_count DESC;

SELECT
    LOWER(query) AS search_term,
    COUNT(*)     AS search_count,
    COUNT(DISTINCT user_id) AS unique_users,
    MAX(searched_at) AS last_searched
FROM search_history
GROUP BY LOWER(query)
ORDER BY search_count DESC
LIMIT 20;

SELECT
    DATE(searched_at) AS search_date,
    COUNT(*)          AS total_searches,
    COUNT(DISTINCT user_id) AS unique_searchers
FROM search_history
WHERE searched_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(searched_at)
ORDER BY search_date DESC;

SELECT
    r.difficulty,
    COUNT(*) AS recipe_count,
    ROUND(AVG(r.prep_time)) AS avg_prep_min,
    ROUND(AVG(r.cook_time)) AS avg_cook_min,
    ROUND(AVG(r.prep_time + r.cook_time)) AS avg_total_min,
    ROUND(AVG(
        (SELECT AVG(rating) FROM review WHERE recipe_id = r.id)
    ), 2) AS avg_rating,
    CASE
        WHEN AVG(r.prep_time + r.cook_time) <= 30 THEN 'Quick (<=30 min)'
        WHEN AVG(r.prep_time + r.cook_time) <= 60 THEN 'Medium (31-60 min)'
        ELSE 'Long (>60 min)'
    END AS time_category
FROM recipe r
WHERE r.status = 'published'
GROUP BY r.difficulty
ORDER BY FIELD(r.difficulty, 'Easy', 'Medium', 'Hard');
