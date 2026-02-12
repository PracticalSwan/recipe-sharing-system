---

## Current Frontend State (React 19)

**AuthContext.jsx** provides centralized authentication state and methods for the React application.

**State Management:**
- `user` — Current logged-in user object (from localStorage)
- `loading` — Loading state for async operations
- `isAdmin` — Derived flag (user.role === 'admin')
- `isPending` — Derived flag (user.status === 'pending')
- `isSuspended` — Derived flag (user.status === 'suspended')
- `canInteract` — Derived flag (can post reviews, like, favorite)

**Methods:**
- `login(email, password)` — Authenticate via localStorage validation
- `logout()` — Clear user from Context and localStorage
- `signup(userData)` — Create new user with role='user', status='pending', then log in
- `updateProfile(updatedData)` — Merge updates into current user and save to localStorage

**Activity Tracking:**
- `updateLastActive()` — Called every minute to track active session
- `recordActiveUser()` — Called hourly to log user activity
- Also tracks `lastActive` on page unload/hide events
- Listens for `favoriteToggled` events to sync across components

### Derive Flags Logic

```javascript
isAdmin = user && user.role === 'admin'
isPending = user && user.status === 'pending'
isSuspended = user && user.status === 'suspended'
canInteract = user && !isPending && !isSuspended && user.id !== null
```

---

## Backend State (PHP + MySQL — Phase 4 Pending)

### Session-Based Authentication (v2.0 Plan Decision)

**Auth Architecture Decision (February 8, 2026):**
Session-based authentication only. JWT option removed from implementation plan.

**Rationale for Session-Only:**
- Simpler implementation without external libraries
- Native PHP session management is secure and battle-tested
- No need for JWT library dependency
- HttpOnly cookies provide CSRF protection automatically

### Database Schema (Complete)

**Session Table:** (`database/02_create_tables.sql` lines 61-77)
```sql
CREATE TABLE session (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    INDEX idx_session_token (session_token),
    INDEX idx_user_session (user_id, expires_at)
) ENGINE=InnoDB;
```

**User Table Key Columns:**
- `id` — Primary key
- `email` — VARCHAR 255 UNIQUE (login identifier)
- `username` — VARCHAR 50 UNIQUE
- `password` — VARCHAR 255 (bcrypt hash, not plaintext)
- `first_name`, `last_name` — User display names
- `is_admin` — TINYINT(1) DEFAULT 0 (admin flag)
- `status` — ENUM('active', 'pending', 'suspended')

### Session Flow

**Registration Flow:**
```
User submits form → POST /api/auth.php
Validate email format, username uniqueness → Create user in DB
Generate bcrypt hash: password_hash($plain_password) → Store in user.password
Create session: INSERT INTO session (user_id, session_token, expires_at)
Set HttpOnly cookie: session_token → Response 200 OK
```

**Login Flow:**
```
User submits credentials → POST /api/auth.php
Fetch user by email → password_verify($input, $db_hash)
If valid password → Create session → Set HttpOnly cookie → 200 OK
If invalid password → 401 Unauthorized
If user not found → 401 Unauthorized
```

**Session Validation (Middleware):**
```php
function validateSession($pdo) {
    $token = $_COOKIE['session_token'] ?? null;
    if (!$token) return null;

    $stmt = $pdo->prepare("
        SELECT u.*, s.expires_at
        FROM session s
        INNER JOIN user u ON s.user_id = u.id
        WHERE s.session_token = ? AND s.expires_at > NOW()
    ");
    $stmt->execute([$token]);
    $session = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$session) return null;

    // Auto-extend session on activity
    $update = $pdo->prepare("
        UPDATE session SET expires_at = DATE_ADD(NOW(), INTERVAL 1 HOUR)
        WHERE id = ?
    ");
    $update->execute([$session['id']]);

    return $session;
}
```

**Logout Flow:**
```
Client calls POST /api/auth.php?action=logout
Server validates session → DELETE FROM session WHERE session_token = ?
Clear HttpOnly cookie (Set-Cookie: session_token=; Expires=Thu, 01 Jan 1970)
Response 200 OK
```

### Session Security Features

