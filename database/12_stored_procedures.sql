-- ============================================================================
-- Script:      12_stored_procedures.sql
-- Description: Stored procedures and functions
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Naming: usp_ prefix for stored procedures, fn_ prefix for functions
-- Params: @p prefix with camelCase (e.g., @pAuthorId)
-- All SPs use transaction handling with ROLLBACK on error
-- ============================================================================

USE cookhub;

DELIMITER //

-- ============================================================================
-- PROCEDURE: usp_CreateRecipe
-- Purpose:   Create a complete recipe with ingredients and instructions
--            in a single transaction
-- Params:    @pAuthorId, @pTitle, @pDescription, @pCuisine, @pDifficulty,
--            @pPrepTime, @pCookTime, @pServings, @pImageUrl,
--            @pIngredients (JSON array), @pInstructions (JSON array)
-- Returns:   The new recipe_id
-- ============================================================================
CREATE PROCEDURE usp_CreateRecipe(
    IN pAuthorId    INT,
    IN pTitle       VARCHAR(200),
    IN pDescription TEXT,
    IN pCuisine     VARCHAR(100),
    IN pDifficulty  ENUM('easy', 'medium', 'hard'),
    IN pPrepTime    INT,
    IN pCookTime    INT,
    IN pServings    INT,
    IN pImageUrl    VARCHAR(500),
    IN pIngredients JSON,
    IN pInstructions JSON,
    OUT pRecipeId   INT
)
BEGIN
    DECLARE v_ingredientCount INT DEFAULT 0;
    DECLARE v_instructionCount INT DEFAULT 0;
    DECLARE v_index INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET pRecipeId = NULL;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error creating recipe. Transaction rolled back.';
    END;

    START TRANSACTION;

    -- Insert the recipe
    INSERT INTO recipe (author_id, title, description, cuisine, difficulty,
                        prep_time, cook_time, servings, status)
    VALUES (pAuthorId, pTitle, pDescription, pCuisine, pDifficulty,
            pPrepTime, pCookTime, pServings, 'pending');

    SET pRecipeId = LAST_INSERT_ID();

    -- Insert primary image if provided
    IF pImageUrl IS NOT NULL AND pImageUrl != '' THEN
        INSERT INTO recipe_image (recipe_id, image_url, is_primary, caption)
        VALUES (pRecipeId, pImageUrl, 1, CONCAT('Primary image for ', pTitle));
    END IF;

    -- Insert ingredients from JSON array
    -- Expected JSON format: [{"name":"...", "amount":"...", "unit":"..."},...]
    SET v_ingredientCount = JSON_LENGTH(pIngredients);
    SET v_index = 0;

    WHILE v_index < v_ingredientCount DO
        INSERT INTO ingredient (recipe_id, name, amount, unit, sort_order)
        VALUES (
            pRecipeId,
            JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[', v_index, '].name'))),
            JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[', v_index, '].amount'))),
            JSON_UNQUOTE(JSON_EXTRACT(pIngredients, CONCAT('$[', v_index, '].unit'))),
            v_index + 1
        );
        SET v_index = v_index + 1;
    END WHILE;

    -- Insert instructions from JSON array
    -- Expected JSON format: [{"description":"Step 1 text"},...]
    SET v_instructionCount = JSON_LENGTH(pInstructions);
    SET v_index = 0;

    WHILE v_index < v_instructionCount DO
        INSERT INTO instruction (recipe_id, step_number, description)
        VALUES (
            pRecipeId,
            v_index + 1,
            JSON_UNQUOTE(JSON_EXTRACT(pInstructions, CONCAT('$[', v_index, '].description')))
        );
        SET v_index = v_index + 1;
    END WHILE;

    COMMIT;
END //


