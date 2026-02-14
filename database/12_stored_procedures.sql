USE cookhub;

DELIMITER //

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

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_recipe_id = NULL;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error creating recipe. Transaction rolled back.';
    END;

    START TRANSACTION;

    INSERT INTO recipe (author_id, title, description, category, difficulty,
                        prep_time, cook_time, servings, status)
    VALUES (p_author_id, p_title, p_description, p_category, p_difficulty,
            p_prep_time, p_cook_time, p_servings, 'pending');

    SET p_recipe_id = LAST_INSERT_ID();

    IF p_image_url IS NOT NULL AND p_image_url != '' THEN
        INSERT INTO recipe_image (recipe_id, image_url, display_order)
        VALUES (p_recipe_id, p_image_url, 1);
    END IF;

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

    SELECT title, author_id
    INTO v_recipeTitle, v_authorId
    FROM recipe
    WHERE id = p_recipe_id;

    IF v_recipeTitle IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipe not found.';
    END IF;

    START TRANSACTION;

    DELETE FROM recipe_view  WHERE recipe_id = p_recipe_id;
    DELETE FROM review       WHERE recipe_id = p_recipe_id;
    DELETE FROM like_record  WHERE recipe_id = p_recipe_id;
    DELETE FROM favorite     WHERE recipe_id = p_recipe_id;
    DELETE FROM recipe_image WHERE recipe_id = p_recipe_id;
    DELETE FROM instruction  WHERE recipe_id = p_recipe_id;
    DELETE FROM ingredient   WHERE recipe_id = p_recipe_id;

    DELETE FROM recipe WHERE id = p_recipe_id;

    INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
    VALUES (p_admin_id, 'recipe_delete', 'recipe', p_recipe_id,
            CONCAT('Deleted recipe: ', v_recipeTitle, ' (author_id: ', v_authorId, ')'));

    COMMIT;
END //

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

    SELECT status, title
    INTO v_currentStatus, v_recipeTitle
    FROM recipe
    WHERE id = p_recipe_id;

    IF v_currentStatus IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipe not found.';
    END IF;

    IF v_currentStatus != 'pending' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipe is not in pending status.';
    END IF;

    IF p_action NOT IN ('approve', 'reject') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid action. Must be "approve" or "reject".';
    END IF;

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

    UPDATE recipe
    SET status = v_newStatus, updated_at = NOW()
    WHERE id = p_recipe_id;

    INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
    VALUES (p_admin_id, v_actionType, 'recipe', p_recipe_id, v_description);

    COMMIT;
END //

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

    IF v_avgRating IS NULL THEN
        SET v_avgRating = 0.00;
    END IF;

    RETURN v_avgRating;
END //

DELIMITER ;
