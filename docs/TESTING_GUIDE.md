# CookHub Testing Guide

Comprehensive testing documentation for the CookHub Recipe Sharing System.

## Testing Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Playwright | Latest | End-to-end browser testing |
| Chromium | Bundled | Test browser |

---

## Setup

### Install Dependencies

```bash
npm install
npx playwright install chromium
```

### Prerequisites

Before running tests, ensure:
1. **XAMPP** is running (Apache + MySQL)
2. **Database** is seeded with test data (`database/05_seed_users.sql`, `06_seed_recipes.sql`, etc.)
3. **Vite dev server** is running: `npm run dev`

---

## Running Tests

### Run All Tests

```bash
npx playwright test
```

### Run with UI Reporter

```bash
npx playwright test --reporter=html
npx playwright show-report
```

### Run Specific Test File

```bash
npx playwright test tests/e2e.spec.js
```

### Run by Test Name

```bash
npx playwright test -g "should login as admin"
```

### Debug Mode (Headed Browser)

```bash
npx playwright test --headed --debug
```

---

## Configuration

Test configuration in `playwright.config.js`:

| Setting | Value | Description |
|---------|-------|-------------|
| Base URL | `http://localhost:5173/recipe-sharing-system-deploy/` | App URL |
| Browser | Chromium | Test browser |
| Workers | 1 | Sequential execution |
| Timeout | 30 seconds | Per-test timeout |
| Retries | 1 | Retry on failure |
| Reporter | HTML + List | Output formats |

---

## Test Suite Overview

**Total: 35 tests across 7 categories**

### 1. Authentication Tests (7 tests)

| ID | Test | Description |
|----|------|-------------|
| TEST-001 | Admin login | Login as admin → redirects to `/admin` dashboard |
| TEST-002 | User login | Login as regular user → sees home page |
| TEST-003 | Invalid credentials | Wrong password → shows error message |
| TEST-004 | Logout | Logout → redirects to login page |
| TEST-005 | Registration form | Signup fields render correctly |
| TEST-006 | Password mismatch | Mismatched passwords → shows validation error |
| TEST-007 | Unauthenticated redirect | Accessing `/` without auth → redirect to `/login` |

**Test Accounts**:
- Admin: `admin@cookhub.com` / `admin`
- User: `john@cookhub.com` / `user`

### 2. Recipe Browsing Tests (4 tests)

| ID | Test | Description |
|----|------|-------------|
| TEST-008 | Home page loads | Home page shows recipe cards |
| TEST-009 | Hero search | Search form visible on home page |
| TEST-010 | Recipe detail | Navigate to recipe → see title, ingredients, instructions |
| TEST-011 | View All | Hero section shows "View All" link |

### 3. Search Tests (3 tests)

| ID | Test | Description |
|----|------|-------------|
| TEST-015 | Search page loads | Navigate to `/search` → page renders |
| TEST-016 | Search with query | Search for "pasta" → results appear |
| TEST-017 | Empty search | Empty query → shows all recipes or message |

### 4. Recipe CRUD Tests (3 tests)

| ID | Test | Description |
|----|------|-------------|
| TEST-020 | Create page | Navigate to `/recipes/create` → form loads |
| TEST-021 | Form fields | Title, description, category, difficulty fields present |
| TEST-022 | Create button | Submit button is visible |

### 5. Profile Tests (4 tests)

| ID | Test | Description |
|----|------|-------------|
| TEST-025 | Profile page | Navigate to `/profile` → page loads |
| TEST-026 | Profile content | Shows user information |
| TEST-027 | My Recipes route | `/recipes/my-recipes` is accessible |
| TEST-028 | Profile icon | Navbar has profile icon with `aria-label="View Profile"` |

### 6. Admin Panel Tests (4 tests)

| ID | Test | Description |
|----|------|-------------|
| TEST-030 | Stats page | Admin dashboard loads with statistics |
| TEST-031 | Users page | `/admin/users` shows user management |
| TEST-032 | Recipes page | `/admin/recipes` shows recipe management |
| TEST-033 | Access control | Regular user cannot access admin panel |

### 7. API Integration Tests (5 tests)

