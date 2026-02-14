USE cookhub;

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
INNER JOIN `user` u ON r.author_id = u.id
WHERE r.status = 'published'
ORDER BY r.created_at DESC;

SET @recipe_id = 1;

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
INNER JOIN `user` u ON r.author_id = u.id
WHERE r.id = @recipe_id;

SELECT
    id,
    name,
    quantity,
    unit,
    sort_order
FROM ingredient
WHERE recipe_id = @recipe_id
ORDER BY sort_order;

SELECT
    id,
    step_number,
    instruction_text
FROM instruction
WHERE recipe_id = @recipe_id
ORDER BY step_number;

SELECT
    id,
    image_url,
    display_order
FROM recipe_image
WHERE recipe_id = @recipe_id
ORDER BY display_order ASC;

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
INNER JOIN `user` u   ON r.author_id = u.id
WHERE f.user_id = @user_id
ORDER BY f.created_at DESC;

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
INNER JOIN `user` u        ON r.author_id = u.id
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
INNER JOIN `user` u ON rv.user_id = u.id
WHERE rv.recipe_id = @recipe_id
ORDER BY rv.created_at DESC;
