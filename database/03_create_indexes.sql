USE cookhub;

CREATE INDEX idx_user_email
    ON `user` (email);

CREATE INDEX idx_user_role_status
    ON `user` (role, status);

CREATE INDEX idx_user_joined_date
    ON `user` (joined_date);

CREATE INDEX idx_recipe_author_id
    ON recipe (author_id);

CREATE INDEX idx_recipe_status
    ON recipe (status);

CREATE INDEX idx_recipe_category
    ON recipe (category);

CREATE INDEX idx_recipe_author_status
    ON recipe (author_id, status);

CREATE INDEX idx_recipe_created_at
    ON recipe (created_at);

CREATE INDEX idx_review_recipe_id
    ON review (recipe_id);

CREATE INDEX idx_review_user_id
    ON review (user_id);

CREATE INDEX idx_favorite_user_id
    ON favorite (user_id);

CREATE INDEX idx_favorite_recipe_id
    ON favorite (recipe_id);

CREATE INDEX idx_like_record_recipe_id
    ON like_record (recipe_id);

CREATE INDEX idx_like_record_user_id
    ON like_record (user_id);

CREATE INDEX idx_search_history_user_id
    ON search_history (user_id);

CREATE INDEX idx_search_history_searched_at
    ON search_history (user_id, searched_at);

CREATE INDEX idx_daily_stat_date
    ON daily_stat (stat_date);

CREATE INDEX idx_activity_log_admin_id
    ON activity_log (admin_id);

CREATE INDEX idx_activity_log_created_at
    ON activity_log (created_at);

CREATE INDEX idx_activity_log_admin_created
    ON activity_log (admin_id, created_at);

CREATE INDEX idx_session_token
    ON session (session_token);

CREATE INDEX idx_session_user_id
    ON session (user_id);

CREATE INDEX idx_session_expires_at
    ON session (expires_at);

CREATE INDEX idx_ingredient_recipe_order
    ON ingredient (recipe_id, sort_order);

CREATE INDEX idx_instruction_recipe_step
    ON instruction (recipe_id, step_number);

SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'cookhub'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
