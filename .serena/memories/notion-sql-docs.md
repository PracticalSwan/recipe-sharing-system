# Notion SQL Documentation - Recipe Sharing System

## Overview
Complete SQL script documentation organized in Notion with reference page and 14 child pages.

## Notion Structure

### Main Reference Page
**URL:** https://www.notion.so/CookHub-Complete-SQL-Scripts-Reference-300e35b852f081c5a148ec7aa1cee4c8

**Created:** February 13, 2026

**Purpose:** Central hub for all SQL scripts used in CookHub Recipe Sharing System.

### Child Pages (14 Total)

Each page contains SQL code with Title and Description header:
```sql
-- ============================================================================
-- Title:       [Title]
-- Description: [Brief one-line description]
-- ============================================================================
```

#### 1. Create Database
- **Page ID:** 305e35b8-52f0-817e-accf-eae0a5d9c56d
- **Description:** Creates main CookHub Recipe Sharing System database with UTF8MB4 support for full Unicode including emojis
- **Key Operations:**
  - Drops existing database (if exists)
  - Creates cookhub database with utf8mb4 character set utf8mb4_unicode_ci collation
  - Verifies database creation

#### 2. Create Tables
- **Page ID:** 305e35b8-52f0-8131-b7e6-ca808927cce3
- **Description:** Creates 13 core database tables
- **Tables Created:**
  1. user - User accounts and profiles
  2. session - Server-side session management
  3. recipe - Recipe metadata and publication status
  4. ingredient - Recipe ingredients with quantities
  5. instruction - Step-by-step cooking instructions
  6. recipe_image - Multiple images per recipe
  7. review - User reviews with star ratings (1-5)
  8. favorite - User-recipe favorites (N:M junction)
  9. like_record - User-recipe likes (N:M junction)
  10. recipe_view - Authenticated user view tracking
  11. search_history - User search query history
  12. daily_stat - Pre-aggregated daily statistics
  13. activity_log - Admin action audit trail

**Dependencies:** Created in order to satisfy foreign key constraints

#### 3. Create Indexes
- **Page ID:** 305e35b8-52f0-812d-9981-ff68556cee96
- **Description:** Creates additional indexes for query performance optimization
- **Indexes Created:** 24 performance indexes on frequently queried columns

#### 4. Create Views
- **Page ID:** 305e35b8-52f0-810d-8684-effca525be16
- **Description:** Creates database views for commonly accessed aggregated data
- **Views Created:**
  1. vw_recipe_with_stat - Recipe listing with engagement metrics
  2. vw_user_dashboard_stat - User dashboard summary statistics

#### 5. Seed Users
- **Page ID:** 305e35b8-52f0-8107-abe7-dd27097cb2fb
- **Description:** Seeds user table with 3 admins and 9 regular users
- **Data:** 12 users with varying roles, statuses, and profiles
- **Password Hashing:** All passwords hashed using bcrypt (cost=12)

#### 6. Seed Recipes
- **Page ID:** 305e35b8-52f0-8167-845a-ed21c2615788
- **Description:** Seeds 13 recipes with varying categories, difficulties, and statuses
- **Data:**
  - 13 recipes across multiple categories (Italian, Asian, Breakfast, Dessert, Dinner, Lunch)
  - 52 ingredients (3-4 per recipe)
  - 65 instructions (4-5 steps per recipe)
  - 13 recipe images

#### 7. Seed Reviews, Likes, Favorites
- **Page ID:** 305e35b8-52f0-8152-ae2d-c595d87c559f
- **Description:** Seeds review, like_record, and favorite tables with sample data
- **Data:**
  - 26 reviews across various recipes (1-5 star ratings)
  - 14 like records
  - 7 favorite records

#### 8. Seed Statistics Data
- **Page ID:** 305e35b8-52f0-812b-aae9-fed589f3fc18
- **Description:** Seeds daily_stat, recipe_view, search_history, and activity_log tables
- **Data:**
  - 30 days of daily statistics (page views, active users, new users, recipe views)
  - 22 recipe view records
  - 14 search history entries
  - 18 activity log entries (admin actions)

#### 9. Common Queries
- **Page ID:** 305e35b8-52f0-8189-8af1-dc622a7e04ae
- **Description:** Essential SELECT queries for recipe listings, details, favorites, search, and reviews
- **Queries:**
  1. Published recipe listing
  2. Recipe detail with all stats
  3. Get ingredients by recipe
  4. Get instructions by recipe
  5. Get images by recipe
  6. User favorites listing
  7. Full-text recipe search
  8. Recipe reviews listing

