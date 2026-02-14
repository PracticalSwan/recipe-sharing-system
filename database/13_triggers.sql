USE cookhub;

DELIMITER //

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

CREATE TRIGGER trg_User_UpdateLastActive
BEFORE UPDATE ON session
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        UPDATE `user`
        SET last_active = NOW()
        WHERE id = NEW.user_id;
    END IF;
END //

CREATE TRIGGER trg_Recipe_DeleteCleanup
BEFORE DELETE ON recipe
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        IF NOT EXISTS (
            SELECT 1 FROM activity_log
            WHERE target_type = 'recipe'
              AND target_id = OLD.id
              AND action_type = 'recipe_delete'
              AND created_at >= DATE_SUB(NOW(), INTERVAL 5 SECOND)
        ) THEN
            INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
            VALUES (
                COALESCE(@current_admin_id, OLD.author_id),
                'recipe_delete',
                'recipe',
                OLD.id,
                CONCAT('Trigger-logged deletion of recipe: ', OLD.title)
            );
        END IF;
    END IF;
END //

CREATE TRIGGER trg_User_NewUserStat
AFTER INSERT ON `user`
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

CREATE TRIGGER trg_Recipe_SetTimestamp
BEFORE INSERT ON recipe
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        IF NEW.created_at IS NULL THEN
            SET NEW.created_at = NOW();
        END IF;
        IF NEW.updated_at IS NULL THEN
            SET NEW.updated_at = NOW();
        END IF;
    END IF;
END //

CREATE TRIGGER trg_User_SetTimestamp
BEFORE INSERT ON `user`
FOR EACH ROW
BEGIN
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS != 1 THEN
        IF NEW.created_at IS NULL THEN
            SET NEW.created_at = NOW();
        END IF;
        IF NEW.updated_at IS NULL THEN
            SET NEW.updated_at = NOW();
        END IF;
    END IF;
END //

DELIMITER ;

SELECT
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    EVENT_OBJECT_TABLE,
    ACTION_TIMING,
    ACTION_STATEMENT
FROM INFORMATION_SCHEMA.TRIGGERS
WHERE TRIGGER_SCHEMA = 'cookhub'
ORDER BY EVENT_OBJECT_TABLE, ACTION_TIMING;
