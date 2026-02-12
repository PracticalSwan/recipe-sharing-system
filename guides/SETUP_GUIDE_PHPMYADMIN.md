# Recipe Sharing System - Database Setup Guide

**Quick setup for database using phpMyAdmin**

---

## Prerequisites

### Install XAMPP

1. Download XAMPP for Windows from https://www.apachefriends.org/
2. Run installer as Administrator
3. Install to: `C:\xampp`
4. Keep default components: Apache, MySQL, PHP, phpMyAdmin

---

## Database Setup

### 1. Start XAMPP

1. Open **XAMPP Control Panel** (or run `C:\xampp\xampp-control.exe`)
2. Click **Start** for both Apache and MySQL
3. Wait for both to show green "Running" status

### 2. Open phpMyAdmin

1. Open browser: http://localhost/phpmyadmin
2. Login with:
   - Username: `root`
   - Password: (leave empty, click "Go")

### 3. Create Database

1. Click **New** in left sidebar (or "Databases" tab)
2. Database name: `cookhub`
3. Collation: `utf8mb4_unicode_ci`
4. Click **Create**

### 4. Execute SQL Scripts

**Run scripts in this order:**

**Create Tables & Views:**
1. With `cookhub` database selected, click **SQL** tab
2. Copy content from each file and paste in SQL query box, then click **Go**:
   - `database/02_create_tables.sql` - Creates all 13 tables
   - `database/03_create_indexes.sql` - Creates indexes
   - `database/04_create_views.sql` - Creates views

**Seed Data:**
3. Execute these scripts in order:
   - `database/05_seed_users.sql` - 12 users (3 admins + 9 regular)
   - `database/06_seed_recipes.sql` - 13+ recipes with ingredients & instructions
   - `database/07_seed_reviews.sql` - Reviews, likes, favorites
   - `database/08_seed_stats.sql` - Statistics & activity logs

**Advanced SQL Features:**
4. Execute:
   - `database/12_stored_procedures.sql` - 4 procedures + 1 function
   - `database/13_triggers.sql` - 6 triggers

### 5. Verify Setup

Run this in SQL tab:

```sql
SHOW TABLES;
-- Should show 13 tables: user, recipe, ingredient, instruction,
-- recipe_image, review, favorite, like_record, recipe_view,
-- search_history, daily_stat, activity_log, session

SELECT COUNT(*) as user_count FROM user;
-- Should return: 12

SELECT COUNT(*) as recipe_count FROM recipe;
-- Should return: 13+
```

**✅ Database ready!**

---

## Test Accounts

### Admin Accounts

| Email | Password | Name |
|-------|----------|------|
| admin@recipeapp.com | Admin123! | Admin User |
| john.doe@recipeapp.com | Admin123! | John Doe |
| sarah.smith@recipeapp.com | Admin123! | Sarah Smith |

### User Accounts

| Email | Password | Name |
|-------|----------|------|
| olivia.smith@email.com | User123! | Olivia Smith |
| marcus.jordan@email.com | User123! | Marcus Jordan |
| john.smith@email.com | User123! | John Smith |
| maria.garcia@email.com | User123! | Maria Garcia |
| tom.wilson@email.com | User123! | Tom Wilson |
| amy.lee@email.com | User123! | Amy Lee |
| kevin.davis@email.com | User123! | Kevin Davis |
| sarah.johnson@email.com | User123! | Sarah Johnson |
| daniel.miller@email.com | User123! | Daniel Miller |

---

## Running the Application

### Every Development Session:

1. **Start XAMPP Services:**
   - Open XAMPP Control Panel
   - Start Apache ✅
   - Start MySQL ✅

2. **Start Frontend:**
   ```powershell
   cd "C:\Assumption University\CSX3006\Class Materials\project\recipe_sharing_system\recipe-sharing-system"
   npm run dev
   ```

3. **Open Application:**
   - Frontend: http://localhost:5173
   - phpMyAdmin: http://localhost/phpmyadmin

**Note:** Backend API will be implemented in Phase 4 (see [plan/upgrade-database-integration-1.md](../plan/upgrade-database-integration-1.md))

---

## Troubleshooting

### phpMyAdmin Access Denied

1. Open `C:\xampp\phpMyAdmin\config.inc.php`
2. Find: `$cfg['Servers'][$i]['password'] = '';`
3. Ensure password is empty
4. Restart Apache

### MySQL Won't Start

1. Check if port 3306 is blocked
2. Click "Logs" next to MySQL in XAMPP Control Panel
3. If needed, delete `C:\xampp\mysql\data\ibdata1` and restart MySQL

### SQL Script Errors

1. Ensure scripts are run in correct order
2. Check that `cookhub` database is selected
3. For errors like "Table already exists", drop and re-run scripts:
   ```sql
   DROP DATABASE IF EXISTS cookhub;
   CREATE DATABASE cookhub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

### Port 80 Already in Use

If Apache fails to start:

1. Click **Config** next to Apache → **httpd.conf**
2. Change `Listen 80` to `Listen 8080`
3. Change `ServerName localhost:80` to `ServerName localhost:8080`
4. Save and restart Apache
5. Access via: http://localhost:8080/phpmyadmin

---

## Project Status

- ✅ **Phase 1:** Database Design (100% complete)
- ✅ **Phase 2:** SQL Data Scripts (100% complete)
- ✅ **Phase 3:** Advanced SQL (100% complete)
- ⏳ **Phase 4:** PHP Backend API (0% complete — pending)
- ⏳ **Phase 5:** Frontend Integration (0% complete — pending)
- ⏳ **Phase 6:** Testing & Documentation (0% complete — pending)

**Next Steps:** See complete implementation plan in [upgrade-database-integration-1.md](../plan/upgrade-database-integration-1.md)
