-- CookHub Database - Master Setup Script
-- Run this file to set up the complete database from scratch.
-- Usage: mysql -u root < database/run_all_scripts.sql

-- Step 1: Create the database
SOURCE database/01_create_database.sql;

-- Step 2: Create all tables
SOURCE database/02_create_tables.sql;

-- Step 3: Create indexes for performance
SOURCE database/03_create_indexes.sql;

-- Step 4: Create views
SOURCE database/04_create_views.sql;

-- Step 5: Seed user accounts
SOURCE database/05_seed_users.sql;

-- Step 6: Seed recipe data
SOURCE database/06_seed_recipes.sql;

-- Step 7: Seed reviews
SOURCE database/07_seed_reviews.sql;

-- Step 8: Seed daily statistics
SOURCE database/08_seed_stats.sql;

-- Step 9: Create stored procedures and functions
SOURCE database/12_stored_procedures.sql;

-- Step 10: Create triggers
SOURCE database/13_triggers.sql;

-- Done! The CookHub database is now ready.
SELECT 'CookHub database setup complete!' AS status;
