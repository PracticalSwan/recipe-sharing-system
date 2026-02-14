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
1. XAMPP is running (Apache + MySQL)
2. Database is seeded with test data (`database/05_seed_users.sql`, `06_seed_recipes.sql`, etc.)
3. Vite dev server is running: `npm run dev`

---

## Running Tests

### Run All Tests

```bash
npx playwright test
```

### Run with HTML Report

```bash
npx playwright test --reporter=html
npx playwright show-report
```

### Run Main E2E File

```bash
npx playwright test tests/e2e.spec.js
```

### Run a Specific Test by Name

```bash
npx playwright test -g "TEST-121"
```

### Run Regression-Fix Block Only

```bash
npx playwright test tests/e2e.spec.js --grep "TEST-120|TEST-121|TEST-122|TEST-123|TEST-124|TEST-125|TEST-126|TEST-127"
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

**Total: 127 tests across 16 suites (`TEST-001`..`TEST-127`)**

| Suite | Test IDs | Count |
|------|----------|-------|
| Authentication | TEST-001..TEST-012 | 12 |
| Home Page | TEST-013..TEST-019 | 7 |
| Recipe Detail | TEST-020..TEST-030 | 11 |
| Search Page | TEST-031..TEST-040 | 10 |
| Recipe Creation | TEST-041..TEST-050 | 10 |
| Profile Page | TEST-051..TEST-060 | 10 |
| Admin Dashboard | TEST-061..TEST-068 | 8 |
| Admin User Management | TEST-069..TEST-076 | 8 |
| Admin Recipe Management | TEST-077..TEST-084 | 8 |
| Admin Sidebar | TEST-085..TEST-088 | 4 |
| Navigation & UI | TEST-089..TEST-098 | 10 |
| Accessibility | TEST-099..TEST-103 | 5 |
| API Integration | TEST-104..TEST-111 | 8 |
| Recipe Interactions | TEST-112..TEST-115 | 4 |
| Regression Fixes | TEST-120..TEST-127 | 8 |
| Error Handling | TEST-116..TEST-119 | 4 |

**Test Accounts**:
- Admin: `admin@cookhub.com` / `admin`
- User: `user@cookhub.com` / `user`

---

## Regression Coverage Added

| ID | Scenario | Expected Behavior |
|----|----------|-------------------|
| TEST-120 | Create recipe visibility | Newly created recipe appears immediately in owner profile list |
| TEST-121 | Recipe views | View count increments once per user per recipe |
| TEST-122 | Reviews | Re-posting review updates existing user review (one per user/recipe) |
| TEST-123 | Search reset | Reset clears keyword, filters, and URL params |
| TEST-124 | Edit profile modal | Outside click does not close modal |
| TEST-125 | Suspended messaging | Like/save disabled text is status-specific for suspended users |
| TEST-126 | Admin recent activity | Active/inactive status transitions are excluded |
| TEST-127 | Logout status | User becomes inactive after logout |

---

## Test Helpers

### `loginAsUser(page)`

Logs in as `user@cookhub.com` (regular user) and waits for the home page.

### `loginAsAdmin(page)`

Logs in as `admin@cookhub.com` (admin) and waits for admin dashboard redirect.

### `logout(page)`

Clicks the logout button (`aria-label="Logout"`) and waits for login page.

---

## Latest Result Snapshot

Last full run: **127/127 PASSED** (~4.1 minutes)

```text
Running 127 tests using 1 worker
...
127 passed (4.1m)
```

---

## Adding New Tests

1. Add tests inside `tests/e2e.spec.js` in the correct `describe` block.
2. Follow naming convention: `TEST-XXX: ...`.
3. Use `loginAsUser(page)` or `loginAsAdmin(page)` for authenticated tests.
4. Target elements by `aria-label`, `role`, or `data-testid` when possible.
5. Verify with `npx playwright test --headed`.

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

> Note: CI requires a running MySQL database with seeded data.