**1. HttpOnly Cookie:**
```php
setcookie('session_token', $token, [
    'expires' => time() + 3600,  // 1 hour
    'path' => '/',
    'domain' => '',  // Current domain
    'secure' => false,  // XAMPP default (true in production HTTPS)
    'httponly' => true,  // Prevents XSS access
    'samesite' => 'Lax'  // CSRF protection
]);
```

**2. Token Generation:**
```php
$sessionToken = bin2hex(random_bytes(32));  // 64-character hex
// Example: 'a1b2c3d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5f6'
```

**3. Session Expiration:**
- Default TTL: 1 hour from last activity
- Auto-extend on each validated request (activity tracking)
- Expired sessions automatically cleaned up by trigger or cron

---

## Migration Strategy (Frontend → Backend)

### Phase 1: Backend Setup (TASK-BK-002 to TASK-BK-006)
1. **Create `backend/` folder structure:**
   ```
   backend/
   ├── config/
   │   └── database.php     # PDO connection
   ├── helpers/
   │   ├── session_check.php   # Session validation middleware
   │   └── auth_helpers.php   # Password hashing, token generation
   └── api/
       ├── auth.php            # register, login, logout
       ├── recipes.php          # CRUD operations
       ├── reviews.php          # Submit reviews
       ├── favorites.php        # Toggle favorites
       └── likes.php           # Toggle likes
   ```

2. **Database Connection (`config/database.php`):**
   ```php
   $dsn = 'mysql:host=localhost;dbname=cookhub;charset=utf8mb4';
   $options = [
       PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
       PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
   ];
   $pdo = new PDO($dsn, 'root', '', $options);
   ```

3. **Auth Endpoints (`api/auth.php`):**
   - `POST /register` — Create user + session + cookie
   - `POST /login` — Validate credentials + session + cookie
   - `POST /logout` — Destroy session + clear cookie

### Phase 2: Frontend Migration (TASK-FE-001 to TASK-FE-005)
1. **Update `AuthContext.jsx`:**
   - Remove `localStorage` state loading
   - Add `fetch('/api/auth.php')` calls for login/signup
   - Remove `isAdmin`, `isPending`, `isSuspended` derived flags (moved to backend)
   - Handle session cookie automatically (no client storage needed)

2. **Create `api.js` helper:**
   ```javascript
   const API_BASE = '/api/';
   const fetchWithAuth = (url, options = {}) => {
       return fetch(API_BASE + url, {
           ...options,
           credentials: 'include'  // Send HttpOnly cookie
       });
   };
   ```

3. **Remove localStorage dependency:**
   - Delete `lib/storage.js` operations after migration complete
   - All user state now server-side (session table)

### Phase 3: Integration Testing (TASK-TEST-001 to TASK-TEST-004)
- Test registration → Session cookie present → User created in DB
- Test login → Session verified → AuthContext updates
- Test logout → Session deleted → Cookie cleared → AuthContext cleared
- Test protected routes → Middleware redirects to login if no valid session

---

## Role-Based Access Control

**Admin Privileges (is_admin = 1):**
- View pending recipes queue (`status = 'pending'`)
- Approve/reject recipes (update `recipe.status`)
- View all users list (admin dashboard)
- View activity logs (`activity_log` table)
- Access moderation endpoints

**User Privileges (is_admin = 0):**
- Create recipes (requires `status = 'active' after approval)
- Edit own recipes only
- Post reviews and ratings
- Like and favorite recipes
- View own profile stats

---

## Related Files

- [database/02_create_tables.sql](../../database/02_create_tables.sql) — Session table schema lines 61-77
- [database/13_triggers.sql](../../database/13_triggers.sql) — `trg_User_UpdateLastActive` trigger
- [src/context/AuthContext.jsx](../../src/context/AuthContext.jsx) — Current React auth state
- [lib/storage.js](../../src/lib/storage.js) — localStorage implementation (to be removed)

---

## Next Steps

1. Execute SQL scripts in phpMyAdmin → Create session table
2. Implement `backend/config/database.php` → PDO connection
3. Implement `backend/api/auth.php` → Register/login/logout
4. Update `src/api.js` → Add fetchWithAuth helper
5. Migrate `AuthContext.jsx` → Use session-based auth
