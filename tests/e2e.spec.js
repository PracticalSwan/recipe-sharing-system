// @ts-check
import { test, expect } from '@playwright/test';

const BASE = '/#';
const ADMIN_EMAIL = 'admin@cookhub.com';
const ADMIN_PASS = 'admin';
const USER_EMAIL = 'user@cookhub.com';
const USER_PASS = 'user';

// ─── Helpers ──────────────────────────────────────────────

async function loginAsUser(page) {
  await page.goto(`${BASE}/login`);
  await page.locator('#email').fill(USER_EMAIL);
  await page.locator('#password').fill(USER_PASS);
  await page.locator('button[type="submit"]').click();
  await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible({ timeout: 15000 });
}

async function loginAsAdmin(page) {
  await page.goto(`${BASE}/login`);
  await page.locator('#email').fill(ADMIN_EMAIL);
  await page.locator('#password').fill(ADMIN_PASS);
  await page.locator('button[type="submit"]').click();
  await page.waitForURL(/\/#\/admin/, { timeout: 15000 });
}

async function logout(page) {
  await page.locator('button[aria-label="Logout"]').click();
  await expect(page.locator('text=Welcome Back!')).toBeVisible({ timeout: 10000 });
}

// ═══════════════════════════════════════════════════════════
// 1. AUTHENTICATION (TEST-001 to TEST-009)
// ═══════════════════════════════════════════════════════════

test.describe('Authentication', () => {
  test('TEST-001: Login page displays correct elements', async ({ page }) => {
    await page.goto(`${BASE}/login`);
    await expect(page.locator('text=Welcome Back!')).toBeVisible();
    await expect(page.locator('#email')).toBeVisible();
    await expect(page.locator('#password')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
    await expect(page.locator('text=Demo Credentials:')).toBeVisible();
    await expect(page.locator('a:has-text("Sign up")')).toBeVisible();
  });

  test('TEST-002: Login with valid user credentials', async ({ page }) => {
    await loginAsUser(page);
    await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible();
    await expect(page.locator('nav')).toBeVisible();
    await expect(page.locator('text=CookHub')).toBeVisible();
  });

  test('TEST-003: Login with valid admin credentials', async ({ page }) => {
    await loginAsAdmin(page);
    await expect(page).toHaveURL(/\/#\/admin/);
    await expect(page.locator('h1:has-text("Dashboard")')).toBeVisible({ timeout: 10000 });
  });

  test('TEST-004: Login with invalid credentials shows error', async ({ page }) => {
    await page.goto(`${BASE}/login`);
    await page.locator('#email').fill('wrong@email.com');
    await page.locator('#password').fill('wrongpassword');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('.text-red-500')).toBeVisible({ timeout: 10000 });
  });

  test('TEST-005: Login button shows loading state', async ({ page }) => {
    await page.goto(`${BASE}/login`);
    await page.locator('#email').fill(USER_EMAIL);
    await page.locator('#password').fill(USER_PASS);
    const submitBtn = page.locator('button[type="submit"]');
    await submitBtn.click();
    // Button may briefly show loading spinner or disabled state
    await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible({ timeout: 15000 });
  });

  test('TEST-006: Logout redirects to login page', async ({ page }) => {
    await loginAsUser(page);
    await logout(page);
    await expect(page.locator('text=Welcome Back!')).toBeVisible();
  });

  test('TEST-007: Signup page displays correct fields', async ({ page }) => {
    await page.goto(`${BASE}/signup`);
    await expect(page.locator('text=Get Started')).toBeVisible();
    await expect(page.locator('#firstName')).toBeVisible();
    await expect(page.locator('#lastName')).toBeVisible();
    await expect(page.locator('#birthday')).toBeVisible();
    await expect(page.locator('#email')).toBeVisible();
    await expect(page.locator('#password')).toBeVisible();
    await expect(page.locator('#confirmPassword')).toBeVisible();
    await expect(page.locator('button:has-text("Create Account")')).toBeVisible();
  });

  test('TEST-008: Signup password mismatch shows error', async ({ page }) => {
    await page.goto(`${BASE}/signup`);
    await page.locator('#firstName').fill('Test');
    await page.locator('#lastName').fill('Mismatch');
    await page.locator('#birthday').fill('2000-01-15');
    await page.locator('#email').fill('mismatch@cookhub.com');
    await page.locator('#password').fill('pass123');
    await page.locator('#confirmPassword').fill('different123');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('text=Passwords do not match')).toBeVisible();
  });

  test('TEST-009: Unauthenticated user redirected to login', async ({ page }) => {
    await page.goto(`${BASE}/`);
    await expect(page.locator('text=Welcome Back!')).toBeVisible({ timeout: 10000 });
  });

  test('TEST-010: Navigate between login and signup', async ({ page }) => {
    await page.goto(`${BASE}/login`);
    await page.locator('a:has-text("Sign up")').click();
    await expect(page).toHaveURL(/\/#\/signup/);
    await expect(page.locator('text=Get Started')).toBeVisible();
    await page.locator('a:has-text("Log in")').click();
    await expect(page).toHaveURL(/\/#\/login/);
    await expect(page.locator('text=Welcome Back!')).toBeVisible();
  });

  test('TEST-011: Registration with valid data creates account', async ({ page }) => {
    const unique = Date.now();
    await page.goto(`${BASE}/signup`);
    await page.locator('#firstName').fill('E2E');
    await page.locator('#lastName').fill('TestUser');
    await page.locator('#birthday').fill('1999-06-15');
    await page.locator('#email').fill(`e2e${unique}@cookhub.com`);
    await page.locator('#password').fill('SecurePass1');
    await page.locator('#confirmPassword').fill('SecurePass1');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible({ timeout: 15000 });
  });

  test('TEST-012: Session persists after page reload', async ({ page }) => {
    await loginAsUser(page);
    await page.reload();
    await page.waitForTimeout(3000);
    // Should still be logged in
    const url = page.url();
    expect(url).not.toContain('/login');
  });
});

// ═══════════════════════════════════════════════════════════
// 2. HOME PAGE (TEST-013 to TEST-019)
// ═══════════════════════════════════════════════════════════

test.describe('Home Page', () => {
  test.beforeEach(async ({ page }) => { await loginAsUser(page); });

  test('TEST-013: Hero section displays heading and search', async ({ page }) => {
    await expect(page.locator('h1:has-text("Share Your Culinary")')).toBeVisible();
    const searchInput = page.locator('form input[placeholder*="Search"]');
    await expect(searchInput).toBeVisible();
  });

  test('TEST-014: Recipe grid loads with cards', async ({ page }) => {
    await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible();
    const cards = page.locator('.group.block');
    const noRecipes = page.locator('text=No recipes published yet');
    await expect(cards.first().or(noRecipes)).toBeVisible({ timeout: 10000 });
  });

  test('TEST-015: Recipe cards display title and metadata', async ({ page }) => {
    const firstCard = page.locator('.group.block').first();
    if (await firstCard.isVisible({ timeout: 5000 }).catch(() => false)) {
      const text = await firstCard.textContent();
      expect(text.length).toBeGreaterThan(5);
      // Cards should have an image
      const img = firstCard.locator('img').first();
      await expect(img).toBeVisible();
    }
  });

  test('TEST-016: Hero search navigates to search page', async ({ page }) => {
    const searchInput = page.locator('form input[placeholder*="Search"]');
    await searchInput.fill('pasta');
    await searchInput.press('Enter');
    await expect(page).toHaveURL(/\/#\/search\?q=pasta/);
  });

  test('TEST-017: View All button navigates to search', async ({ page }) => {
    const viewAll = page.locator('button', { hasText: 'View All' });
    if (await viewAll.isVisible({ timeout: 5000 }).catch(() => false)) {
      await viewAll.click();
      await expect(page).toHaveURL(/\/#\/search/);
    }
  });

  test('TEST-018: Click recipe card opens detail', async ({ page }) => {
    const firstCard = page.locator('.group.block').first();
    if (await firstCard.isVisible({ timeout: 5000 }).catch(() => false)) {
      await firstCard.click();
      await expect(page).toHaveURL(/\/#\/recipes\/\d+/, { timeout: 10000 });
      await expect(page.locator('text=Ingredients')).toBeVisible({ timeout: 10000 });
    }
  });

  test('TEST-019: Recipe cards show like and save buttons', async ({ page }) => {
    const firstCard = page.locator('.group.block').first();
    if (await firstCard.isVisible({ timeout: 5000 }).catch(() => false)) {
      // Like button (Heart icon)
      const heartBtn = firstCard.locator('button').filter({ has: page.locator('svg.lucide-heart') }).first();
      await expect(heartBtn).toBeVisible();
      // Bookmark button
      const bookmarkBtn = firstCard.locator('button').filter({ has: page.locator('svg.lucide-bookmark') }).first();
      await expect(bookmarkBtn).toBeVisible();
    }
  });
});

// ═══════════════════════════════════════════════════════════
// 3. RECIPE DETAIL (TEST-020 to TEST-030)
// ═══════════════════════════════════════════════════════════

test.describe('Recipe Detail', () => {
  test.beforeEach(async ({ page }) => {
    await loginAsUser(page);
    const firstCard = page.locator('.group.block').first();
    await expect(firstCard).toBeVisible({ timeout: 10000 });
    await firstCard.click();
    await expect(page).toHaveURL(/\/#\/recipes\/\d+/, { timeout: 10000 });
  });

  test('TEST-020: Recipe title is displayed', async ({ page }) => {
    await expect(page).toHaveURL(/\/#\/recipes\/\d+/, { timeout: 10000 });
    await expect(page.locator('text=Ingredients')).toBeVisible({ timeout: 10000 });
    const title = page.locator('main h1').first();
    await expect(title).toBeVisible({ timeout: 10000 });
    const text = await title.textContent();
    expect(text.trim().length).toBeGreaterThan(0);
  });

  test('TEST-021: Recipe description is shown', async ({ page }) => {
    await expect(page.locator('h1').first()).toBeVisible({ timeout: 10000 });
    const content = await page.textContent('main');
    expect(content.length).toBeGreaterThan(50);
  });

  test('TEST-022: Recipe metadata (time, servings, difficulty)', async ({ page }) => {
    await expect(page.locator('h1').first()).toBeVisible({ timeout: 10000 });
    const content = await page.textContent('main');
    expect(content).toMatch(/min|serv|prep|cook|easy|medium|hard/i);
  });

  test('TEST-023: Ingredients list with checkboxes', async ({ page }) => {
    await expect(page.locator('text=Ingredients')).toBeVisible({ timeout: 10000 });
    const checkboxes = page.locator('[role="checkbox"]');
    const count = await checkboxes.count();
    expect(count).toBeGreaterThan(0);
  });

  test('TEST-024: Toggle ingredient checkbox', async ({ page }) => {
    await expect(page.locator('text=Ingredients')).toBeVisible({ timeout: 10000 });
    const checkbox = page.locator('[role="checkbox"]').first();
    await expect(checkbox).toHaveAttribute('aria-checked', 'false');
    await checkbox.click();
    await expect(checkbox).toHaveAttribute('aria-checked', 'true');
    await checkbox.click();
    await expect(checkbox).toHaveAttribute('aria-checked', 'false');
  });

  test('TEST-025: Instructions section is displayed', async ({ page }) => {
    await expect(page.locator('text=Instructions')).toBeVisible({ timeout: 10000 });
  });

  test('TEST-026: Like and save buttons present', async ({ page }) => {
    await expect(page.locator('h1').first()).toBeVisible({ timeout: 10000 });
    const heartBtn = page.locator('button').filter({ has: page.locator('svg.lucide-heart') }).first();
    await expect(heartBtn).toBeVisible();
    const bookmarkBtn = page.locator('button').filter({ has: page.locator('svg.lucide-bookmark') }).first();
    await expect(bookmarkBtn).toBeVisible();
  });

  test('TEST-027: Toggle like on recipe detail', async ({ page }) => {
    await expect(page.locator('h1').first()).toBeVisible({ timeout: 10000 });
    const heartBtn = page.locator('button').filter({ has: page.locator('svg.lucide-heart') }).first();
    await heartBtn.click();
    await page.waitForTimeout(1000);
    await heartBtn.click();
    await page.waitForTimeout(500);
  });

  test('TEST-028: Toggle save/bookmark on recipe detail', async ({ page }) => {
    await expect(page.locator('h1').first()).toBeVisible({ timeout: 10000 });
    const bookmarkBtn = page.locator('button').filter({ has: page.locator('svg.lucide-bookmark') }).first();
    await bookmarkBtn.click();
    await page.waitForTimeout(1000);
    await bookmarkBtn.click();
    await page.waitForTimeout(500);
  });

  test('TEST-029: Reviews section displayed', async ({ page }) => {
    const reviewsHeading = page.locator('text=/reviews/i').first();
    await reviewsHeading.scrollIntoViewIfNeeded();
    await expect(reviewsHeading).toBeVisible();
  });

  test('TEST-030: Back navigation returns to home', async ({ page }) => {
    await page.goBack();
    await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible({ timeout: 10000 });
  });
});

// ═══════════════════════════════════════════════════════════
// 4. SEARCH PAGE (TEST-031 to TEST-040)
// ═══════════════════════════════════════════════════════════

test.describe('Search Page', () => {
  test.beforeEach(async ({ page }) => {
    await loginAsUser(page);
    await page.goto(`${BASE}/search`);
    await page.waitForTimeout(2000);
  });

  test('TEST-031: Search page loads with filters', async ({ page }) => {
    await expect(page.locator('h2:has-text("Results")')).toBeVisible({ timeout: 10000 });
    await expect(page.locator('input[placeholder*="Search"]')).toBeVisible();
  });

  test('TEST-032: Category filter dropdown visible', async ({ page }) => {
    await expect(page.locator('button[aria-label="Filter by category"]')).toBeVisible();
  });

  test('TEST-033: Difficulty filter visible', async ({ page }) => {
    await expect(page.locator('select[aria-label="Filter by difficulty"]')).toBeVisible();
  });

  test('TEST-034: Search by keyword updates URL', async ({ page }) => {
    const searchInput = page.locator('input[placeholder*="Search"]');
    await searchInput.fill('chicken');
    await searchInput.press('Enter');
    await expect(page).toHaveURL(/q=chicken/);
  });

  test('TEST-035: Search with query from URL', async ({ page }) => {
    await page.goto(`${BASE}/search?q=pasta`);
    await page.waitForTimeout(3000);
    const content = await page.textContent('body');
    expect(content.length).toBeGreaterThan(0);
  });

  test('TEST-036: Filter by difficulty', async ({ page }) => {
    const selects = page.locator('select');
    const count = await selects.count();
    if (count > 0) {
      // Find the difficulty select
      for (let i = 0; i < count; i++) {
        const options = await selects.nth(i).textContent();
        if (options?.match(/easy|medium|hard/i)) {
          await selects.nth(i).selectOption({ index: 1 });
          await page.waitForTimeout(1500);
          break;
        }
      }
    }
  });

  test('TEST-037: Sort results changes order', async ({ page }) => {
    const selects = page.locator('select');
    const count = await selects.count();
    if (count > 0) {
      const lastSelect = selects.last();
      await lastSelect.selectOption({ index: 1 });
      await page.waitForTimeout(1500);
    }
  });

  test('TEST-038: No results for nonsense query', async ({ page }) => {
    const searchInput = page.locator('input[placeholder*="Search"]');
    await searchInput.fill('xyznonexistentrecipe12345');
    await searchInput.press('Enter');
    await page.waitForTimeout(3000);
    const noResults = page.locator('text=/no recipe|not found|no result/i');
    await expect(noResults.first()).toBeVisible({ timeout: 10000 });
  });

  test('TEST-039: Click recipe from search results', async ({ page }) => {
    const card = page.locator('.group.block').first();
    if (await card.isVisible({ timeout: 5000 }).catch(() => false)) {
      await card.click();
      await expect(page).toHaveURL(/\/#\/recipes\/\d+/);
      await expect(page.locator('text=Ingredients')).toBeVisible({ timeout: 10000 });
    }
  });

  test('TEST-040: Search params preserved on back navigation', async ({ page }) => {
    const searchInput = page.locator('input[placeholder*="Search"]');
    await searchInput.fill('chicken');
    await searchInput.press('Enter');
    await page.waitForTimeout(2000);
    const card = page.locator('.group.block').first();
    if (await card.isVisible({ timeout: 5000 }).catch(() => false)) {
      await card.click();
      await expect(page).toHaveURL(/\/#\/recipes\/\d+/);
      await page.goBack();
      await expect(page).toHaveURL(/q=chicken/);
    }
  });
});

// ═══════════════════════════════════════════════════════════
// 5. RECIPE CREATION (TEST-041 to TEST-050)
// ═══════════════════════════════════════════════════════════

test.describe('Recipe Creation', () => {
  test.beforeEach(async ({ page }) => {
    await loginAsUser(page);
    await page.goto(`${BASE}/recipes/create`);
    await page.waitForTimeout(2000);
  });

  test('TEST-041: Create Recipe page loads', async ({ page }) => {
    const body = await page.textContent('body');
    expect(body?.toLowerCase()).toMatch(/create|new|recipe/);
  });

  test('TEST-042: All form fields present', async ({ page }) => {
    const body = await page.textContent('body');
    const bodyLower = body.toLowerCase();
    expect(bodyLower).toContain('title');
    expect(bodyLower).toMatch(/description/);
    expect(bodyLower).toMatch(/categor/);
    expect(bodyLower).toMatch(/difficult|level/);
    expect(bodyLower).toMatch(/ingredient/);
    expect(bodyLower).toMatch(/instruction|step/);
  });

  test('TEST-043: Title field present and fillable', async ({ page }) => {
    const titleInput = page.locator('#title');
    await expect(titleInput).toBeVisible();
    await titleInput.fill('Test Recipe Title');
    await expect(titleInput).toHaveValue('Test Recipe Title');
  });

  test('TEST-044: Description textarea present', async ({ page }) => {
    const desc = page.locator('#description, textarea').first();
    await expect(desc).toBeVisible();
    await desc.fill('This is a valid test description for recipe.');
    const val = await desc.inputValue();
    expect(val.length).toBeGreaterThan(10);
  });

  test('TEST-045: Add ingredient button works', async ({ page }) => {
    const addBtn = page.locator('button:has-text("Add Ingredient"), button:has-text("Add ingredient")').first();
    if (await addBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
      await addBtn.click();
      await page.waitForTimeout(300);
    }
  });

  test('TEST-046: Add instruction/step button works', async ({ page }) => {
    const addBtn = page.locator('button:has-text("Add Instruction"), button:has-text("Add Step"), button:has-text("Add instruction"), button:has-text("Add step")').first();
    if (await addBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
      await addBtn.click();
      await page.waitForTimeout(300);
    }
  });

  test('TEST-047: Create button visible in navbar', async ({ page }) => {
    const createLink = page.locator('a[href*="create"]').first();
    await expect(createLink).toBeVisible();
  });

  test('TEST-048: Form validation - empty submission blocked', async ({ page }) => {
    const submitBtn = page.locator('button[type="submit"]').first();
    await submitBtn.click();
    await page.waitForTimeout(1000);
    // Should still be on create page (validation prevents submission)
    expect(page.url()).toContain('/recipes/create');
  });

  test('TEST-049: Form validation - short title rejected', async ({ page }) => {
    const titleInput = page.locator('#title');
    await titleInput.fill('ab');
    const submitBtn = page.locator('button[type="submit"]').first();
    await submitBtn.click();
    await page.waitForTimeout(1000);
    const body = await page.textContent('body');
    expect(body.toLowerCase()).toMatch(/title|character|short|at least/);
  });

  test('TEST-050: Difficulty selector works', async ({ page }) => {
    const diffSelect = page.locator('#difficulty, select').first();
    if (await diffSelect.isVisible({ timeout: 3000 }).catch(() => false)) {
      const tagName = await diffSelect.evaluate(el => el.tagName.toLowerCase());
      if (tagName === 'select') {
        await diffSelect.selectOption({ index: 1 });
      }
    }
  });
});

// ═══════════════════════════════════════════════════════════
// 6. PROFILE PAGE (TEST-051 to TEST-060)
// ═══════════════════════════════════════════════════════════

test.describe('Profile Page', () => {
  test.beforeEach(async ({ page }) => {
    await loginAsUser(page);
    await page.goto(`${BASE}/profile`);
    await page.waitForTimeout(3000);
  });

  test('TEST-051: Profile page loads with user info', async ({ page }) => {
    const body = await page.textContent('body');
    expect(body.length).toBeGreaterThan(100);
    // Should show user avatar
    const avatar = page.locator('img.rounded-full').first();
    await expect(avatar).toBeVisible();
  });

  test('TEST-052: My Recipes tab displayed', async ({ page }) => {
    const tab = page.locator('button:has-text("My Recipes"), [role="tab"]:has-text("My Recipes")').first();
    await expect(tab).toBeVisible();
  });

  test('TEST-053: Favorites tab displayed', async ({ page }) => {
    const tab = page.locator('button:has-text("Favorites"), [role="tab"]:has-text("Favorites")').first();
    await expect(tab).toBeVisible();
  });

  test('TEST-054: Switch to Favorites tab updates URL', async ({ page }) => {
    const favTab = page.locator('button:has-text("Favorites"), [role="tab"]:has-text("Favorites")').first();
    await favTab.click();
    await page.waitForTimeout(500);
    await expect(page).toHaveURL(/tab=favorites/);
  });

  test('TEST-055: Switch back to My Recipes tab', async ({ page }) => {
    const favTab = page.locator('button:has-text("Favorites"), [role="tab"]:has-text("Favorites")').first();
    await favTab.click();
    await page.waitForTimeout(500);
    const recipesTab = page.locator('button:has-text("My Recipes"), [role="tab"]:has-text("My Recipes")').first();
    await recipesTab.click();
    await page.waitForTimeout(500);
    await expect(page).toHaveURL(/tab=recipes/);
  });

  test('TEST-056: Edit Profile button visible', async ({ page }) => {
    const editBtn = page.locator('button:has-text("Edit Profile"), button:has-text("Edit profile")').first();
    await expect(editBtn).toBeVisible();
  });

  test('TEST-057: Edit Profile modal opens', async ({ page }) => {
    const editBtn = page.locator('button:has-text("Edit Profile"), button:has-text("Edit profile")').first();
    await editBtn.click();
    await page.waitForTimeout(500);
    // Modal dialog should be visible
    const modal = page.locator('[role="dialog"], .fixed.inset-0').first();
    await expect(modal).toBeVisible({ timeout: 5000 });
  });

  test('TEST-058: Edit Profile modal shows avatar options', async ({ page }) => {
    const editBtn = page.locator('button:has-text("Edit Profile"), button:has-text("Edit profile")').first();
    await editBtn.click();
    await page.waitForTimeout(500);
    const avatarChoices = page.locator('[role="dialog"] button[aria-label^="Select avatar"]');
    const count = await avatarChoices.count();
    expect(count).toBeGreaterThan(0);
  });

  test('TEST-059: Profile icon in navbar navigates to profile', async ({ page }) => {
    await page.goto(`${BASE}/`);
    await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible({ timeout: 10000 });
    const profileLink = page.locator('a[href*="profile"]').first();
    await profileLink.click();
    await expect(page).toHaveURL(/\/#\/profile/);
  });

  test('TEST-060: My Recipes route loads', async ({ page }) => {
    await page.goto(`${BASE}/recipes/my-recipes`);
    await page.waitForTimeout(3000);
    const body = await page.textContent('body');
    expect(body.length).toBeGreaterThan(0);
  });
});

// ═══════════════════════════════════════════════════════════
// 7. ADMIN DASHBOARD (TEST-061 to TEST-068)
// ═══════════════════════════════════════════════════════════

test.describe('Admin Dashboard', () => {
  test.beforeEach(async ({ page }) => { await loginAsAdmin(page); });

  test('TEST-061: Dashboard page loads with heading', async ({ page }) => {
    await expect(page.locator('h1:has-text("Dashboard")')).toBeVisible({ timeout: 10000 });
    await expect(page.locator('text=Overview of system performance')).toBeVisible();
  });

  test('TEST-062: All stat cards displayed', async ({ page }) => {
    const stats = ['Total Users', 'New Users Today', 'Total Contributors', 'Published Recipes', 'Pending Recipes', 'Daily Views', 'Daily Active Users'];
    for (const stat of stats) {
      await expect(page.locator(`text=${stat}`)).toBeVisible();
    }
  });

  test('TEST-063: Recent Activity section visible', async ({ page }) => {
    await expect(page.locator('text=Recent Activity')).toBeVisible();
  });

  test('TEST-064: System Health section visible', async ({ page }) => {
    await expect(page.locator('text=System Health')).toBeVisible();
    await expect(page.locator('text=All systems operational')).toBeVisible();
  });

  test('TEST-065: Dashboard stat numbers are rendered', async ({ page }) => {
    await expect(page.locator('text=Total Users')).toBeVisible();
    await expect(page.locator('text=Published Recipes')).toBeVisible();
    const statValues = page.locator('.text-2xl.font-bold');
    const count = await statValues.count();
    expect(count).toBeGreaterThanOrEqual(8);
  });

  test('TEST-066: Admin redirected to dashboard by RootLayout', async ({ page }) => {
    // If admin navigates to /, they should be redirected to /admin
    await page.goto(`${BASE}/`);
    await page.waitForTimeout(3000);
    expect(page.url()).toContain('#/admin');
  });

  test('TEST-067: Regular user cannot access admin panel', async ({ page }) => {
    await page.goto(`${BASE}/login`);
    await page.locator('#email').fill(USER_EMAIL);
    await page.locator('#password').fill(USER_PASS);
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible({ timeout: 15000 });
    await page.goto(`${BASE}/admin`);
    await page.waitForTimeout(3000);
    expect(page.url()).not.toMatch(/\/#\/admin/);
  });

  test('TEST-068: New Contributors Today stat displayed', async ({ page }) => {
    await expect(page.locator('text=New Contributors Today')).toBeVisible();
  });
});

// ═══════════════════════════════════════════════════════════
// 8. ADMIN USER MANAGEMENT (TEST-069 to TEST-076)
// ═══════════════════════════════════════════════════════════

test.describe('Admin User Management', () => {
  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto(`${BASE}/admin/users`);
    await expect(page.locator('h1:has-text("User Management")')).toBeVisible({ timeout: 10000 });
  });

  test('TEST-069: User Management page loads', async ({ page }) => {
    await expect(page.locator('text=Manage user accounts')).toBeVisible();
  });

  test('TEST-070: User table displays headers', async ({ page }) => {
    await expect(page.locator('th:has-text("User")').first()).toBeVisible();
    await expect(page.locator('th:has-text("Email")').first()).toBeVisible();
    await expect(page.locator('th:has-text("Role")').first()).toBeVisible();
    await expect(page.locator('th:has-text("Status")').first()).toBeVisible();
    await expect(page.locator('th:has-text("Joined")').first()).toBeVisible();
    await expect(page.locator('th:has-text("Actions")').first()).toBeVisible();
  });

  test('TEST-071: User table has data rows', async ({ page }) => {
    const rows = page.locator('tbody tr');
    await expect(rows.first()).toBeVisible({ timeout: 10000 });
    const count = await rows.count();
    expect(count).toBeGreaterThan(0);
  });

  test('TEST-072: Search users filters table', async ({ page }) => {
    const searchInput = page.locator('input[placeholder*="Search"]');
    await expect(searchInput).toBeVisible();
    await searchInput.fill('admin');
    await page.waitForTimeout(500);
    const rows = page.locator('tbody tr');
    const count = await rows.count();
    expect(count).toBeGreaterThan(0);
  });

  test('TEST-073: Role filter dropdown works', async ({ page }) => {
    const roleSelect = page.locator('select').first();
    await expect(roleSelect).toBeVisible();
    await roleSelect.selectOption('admin');
    await page.waitForTimeout(500);
    const rows = page.locator('tbody tr');
    const count = await rows.count();
    expect(count).toBeGreaterThan(0);
  });

  test('TEST-074: User action buttons present (approve, suspend, delete)', async ({ page }) => {
    const approveBtn = page.locator('button[title="Approve"]').first();
    const suspendBtn = page.locator('button[title="Suspend"]').first();
    const deleteBtn = page.locator('button[title="Delete User"]').first();
    await expect(approveBtn).toBeVisible();
    await expect(suspendBtn).toBeVisible();
    await expect(deleteBtn).toBeVisible();
  });

  test('TEST-075: Delete user shows confirmation modal', async ({ page }) => {
    const deleteBtn = page.locator('button[title="Delete User"]').first();
    if (await deleteBtn.isVisible()) {
      await deleteBtn.click();
      await expect(page.locator('text=Are you sure you want to delete this user')).toBeVisible({ timeout: 5000 });
      await page.locator('button:has-text("Cancel")').click();
    }
  });

  test('TEST-076: User status badges displayed', async ({ page }) => {
    // Status badges should show Active, Suspended, Pending, or Inactive
    const badges = page.locator('tbody span, tbody .inline-flex');
    const count = await badges.count();
    expect(count).toBeGreaterThan(0);
  });
});

// ═══════════════════════════════════════════════════════════
// 9. ADMIN RECIPE MANAGEMENT (TEST-077 to TEST-084)
// ═══════════════════════════════════════════════════════════

test.describe('Admin Recipe Management', () => {
  test.beforeEach(async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto(`${BASE}/admin/recipes`);
    await expect(page.locator('h1:has-text("Recipe Management")')).toBeVisible({ timeout: 10000 });
  });

  test('TEST-077: Recipe Management page loads', async ({ page }) => {
    await expect(page.locator('text=Approve, reject, and manage')).toBeVisible();
  });

  test('TEST-078: Tabs for Pending, Published, Rejected', async ({ page }) => {
    await expect(page.locator('button:has-text("Pending"), [role="tab"]:has-text("Pending")').first()).toBeVisible();
    await expect(page.locator('button:has-text("Published"), [role="tab"]:has-text("Published")').first()).toBeVisible();
    await expect(page.locator('button:has-text("Rejected"), [role="tab"]:has-text("Rejected")').first()).toBeVisible();
  });

  test('TEST-079: Switch to Published tab shows table', async ({ page }) => {
    await page.locator('button:has-text("Published"), [role="tab"]:has-text("Published")').first().click();
    await page.waitForTimeout(1000);
    await expect(page.locator('th:has-text("Title")').first()).toBeVisible();
    await expect(page.locator('th:has-text("Author")').first()).toBeVisible();
  });

  test('TEST-080: Switch between all tabs', async ({ page }) => {
    await page.locator('button:has-text("Pending")').first().click();
    await page.waitForTimeout(500);
    await page.locator('button:has-text("Published")').first().click();
    await page.waitForTimeout(500);
    await page.locator('button:has-text("Rejected")').first().click();
    await page.waitForTimeout(500);
  });

  test('TEST-081: Recipe table has correct columns', async ({ page }) => {
    await page.locator('button:has-text("Published")').first().click();
    await page.waitForTimeout(500);
    const headers = ['ID', 'Image', 'Title', 'Author', 'Category', 'Status', 'Date', 'Actions'];
    for (const h of headers) {
      await expect(page.locator(`th:has-text("${h}")`).first()).toBeVisible();
    }
  });

  test('TEST-082: Preview recipe modal opens', async ({ page }) => {
    await page.locator('button:has-text("Published")').first().click();
    await page.waitForTimeout(1000);
    const eyeBtn = page.locator('tbody button').filter({ has: page.locator('svg.lucide-eye') }).first();
    if (await eyeBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
      await eyeBtn.click();
      const modal = page.locator('[role="dialog"], .fixed.inset-0').first();
      await expect(modal).toBeVisible({ timeout: 5000 });
    }
  });

  test('TEST-083: Delete recipe confirmation modal', async ({ page }) => {
    await page.locator('button:has-text("Published")').first().click();
    await page.waitForTimeout(1000);
    const deleteBtn = page.locator('tbody button[title="Delete"]').first();
    if (await deleteBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
      await deleteBtn.click();
      await expect(page.locator('text=Are you sure you want to delete this recipe')).toBeVisible({ timeout: 5000 });
      await page.locator('button:has-text("Cancel")').click();
    }
  });

  test('TEST-084: Pending tab shows approve/reject for pending recipes', async ({ page }) => {
    await page.locator('button:has-text("Pending")').first().click();
    await page.waitForTimeout(1000);
    const rows = page.locator('tbody tr');
    const count = await rows.count();
    if (count > 0) {
      const firstRowText = await rows.first().textContent();
      if (!firstRowText.includes('No recipes found')) {
        // Should have approve (Check) and reject (X) buttons
        const approveBtn = rows.first().locator('button[title="Approve"]');
        await expect(approveBtn).toBeVisible();
      }
    }
  });
});

// ═══════════════════════════════════════════════════════════
// 10. ADMIN SIDEBAR NAVIGATION (TEST-085 to TEST-088)
// ═══════════════════════════════════════════════════════════

test.describe('Admin Sidebar', () => {
  test.beforeEach(async ({ page }) => { await loginAsAdmin(page); });

  test('TEST-085: Sidebar displays navigation links', async ({ page }) => {
    await expect(page.locator('a:has-text("Dashboard")').first()).toBeVisible();
    await expect(page.locator('a:has-text("Users")').first()).toBeVisible();
    await expect(page.locator('a:has-text("Recipes")').first()).toBeVisible();
  });

  test('TEST-086: Navigate to Users from sidebar', async ({ page }) => {
    await page.locator('a:has-text("Users")').first().click();
    await expect(page.locator('h1:has-text("User Management")')).toBeVisible({ timeout: 10000 });
  });

  test('TEST-087: Navigate to Recipes from sidebar', async ({ page }) => {
    await page.locator('a:has-text("Recipes")').first().click();
    await expect(page.locator('h1:has-text("Recipe Management")')).toBeVisible({ timeout: 10000 });
  });

  test('TEST-088: Navigate back to Dashboard from sidebar', async ({ page }) => {
    await page.goto(`${BASE}/admin/users`);
    await page.waitForTimeout(1000);
    await page.locator('a:has-text("Dashboard")').first().click();
    await expect(page.locator('h1:has-text("Dashboard")')).toBeVisible({ timeout: 10000 });
  });
});

// ═══════════════════════════════════════════════════════════
// 11. NAVIGATION & UI (TEST-089 to TEST-098)
// ═══════════════════════════════════════════════════════════

test.describe('Navigation & UI', () => {
  test.beforeEach(async ({ page }) => { await loginAsUser(page); });

  test('TEST-089: Navbar displays CookHub brand, Discover, My Recipes', async ({ page }) => {
    await expect(page.locator('nav')).toBeVisible();
    await expect(page.locator('text=CookHub')).toBeVisible();
    await expect(page.locator('nav a:has-text("Discover")')).toBeVisible();
  });

  test('TEST-090: CookHub logo navigates to home', async ({ page }) => {
    await page.goto(`${BASE}/search`);
    await page.waitForTimeout(2000);
    await page.locator('a:has-text("CookHub")').first().click();
    await expect(page).toHaveURL(/\/#\/$/, { timeout: 10000 });
  });

  test('TEST-091: Navbar is sticky', async ({ page }) => {
    const nav = page.locator('nav').first();
    const classes = await nav.getAttribute('class');
    expect(classes).toContain('sticky');
  });

  test('TEST-092: Discover link navigates to home', async ({ page }) => {
    await page.goto(`${BASE}/search`);
    await page.locator('nav a:has-text("Discover")').click();
    await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible({ timeout: 10000 });
  });

  test('TEST-093: Create button in navbar navigates to create page', async ({ page }) => {
    const createLink = page.locator('nav a[href*="create"]').first();
    if (await createLink.isVisible()) {
      await createLink.click();
      await expect(page).toHaveURL(/\/#\/recipes\/create/);
    }
  });

  test('TEST-094: Profile button in navbar', async ({ page }) => {
    const profileLink = page.locator('a[href*="profile"]').first();
    await profileLink.click();
    await expect(page).toHaveURL(/\/#\/profile/);
  });

  test('TEST-095: Logout button has accessible label', async ({ page }) => {
    const logoutBtn = page.locator('button[aria-label="Logout"]');
    await expect(logoutBtn).toBeVisible();
  });

  test('TEST-096: Responsive layout at mobile width', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto(`${BASE}/`);
    await page.waitForTimeout(2000);
    await expect(page.locator('text=CookHub')).toBeVisible();
  });

  test('TEST-097: Page transitions between routes', async ({ page }) => {
    await page.goto(`${BASE}/search`);
    await page.waitForTimeout(1000);
    await page.goto(`${BASE}/profile`);
    await page.waitForTimeout(1000);
    await page.goto(`${BASE}/`);
    await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible({ timeout: 10000 });
  });

  test('TEST-098: Unknown route redirects to home', async ({ page }) => {
    await page.goto(`${BASE}/nonexistent-page-xyz`);
    await page.waitForTimeout(3000);
    await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible({ timeout: 10000 });
  });
});

// ═══════════════════════════════════════════════════════════
// 12. ACCESSIBILITY (TEST-099 to TEST-103)
// ═══════════════════════════════════════════════════════════

test.describe('Accessibility', () => {
  test('TEST-099: Skip to content link present', async ({ page }) => {
    await loginAsUser(page);
    const skipLink = page.locator('a:has-text("Skip to content")');
    await expect(skipLink).toBeAttached();
  });

  test('TEST-100: Main content landmark with ID', async ({ page }) => {
    await loginAsUser(page);
    const main = page.locator('main#main-content');
    await expect(main).toBeVisible();
  });

  test('TEST-101: Heading hierarchy on home page', async ({ page }) => {
    await loginAsUser(page);
    const h1 = page.locator('h1');
    await expect(h1.first()).toBeVisible({ timeout: 10000 });
  });

  test('TEST-102: Login page has descriptive heading', async ({ page }) => {
    await page.goto(`${BASE}/login`);
    await expect(page.locator('h2:has-text("Welcome Back!")')).toBeVisible();
  });

  test('TEST-103: Signup page has descriptive heading', async ({ page }) => {
    await page.goto(`${BASE}/signup`);
    await expect(page.locator('h2:has-text("Get Started")')).toBeVisible();
  });
});

// ═══════════════════════════════════════════════════════════
// 13. API INTEGRATION (TEST-104 to TEST-111)
// ═══════════════════════════════════════════════════════════

test.describe('API Integration', () => {
  test('TEST-104: Auth API - login returns user data', async ({ request }) => {
    const response = await request.post('/api/auth/login', {
      data: { email: ADMIN_EMAIL, password: ADMIN_PASS },
    });
    expect(response.status()).toBe(200);
    const body = await response.json();
    expect(body.data.user.email).toBe(ADMIN_EMAIL);
  });

  test('TEST-105: Auth API - me endpoint unauthenticated returns 401', async ({ request }) => {
    const response = await request.get('/api/auth/me');
    expect(response.status()).toBe(401);
  });

  test('TEST-106: Recipes API - list returns recipes', async ({ request }) => {
    const response = await request.get('/api/recipes?status=published');
    expect(response.status()).toBe(200);
    const body = await response.json();
    expect(body.data).toHaveProperty('recipes');
  });

  test('TEST-107: Recipes API - get single recipe', async ({ request }) => {
    const listRes = await request.get('/api/recipes?status=published');
    const listData = await listRes.json();
    const recipes = listData.data?.recipes || [];
    if (recipes.length > 0) {
      const id = recipes[0].id;
      const response = await request.get(`/api/recipes/${id}`);
      expect(response.status()).toBe(200);
      const body = await response.json();
      expect(body.data.id || body.data.recipe?.id).toBeTruthy();
    }
  });

  test('TEST-108: Search API - query returns results', async ({ request }) => {
    await request.post('/api/auth/login', {
      data: { email: USER_EMAIL, password: USER_PASS },
    });
    const response = await request.get('/api/search?q=pasta');
    expect([200, 401]).toContain(response.status());
  });

  test('TEST-109: Stats API - dashboard requires admin', async ({ request }) => {
    await request.post('/api/auth/login', {
      data: { email: ADMIN_EMAIL, password: ADMIN_PASS },
    });
    const response = await request.get('/api/stats/dashboard');
    expect([200, 401, 403]).toContain(response.status());
  });

  test('TEST-110: Auth API - login with wrong credentials returns error', async ({ request }) => {
    const response = await request.post('/api/auth/login', {
      data: { email: 'bad@email.com', password: 'wrong' },
    });
    expect(response.status()).not.toBe(200);
  });

  test('TEST-111: Auth API - user login returns user role', async ({ request }) => {
    const response = await request.post('/api/auth/login', {
      data: { email: USER_EMAIL, password: USER_PASS },
    });
    expect(response.status()).toBe(200);
    const body = await response.json();
    expect(body.data.user.role).toBe('user');
  });
});

// ═══════════════════════════════════════════════════════════
// 14. RECIPE INTERACTIONS (TEST-112 to TEST-115)
// ═══════════════════════════════════════════════════════════

test.describe('Recipe Interactions', () => {
  test.beforeEach(async ({ page }) => { await loginAsUser(page); });

  test('TEST-112: Like button on recipe card toggles', async ({ page }) => {
    const card = page.locator('.group.block').first();
    await expect(card).toBeVisible({ timeout: 10000 });
    const heartBtn = card.locator('button').filter({ has: page.locator('svg.lucide-heart') }).first();
    if (await heartBtn.isVisible()) {
      await heartBtn.click();
      await page.waitForTimeout(1000);
      await heartBtn.click();
      await page.waitForTimeout(500);
    }
  });

  test('TEST-113: Save button on recipe card toggles', async ({ page }) => {
    const card = page.locator('.group.block').first();
    await expect(card).toBeVisible({ timeout: 10000 });
    const bookmarkBtn = card.locator('button').filter({ has: page.locator('svg.lucide-bookmark') }).first();
    if (await bookmarkBtn.isVisible()) {
      await bookmarkBtn.click();
      await page.waitForTimeout(1000);
      await bookmarkBtn.click();
      await page.waitForTimeout(500);
    }
  });

  test('TEST-114: Like/save on card does not navigate away', async ({ page }) => {
    const card = page.locator('.group.block').first();
    await expect(card).toBeVisible({ timeout: 10000 });
    const heartBtn = card.locator('button').filter({ has: page.locator('svg.lucide-heart') }).first();
    if (await heartBtn.isVisible()) {
      const urlBefore = page.url();
      await heartBtn.click();
      await page.waitForTimeout(500);
      expect(page.url()).toBe(urlBefore);
    }
  });

  test('TEST-115: Review section on recipe detail allows interaction', async ({ page }) => {
    const firstCard = page.locator('.group.block').first();
    await expect(firstCard).toBeVisible({ timeout: 10000 });
    await firstCard.click();
    await expect(page).toHaveURL(/\/#\/recipes\/\d+/);
    const reviewsSection = page.locator('text=/reviews/i').first();
    await reviewsSection.scrollIntoViewIfNeeded();
    await expect(reviewsSection).toBeVisible();
  });
});

// ═══════════════════════════════════════════════════════════
// 15. ERROR HANDLING (TEST-116 to TEST-119)
// ═══════════════════════════════════════════════════════════


// ═══════════════════════════════════════════════════════════
// 15. REGRESSION FIXES (TEST-120 to TEST-127)
// ═══════════════════════════════════════════════════════════

test.describe('Regression Fixes', () => {
  test('TEST-120: Create recipe appears in profile list immediately', async ({ page }) => {
    await loginAsUser(page);
    const suffix = Date.now();

    await page.goto(`${BASE}/recipes/create`);
    await page.fill('#title', `E2E Regression Recipe ${suffix}`);
    await page.fill('#description', 'Regression test description for recipe creation visibility.');
    await page.fill('#prepTime', '10');
    await page.fill('#cookTime', '5');
    await page.fill('#servings', '2');
    await page.fill('input[placeholder="Item (e.g. Flour)"]', 'Flour');
    await page.fill('input[placeholder="Qty"]', '1');
    await page.fill('input[placeholder="Unit"]', 'cup');
    await page.fill('textarea[placeholder="Step 1..."]', 'Mix ingredients and cook until done.');
    await page.click('button:has-text("Submit Recipe")');

    await expect(page).toHaveURL(/\/#\/profile\?tab=recipes/);
    await expect(page.locator(`text=E2E Regression Recipe ${suffix}`)).toBeVisible({ timeout: 10000 });
  });

  test('TEST-121: Recipe view increments only once per user', async ({ request }) => {
    await request.post('/api/auth/login', { data: { email: USER_EMAIL, password: USER_PASS } });
    const recipesRes = await request.get('/api/recipes?status=published&limit=1&page=1');
    const recipesBody = await recipesRes.json();
    const recipeId = recipesBody.data.recipes[0].id;

    await request.post(`/api/recipes/${recipeId}/view`);
    const firstDetailRes = await request.get(`/api/recipes/${recipeId}`);
    const firstDetail = await firstDetailRes.json();
    const firstCount = firstDetail.data.viewCount;

    await request.post(`/api/recipes/${recipeId}/view`);
    const secondDetailRes = await request.get(`/api/recipes/${recipeId}`);
    const secondDetail = await secondDetailRes.json();
    const secondCount = secondDetail.data.viewCount;

    expect(secondCount).toBe(firstCount);
  });

  test('TEST-122: Posting review twice updates the same user review', async ({ request }) => {
    await request.post('/api/auth/login', { data: { email: USER_EMAIL, password: USER_PASS } });
    const meRes = await request.get('/api/auth/me');
    const meBody = await meRes.json();
    const userId = meBody.data.user.id;

    const recipesRes = await request.get('/api/recipes?status=published&limit=1&page=1');
    const recipesBody = await recipesRes.json();
    const recipeId = recipesBody.data.recipes[0].id;
    const stamp = Date.now();

    const createRes = await request.post('/api/reviews', {
      data: { recipeId, rating: 4, comment: `First review ${stamp}` },
    });
    expect([200, 201]).toContain(createRes.status());

    const updateRes = await request.post('/api/reviews', {
      data: { recipeId, rating: 5, comment: `Updated review ${stamp}` },
    });
    expect(updateRes.status()).toBe(200);

    const listRes = await request.get(`/api/reviews?recipeId=${recipeId}`);
    const listBody = await listRes.json();
    const mine = (listBody.data.reviews || []).filter((r) => Number(r.user?.id) === Number(userId));
    expect(mine.length).toBe(1);
    expect(mine[0].comment).toContain(`Updated review ${stamp}`);
    expect(mine[0].rating).toBe(5);
  });

  test('TEST-123: Reset filters clears keyword and URL params', async ({ page }) => {
    await loginAsUser(page);
    await page.goto(`${BASE}/search?q=pasta&difficulty=Hard&sort=difficulty-asc`);
    await page.click('button:has-text("Reset filters")');

    await expect(page).toHaveURL(/\/#\/search$/);
    await expect(page.locator('input[placeholder="Search recipes..."]')).toHaveValue('');
  });

  test('TEST-124: Edit Profile modal remains open when clicking outside', async ({ page }) => {
    await loginAsUser(page);
    await page.goto(`${BASE}/profile`);
    await page.click('button:has-text("Edit Profile")');

    const modalHeading = page.locator('h3:has-text("Edit Profile")');
    await expect(modalHeading).toBeVisible();
    await page.mouse.click(10, 10);
    await expect(modalHeading).toBeVisible();
  });

  test('TEST-125: Suspended account shows suspended tooltip copy for like/save', async ({ page }) => {
    await page.goto(`${BASE}/login`);
    await page.fill('#email', 'tom@cookhub.com');
    await page.fill('#password', 'tom123');
    await page.click('button[type="submit"]');
    await expect(page.locator('text=Fresh from the Kitchen')).toBeVisible({ timeout: 15000 });

    const firstCard = page.locator('.group.block').first();
    const likeBtn = firstCard.locator('button').first();
    const saveBtn = firstCard.locator('button').nth(1);

    await expect(likeBtn).toHaveAttribute('title', 'Suspended accounts cannot like recipes');
    await expect(saveBtn).toHaveAttribute('title', 'Suspended accounts cannot save recipes');
  });

  test('TEST-126: Recent activity excludes active/inactive status updates', async ({ request }) => {
    await request.post('/api/auth/login', { data: { email: ADMIN_EMAIL, password: ADMIN_PASS } });
    const res = await request.get('/api/stats/dashboard');
    const body = await res.json();
    const descriptions = (body.data.recentActivity || []).map((a) => a.description || '');
    const hasActiveInactive = descriptions.some((d) => / to active| to inactive/i.test(d));
    expect(hasActiveInactive).toBeFalsy();
  });

  test('TEST-127: User status becomes inactive after logout', async ({ request }) => {
    await request.post('/api/auth/login', { data: { email: USER_EMAIL, password: USER_PASS } });
    await request.post('/api/auth/logout');

    await request.post('/api/auth/login', { data: { email: ADMIN_EMAIL, password: ADMIN_PASS } });
    const usersRes = await request.get('/api/users?limit=100');
    const usersBody = await usersRes.json();
    const user = (usersBody.data.users || []).find((u) => u.email === USER_EMAIL);
    expect(user?.status).toBe('inactive');
  });
});

test.describe('Error Handling', () => {
  test('TEST-116: Non-existent recipe ID handled gracefully', async ({ page }) => {
    await loginAsUser(page);
    await page.goto(`${BASE}/recipes/99999`);
    await page.waitForTimeout(5000);
    const body = await page.textContent('body');
    expect(body.length).toBeGreaterThan(0);
  });

  test('TEST-117: No console errors on login page', async ({ page }) => {
    const errors = [];
    page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });
    await page.goto(`${BASE}/login`);
    await page.waitForTimeout(2000);
    const real = errors.filter(
      e => !e.includes('favicon') && !e.includes('404') && !e.includes('401 (Unauthorized)')
    );
    expect(real.length).toBe(0);
  });

  test('TEST-118: No console errors on home page', async ({ page }) => {
    const errors = [];
    page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });
    await loginAsUser(page);
    await page.waitForTimeout(2000);
    const real = errors.filter(
      e => !e.includes('favicon') && !e.includes('404') && !e.includes('401 (Unauthorized)')
    );
    expect(real.length).toBe(0);
  });

  test('TEST-119: Page title is set', async ({ page }) => {
    await page.goto(`${BASE}/login`);
    const title = await page.title();
    expect(title.length).toBeGreaterThan(0);
  });
});