-- ============================================================================
-- PROCEDURE: usp_DeleteRecipe
-- Purpose:   Delete a recipe and all related data with cascade,
--            logging the action in activity_log
-- Params:    @pRecipeId, @pAdminId (the admin performing the deletion)
-- ============================================================================
CREATE PROCEDURE usp_DeleteRecipe(
    IN pRecipeId INT,
    IN pAdminId  INT
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
    WHERE recipe_id = pRecipeId;

    IF v_recipeTitle IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipe not found.';
    END IF;

    START TRANSACTION;

    -- Delete child records (FK CASCADE handles most, but explicit for clarity)
    DELETE FROM recipe_view  WHERE recipe_id = pRecipeId;
    DELETE FROM review       WHERE recipe_id = pRecipeId;
    DELETE FROM like_record  WHERE recipe_id = pRecipeId;
    DELETE FROM favorite     WHERE recipe_id = pRecipeId;
    DELETE FROM recipe_image WHERE recipe_id = pRecipeId;
    DELETE FROM instruction  WHERE recipe_id = pRecipeId;
    DELETE FROM ingredient   WHERE recipe_id = pRecipeId;

    -- Delete the recipe itself
    DELETE FROM recipe WHERE recipe_id = pRecipeId;

    -- Log the admin action
    INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
    VALUES (pAdminId, 'recipe_delete', 'recipe', pRecipeId,
            CONCAT('Deleted recipe: ', v_recipeTitle, ' (author_id: ', v_authorId, ')'));

    COMMIT;
END //


-- ============================================================================
-- PROCEDURE: usp_ApproveRecipe
-- Purpose:   Approve or reject a pending recipe, logging the decision
-- Params:    @pRecipeId, @pAdminId, @pAction ('approve' or 'reject'),
--            @pReason (optional reason for rejection)
-- ============================================================================
CREATE PROCEDURE usp_ApproveRecipe(
    IN pRecipeId INT,
    IN pAdminId  INT,
    IN pAction   VARCHAR(10),
    IN pReason   VARCHAR(500)
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
    WHERE recipe_id = pRecipeId;

    IF v_currentStatus IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipe not found.';
    END IF;

    IF v_currentStatus != 'pending' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipe is not in pending status.';
    END IF;

    -- Validate action
    IF pAction NOT IN ('approve', 'reject') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid action. Must be "approve" or "reject".';
    END IF;

    -- Determine new status and log details
    IF pAction = 'approve' THEN
        SET v_newStatus = 'published';
        SET v_actionType = 'recipe_approve';
        SET v_description = CONCAT('Approved recipe: ', v_recipeTitle);
    ELSE
        SET v_newStatus = 'rejected';
        SET v_actionType = 'recipe_reject';
        SET v_description = CONCAT('Rejected recipe: ', v_recipeTitle);
        IF pReason IS NOT NULL AND pReason != '' THEN
            SET v_description = CONCAT(v_description, ' - ', pReason);
        END IF;
    END IF;

    START TRANSACTION;

    -- Update recipe status
    UPDATE recipe
    SET status = v_newStatus, updated_at = NOW()
    WHERE recipe_id = pRecipeId;

    -- Log the admin action
    INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
    VALUES (pAdminId, v_actionType, 'recipe', pRecipeId, v_description);

    COMMIT;
END //


-- ============================================================================
-- PROCEDURE: usp_GetRecipeStat
-- Purpose:   Get aggregated statistics for a specific recipe
-- Params:    @pRecipeId
-- Returns:   Single-row result set with all recipe stats
-- ============================================================================
CREATE PROCEDURE usp_GetRecipeStat(
    IN pRecipeId INT
)
BEGIN
    SELECT
        r.recipe_id,
        r.title,
        r.status,
        u.display_name AS author_name,
        DATE_FORMAT(r.created_at, '%Y-%m-%d') AS created_date,
        (SELECT COUNT(*) FROM recipe_view WHERE recipe_id = pRecipeId)                AS total_views,
        (SELECT COUNT(*) FROM like_record WHERE recipe_id = pRecipeId)                AS total_likes,
        (SELECT COUNT(*) FROM favorite    WHERE recipe_id = pRecipeId)                AS total_favorites,
        (SELECT COUNT(*) FROM review      WHERE recipe_id = pRecipeId)                AS total_reviews,
        (SELECT ROUND(AVG(rating), 2) FROM review WHERE recipe_id = pRecipeId)        AS avg_rating,
        (SELECT MIN(rating) FROM review WHERE recipe_id = pRecipeId)                  AS min_rating,
        (SELECT MAX(rating) FROM review WHERE recipe_id = pRecipeId)                  AS max_rating,
        (SELECT COUNT(DISTINCT user_id) FROM recipe_view WHERE recipe_id = pRecipeId) AS unique_viewers
    FROM recipe r
    INNER JOIN user u ON r.author_id = u.user_id
    WHERE r.recipe_id = pRecipeId;
END //


-- ============================================================================
-- FUNCTION: fn_CalculateAvgRating
-- Purpose:  Calculate average rating for a recipe, returning 0.0 if no reviews
-- Params:   @pRecipeId
-- Returns:  DECIMAL(3,2) average rating
-- ============================================================================
CREATE FUNCTION fn_CalculateAvgRating(
    pRecipeId INT
)
RETURNS DECIMAL(3, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avgRating DECIMAL(3, 2);

    SELECT ROUND(AVG(rating), 2)
    INTO v_avgRating
    FROM review
    WHERE recipe_id = pRecipeId;

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
--     'American',                                           -- cuisine
--     'easy',                                               -- difficulty
--     5,                                                    -- prep_time
--     10,                                                   -- cook_time
--     1,                                                    -- servings
--     'https://images.unsplash.com/photo-grilled-cheese',   -- image_url
--     '[{"name":"Bread","amount":"2","unit":"slices"},{"name":"Cheese","amount":"2","unit":"slices"},{"name":"Butter","amount":"1","unit":"tbsp"}]',
--     '[{"description":"Butter one side of each bread slice."},{"description":"Place cheese between bread slices."},{"description":"Grill on medium heat until golden and cheese is melted."}]',
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
