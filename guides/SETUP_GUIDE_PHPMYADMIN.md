# Recipe Sharing System - phpMyAdmin Setup Guide

> Last Updated: 2026-02-14
> Scope: Database setup and validation for current project state

## Current Status

- ✅ Phase 1 complete: database design and schema
- ✅ Phase 2 complete: seed data and SQL queries
- ✅ Phase 3 complete: stored procedures, triggers, backup/restore script
- ⏳ Phase 4 pending: PHP backend API
- ⏳ Phase 5 pending: frontend integration from localStorage to API
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

Use the scripts in this exact order:

1. `database/01_create_database.sql`
2. `database/02_create_tables.sql`
3. `database/03_create_indexes.sql`
4. `database/04_create_views.sql`
5. `database/12_stored_procedures.sql`
6. `database/13_triggers.sql`

### Important for Seeding

Before seed scripts:

```sql
SET @DISABLE_TRIGGERS = 1;
```

Run seed scripts:

7. `database/05_seed_users.sql`
8. `database/06_seed_recipes.sql`
9. `database/07_seed_reviews.sql`
10. `database/08_seed_stats.sql`

After seed scripts:

```sql
SET @DISABLE_TRIGGERS = NULL;
```

Optional verification script:

11. `database/14_backup_restore.sql`

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

At this moment, the React app still uses local storage. The API backend (`backend/...`) and API service layer (`src/lib/api.js`) are planned but not implemented yet.

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

After DB setup is verified, proceed with Phase 4 implementation plan in:

- `plan/upgrade-database-integration-1.md`
