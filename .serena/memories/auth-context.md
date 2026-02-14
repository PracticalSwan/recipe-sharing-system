# Auth Context & Authentication

**Last Updated**: 2026-02-14
**Status**: ✅ Fully migrated to API-based auth

## `src/context/AuthContext.jsx` — Current Implementation
- Uses `api.auth.me()` on mount to restore session from HttpOnly cookie
- `login(email, password)`: Calls `api.auth.login()`, sets user state on success
- `register(data)`: Calls `api.auth.register()`, sets user state on success
- `logout()`: Calls `api.auth.logout()`, clears user state
- Heartbeat: Periodic `api.auth.me()` calls to check session validity
- Loading state: `initializing` flag prevents flash of login screen
- No more localStorage for user data — fully session/cookie-based

## Auth Pages — Current Implementation
- **`src/pages/Auth/Login.jsx`**: Async login with loading spinner, error display, network error handling
- **`src/pages/Auth/Signup.jsx`**: Async register with loading state, validation error display, duplicate email handling

## Backend Auth Flow
1. `POST /api/auth/login` → validates credentials → creates `session` table row → sets HttpOnly cookie
2. `POST /api/auth/register` → validates fields → bcrypt hash → inserts user → creates session → sets cookie
3. `POST /api/auth/logout` → deletes session row → clears cookie
4. `GET /api/auth/me` → reads cookie → validates session token → returns user data (excludes password_hash)

## Security
- Passwords: `password_hash()` with BCRYPT
- Sessions: `bin2hex(random_bytes(32))` tokens stored in `session` table
- Cookie: HttpOnly, SameSite=Lax
- All data endpoints require valid session (except register/login)
- Admin endpoints additionally check `role = 'admin'`
