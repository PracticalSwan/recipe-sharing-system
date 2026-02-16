# CookHub Database

MySQL/MariaDB database for the CookHub Recipe Sharing System.

## Overview

- **Database Name**: `cookhub`
- **Engine**: InnoDB
- **Charset**: utf8mb4 (utf8mb4_unicode_ci)
- **Tables**: 13
- **Views**: 2
- **Stored Procedures**: 4
- **Functions**: 1
- **Triggers**: See `13_triggers.sql`

## Schema Diagram

```
user ─────────┬──── session
              │
              ├──── recipe ──────┬── ingredient
              │       │          ├── instruction
              │       │          ├── recipe_image
              │       │          ├── recipe_view ◄── user
              │       │          ├── like_record ◄─── user
              │       │          ├── favorite ◄────── user
              │       │          └── review ◄──────── user
              │
              ├──── search_history
              └──── activity_log (admin actions)

daily_stat (standalone aggregation table)
```

## Tables

| Table | Description | Key Relationships |
|-------|-------------|-------------------|
| `user` | User accounts (admin/user roles) | PK for all user-related FKs |
| `session` | Session tokens for auth | FK → user (CASCADE) |
| `recipe` | Recipe metadata | FK → user (CASCADE) |
| `ingredient` | Recipe ingredients | FK → recipe (CASCADE) |
| `instruction` | Recipe steps | FK → recipe (CASCADE) |
| `recipe_image` | Recipe photos | FK → recipe (CASCADE) |
| `review` | User reviews (1 per user per recipe) | FK → user, recipe (CASCADE) |
| `like_record` | Recipe likes | FK → user, recipe (CASCADE) |
| `favorite` | Saved/bookmarked recipes | FK → user, recipe (CASCADE) |
| `recipe_view` | View tracking | FK → user, recipe (CASCADE) |
| `search_history` | User search terms | FK → user (CASCADE) |
| `daily_stat` | Daily aggregated statistics | Standalone |
| `activity_log` | Admin action audit trail | FK → user (SET NULL) |

## Views

| View | Description |
|------|-------------|
| `vw_recipe_with_stat` | Recipes with aggregated likes, views, reviews, ratings, favorites |
| `vw_user_dashboard_stat` | Users with recipe counts, review counts, like stats |

## Stored Procedures

| Procedure | Description |
|-----------|-------------|
| `usp_CreateRecipe` | Transactional recipe creation with ingredients, instructions, images |
| `usp_DeleteRecipe` | Cascade delete recipe with activity logging |
| `usp_ApproveRecipe` | Approve/reject pending recipes with audit trail |
| `usp_GetRecipeStat` | Get comprehensive recipe statistics |

## Functions

| Function | Description |
|----------|-------------|
| `fn_CalculateAvgRating` | Calculate average rating for a recipe |

## SQL Scripts (Execution Order)

Run scripts in numerical order:

| # | File | Purpose |
|---|------|---------|
| 01 | `01_create_database.sql` | Create database |
| 02 | `02_create_tables.sql` | Create all 13 tables |
| 03 | `03_create_indexes.sql` | Create performance indexes |
| 04 | `04_create_views.sql` | Create views |
| 05 | `05_seed_users.sql` | Seed user accounts (12 users) |
| 06 | `06_seed_recipes.sql` | Seed sample recipes |
| 07 | `07_seed_reviews.sql` | Seed reviews |
| 08 | `08_seed_stats.sql` | Seed daily statistics |
| 09 | `09_common_queries.sql` | Common query examples |
| 10 | `10_admin_queries.sql` | Admin query examples |
| 11 | `11_analytics_queries.sql` | Analytics query examples |
| 12 | `12_stored_procedures.sql` | Stored procedures & functions |
| 13 | `13_triggers.sql` | Database triggers |

Or use the master script: `run_all_scripts.sql`

## Quick Setup

```bash
# Using MySQL CLI
mysql -u root < database/run_all_scripts.sql

# Or run individual scripts
mysql -u root < database/01_create_database.sql
mysql -u root < database/02_create_tables.sql
# ... continue in order
```

## Default Accounts

| Email | Password | Role |
|-------|----------|------|
| admin@cookhub.com | admin | Admin |
| olivia@cookhub.com | admin | Admin |
| marcus@cookhub.com | admin | Admin |
| user@cookhub.com | user | User |
| maria@cookhub.com | maria123 | User |
| tom@cookhub.com | tom123 | User |
| amy@cookhub.com | amy123 | User |
| kevin@cookhub.com | kevin123 | User |
| sarah@cookhub.com | sarah123 | User |
| daniel@cookhub.com | daniel123 | User |
| lina@cookhub.com | lina123 | User |
| omar@cookhub.com | omar123 | User |

## Index Strategy

- **Primary lookups**: email, session_token
- **Status filtering**: role+status, recipe status
- **Relationship queries**: author_id, recipe_id, user_id
- **Temporal queries**: created_at, joined_date, searched_at, expires_at
- **Ordering**: sort_order (ingredients), step_number (instructions)
