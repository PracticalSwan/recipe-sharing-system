# CookHub Live Browser Testing Results

## Date
Session completed with comprehensive Chrome DevTools live testing.

## Test Accounts
- **Regular User**: user@cookhub.com / user (John Doe, user ID 4)
- **Admin**: admin@cookhub.com / admin

---

## Test Results Summary

### 1. Auth Flow - PASSED
- Login with valid credentials → redirects to home
- Login with wrong credentials → "Invalid credentials" error
- Empty field validation (HTML5 required attributes)
- Signup form → creates account with "pending" status
- Pending account restrictions (cannot like, save, review)
- Logout → redirects to login

### 2. Home Page - PASSED
- Recipe cards display with image, title, author, ratings, cook time, difficulty
- Like toggle on cards (count updates)
- Save/favorite toggle on cards
- Search bar navigates to /search with query
- "View All" button navigates to /search

### 3. Search & Filters - PASSED
- Keyword search ("curry" returns Thai Green Curry)
- Clear search button
- Difficulty filter (Easy/Medium/Hard)
- Category filter (multi-select checkboxes)
- Combined filters work correctly
- Reset filters clears all
- Sort options: Most Popular, Newest First, Difficulty Low to High
- Recent search history buttons
- Clear History button

### 4. Recipe Detail Page - PASSED
- Hero image, category badge, date, title
- Author link with avatar (navigates to /users/:id)
- Star rating display
- Cook time, difficulty display
- Description text
- Like/unlike toggle with count
- Save/unsave toggle
- View count with correct singular/plural ("1 view" vs "X views")
- Ingredients with interactive checkboxes + Reset button
- Numbered instructions
- Reviews section
- Edit/Delete buttons for own recipes only

### 5. Ratings & Reviews - PASSED
- Update existing review (change rating + text)
- Submit new review on a recipe without user's review
- Review count updates after submission
- Delete review with confirmation modal
- Review count updates after deletion

### 6. Create Recipe - PASSED
- Full form: title, description, categories (multi-select), ingredients (add/remove), instructions (add/remove), difficulty, prep time, cook time, servings
- Submit → creates recipe with "pending" status
- Redirects to /profile?tab=recipes showing new recipe

### 7. Edit Recipe - PASSED
- Pre-populated form with existing data
- Can edit title, remove ingredients
- Update → redirects to profile with updated data

### 8. Delete Recipe - PASSED
- Confirmation modal with warning text
- Confirm → recipe removed from list, count updated

### 9. Profile & Edit Profile - PASSED
- Profile shows avatar, name, badge, bio, location, joined date
- My Recipes tab shows user's recipes with status badges
- Favorites tab shows favorited recipes
- Edit Profile modal: avatar selector (6 presets + custom URL), form fields
- Save updates profile correctly
- Favorites preserved after profile edit (BUG FIXED - see below)

### 10. Favorites Flow - PASSED
- Unsave from favorites tab → removed, count decreases
- Re-save from recipe detail → appears in favorites, count increases

### 11. Admin Dashboard - PASSED
- Stats cards: Total Users, New Users Today, Contributors, Published Recipes, Pending Recipes, Daily Views, DAU
- Activity feed with timestamps
- System Health indicator

### 12. Admin User Management - PASSED
- User table with search filter and role filter
- Search by name filters correctly
- Approve pending user → status Active
- Suspend user → status Suspended

### 13. Admin Recipe Management - PASSED
- Pending tab shows pending recipes
- Approve → moves to Published tab
- Reject → moves to Rejected tab
- Delete → confirmation modal → recipe removed permanently

### 14. Edge Cases & Security - PASSED
- Route protection: unauthenticated users redirected to /login
- Role-based access: regular users can't access /admin routes
- XSS: `<script>alert('xss')</script>` rendered as text (React JSX escaping)
- SQL injection: `' OR '1'='1'; DROP TABLE recipe; --` returns 0 results, no crash
- Non-existent recipe (ID 99999): redirects to home
- Non-existent user: shows "User not found"
- Unknown routes: redirect to home

---

## Bugs Found & Fixed

### Bug #1: Author Profile "User not found"
- **File**: `src/pages/Recipe/Profile.jsx`
- **Issue**: Clicking author link (e.g., Maria Garcia → /users/5) showed "User not found"
- **Root Cause**: `api.users.get(userId)` returns user object directly, but component accessed `data.user` (undefined)
- **Fix**: Changed `setProfileUser(data.user)` to `setProfileUser(data)`

### Bug #2: Profile Edit Wipes Favorites
- **File**: `backend/api/users.php`
- **Issue**: After editing profile (bio, avatar), favorites count dropped from (2) to (0)
- **Root Cause**: `handleUpdateUser` didn't return `favorites` array in response. When `updateProfile` called `setUser(updatedUser)`, favorites field was missing causing `loadFavorites` to see empty array.
- **Fix**: Added favorites query to `handleUpdateUser`:
  ```php
  $favStmt = $pdo->prepare("SELECT recipe_id FROM favorite WHERE user_id = :id");
  $favStmt->execute([':id' => $id]);
  $favorites = $favStmt->fetchAll(PDO::FETCH_COLUMN, 0);
  // Added 'favorites' => array_map('intval', $favorites) to response
  ```

### Bug #3: Login Error Persists After Clearing Fields
- **File**: `src/pages/Auth/Login.jsx`
- **Issue**: "Invalid credentials" error stayed visible after clearing/changing form fields
- **Fix**: Added `setError('')` to onChange handlers for both email and password inputs

### Bug #4: "1 views" Grammar
- **File**: `src/pages/Recipe/RecipeDetail.jsx`
- **Issue**: View count showed "1 views" instead of "1 view"
- **Fix**: Changed to `{viewCount} {viewCount === 1 ? 'view' : 'views'}`

### Bug #5: Non-Functional "Forgot Password?" Link
- **File**: `src/pages/Auth/Login.jsx`
- **Issue**: "Forgot password?" link pointed to `/login` itself (placeholder)
- **Fix**: Removed the link entirely (no forgot password feature exists)

### Bug #6: Missing Autocomplete Attributes
- **Files**: `src/pages/Auth/Login.jsx`, `src/pages/Auth/Signup.jsx`
- **Issue**: Form inputs lacked `autocomplete` and `name` attributes (browser warnings)
- **Fix**: Added `autoComplete` and `name` props to all auth form inputs

---

## Console Warnings (Minor)
- Form field missing id/name attribute (from external component - now fixed)
- CORB blocking on Unsplash images (external, not actionable)

## Technical Notes
- Native `<select>` elements require JavaScript evaluation with `Object.getOwnPropertyDescriptor` pattern in Chrome DevTools MCP tools
- HashRouter prefixes all routes with `/#/`
- Backend uses PDO prepared statements (SQL injection safe)
- React JSX escaping prevents XSS by default
