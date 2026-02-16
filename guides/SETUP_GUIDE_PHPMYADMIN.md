# Recipe Sharing System - phpMyAdmin Setup Guide

> Last Updated: 2026-02-14
> Scope: Database setup and validation for current project state

## Current Status

- ✅ Phase 1 complete: database design and schema
- ✅ Phase 2 complete: seed data and SQL queries
- ✅ Phase 3 complete: stored procedures, triggers, backup/restore script
- ✅ Phase 4 complete: PHP backend API implemented
- ✅ Phase 5 complete: frontend migrated to API service layer
- ⏳ Phase 6 pending: integration testing and deployment docs

## Prerequisites

- XAMPP installed (Apache + MySQL + phpMyAdmin)
- Project path available locally
- Database scripts present in `database/01_create_database.sql` to `database/14_backup_restore.sql`

## 1) Start Services

1. Open XAMPP Control Panel.
2. Start `Apache` and `MySQL`.
3. Confirm both are running (green status).

## 2) Open phpMyAdmin

- URL: `http://localhost/phpmyadmin`
- Default XAMPP login:
  - Username: `root`
  - Password: *(empty by default)*

## 3) Create and Initialize Database

### Step-by-Step Instructions

#### Step 3.1: Create the Database

1. In phpMyAdmin home page (`http://localhost/phpmyadmin/`), look at the left sidebar
2. Click the **"SQL"** tab at the top of the page (it's next to "Databases")
3. You'll see a large text box where you can type SQL queries
4. Open the file `database/01_create_database.sql` from your project folder
5. Copy **ALL** the content from that file
6. Paste it into the SQL text box in phpMyAdmin
7. Click the **"Go"** button (bottom right of the text box)
8. You should see a green success message
9. Now look at the left sidebar - you should see `cookhub` database listed

#### Step 3.2: Select the Database

1. In the left sidebar, click on **`cookhub`** database name
2. The database is now selected (you'll see it highlighted)

#### Step 3.3: Run the Table Creation Scripts

**For each script below, repeat these steps:**

1. Click the **"SQL"** tab at the top
2. Open the script file from your project's `database/` folder
3. Copy the entire content of the file
4. Paste it into the SQL text box
5. Click **"Go"**
6. Wait for green success message

**Run these scripts IN THIS EXACT ORDER:**

1. `02_create_tables.sql` ← Creates all tables
2. `03_create_indexes.sql` ← Adds indexes for performance
3. `04_create_views.sql` ← Creates views
4. `12_stored_procedures.sql` ← Creates stored procedures
5. `13_triggers.sql` ← Creates triggers

#### Step 3.4: Seed the Database with Sample Data

**Current behavior:** `05_seed_users.sql` and `08_seed_stats.sql` now preserve and restore `@DISABLE_TRIGGERS` internally.
You can run seed scripts directly without manual trigger toggling.

**Now run each seed script** (same process as Step 3.3):

1. `05_seed_users.sql` ← Sample users
2. `06_seed_recipes.sql` ← Sample recipes
3. `07_seed_reviews.sql` ← Sample reviews
4. `08_seed_stats.sql` ← Sample statistics

**Optional wrapper mode (advanced):** if you intentionally set `@DISABLE_TRIGGERS` yourself before seeding, these scripts will preserve your existing value and restore it after execution.

### Alternative Method: Using Import

If you prefer importing files instead of copy-paste:

1. Select the `cookhub` database from left sidebar
2. Click the **"Import"** tab at the top
3. Click **"Choose File"** button
4. Navigate to your project's `database/` folder
5. Select the SQL file you want to run
6. Click **"Go"** at the bottom
7. Wait for success message
8. Repeat for each script in order

**Note:** Some large seed files may have import size limits. If you get an error, use the copy-paste method from Step 3.3 instead.

## 4) Quick Verification

Run these in phpMyAdmin SQL tab:

```sql
USE cookhub;
SHOW TABLES;
```

Expected core results:
- 13 tables
- 2 views
- 4 stored procedures + 1 function
- 6 triggers

Suggested checks:

```sql
SELECT COUNT(*) AS users_count FROM user;
SELECT COUNT(*) AS recipes_count FROM recipe;
SELECT COUNT(*) AS reviews_count FROM review;
SELECT COUNT(*) AS stats_rows FROM daily_stat;
```

## 5) Known Current Architecture Note

The React app is integrated with the PHP backend API. Use `src/lib/api.js` for frontend data access and `backend/api/*` for endpoint handlers.

## 6) Common Troubleshooting

### MySQL does not start

- Check if port `3306` is occupied.
- Review MySQL logs from XAMPP Control Panel.

### phpMyAdmin access denied

- Verify root credentials in your XAMPP/phpMyAdmin configuration.
- Restart Apache and MySQL.

### Script fails with FK or existing object errors

- Ensure execution order is correct.
- Reset and rerun from scratch:

```sql
DROP DATABASE IF EXISTS cookhub;
CREATE DATABASE cookhub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## 7) Next Step

After DB setup is verified, proceed with Phase 6 testing/documentation tasks in:

- `plan/upgrade-database-integration-1.md`
