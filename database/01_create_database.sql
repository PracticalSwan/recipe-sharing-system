-- ============================================================================
-- Script:      01_create_database.sql
-- Description: Creates the CookHub Recipe Sharing System database
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- This script creates the main database with UTF8MB4 character set
-- to support full Unicode including emojis in recipe descriptions and reviews.
-- ============================================================================

-- Drop existing database if it exists (use with caution in production)
DROP DATABASE IF EXISTS cookhub;

-- Create the database with full Unicode support
CREATE DATABASE cookhub
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Switch to the new database
USE cookhub;

-- Verify database creation
SELECT SCHEMA_NAME, DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME
FROM INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'cookhub';
