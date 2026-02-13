-- ============================================================================
-- Script:      12_stored_procedures.sql
-- Description: Stored procedures and functions
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Naming: usp_ prefix for stored procedures, fn_ prefix for functions
-- Params: p_ prefix with snake_case (e.g., p_author_id)
-- All SPs use transaction handling with ROLLBACK on error
-- ============================================================================

USE cookhub;

DELIMITER //

-- ============================================================================
-- PROCEDURE: usp_CreateRecipe
-- Purpose:   Create a complete recipe with ingredients and instructions
--            in a single transaction
-- Params:    p_author_id, p_title, p_description, p_category, p_difficulty,
--            p_prep_time, p_cook_time, p_servings, p_image_url,
--            p_ingredients (JSON array), p_instructions (JSON array)
-- Returns:   The new recipe id
-- ============================================================================
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

    -- Insert the recipe
    INSERT INTO recipe (author_id, title, description, category, difficulty,
                        prep_time, cook_time, servings, status)
    VALUES (p_author_id, p_title, p_description, p_category, p_difficulty,
            p_prep_time, p_cook_time, p_servings, 'pending');

    SET p_recipe_id = LAST_INSERT_ID();

    -- Insert primary image if provided
    IF p_image_url IS NOT NULL AND p_image_url != '' THEN
        INSERT INTO recipe_image (recipe_id, image_url, display_order)
        VALUES (p_recipe_id, p_image_url, 1);
    END IF;

    -- Insert ingredients from JSON array
    -- Expected JSON format: [{"name":"...", "quantity":"...", "unit":"..."},...]
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

    -- Insert instructions from JSON array
    -- Expected JSON format: [{"instruction_text":"Step 1 text"},...]
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


-- ============================================================================
-- PROCEDURE: usp_DeleteRecipe
-- Purpose:   Delete a recipe and all related data with cascade,
--            logging the action in activity_log
-- Params:    p_recipe_id, p_admin_id (the admin performing the deletion)
-- ============================================================================
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

    -- Verify recipe exists
    SELECT title, author_id
    INTO v_recipeTitle, v_authorId
    FROM recipe
    WHERE id = p_recipe_id;

    IF v_recipeTitle IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipe not found.';
    END IF;

    START TRANSACTION;

    -- Delete child records (FK CASCADE handles most, but explicit for clarity)
    DELETE FROM recipe_view  WHERE recipe_id = p_recipe_id;
    DELETE FROM review       WHERE recipe_id = p_recipe_id;
    DELETE FROM like_record  WHERE recipe_id = p_recipe_id;
    DELETE FROM favorite     WHERE recipe_id = p_recipe_id;
    DELETE FROM recipe_image WHERE recipe_id = p_recipe_id;
    DELETE FROM instruction  WHERE recipe_id = p_recipe_id;
    DELETE FROM ingredient   WHERE recipe_id = p_recipe_id;

    -- Delete the recipe itself
    DELETE FROM recipe WHERE id = p_recipe_id;

    -- Log the admin action
    INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
    VALUES (p_admin_id, 'recipe_delete', 'recipe', p_recipe_id,
            CONCAT('Deleted recipe: ', v_recipeTitle, ' (author_id: ', v_authorId, ')'));

    COMMIT;
END //


-- ============================================================================
-- PROCEDURE: usp_ApproveRecipe
-- Purpose:   Approve or reject a pending recipe, logging the decision
-- Params:    p_recipe_id, p_admin_id, p_action ('approve' or 'reject'),
--            p_reason (optional reason for rejection)
-- ============================================================================
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

    -- Validate recipe exists and is pending
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

    -- Validate action
    IF p_action NOT IN ('approve', 'reject') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid action. Must be "approve" or "reject".';
    END IF;

    -- Determine new status and log details
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

    -- Update recipe status
    UPDATE recipe
    SET status = v_newStatus, updated_at = NOW()
    WHERE id = p_recipe_id;

    -- Log the admin action
    INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
    VALUES (p_admin_id, v_actionType, 'recipe', p_recipe_id, v_description);

    COMMIT;
END //


-- ============================================================================
-- PROCEDURE: usp_GetRecipeStat
-- Purpose:   Get aggregated statistics for a specific recipe
-- Params:    p_recipe_id
-- Returns:   Single-row result set with all recipe stats
-- ============================================================================
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
    INNER JOIN user u ON r.author_id = u.id
    WHERE r.id = p_recipe_id;
END //


-- ============================================================================
-- FUNCTION: fn_CalculateAvgRating
-- Purpose:  Calculate average rating for a recipe, returning 0.0 if no reviews
-- Params:   p_recipe_id
-- Returns:  DECIMAL(3,2) average rating
-- ============================================================================
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

-- ============================================================================
-- USAGE EXAMPLES
-- ============================================================================

-- Example: Create a new recipe with ingredients and instructions
-- CALL usp_CreateRecipe(
--     4,                                                    -- author_id (John)
--     'Grilled Cheese Sandwich',                            -- title
--     'Classic comfort food',                               -- description
--     'American',                                           -- category
--     'Easy',                                               -- difficulty
--     5,                                                    -- prep_time
--     10,                                                   -- cook_time
--     1,                                                    -- servings
--     'https://images.unsplash.com/photo-grilled-cheese',   -- image_url
--     '[{"name":"Bread","quantity":"2","unit":"slices"},{"name":"Cheese","quantity":"2","unit":"slices"},{"name":"Butter","quantity":"1","unit":"tbsp"}]',
--     '[{"instruction_text":"Butter one side of each bread slice."},{"instruction_text":"Place cheese between bread slices."},{"instruction_text":"Grill on medium heat until golden and cheese is melted."}]',
--     @new_recipe_id
-- );
-- SELECT @new_recipe_id;

-- Example: Approve a pending recipe
-- CALL usp_ApproveRecipe(14, 1, 'approve', NULL);

-- Example: Reject a pending recipe
-- CALL usp_ApproveRecipe(14, 1, 'reject', 'Missing required nutritional info');

-- Example: Delete a recipe
-- CALL usp_DeleteRecipe(14, 1);

-- Example: Get recipe stats
-- CALL usp_GetRecipeStat(1);

-- Example: Calculate average rating
-- SELECT fn_CalculateAvgRating(1) AS avg_rating;
