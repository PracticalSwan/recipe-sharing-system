-- ============================================================================
-- Script:      14_backup_restore.sql
-- Description: Database backup and restore documentation with utility scripts
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- This file contains documentation and SQL utilities for backup/restore.
-- Shell commands are in comments; SQL utilities can be run from phpMyAdmin.
-- ============================================================================

USE cookhub;

-- ============================================================================
-- SECTION 1: FULL DATABASE BACKUP (mysqldump)
-- ============================================================================
-- Run these commands from the terminal / command prompt (NOT in phpMyAdmin).
-- Adjust paths based on your XAMPP installation directory.
--
-- FULL BACKUP (structure + data):
-- Windows (XAMPP):
--   C:\xampp\mysql\bin\mysqldump -u root cookhub > C:\backup\cookhub_full_YYYYMMDD.sql
--
-- With timestamp (PowerShell):
--   C:\xampp\mysql\bin\mysqldump -u root cookhub > "C:\backup\cookhub_full_$(Get-Date -Format yyyyMMdd_HHmmss).sql"
--
-- STRUCTURE ONLY (no data):
--   C:\xampp\mysql\bin\mysqldump -u root --no-data cookhub > C:\backup\cookhub_schema_YYYYMMDD.sql
--
-- DATA ONLY (no CREATE statements):
--   C:\xampp\mysql\bin\mysqldump -u root --no-create-info cookhub > C:\backup\cookhub_data_YYYYMMDD.sql
--
-- SPECIFIC TABLES ONLY:
--   C:\xampp\mysql\bin\mysqldump -u root cookhub user recipe ingredient instruction > C:\backup\cookhub_core_YYYYMMDD.sql
--
-- WITH TRIGGERS AND ROUTINES:
--   C:\xampp\mysql\bin\mysqldump -u root --routines --triggers cookhub > C:\backup\cookhub_complete_YYYYMMDD.sql
-- ============================================================================


-- ============================================================================
-- SECTION 2: DATABASE RESTORE (mysql import)
-- ============================================================================
-- FULL RESTORE from backup:
--   C:\xampp\mysql\bin\mysql -u root cookhub < C:\backup\cookhub_full_YYYYMMDD.sql
--
-- RESTORE INTO NEW DATABASE:
--   C:\xampp\mysql\bin\mysql -u root -e "CREATE DATABASE cookhub_restored CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
--   C:\xampp\mysql\bin\mysql -u root cookhub_restored < C:\backup\cookhub_full_YYYYMMDD.sql
--
-- RESTORE VIA PHPMYADMIN:
--   1. Open phpMyAdmin (http://localhost/phpmyadmin)
--   2. Select the 'cookhub' database (or create it first)
--   3. Click the 'Import' tab
--   4. Click 'Choose File' and select your .sql backup file
--   5. Keep default settings (SQL format, utf-8 charset)
--   6. Click 'Go' to import
-- ============================================================================


-- ============================================================================
-- SECTION 3: SQL UTILITY - Export recipe data as INSERT statements
-- Run this in phpMyAdmin to generate portable INSERT statements
-- ============================================================================

-- Generate INSERT statements for all users (useful for migration)
SELECT CONCAT(
    'INSERT INTO user (username, email, password_hash, display_name, role, status, bio, avatar_url) VALUES (',
    QUOTE(username), ', ',
    QUOTE(email), ', ',
    QUOTE(password_hash), ', ',
    QUOTE(display_name), ', ',
    QUOTE(role), ', ',
    QUOTE(status), ', ',
    IFNULL(QUOTE(bio), 'NULL'), ', ',
    IFNULL(QUOTE(avatar_url), 'NULL'),
    ');'
) AS insert_statement
FROM user;


-- ============================================================================
-- SECTION 4: DATABASE HEALTH CHECK
-- Run these queries to verify database integrity after restore
-- ============================================================================

-- Check table counts (expected: 13 tables)
SELECT
    TABLE_NAME,
    TABLE_ROWS   AS estimated_rows,
    ROUND(DATA_LENGTH / 1024, 2) AS data_kb,
    ROUND(INDEX_LENGTH / 1024, 2) AS index_kb,
    TABLE_COLLATION
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'cookhub'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Check view count (expected: 2 views)
SELECT TABLE_NAME, VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'cookhub';

-- Check stored procedures and functions (expected: 4 procedures + 1 function)
SELECT ROUTINE_NAME, ROUTINE_TYPE, CREATED
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'cookhub'
ORDER BY ROUTINE_TYPE, ROUTINE_NAME;

-- Check triggers (expected: 6 triggers)
SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE, EVENT_MANIPULATION, ACTION_TIMING
FROM INFORMATION_SCHEMA.TRIGGERS
WHERE TRIGGER_SCHEMA = 'cookhub'
ORDER BY EVENT_OBJECT_TABLE;

-- Check foreign key constraints
SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'cookhub'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- Check indexes
SELECT
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns,
    NON_UNIQUE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'cookhub'
GROUP BY TABLE_NAME, INDEX_NAME, NON_UNIQUE
ORDER BY TABLE_NAME, INDEX_NAME;

-- Row counts for all tables (exact)
SELECT 'user' AS table_name, COUNT(*) AS row_count FROM user
UNION ALL SELECT 'recipe', COUNT(*) FROM recipe
UNION ALL SELECT 'ingredient', COUNT(*) FROM ingredient
UNION ALL SELECT 'instruction', COUNT(*) FROM instruction
UNION ALL SELECT 'recipe_image', COUNT(*) FROM recipe_image
UNION ALL SELECT 'review', COUNT(*) FROM review
UNION ALL SELECT 'like_record', COUNT(*) FROM like_record
UNION ALL SELECT 'favorite', COUNT(*) FROM favorite
UNION ALL SELECT 'recipe_view', COUNT(*) FROM recipe_view
UNION ALL SELECT 'search_history', COUNT(*) FROM search_history
UNION ALL SELECT 'daily_stat', COUNT(*) FROM daily_stat
UNION ALL SELECT 'activity_log', COUNT(*) FROM activity_log
UNION ALL SELECT 'session', COUNT(*) FROM session;


-- ============================================================================
-- SECTION 5: COMPLETE REBUILD SEQUENCE
-- Execute scripts in order to rebuild the entire database from scratch
-- ============================================================================
-- 1.  SOURCE database/01_create_database.sql;
-- 2.  SOURCE database/02_create_tables.sql;
-- 3.  SOURCE database/03_create_indexes.sql;
-- 4.  SOURCE database/04_create_views.sql;
-- 5.  SOURCE database/12_stored_procedures.sql;   -- Before triggers (SPs referenced)
-- 6.  SOURCE database/13_triggers.sql;
-- 7.  SET @DISABLE_TRIGGERS = 1;                  -- Disable triggers during seeding
-- 8.  SOURCE database/05_seed_users.sql;
-- 9.  SOURCE database/06_seed_recipes.sql;
-- 10. SOURCE database/07_seed_reviews.sql;
-- 11. SOURCE database/08_seed_stats.sql;
-- 12. SET @DISABLE_TRIGGERS = NULL;               -- Re-enable triggers
-- 13. SOURCE database/14_backup_restore.sql;      -- Verify with health check