#### 10. Admin Queries
- **Page ID:** 305e35b8-52f0-811f-bc7f-c7f6dc3c5d8a
- **Description:** Admin dashboard queries for user management, recipe administration, and system statistics
- **Queries:**
  1. User role/status breakdown
  2. Paginated user listing with metrics
  3. Recipe status breakdown
  4. Full recipe listing for admin
  5. Pending recipe approval queue
  6. System dashboard statistics
  7. Activity log listing

#### 11. Analytics Queries
- **Page ID:** 305e35b8-52f0-81c5-9416-cb6562524a4c
- **Description:** Advanced analytics and trending queries for recipe rankings and user engagement metrics
- **Queries:**
  1. Top 10 recipes by views
  2. Top 10 recipes by likes
  3. Top 10 rated recipes
  4. User engagement summary
  5. Daily statistics trend (30 days)
  6. Weekly statistics summary
  7. Monthly statistics report
  8. Category performance analysis
  9. Popular search terms
  10. Daily search analysis
  11. Recipe difficulty vs time analysis

#### 12. Stored Procedures and Functions
- **Page ID:** 305e35b8-52f0-815b-bba1-ef155443f045
- **Description:** 4 stored procedures and 1 function for recipe management and calculations
- **Procedures:**
  1. usp_CreateRecipe - Create complete recipe with ingredients/instructions (JSON input)
  2. usp_DeleteRecipe - Delete recipe with cascade and activity log
  3. usp_ApproveRecipe - Approve or reject pending recipes
  4. usp_GetRecipeStat - Get comprehensive recipe statistics

- **Functions:**
  1. fn_CalculateAvgRating - Calculate average rating for a recipe

**Safety:** All procedures use transaction handling with ROLLBACK on error

#### 13. Database Triggers
- **Page ID:** 305e35b8-52f0-8199-8fe6-d992a2f37900
- **Description:** 6 triggers for automatic stat updates, timestamps, and logging
- **Triggers:**
  1. trg_RecipeView_UpdateStat - Updates daily stats on new recipe view
  2. trg_User_UpdateLastActive - Updates user last_active timestamp
  3. trg_Recipe_DeleteCleanup - Logs recipe deletion
  4. trg_User_NewUserStat - Updates daily stats on new user
  5. trg_Recipe_SetTimestamp - Auto-updates recipe.updated_at
  6. trg_User_SetTimestamp - Auto-updates user.updated_at

**Safety:** All triggers check @DISABLE_TRIGGERS to allow safe data seeding

#### 14. Backup and Restore
- **Page ID:** 305e35b852f081a18529f05549bf4d41
- **Description:** Database backup utilities and health check queries
- **Queries:**
  1. Generate INSERT statements for users
  2. Table sizes and row counts
  3. List all views
  4. List all procedures/functions
  5. List all triggers
  6. List all foreign key constraints
  7. List all indexes
  8. Row count summary by table

## Database Schema Summary

- **Tables:** 13
- **Views:** 2
- **Stored Procedures:** 4
- **Functions:** 1
- **Triggers:** 6
- **Indexes:** 24+
- **Total Seeded Records:**
  - Users: 12
  - Recipes: 13 (10 published, 2 pending, 1 rejected)
  - Ingredients: 52
  - Instructions: 65
  - Recipe Images: 13
  - Reviews: 26
  - Likes: 14
  - Favorites: 7
  - Recipe Views: 22
  - Search History: 14
  - Daily Stats: 30
  - Activity Logs: 18

## Technical Specifications

- **Character Set:** utf8mb4 (full Unicode support including emojis)
- **Collation:** utf8mb4_unicode_ci
- **Engine:** InnoDB (foreign key support, ACID compliance)
- **Naming Conventions:**
  - Tables: lowercase_with_underscores (e.g., recipe_view)
  - Stored Procedures: usp_PascalCase (e.g., usp_CreateRecipe)
  - Functions: fn_PascalCase (e.g., fn_CalculateAvgRating)
  - Triggers: trg_TableName_Purpose (e.g., trg_RecipeView_UpdateStat)
  - Columns: lowercase_with_underscores

## Execution Order

For a complete database setup:

1. 01_create_database.sql
2. 02_create_tables.sql
3. 03_create_indexes.sql
4. 04_create_views.sql
5. 05_seed_users.sql
6. 06_seed_recipes.sql
7. 07_seed_reviews.sql (includes likes and favorites)
8. 08_seed_stats.sql (includes views, search, activity logs)
9-14. Stored procedures, triggers, and queries can be executed in any order after tables are created

## Last Updated

**Date:** February 13, 2026
**Update:** Initial comprehensive Notion documentation created with 14 SQL pages