| ID | Test | Description |
|----|------|-------------|
| TEST-036 | Login endpoint | POST `/api/auth/login` returns user data with email |
| TEST-037 | Unauth /me | GET `/api/auth/me` without auth returns 401 |
| TEST-038 | Recipes list | GET `/api/recipes` returns recipe array |
| TEST-039 | Search API | GET `/api/search?q=pasta` returns results (requires auth) |
| TEST-040 | Stats API | GET `/api/stats` with admin auth returns stats |

### 8. Navigation & UI Tests (5 tests)

| ID | Test | Description |
|----|------|-------------|
| TEST-041 | Logo navigation | CookHub logo navigates to home |
| TEST-042 | Sticky navbar | Navbar has `sticky` CSS class |
| TEST-043 | Responsive | Viewport meta tag present |
| TEST-044 | Transitions | Transition CSS classes exist |
| TEST-045 | Error boundary | ErrorBoundary component is mounted |

---

## Test Helpers

### `loginAsUser(page)`

Logs in as `john@cookhub.com` (regular user) and waits for home page to load.

### `loginAsAdmin(page)`

Logs in as `admin@cookhub.com` (admin) and waits for admin dashboard redirect.

### `logout(page)`

Clicks the logout button (`aria-label="Logout"`) and waits for login page.

---

## Test Results

Last run: **35/35 PASSED** (1.1 minutes)

```
Running 35 tests using 1 worker

  ✓ Authentication > TEST-001: should login as admin
  ✓ Authentication > TEST-002: should login as regular user
  ✓ Authentication > TEST-003: should show error for invalid credentials
  ✓ Authentication > TEST-004: should logout successfully
  ✓ Authentication > TEST-005: should load registration form
  ✓ Authentication > TEST-006: should prevent password mismatch
  ✓ Authentication > TEST-007: should redirect to login when not authenticated
  ✓ Recipe Browsing > TEST-008: should display recipe listing on home
  ✓ Recipe Browsing > TEST-009: should show hero search on home
  ✓ Recipe Browsing > TEST-010: should navigate to recipe detail
  ✓ Recipe Browsing > TEST-011: should show View All in hero section
  ✓ Search > TEST-015: should load search page
  ✓ Search > TEST-016: should show results for valid query
  ✓ Search > TEST-017: should handle empty search
  ✓ Recipe CRUD > TEST-020: should navigate to create recipe page
  ✓ Recipe CRUD > TEST-021: should show recipe form fields
  ✓ Recipe CRUD > TEST-022: should have create button
  ✓ Profile > TEST-025: should navigate to profile page
  ✓ Profile > TEST-026: should load profile content
  ✓ Profile > TEST-027: should load my recipes route
  ✓ Profile > TEST-028: should have profile icon in navbar
  ✓ Admin Panel > TEST-030: should load admin stats page
  ✓ Admin Panel > TEST-031: should load admin users page
  ✓ Admin Panel > TEST-032: should load admin recipes page
  ✓ Admin Panel > TEST-033: should block regular user from admin
  ✓ API Integration > TEST-036: should return user on login
  ✓ API Integration > TEST-037: should reject unauthenticated /me
  ✓ API Integration > TEST-038: should list recipes via API
  ✓ API Integration > TEST-039: should search recipes via API
  ✓ API Integration > TEST-040: should return stats for admin
  ✓ Navigation & UI > TEST-041: should navigate home via logo
  ✓ Navigation & UI > TEST-042: should have sticky navbar
  ✓ Navigation & UI > TEST-043: should have responsive viewport
  ✓ Navigation & UI > TEST-044: should have transitions
  ✓ Navigation & UI > TEST-045: should have error boundary

  35 passed
```

---

## Adding New Tests

1. Add tests inside `tests/e2e.spec.js` in the appropriate `describe` block
2. Follow the naming convention: `TEST-XXX: should ...`
3. Use `loginAsUser(page)` or `loginAsAdmin(page)` for authenticated tests
4. Use `logout(page)` to end a session
5. Target elements via `aria-label`, `role`, or `data-testid` attributes
6. Run and verify: `npx playwright test --headed`

---

## Continuous Integration

To run tests in CI (e.g., GitHub Actions):

```yaml
- name: Install dependencies
  run: npm ci

- name: Install Playwright
  run: npx playwright install chromium --with-deps

- name: Start dev server
  run: npm run dev &
  
- name: Wait for server
  run: npx wait-on http://localhost:5173

- name: Run tests
  run: npx playwright test
```

> **Note**: CI requires a running MySQL database with seeded data. Use Docker Compose or a service container for the database.
