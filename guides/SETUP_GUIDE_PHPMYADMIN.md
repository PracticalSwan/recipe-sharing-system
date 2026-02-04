# Recipe Sharing System - Setup Guide (phpMyAdmin Only)

**Complete setup guide using phpMyAdmin interface for all database operations**

---

## 📋 Table of Contents

1. [Prerequisites Installation](#prerequisites-installation)
2. [XAMPP Setup](#xampp-setup)
3. [Database Setup via phpMyAdmin](#database-setup-via-phpmyadmin)
4. [Backend Configuration](#backend-configuration)
5. [Frontend Setup](#frontend-setup)
6. [Running the Application](#running-the-application)
7. [Test Accounts](#test-accounts)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites Installation

### 1. Install XAMPP

**Download & Install:**
1. Visit https://www.apachefriends.org/
2. Download XAMPP for Windows (Latest version with PHP 8.0+)
3. Run installer as Administrator
4. Install to default location: `C:\xampp`
5. Select components:
   - ✅ Apache
   - ✅ MySQL
   - ✅ PHP
   - ✅ phpMyAdmin
   - ⬜ Others (optional)

**Verify Installation:**
- Check that folder `C:\xampp` exists
- Check that `C:\xampp\htdocs` exists
- Check that `C:\xampp\mysql\bin\mysql.exe` exists

### 2. Install Node.js (if not installed)

1. Visit https://nodejs.org/
2. Download LTS version (v16.x or higher)
3. Run installer with default settings
4. Verify installation:

```powershell
node --version    # Should show v16.x or higher
npm --version     # Should show v8.x or higher
```

---

## XAMPP Setup

### Step 1: Start XAMPP Services

1. **Open XAMPP Control Panel:**
   ```powershell
   C:\xampp\xampp-control.exe
   ```
   Or find "XAMPP Control Panel" in Start Menu

2. **Start Services:**
   - Click **"Start"** next to **Apache**
   - Click **"Start"** next to **MySQL**
   
   ✅ Both should show green "Running" status

3. **Verify Services:**
   - Open browser: http://localhost
   - Should see XAMPP dashboard
   - Open browser: http://localhost/phpmyadmin
   - Should see phpMyAdmin interface

### Step 2: Configure Apache (if needed)

**If Port 80 is already in use:**

1. Click **"Config"** next to Apache → **"httpd.conf"**
2. Find line `Listen 80`
3. Change to `Listen 8080`
4. Find line `ServerName localhost:80`
5. Change to `ServerName localhost:8080`
6. Save and restart Apache
7. Access via: http://localhost:8080

---

## Database Setup via phpMyAdmin

### Step 1: Access phpMyAdmin

1. **Open phpMyAdmin:**
   - URL: http://localhost/phpmyadmin
   - Default login:
     - Username: `root`
     - Password: (leave empty, just click "Go")

2. **You should see:**
   - Left sidebar with existing databases
   - Main panel with server information
   - Top navigation tabs

### Step 2: Create Database

1. **Click "New" in left sidebar** (or "Databases" tab at top)

2. **Create database:**
   - Database name: `recipe_sharing_db`
   - Collation: `utf8mb4_unicode_ci`
   - Click **"Create"**

3. **Verify:**
   - Left sidebar should now show `recipe_sharing_db`
   - Click on it to select

### Step 3: Execute SQL Scripts

**Important: Run scripts in exact order!**

#### 3.1 Create Tables

1. **With `recipe_sharing_db` selected**, click **"SQL"** tab at top

2. **Prepare script file:**
   - Navigate to: `c:\Assumption University\CSX3006\Class Materials\project\recipe_sharing_system\database\`
   - Open `02_create_tables.sql` in text editor (Notepad++, VS Code, or Notepad)
   - Copy ALL content (Ctrl+A, Ctrl+C)

3. **Execute in phpMyAdmin:**
   - Paste into SQL query box
   - Click **"Go"** button at bottom right
   - **Success:** "Query executed successfully" message appears
   - **Verify:** Click "Structure" tab → Should see all tables listed

4. **Repeat for remaining DDL scripts:**
   - `03_create_indexes.sql` (Creates performance indexes)
   - `04_create_views.sql` (Creates useful database views)

**Visual Guide:**
```
phpMyAdmin Interface:
┌─────────────────────────────────────────────┐
│ phpMyAdmin                         [X]      │
├─────────────────┬───────────────────────────┤
│ Databases       │  SQL  Structure  Search   │
│ ├ recipe_sha... │                           │
│   ├ users       │  [SQL Query Box]          │
│   ├ recipes     │  [Paste SQL here]         │
│   └ ...         │                           │
│                 │  [Go] ← Click here        │
└─────────────────┴───────────────────────────┘
```

#### 3.2 Seed Data (Sample Data)

**Execute seed scripts in order:**

1. **Users data:**
   - File: `05_seed_users.sql`
   - Copy content → Paste in SQL tab → Click "Go"
   - Verify: Click "users" table → "Browse" → Should see 10 users

2. **Recipes data:**
   - File: `06_seed_recipes.sql`
   - Copy content → Paste in SQL tab → Click "Go"
   - Verify: Click "recipes" table → "Browse" → Should see recipes
   - Also check: `ingredients`, `instructions`, `recipe_images` tables

3. **Reviews data:**
   - File: `07_seed_reviews.sql`
   - Copy content → Paste in SQL tab → Click "Go"
   - Verify: Check `reviews`, `likes`, `favorites` tables

4. **Statistics data:**
   - File: `08_seed_stats.sql`
   - Copy content → Paste in SQL tab → Click "Go"
   - Verify: Check `daily_stats`, `activity_logs` tables

#### 3.3 Advanced SQL Features (Optional but Recommended)

**Stored Procedures:**
- File: `12_stored_procedures.sql`
- Copy & execute in SQL tab
- Verify: Click "Routines" tab → Should see procedures listed

**Triggers:**
- File: `13_triggers.sql`
- Copy & execute in SQL tab
- Verify: Click any table → "Triggers" tab → Should see triggers

### Step 4: Verify Database Setup

**Run verification queries:**

1. **In SQL tab, paste and execute:**

```sql
-- Check all tables exist
SHOW TABLES;
-- Should return: users, recipes, ingredients, instructions, recipe_images,
-- reviews, favorites, likes, recipe_views, search_history, 
-- daily_stats, activity_logs, sessions

-- Check user count
SELECT COUNT(*) as user_count FROM users;
-- Should return: 10

-- Check recipe count
SELECT COUNT(*) as recipe_count FROM recipes;
-- Should return: 10+ recipes

-- Check reviews
SELECT COUNT(*) as review_count FROM reviews;
-- Should return: 20+ reviews

-- Test view
SELECT * FROM recipe_with_stats LIMIT 3;
-- Should return recipe data with statistics
```

2. **Browse sample data:**
   - Click "users" table → "Browse" → View user records
   - Click "recipes" table → "Browse" → View recipes
   - Verify email: `admin@recipeapp.com` exists (for login testing)

**✅ Database setup complete!**

---

## Backend Configuration

### Step 1: Locate Backend Files

Your backend should be at:
```
c:\Assumption University\CSX3006\Class Materials\project\recipe_sharing_system\backend\
```

### Step 2: Configure Database Connection

**Edit `backend/config/config.php`:**

```php
<?php
// Database configuration
define('DB_HOST', 'localhost');
define('DB_NAME', 'recipe_sharing_db');
define('DB_USER', 'root');
define('DB_PASS', '');  // Empty for XAMPP default

// API configuration
define('JWT_SECRET', 'your-secret-key-change-in-production-abc123xyz789');
define('API_VERSION', 'v1');

// CORS settings
define('ALLOWED_ORIGINS', ['http://localhost:5173', 'http://localhost:3000']);

// Session settings
define('SESSION_LIFETIME', 86400); // 24 hours in seconds

// Timezone
date_default_timezone_set('Asia/Bangkok');
?>
```

### Step 3: Deploy Backend to XAMPP

**Option A: Create Symbolic Link (Recommended)**

1. **Open Command Prompt as Administrator:**
   - Press Windows Key
   - Type "cmd"
   - Right-click "Command Prompt"
   - Select "Run as administrator"

2. **Create symlink:**
   ```cmd
   cd C:\xampp\htdocs
   mklink /D recipe_api "C:\Assumption University\CSX3006\Class Materials\project\recipe_sharing_system\backend"
   ```

3. **Verify:**
   - Check that `C:\xampp\htdocs\recipe_api` exists
   - It should point to your backend folder

**Option B: Copy Files (Alternative)**

```powershell
# Copy entire backend folder to htdocs
xcopy "C:\Assumption University\CSX3006\Class Materials\project\recipe_sharing_system\backend" "C:\xampp\htdocs\recipe_api" /E /I /Y
```

**Note:** With Option B, you need to copy files again after any changes.

### Step 4: Test Backend API

1. **Open browser and test base endpoint:**
   ```
   http://localhost/recipe_api/api/index.php
   ```

   **Expected response:**
   ```json
   {
     "status": "success",
     "message": "Recipe Sharing API is running",
     "version": "1.0",
     "timestamp": "2026-02-04T10:30:00+07:00"
   }
   ```

2. **Test database connection:**
   ```
   http://localhost/recipe_api/api/test-db.php
   ```

   **Expected response:**
   ```json
   {
     "status": "success",
     "message": "Database connected successfully",
     "database": "recipe_sharing_db"
   }
   ```

**🎉 Backend is ready!**

---

## Frontend Setup

### Step 1: Navigate to Project

```powershell
cd "C:\Assumption University\CSX3006\Class Materials\project\recipe_sharing_system"
```

### Step 2: Install Dependencies

```powershell
# Install all npm packages (if not done before)
npm install

# Install axios for API calls
npm install axios
```

### Step 3: Configure Environment

**Create `.env` file in project root:**

```env
VITE_API_BASE_URL=http://localhost/recipe_api/api
VITE_API_TIMEOUT=10000
```

**Create/Update `src/config/environment.js`:**

```javascript
// filepath: src/config/environment.js
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost/recipe_api/api';
export const API_TIMEOUT = import.meta.env.VITE_API_TIMEOUT || 10000;

export const isDevelopment = import.meta.env.DEV;
export const isProduction = import.meta.env.PROD;
```

### Step 4: Start Development Server

```powershell
npm run dev
```

**Expected output:**
```
VITE v5.0.0  ready in 500 ms

➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
➜  press h + enter to show help
```

**✅ Frontend is running!**

---

## Running the Application

### Complete Startup Sequence

**Every time you work on the project:**

1. **Start XAMPP Services:**
   ```
   - Open XAMPP Control Panel
   - Click "Start" for Apache
   - Click "Start" for MySQL
   - Both should show green "Running"
   ```

2. **Verify phpMyAdmin (optional):**
   ```
   - Open: http://localhost/phpmyadmin
   - Database "recipe_sharing_db" should be visible
   ```

3. **Verify Backend API:**
   ```
   - Open: http://localhost/recipe_api/api/index.php
   - Should return JSON response
   ```

4. **Start Frontend:**
   ```powershell
   cd "C:\Assumption University\CSX3006\Class Materials\project\recipe_sharing_system"
   npm run dev
   ```

5. **Access Application:**
   ```
   - Open browser: http://localhost:5173
   - You should see Recipe Sharing homepage
   ```

### Workflow Diagram

```
┌─────────────────────────────────────────────────────┐
│          Start Development Session                  │
└────────────────┬────────────────────────────────────┘
                 │
    ┌────────────▼──────────────┐
    │   1. Start XAMPP          │
    │   - Apache (Web Server)   │
    │   - MySQL (Database)      │
    └────────────┬──────────────┘
                 │
    ┌────────────▼──────────────┐
    │   2. Verify Services      │
    │   - phpMyAdmin works      │
    │   - API responds          │
    └────────────┬──────────────┘
                 │
    ┌────────────▼──────────────┐
    │   3. Start Frontend       │
    │   - npm run dev           │
    └────────────┬──────────────┘
                 │
    ┌────────────▼──────────────┐
    │   4. Open Application     │
    │   http://localhost:5173   │
    └───────────────────────────┘
```

---

## Test Accounts

**Login with these pre-seeded accounts:**

### Admin Accounts

| Email | Password | Name | Features |
|-------|----------|------|----------|
| admin@recipeapp.com | Admin123! | Admin User | Full admin access |
| john.doe@recipeapp.com | Admin123! | John Doe | Recipe approval, user management |
| sarah.smith@recipeapp.com | Admin123! | Sarah Smith | Statistics, activity logs |

### Regular User Accounts

| Email | Password | Name | Status |
|-------|----------|------|--------|
| mike.johnson@email.com | User123! | Mike Johnson | Active |
| emily.brown@email.com | User123! | Emily Brown | Active |
| alex.wilson@email.com | User123! | Alex Wilson | Inactive |
| lisa.davis@email.com | User123! | Lisa Davis | Pending |

### Testing Workflow

1. **Test User Registration:**
   - Go to Signup page
   - Create new account
   - Verify in phpMyAdmin: `SELECT * FROM users ORDER BY created_at DESC LIMIT 1;`

2. **Test User Login:**
   - Use `admin@recipeapp.com` / `Admin123!`
   - Should redirect to home page
   - Verify session in phpMyAdmin: `SELECT * FROM sessions ORDER BY created_at DESC LIMIT 1;`

3. **Test Recipe Creation:**
   - Login as admin
   - Create new recipe
   - Verify in phpMyAdmin: `SELECT * FROM recipes ORDER BY created_at DESC LIMIT 1;`

4. **Test Admin Features:**
   - Login as admin
   - Go to Admin Dashboard
   - View pending recipes
   - Approve/reject a recipe
   - Check activity log in phpMyAdmin: `SELECT * FROM activity_logs ORDER BY created_at DESC LIMIT 5;`

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
   DROP DATABASE IF EXISTS recipe_sharing_db;
   CREATE DATABASE recipe_sharing_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   USE recipe_sharing_db;
   -- Now run scripts in order again
   ```

### Problem: API returns "Database connection failed"

**Solution:**
1. **Verify database exists:**
   - phpMyAdmin → Database list should show `recipe_sharing_db`

2. **Check config.php:**
   - File: `C:\xampp\htdocs\recipe_api\config\config.php`
   - Verify: `DB_NAME = 'recipe_sharing_db'`
   - Verify: `DB_USER = 'root'`
   - Verify: `DB_PASS = ''` (empty string)

3. **Test connection manually:**
   ```php
   <?php
   // Create file: C:\xampp\htdocs\test-db.php
   $pdo = new PDO('mysql:host=localhost;dbname=recipe_sharing_db', 'root', '');
   echo "Connected successfully!";
   ?>
   ```
   Open: http://localhost/test-db.php

### Problem: CORS error in browser console

**Solution:**
1. **Check backend CORS middleware:**
   - File: `backend/middleware/cors.php`
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
   - Left sidebar: `recipe_sharing_db` should be highlighted
   - If not, click on it

### Problem: Frontend shows "Network Error"

**Solution:**
1. **Check all services running:**
   - XAMPP: Apache and MySQL both green
   - Frontend: `npm run dev` running without errors

2. **Test API manually:**
   - Open: http://localhost/recipe_api/api/index.php
   - Should return JSON, not HTML error page

3. **Check browser console:**
   - Press F12 → Console tab
   - Look for specific error messages
   - Common: CORS error, 404 Not Found, 500 Internal Server Error

### Problem: Login doesn't work

**Solution:**
1. **Verify users exist:**
   ```sql
   -- In phpMyAdmin:
   SELECT email, username FROM users WHERE role = 'admin';
   ```

2. **Check password hashing:**
   - Passwords should be bcrypt hashes, not plain text
   - Re-run `05_seed_users.sql` if needed

3. **Test with Postman:**
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
SELECT * FROM users WHERE email = 'admin@recipeapp.com';

-- Check latest recipes
SELECT recipe_id, title, author_id, status, created_at 
FROM recipes 
ORDER BY created_at DESC 
LIMIT 5;

-- Check session validity
SELECT * FROM sessions 
WHERE expires_at > NOW() 
ORDER BY created_at DESC;

-- View recipe with ingredients
SELECT 
    r.title,
    i.name as ingredient,
    i.quantity,
    i.unit
FROM recipes r
LEFT JOIN ingredients i ON r.recipe_id = i.recipe_id
WHERE r.recipe_id = 1;
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
│     http://localhost/recipe_api/api/index.php          │
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
│     Database: recipe_sharing_db                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

**🎉 Setup Complete! You're ready to develop and test your Recipe Sharing System!**

**Next Steps:**
1. Test login with admin account
2. Create a sample recipe
3. Approve recipe from admin dashboard
4. Test search functionality
5. Review database changes in phpMyAdmin after each action

**Happy Coding! 🚀**