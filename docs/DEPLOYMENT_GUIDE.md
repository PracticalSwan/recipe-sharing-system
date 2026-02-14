# CookHub Deployment Guide

Step-by-step deployment guide for the CookHub Recipe Sharing System.

## Prerequisites

| Software | Version | Purpose |
|----------|---------|---------|
| XAMPP | 8.x+ | Apache + MySQL + PHP |
| Node.js | 18+ | Vite dev server / build |
| npm | 9+ | Package management |
| Git | Any | Source control |

---

## 1. Clone the Repository

```bash
git clone <repository-url> recipe-sharing-system
cd recipe-sharing-system
```

## 2. XAMPP Setup

### 2.1 Install XAMPP

Download from [apachefriends.org](https://www.apachefriends.org/) and install to `C:\xampp`.

### 2.2 Link Project to Apache

Create a directory junction so Apache can serve the PHP backend:

```powershell
# Run as Administrator
cmd /c mklink /J "C:\xampp\htdocs\recipe-sharing-system" "C:\path\to\recipe-sharing-system"
```

### 2.3 Start Services

Open XAMPP Control Panel and start:
- **Apache** (port 80)
- **MySQL** (port 3306)

### 2.4 Verify PHP

```powershell
C:\xampp\php\php.exe -v
# Should show PHP 8.x
```

---

## 3. Database Setup

### 3.1 Create Database via phpMyAdmin

1. Open `http://localhost/phpmyadmin`
2. Click **New** in the left sidebar
3. Enter database name: `cookhub`
4. Select collation: `utf8mb4_unicode_ci`
5. Click **Create**

### 3.2 Run SQL Scripts

Execute scripts **in order** from the `database/` folder. You can use phpMyAdmin's **Import** tab or MySQL CLI:

```bash
cd database
mysql -u root cookhub < 01_create_database.sql
mysql -u root cookhub < 02_create_tables.sql
mysql -u root cookhub < 03_create_indexes.sql
mysql -u root cookhub < 04_create_views.sql
mysql -u root cookhub < 05_seed_users.sql
mysql -u root cookhub < 06_seed_recipes.sql
mysql -u root cookhub < 07_seed_reviews.sql
mysql -u root cookhub < 08_seed_stats.sql
mysql -u root cookhub < 12_stored_procedures.sql
mysql -u root cookhub < 13_triggers.sql
```

Or use the master script:

```bash
mysql -u root < run_all_scripts.sql
```

> See [SETUP_GUIDE_PHPMYADMIN.md](../guides/SETUP_GUIDE_PHPMYADMIN.md) for the phpMyAdmin GUI walkthrough.

### 3.3 Verify Database

Check that tables were created:

```sql
USE cookhub;
SHOW TABLES;
-- Should show 13 tables
```

### 3.4 Default Accounts

| Email | Password | Role |
|-------|----------|------|
| admin@cookhub.com | admin | Admin |
| olivia@cookhub.com | admin | Admin |
| marcus@cookhub.com | admin | Admin |
| john@cookhub.com | user | User |
| maria@cookhub.com | maria123 | User |
| tom@cookhub.com | tom123 | User |

---

## 4. Backend Configuration

### 4.1 Database Connection

The database config is in `backend/config/database.php`:

```php
private $host = 'localhost';
private $dbName = 'cookhub';
private $username = 'root';
private $password = '';  // Default XAMPP has no password
```

Update credentials if your MySQL has a password set.

### 4.2 CORS Configuration

CORS headers are set in `backend/helpers/cors.php`. For production, update the allowed origins:

```php
$allowedOrigins = [
    'http://localhost:5173',     // Vite dev server
    'http://127.0.0.1:5173',
    'https://your-production-domain.com'  // Add production domain
];
```

### 4.3 Verify API Access

```bash
curl http://localhost/recipe-sharing-system/backend/api/auth/me
# Should return: {"error":"Unauthorized"}
```

---

## 5. Frontend Setup

### 5.1 Install Dependencies

```bash
npm install
```

### 5.2 Development Server

```bash
npm run dev
```

The app will be available at `http://localhost:5173/recipe-sharing-system-deploy/`

### 5.3 Vite Proxy Configuration

The Vite dev server proxies API requests to the PHP backend in `vite.config.js`:

```js
server: {
  proxy: {
    '/api': {
      target: 'http://localhost/recipe-sharing-system/backend',
      changeOrigin: true,
      secure: false,
    }
  }
}
```

This means frontend calls to `/api/auth/login` are proxied to `http://localhost/recipe-sharing-system/backend/api/auth/login`, which Apache rewrites to `backend/api/auth.php?route=login`.

### 5.4 Production Build

```bash
npm run build
```

Output is in `dist/`. Deploy with:

```bash
npm run preview
```

---

## 6. Apache URL Rewriting

The backend uses `.htaccess` for clean API URLs:

```
api/auth/login → api/auth.php?route=login
api/recipes/5  → api/recipes.php?route=5
api/stats      → api/stats.php
```

Ensure Apache `mod_rewrite` is enabled in `httpd.conf`:

```apache
LoadModule rewrite_module modules/mod_rewrite.so
```

---

## 7. Production Deployment

### 7.1 Build Frontend

```bash
npm run build
```

### 7.2 Deploy Files

Copy to your web server:
- `dist/` → Web root (or subdirectory)
- `backend/` → Same server (accessible via Apache/Nginx)
- Ensure `.htaccess` is preserved

### 7.3 Production Checklist

- [ ] Update `vite.config.js` `base` path for production URL
- [ ] Set MySQL password and update `database.php`
- [ ] Update CORS origins in `cors.php`
- [ ] Enable HTTPS
- [ ] Set `session.cookie_secure = true` in PHP
- [ ] Disable `display_errors` in `php.ini`
- [ ] Set up database backups (see `database/14_backup_restore.sql`)
- [ ] Review error logging configuration

---

## Troubleshooting

### API Returns 404

- Verify XAMPP Apache is running
- Check directory junction exists: `dir C:\xampp\htdocs\recipe-sharing-system`
- Verify `.htaccess` is present in `backend/`
- Ensure `mod_rewrite` is enabled

### Login Returns 401 "Invalid credentials"

- Verify password hashes are correct bcrypt hashes in the database
- Run `database/fix_passwords.sql` to reset all passwords
- Check PHP `password_verify()` is working: `php -r "echo password_verify('admin', '<hash>');" `

### CORS Errors in Browser

- Check `backend/helpers/cors.php` has your frontend origin listed
- Verify `credentials: 'include'` is set in fetch calls
- Ensure preflight OPTIONS requests return correct headers

### Database Connection Failed

- Verify MySQL service is running in XAMPP
- Check credentials in `backend/config/database.php`
- Test with: `mysql -u root -p cookhub -e "SELECT 1"`
