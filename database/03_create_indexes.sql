-- ============================================================================
-- Script:      03_create_indexes.sql
-- Description: Creates additional indexes for query performance optimization
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Indexes supplement the primary keys, unique keys, and foreign keys
-- already defined in 02_create_tables.sql. These target:
--   - Frequent WHERE clause columns
--   - JOIN columns
--   - Columns used in ORDER BY / GROUP BY
--   - Composite indexes for multi-column queries
-- ============================================================================

USE cookhub;

-- ============================================================================
-- USER TABLE INDEXES
-- ============================================================================

-- Fast lookup by email (used during login authentication)
CREATE INDEX idx_user_email
    ON user (email);

-- Filter users by role and status (admin dashboard)
CREATE INDEX idx_user_role_status
    ON user (role, status);

-- Sort users by join date (admin user listing)
CREATE INDEX idx_user_joined_date
    ON user (joined_date);

-- ============================================================================
-- RECIPE TABLE INDEXES
-- ============================================================================

-- Filter recipes by author (profile page, user's recipes)
CREATE INDEX idx_recipe_author_id
    ON recipe (author_id);

-- Filter recipes by publication status (approval queue, published listing)
CREATE INDEX idx_recipe_status
    ON recipe (status);

-- Filter recipes by category (browse by category)
CREATE INDEX idx_recipe_category
    ON recipe (category);

-- Composite: author + status (user's published/pending recipes)
CREATE INDEX idx_recipe_author_status
    ON recipe (author_id, status);

-- Sort recipes by creation date (newest first)
CREATE INDEX idx_recipe_created_at
    ON recipe (created_at);

-- ============================================================================
-- REVIEW TABLE INDEXES
-- ============================================================================

-- Get all reviews for a recipe (recipe detail page)
CREATE INDEX idx_review_recipe_id
    ON review (recipe_id);

-- Get all reviews by a user (user profile)
CREATE INDEX idx_review_user_id
    ON review (user_id);

-- ============================================================================
-- FAVORITE TABLE INDEXES
-- ============================================================================

-- Get all favorites for a user (user profile favorites tab)
CREATE INDEX idx_favorite_user_id
    ON favorite (user_id);

-- Count favorites for a recipe
CREATE INDEX idx_favorite_recipe_id
    ON favorite (recipe_id);

-- ============================================================================
-- LIKE_RECORD TABLE INDEXES
-- ============================================================================

-- Get all likes for a recipe (like count)
CREATE INDEX idx_like_record_recipe_id
    ON like_record (recipe_id);

-- Get all likes by a user
CREATE INDEX idx_like_record_user_id
    ON like_record (user_id);

-- ============================================================================
-- SEARCH_HISTORY TABLE INDEXES
-- ============================================================================

-- Get search history for a user (search suggestions)
CREATE INDEX idx_search_history_user_id
    ON search_history (user_id);

-- Sort by search date (most recent first)
CREATE INDEX idx_search_history_searched_at
    ON search_history (user_id, searched_at);

-- ============================================================================
-- DAILY_STAT TABLE INDEXES
-- ============================================================================

-- Lookup stats by date range (dashboard charts)
CREATE INDEX idx_daily_stat_date
    ON daily_stat (stat_date);

-- ============================================================================
-- ACTIVITY_LOG TABLE INDEXES
-- ============================================================================

-- Filter activities by admin user
CREATE INDEX idx_activity_log_admin_id
    ON activity_log (admin_id);

-- Sort activities by date (recent activity feed)
CREATE INDEX idx_activity_log_created_at
    ON activity_log (created_at);

-- Composite: admin + date (admin's recent actions)
CREATE INDEX idx_activity_log_admin_created
    ON activity_log (admin_id, created_at);

-- ============================================================================
-- SESSION TABLE INDEXES
-- ============================================================================

-- Fast session lookup by token (authentication middleware)
CREATE INDEX idx_session_token
    ON session (session_token);

-- Find sessions by user (logout all sessions)
CREATE INDEX idx_session_user_id
    ON session (user_id);

-- Find expired sessions (cleanup job)
CREATE INDEX idx_session_expires_at
    ON session (expires_at);

-- ============================================================================
-- INGREDIENT TABLE INDEXES
-- ============================================================================

-- Get ingredients for a recipe in order
CREATE INDEX idx_ingredient_recipe_order
    ON ingredient (recipe_id, sort_order);

-- ============================================================================
-- INSTRUCTION TABLE INDEXES
-- ============================================================================

-- Get instructions for a recipe in step order
CREATE INDEX idx_instruction_recipe_step
    ON instruction (recipe_id, step_number);

-- Verify indexes were created
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'cookhub'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
