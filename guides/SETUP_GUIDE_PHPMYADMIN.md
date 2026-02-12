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

1. Ensure scripts are run in correct order (01 → 14)
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

---

## Test Accounts

### Regular User Accounts

| Email | Password | Name | Status |
|-------|----------|------|--------|
| olivia.smith@email.com | User123! | Olivia Smith | Active |
| marcus.jordan@email.com | User123! | Marcus Jordan | Active |
| john.smith@email.com | User123! | John Smith | Active |
| maria.garcia@email.com | User123! | Maria Garcia | Active |
| tom.wilson@email.com | User123! | Tom Wilson | Active |
| amy.lee@email.com | User123! | Amy Lee | Active |
| kevin.davis@email.com | User123! | Kevin Davis | Active |
| sarah.johnson@email.com | User123! | Sarah Johnson | Active |
| daniel.miller@email.com | User123! | Daniel Miller | Active |

### Testing Workflow

1. **Test User Registration:**
   - Go to Signup page (requires Phase 4 & 5 completion)
   - Create new account
   - Verify in phpMyAdmin: `SELECT * FROM user ORDER BY created_at DESC LIMIT 1;`

2. **Test User Login:**
   - Use `admin@recipeapp.com` / `Admin123!`
   - Should redirect to home page (requires Phase 4 & 5 completion)
   - Verify session in phpMyAdmin: `SELECT * FROM session ORDER BY created_at DESC LIMIT 1;`

3. **Test Recipe Creation:**
   - Login as admin
   - Create new recipe (requires Phase 4 & 5 completion)
   - Verify in phpMyAdmin: `SELECT * FROM recipe ORDER BY created_at DESC LIMIT 1;`

4. **Test Admin Features:**
   - Login as admin
   - Go to Admin Dashboard (requires Phase 4 & 5 completion)
   - View pending recipes
   - Approve/reject a recipe
   - Check activity log in phpMyAdmin: `SELECT * FROM activity_log ORDER BY created_at DESC LIMIT 5;`

---

## Troubleshooting

### Problem: phpMyAdmin shows "Access Denied"

**Solution:**
1. Open phpMyAdmin config: `C:\xampp\phpMyAdmin\config.inc.php`
2. Find line: `$cfg['Servers'][$i]['password'] = '';`
3. Ensure password is empty (default XAMPP)
4. Restart Apache in XAMPP Control Panel

### Problem: "Cannot connect to MySQL server"

**Solution:**
1. Check MySQL is running (green in XAMPP)
2. Click "Admin" next to MySQL → Should open phpMyAdmin
3. If fails, click "Logs" next to MySQL → Check error messages
4. Common fix: Delete `C:\xampp\mysql\data\ibdata1` and restart MySQL
   **⚠️ Warning: This deletes all databases! Only do on fresh install**

### Problem: SQL script execution fails

**Solution:**
1. **Check for errors in result:**
   - phpMyAdmin shows error message
   - Common: "Table already exists" → Drop table first
   - Common: "Foreign key constraint fails" → Run scripts in correct order

2. **Clear and start over:**
   ```sql
   -- In phpMyAdmin SQL tab:
   DROP DATABASE IF EXISTS cookhub;
   CREATE DATABASE cookhub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   USE cookhub;
   -- Now run scripts in order again
   ```

### Problem: API returns "Database connection failed"

**Solution:**
1. **Verify database exists:**
   - phpMyAdmin → Database list should show `cookhub`

2. **Check config.php (when Phase 4 complete):**
   - File: `C:\xampp\htdocs\recipe-sharing-system\backend\config\database.php`
   - Verify: `DB_NAME = 'cookhub'`
   - Verify: `DB_USER = 'root'`
   - Verify: `DB_PASS = ''` (empty string)

3. **Test connection manually:**
   ```php
   <?php
   // Create file: C:\xampp\htdocs\test-db.php
   $pdo = new PDO('mysql:host=localhost;dbname=cookhub', 'root', '');
   echo "Connected successfully!";
   ?>
   ```
   Open: http://localhost/test-db.php

### Problem: CORS error in browser console

**Solution:**
1. **Check backend CORS middleware (when Phase 4 complete):**
   - File: `backend/helpers/cors.php` (not middleware/)
   - Should have: `header('Access-Control-Allow-Origin: http://localhost:5173');`

2. **Verify frontend URL:**
   - Frontend must run on http://localhost:5173 (default Vite port)

3. **Clear browser cache:**
   - Press Ctrl+Shift+Delete
   - Clear cached images and files
   - Restart browser

### Problem: "Table doesn't exist" error

**Solution:**
1. **Verify table creation:**
   ```sql
   -- In phpMyAdmin SQL tab:
   SHOW TABLES;
   ```

2. **Re-run create tables script:**
   - Copy `02_create_tables.sql` content
   - Paste in phpMyAdmin SQL tab
   - Execute

