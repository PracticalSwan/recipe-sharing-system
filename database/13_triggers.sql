-- ============================================================================
-- Script:      13_triggers.sql
-- Description: Database triggers for automated operations
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Naming: trg_ prefix followed by TableName_Purpose
-- Safety: All triggers check @DISABLE_TRIGGERS to allow safe seeding
-- ============================================================================

USE cookhub;

DELIMITER //

-- ============================================================================
-- TRIGGER: trg_RecipeView_UpdateStat
-- Purpose: After inserting a recipe_view, increment daily_stat.recipe_view_count
--          for the current date (auto-create row if it doesn't exist)
-- ============================================================================
CREATE TRIGGER trg_RecipeView_UpdateStat
AFTER INSERT ON recipe_view
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        INSERT INTO daily_stat (stat_date, page_view_count, active_user_count, new_user_count, recipe_view_count)
        VALUES (CURDATE(), 1, 0, 0, 1)
        ON DUPLICATE KEY UPDATE
            recipe_view_count = recipe_view_count + 1,
            page_view_count   = page_view_count + 1;
    END IF;
END //


-- ============================================================================
-- TRIGGER: trg_User_UpdateLastActive
-- Purpose: Before updating a session record, update the user's last_active
--          timestamp to keep session activity in sync
-- ============================================================================
CREATE TRIGGER trg_User_UpdateLastActive
BEFORE UPDATE ON session
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        UPDATE user
        SET last_active = NOW()
        WHERE user_id = NEW.user_id;
    END IF;
END //


-- ============================================================================
-- TRIGGER: trg_Recipe_DeleteCleanup
-- Purpose: Before deleting a recipe, log the action to activity_log
--          (defensive logging in case deletion bypasses the stored procedure)
-- ============================================================================
CREATE TRIGGER trg_Recipe_DeleteCleanup
BEFORE DELETE ON recipe
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        -- Only log if not already logged by the stored procedure
        -- Check if a recent log entry exists (within 5 seconds)
        IF NOT EXISTS (
            SELECT 1 FROM activity_log
            WHERE target_type = 'recipe'
              AND target_id = OLD.recipe_id
              AND action_type = 'recipe_delete'
              AND created_at >= DATE_SUB(NOW(), INTERVAL 5 SECOND)
        ) THEN
            INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
            VALUES (
                COALESCE(@current_admin_id, 1),
                'recipe_delete',
                'recipe',
                OLD.recipe_id,
                CONCAT('Trigger-logged deletion of recipe: ', OLD.title)
            );
        END IF;
    END IF;
END //


-- ============================================================================
-- TRIGGER: trg_User_NewUserStat
-- Purpose: After inserting a new user, increment daily_stat.new_user_count
--          for the current date
-- ============================================================================
CREATE TRIGGER trg_User_NewUserStat
AFTER INSERT ON user
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        INSERT INTO daily_stat (stat_date, page_view_count, active_user_count, new_user_count, recipe_view_count)
        VALUES (CURDATE(), 0, 1, 1, 0)
        ON DUPLICATE KEY UPDATE
            new_user_count    = new_user_count + 1,
            active_user_count = active_user_count + 1;
    END IF;
END //


-- ============================================================================
-- TRIGGER: trg_Recipe_SetTimestamp
-- Purpose: Before updating a recipe, automatically set updated_at to NOW()
-- ============================================================================
CREATE TRIGGER trg_Recipe_SetTimestamp
BEFORE UPDATE ON recipe
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        SET NEW.updated_at = NOW();
    END IF;
END //


-- ============================================================================
-- TRIGGER: trg_User_SetTimestamp
-- Purpose: Before updating a user, automatically set updated_at to NOW()
-- ============================================================================
CREATE TRIGGER trg_User_SetTimestamp
BEFORE UPDATE ON user
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        SET NEW.updated_at = NOW();
    END IF;
END //


DELIMITER ;

-- ============================================================================
-- VERIFY TRIGGERS
-- ============================================================================
SELECT
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    EVENT_OBJECT_TABLE,
    ACTION_TIMING,
    ACTION_STATEMENT
FROM INFORMATION_SCHEMA.TRIGGERS
WHERE TRIGGER_SCHEMA = 'cookhub'
ORDER BY EVENT_OBJECT_TABLE, ACTION_TIMING;