3. **Check database selected:**
   - Left sidebar: `cookhub` should be highlighted
   - If not, click on it

### Problem: Frontend shows "Network Error"

**Solution:**
1. **Check all services running:**
   - XAMPP: Apache and MySQL both green
   - Frontend: `npm run dev` running without errors

2. **Test API manually (when Phase 4 complete):**
   - Open: http://localhost/recipe-sharing-system/backend/api/auth.php
   - Should return JSON, not HTML error page

3. **Check browser console:**
   - Press F12 → Console tab
   - Look for specific error messages
   - Common: CORS error, 404 Not Found, 500 Internal Server Error

### Problem: Login doesn't work (after Phase 4 & 5 completion)

**Solution:**
1. **Verify users exist:**
   ```sql
   -- In phpMyAdmin:
   SELECT email, username FROM user WHERE role = 'admin';
   ```

2. **Check password hashing:**
   - Passwords should be bcrypt hashes, not plain text
   - Re-run `05_seed_users.sql` if needed

3. **Test with Postman (when Phase 4 complete):**
   ```
   POST http://localhost/recipe_api/api/auth/login
   Body (JSON):
   {
     "email": "admin@recipeapp.com",
     "password": "Admin123!"
   }
   ```

### Need More Help?

**Useful phpMyAdmin Features:**

1. **View recent queries:**
   - Click "Status" tab → "Monitor" → "Query Statistics"

2. **Export database:**
   - Select database → "Export" tab → "Go"
   - Saves backup as `.sql` file

3. **Import database:**
   - Select database → "Import" tab → Choose file → "Go"

4. **Search data:**
   - Select table → "Search" tab → Enter criteria

5. **Execute custom queries:**
   - Select database → "SQL" tab → Write query → "Go"

**Common SQL Queries for Debugging:**

```sql
-- Check if admin user exists
SELECT * FROM user WHERE email = 'admin@recipeapp.com';

-- Check latest recipes
SELECT id, title, author_id, status, created_at
FROM recipe
ORDER BY created_at DESC
LIMIT 5;

-- Check session validity
SELECT * FROM session
WHERE expires_at > NOW()
ORDER BY created_at DESC;

-- View recipe with ingredients
SELECT
    r.title,
    i.name as ingredient,
    i.quantity,
    i.unit
FROM recipe r
LEFT JOIN ingredient i ON r.id = i.recipe_id
WHERE r.id = 1;
```

---

## Quick Reference Card

**Print this for quick access:**

```
┌─────────────────────────────────────────────────────────┐
│          RECIPE SHARING SYSTEM - QUICK START            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. START XAMPP                                        │
│     C:\xampp\xampp-control.exe                         │
│     Start: Apache + MySQL                              │
│                                                         │
│  2. VERIFY SERVICES                                    │
│     http://localhost/phpmyadmin                        │
│     Database: cookhub                                    │
│                                                         │
│  3. START FRONTEND                                     │
│     cd "C:\...\recipe_sharing_system"                  │
│     npm run dev                                         │
│                                                         │
│  4. OPEN APPLICATION                                   │
│     http://localhost:5173                              │
│                                                         │
│  TEST LOGIN                                            │
│     Email: admin@recipeapp.com                         │
│     Password: Admin123!                                │
│                                                         │
│  PHPMYADMIN ACCESS                                     │
│     Username: root                                      │
│     Password: (empty)                                   │
│     Database: cookhub                                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

**🎉 Database setup complete!**

**Next Steps:**

1. **Execute remaining SQL scripts** (08-14) — see "SQL Scripts Execution" section above
2. **Begin Phase 4** — Create PHP backend API (see [upgrade-database-integration-1.md](../plan/upgrade-database-integration-1.md) TASK-057 to TASK-092)
3. **Plan Phase 5** — Update frontend to use API instead of localStorage (TASK-093 to TASK-115)
4. **Test login** with admin account (`admin@recipeapp.com` / `Admin123!`)
5. **Create a sample recipe** (requires Phase 4 & 5 completion)
6. **Approve recipe** from admin dashboard (requires Phase 4 & 5 completion)
7. **Test search functionality** (requires Phase 4 & 5 completion)
8. **Review database changes** in phpMyAdmin after each action

**Current Project Status:**
- ✅ **Phase 1:** Database Design (100% complete)
- ✅ **Phase 2:** SQL Data Scripts (100% complete)
- ✅ **Phase 3:** Advanced SQL (100% complete)
- ⏳ **Phase 4:** PHP Backend API (0% complete — 36 tasks pending)
- ⏳ **Phase 5:** Frontend Integration (0% complete — 23 tasks pending)
- ⏳ **Phase 6:** Testing & Documentation (0% complete — 23 tasks pending)

**Reference:** See [upgrade-database-integration-1.md](../plan/upgrade-database-integration-1.md) for complete implementation plan (138 tasks total).

**Happy Coding! 🚀**