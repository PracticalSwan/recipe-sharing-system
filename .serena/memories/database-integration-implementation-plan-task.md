# Database Integration Implementation Plan Task

## Task Overview

**Date Created:** 2026-02-04  
**Project:** Recipe Sharing System (CSX3006 Database Systems Course)  
**Status:** Phases 1-3 SQL Implementation Complete - Phase 4+ Pending

## What Was Done

### 1. Updated Implementation Plan (`upgrade-database-integration-1.md`)

The implementation plan was updated to follow SQL naming conventions from `sql-sp-generation.instructions.md`:

#### Database Requirements Updated (REQ-DB-001 to REQ-DB-011)
- Added requirements for singular table names
- Added requirements for snake_case column naming
- Added foreign key constraint naming requirements
- Added timestamp column requirements (created_at, updated_at)

#### Data Migration Requirements Updated (REQ-MIG-003)
- Changed from "Support guest user tracking (temporary IDs for non-authenticated views)"
- To "All recipe views must be associated with authenticated users only (no guest tracking)"
- Removed guest/user separation - all viewers must be authenticated users

#### Table Designs Updated (TASK-006 to TASK-018)
- All tables use singular names: `user`, `recipe`, `ingredient`, `instruction`, `recipe_image`, `review`, `favorite`, `like_record`, `recipe_view`, `search_history`, `daily_stat`, `activity_log`, `session`
- Foreign keys defined inline with ON DELETE CASCADE/SET NULL as appropriate
- All columns use snake_case naming

#### recipe_view Table Simplified (TASK-014)
- Removed `viewer_type` ENUM column ('user', 'guest')
- Removed `guest_identifier` VARCHAR(100) column
- Changed `viewer_id` to `user_id` with NOT NULL constraint
- Added ON DELETE CASCADE to user_id foreign key
- Added `idx_user_viewed` index for user-based view queries
- All recipe views now require authenticated users only

#### Advanced SQL Features Updated (TASK-043 to TASK-055)
- Stored procedures: `usp_` prefix + PascalCase (e.g., `usp_CreateRecipe`, `usp_ApproveRecipe`)
- Functions: `fn_` prefix + PascalCase (e.g., `fn_CalculateAvgRating`)
- Views: `vw_` prefix + snake_case (e.g., `vw_recipe_with_stat`, `vw_user_dashboard_stat`)
- Triggers: `trg_` prefix + TableName_Action (e.g., `trg_User_NewUserStat`, `trg_RecipeView_UpdateStat`)

#### Testing Updated (TEST-029)
- Changed from "Guest View Tracking - Verify view recorded for guest with temporary ID"
- To "Multiple Views Tracking - Verify same user viewing same recipe multiple times creates multiple view records"

#### Guidelines Updated (GUD-001 to GUD-020, PAT-001 to PAT-004)
- Added 15 new SQL-specific guidelines
- SQL keywords UPPERCASE
- Stored procedure naming conventions
- Parameter naming with @ prefix and camelCase

### 2. Created Explanation Document (`database_implementation_logic_explanation.md`)

Comprehensive document covering:
- Database design philosophy (3NF normalization)
- Entity-relationship model with cardinality
- All 13 table designs with column logic and constraints
- Naming conventions summary
- Constraint types and referential integrity
- Indexing strategy
- Views logic
- Stored procedures logic
- Triggers logic
- Data seeding strategy
- Query patterns and examples
- Security considerations
- Performance optimization

## Implementation Status

### ✅ COMPLETED (February 7, 2026)

1. **Phase 1: Database Design** (TASK-004 to TASK-021) ✅
   - All DDL scripts: 01_create_database.sql through 04_create_views.sql
   - 13 tables, 2 views, 25+ indexes
   - TASK-001 to TASK-003 (ER diagrams/normalization) NOT done - not SQL scripts

2. **Phase 2: Data Scripts** (TASK-021 to TASK-042) ✅
   - All seed data: 05_seed_users.sql through 08_seed_stats.sql
   - All query scripts: 09_common_queries.sql through 11_analytics_queries.sql

3. **Phase 3: Advanced SQL** (TASK-043 to TASK-055) ✅
   - Stored procedures: 12_stored_procedures.sql (4 procedures + 1 function)
   - Triggers: 13_triggers.sql (6 triggers with @DISABLE_TRIGGERS pattern)
   - Backup/restore: 14_backup_restore.sql

### Additional Deliverables Created (February 7, 2026)
- `guides/SQL_SCRIPTS.md` - Consolidated guide with all 14 scripts
- Notion child page: "CookHub - Complete SQL Scripts Reference" (https://www.notion.so/300e35b852f081c5a148ec7aa1cee4c8)
- Implementation plan updated: 53 tasks marked ✅ with date 2026-02-07

### ⏳ NOT YET IMPLEMENTED (Pending)

4. **Phase 4: PHP Backend** (TASK-056 to TASK-101)
   - All PHP API files

5. **Phase 5: Frontend Integration** (TASK-102 to TASK-157)
   - Update React components for API calls

6. **Phase 6: Testing & Deployment** (TASK-158 to TASK-170)
   - Testing and documentation

## Key Files

| File | Purpose | Status |
|------|---------|--------|
| `plan/upgrade-database-integration-1.md` | Implementation plan | ✅ Updated |
| `plan/database_implementation_logic_explanation.md` | Logic explanation | ✅ Created |
| `database/*.sql` (14 files) | SQL scripts | ✅ Complete (2026-02-07) |
| `guides/SQL_SCRIPTS.md` | All SQL scripts consolidated | ✅ Complete (2026-02-07) |
| `backend/**/*.php` | PHP API | ⏳ Pending |
| `src/lib/api.js` | Frontend API layer | ⏳ Pending |

## SQL Naming Convention Summary

```
Tables:          singular, snake_case     → user, recipe, recipe_view
Columns:         singular, snake_case     → author_id, created_at
Primary Keys:    id                       → user.id, recipe.id
Foreign Keys:    {table}_id               → author_id, recipe_id
Stored Procs:    usp_PascalCase          → usp_CreateRecipe
Functions:       fn_PascalCase           → fn_CalculateAvgRating
Views:           vw_snake_case           → vw_recipe_with_stat
Triggers:        trg_Table_Action        → trg_User_NewUserStat
Indexes:         idx_table_column        → idx_recipe_author_status
```

## Frontend to Backend Integration Verification (Completed 2026-02-04)

### Status Update (2026-02-04)

✅ **ALL MISSING TASKS ADDED TO IMPLEMENTATION PLAN**

The implementation plan has been successfully updated with all identified gaps:

#### Backend Tasks Added to Phase 4:
- **TASK-098**: GET /api/search/history/:userId endpoint (retrieve user search history)
- **TASK-099**: DELETE /api/search/history/:userId endpoint (clear user search history)

#### Frontend Tasks Added to Phase 5:
- **TASK-132**: Implement api.search.getHistory(userId) method
- **TASK-133**: Implement api.search.clearHistory(userId) method
- **TASK-140**: Update RecipeDetail.jsx - Remove guest view tracking, require authentication
- **TASK-142**: Update Search.jsx - Remove storage.getOrCreateGuestId() calls
- **TASK-143-145**: Profile.jsx updates (3 tasks for user profile, recipe deletion, user data fetching)
- **TASK-146-148**: UserList.jsx updates (3 tasks for user management, API integration, activity logging removal)
- **TASK-149-150**: AdminStats.jsx updates (2 tasks for dashboard stats and activity logs)
- **TASK-151-153**: AdminRecipes.jsx updates (3 tasks for recipe management, approval, deletion)

#### Task Count Summary:
- **Previous Plan**: 146 tasks
- **Tasks Added**: 11 tasks
- **Updated Plan**: 181 tasks total

All frontend components now have explicit backend integration tasks. No localStorage calls will remain after full implementation.

---

### Comprehensive Audit Results (Original Verification)

**Verification Goal:** Ensure ALL front-end components connect to backend database, with NO hard-coded data values remaining.

#### Storage.js API Methods (63 calls identified across frontend)

All localStorage operations in `src/lib/storage.js` must be replaced with backend API calls:

##### User Management (15 calls)
- ✅ `storage.initialize()` → Will be removed (backend handles initialization)
- ✅ `storage.getCurrentUser()` → API: `GET /api/auth/me`
- ✅ `storage.login(email, password)` → API: `POST /api/auth/login`
- ✅ `storage.logout(userId)` → API: `POST /api/auth/logout`
- ✅ `storage.getUsers()` → API: `GET /api/users`
- ✅ `storage.saveUser(user)` → API: `PUT /api/users/:id`
- ✅ `storage.deleteUser(userId)` → API: `DELETE /api/users/:id`
- ✅ `storage.updateLastActive(userId)` → API: Auto-updated via session middleware
- ✅ `storage.setCurrentUser(user)` → Client-side state management only
- ✅ `storage.recordActiveUser(userId)` → API: Trigger via session tracking
- ✅ `storage.recordNewUser(userId, role)` → API: Trigger via `POST /api/auth/register`

##### Recipe Management (11 calls)
- ✅ `storage.getRecipes()` → API: `GET /api/recipes`
- ✅ `storage.getRecipeById(id)` → API: `GET /api/recipes/:id`
- ✅ `storage.saveRecipe(recipe)` → API: `POST /api/recipes` or `PUT /api/recipes/:id`
- ✅ `storage.deleteRecipe(recipeId)` → API: `DELETE /api/recipes/:id`

##### Review Management (5 calls)
- ✅ `storage.getReviews(recipeId)` → API: `GET /api/recipes/:id/reviews`
- ✅ `storage.addReview(review)` → API: `POST /api/recipes/:id/reviews`
- ✅ `storage.deleteReview(reviewId)` → API: `DELETE /api/reviews/:id`
- ✅ `storage.getAverageRating(recipeId)` → API: Included in recipe details response

##### Engagement (8 calls)
- ✅ `storage.toggleLike(userId, recipeId)` → API: `POST /api/recipes/:id/like`
- ✅ `storage.toggleFavorite(userId, recipeId)` → API: `POST /api/recipes/:id/favorite`
- ✅ `storage.hasUserLiked(userId, recipeId)` → API: Included in recipe details
- ✅ `storage.hasUserFavorited(userId, recipeId)` → API: Included in recipe details
- ✅ `storage.getLikeCount(recipeId)` → API: Included in recipe stats
- ✅ `storage.getViewCount(recipeId)` → API: Included in recipe stats
- ✅ `storage.recordView(options)` → API: `POST /api/recipes/:id/view`
- ✅ `storage.getOrCreateGuestId()` → **REMOVED** (no guest tracking per REQ-MIG-003)

##### Search & History (4 calls)
- ✅ `storage.getSearchHistory(userId)` → API: `GET /api/search/history/:userId` (NEW endpoint needed)
- ✅ `storage.addSearchHistory(query)` → API: `POST /api/search/history`
- ✅ `storage.clearSearchHistory(userId)` → API: `DELETE /api/search/history/:userId` (NEW endpoint needed)

##### Statistics & Activity (9 calls)
- ✅ `storage.getDailyStats()` → API: `GET /api/stats/daily`
- ✅ `storage.getNewUsersToday()` → API: `GET /api/stats/dashboard`
- ✅ `storage.getNewContributorsToday()` → API: `GET /api/stats/dashboard`
- ✅ `storage.getDailyActiveUsers()` → API: `GET /api/stats/dashboard`
- ✅ `storage.getDailyViews()` → API: `GET /api/stats/dashboard`
- ✅ `storage.addActivity(activity)` → API: Auto-logged via triggers & admin endpoints
- ✅ `storage.getRecentActivity(limit)` → API: `GET /api/activity`
- ✅ `storage.resetData()` → **REMOVED** (development only, not in production)

#### Files Using Storage (Component Coverage)

| File | Storage Calls | Backend Integration Status |
|------|---------------|----------------------------|
| `src/context/AuthContext.jsx` | 15 calls | ✅ Covered by TASK-130 to TASK-132 |
| `src/pages/Auth/Login.jsx` | Indirect (via context) | ✅ Covered by TASK-133 |
| `src/pages/Auth/Signup.jsx` | Indirect (via context) | ✅ Covered by TASK-134 |
| `src/pages/Recipe/Home.jsx` | 2 calls (`getRecipes`) | ✅ Covered by TASK-135 |
| `src/pages/Recipe/Search.jsx` | 10 calls | ✅ Covered by TASK-128, TASK-129 |
| `src/pages/Recipe/RecipeDetail.jsx` | 11 calls | ✅ Covered by TASK-136 |
| `src/pages/Recipe/CreateRecipe.jsx` | 3 calls | ✅ Covered by TASK-137 |
| `src/pages/Recipe/Profile.jsx` | 3 calls | ⚠️ **GAP** - Not explicitly in plan |
| `src/pages/Admin/UserList.jsx` | 8 calls | ⚠️ **GAP** - Not explicitly in plan |
| `src/pages/Admin/AdminStats.jsx` | 8 calls | ⚠️ **GAP** - Not explicitly in plan |
| `src/pages/Admin/AdminRecipes.jsx` | 8 calls | ⚠️ **GAP** - Not explicitly in plan |
| `src/components/recipe/RecipeCard.jsx` | 8 calls | ✅ Covered (used by Home/Search) |

#### Hard-Coded Values Identified

##### ✅ ACCEPTABLE (Reference Data - Should be in Database)

These are currently hard-coded in `src/lib/utils.js` but should ideally come from backend:

```javascript
RECIPE_CATEGORIES = ['Breakfast', 'Lunch', 'Dinner', 'Dessert', 'Italian', 'Asian', 'Health']
RECIPE_DIFFICULTIES = ['Easy', 'Medium', 'Hard']
```

**Recommendation:** Add to implementation plan:
- **TASK-XXX**: Create `category` reference table with seed data
- **API Endpoint**: `GET /api/recipes/categories` → Returns list of valid categories
- **API Endpoint**: `GET /api/recipes/difficulties` → Returns list of valid difficulties (or keep as ENUM)

##### ✅ ACCEPTABLE (UI Constants - Can remain client-side)

- Avatar URLs from Dicebear API (default avatars)
- UI labels, button text, form placeholders
- Tailwind CSS classes
- Route paths in React Router

##### 🚨 CRITICAL GAPS FOUND

**Gap 1: Profile Page Update Not Covered**
- File: `src/pages/Recipe/Profile.jsx`
- Missing Tasks:
  - Update user profile (uses `storage.saveUser()`)
  - Delete recipes from profile (uses `storage.deleteRecipe()`)
  - Fetch user data (uses `storage.getUsers()`)

**Gap 2: Admin Pages Not Covered**
- Files: `src/pages/Admin/UserList.jsx`, `AdminStats.jsx`, `AdminRecipes.jsx`
- Missing Tasks for UserList:
  - Fetch all users
  - Update user status
  - Delete users
  - Log admin activities
- Missing Tasks for AdminStats:
  - Fetch aggregated dashboard statistics
  - Fetch recent activity logs
- Missing Tasks for AdminRecipes:
  - Fetch all recipes (including pending/rejected)
  - Approve/reject recipes
  - Delete recipes
  - Log admin activities

**Gap 3: Search History Endpoints Missing**
- Current plan has `POST /api/search/history` (TASK-129)
- Missing:
  - `GET /api/search/history/:userId` - Retrieve user's search history
  - `DELETE /api/search/history/:userId` - Clear user's search history

**Gap 4: Guest Tracking Removal Impact**
- `Search.jsx` and `RecipeDetail.jsx` still reference `storage.getOrCreateGuestId()`
- These calls must be removed or wrapped in authentication checks

#### Implementation Plan Completeness Assessment

| Phase | Completeness | Missing Items |
|-------|--------------|---------------|
| Phase 1: Database Schema | ✅ 100% | None |
| Phase 2: SQL Data Scripts | ✅ 100% | None |
| Phase 3: Advanced SQL | ✅ 100% | None |
| Phase 4: PHP Backend | ⚠️ ~90% | Admin endpoints, search history GET/DELETE |
| Phase 5: Frontend Integration | ⚠️ ~75% | Profile page, Admin pages updates |

### Required Additions to Implementation Plan

#### Add to Phase 4 (Backend API):

```markdown
| TASK-098a | Create `controllers/SearchController.php` - GET /api/search/history/:userId endpoint | | |
| TASK-098b | Create `controllers/SearchController.php` - DELETE /api/search/history/:userId endpoint | | |
```

#### Add to Phase 5 (Frontend Integration):

```markdown
| TASK-138 | Update `src/pages/Recipe/Profile.jsx` - Replace storage.saveUser() with api.users.update() | | |
| TASK-139 | Update `src/pages/Recipe/Profile.jsx` - Replace storage.deleteRecipe() with api.recipes.delete() | | |
| TASK-140 | Update `src/pages/Recipe/Profile.jsx` - Replace storage.getUsers() with api.users.getById() | | |
| TASK-141 | Update `src/pages/Admin/UserList.jsx` - Replace storage calls with api.users methods | | |
| TASK-142 | Update `src/pages/Admin/UserList.jsx` - Replace storage.addActivity() with API auto-logging | | |
| TASK-143 | Update `src/pages/Admin/AdminStats.jsx` - Replace all storage.get*() with api.stats.getDashboard() | | |
| TASK-144 | Update `src/pages/Admin/AdminRecipes.jsx` - Replace storage calls with api.recipes methods | | |
| TASK-145 | Update `src/pages/Recipe/Search.jsx` - Remove storage.getOrCreateGuestId() calls (guest tracking removed) | | |
| TASK-146 | Update `src/pages/Recipe/RecipeDetail.jsx` - Remove guest view tracking, require authentication | | |
```

### Final Verification Status

✅ **Database Schema:** Complete - All tables support required frontend features  
✅ **Guest Tracking:** Removed from plan as required (REQ-MIG-003)  
✅ **Backend API:** 100% complete - All endpoints including search history GET/DELETE added  
✅ **Frontend Integration:** 100% complete - All Profile + Admin pages + guest removal tasks added  
✅ **No Hard-Coded Data:** Categories/difficulties acceptable as constants (can be enhanced with API endpoints later)  
✅ **Implementation Plan:** Updated with all 181 tasks - Ready for execution

### Implementation Plan Update Summary

**Date Updated:** 2026-02-04  
**Plan Version:** 1.0 (Updated)  
**Total Tasks:** 181 (was 146, added 11 frontend tasks + 2 backend tasks + renumbered Phase 6)

**Changes Made:**
1. Added TASK-098 (GET search history endpoint) to Phase 4
2. Added TASK-099 (DELETE search history endpoint) to Phase 4  
3. Added TASK-132-133 (search history API methods) to Phase 5
4. Updated TASK-140 to include guest tracking removal for RecipeDetail.jsx
5. Updated TASK-142 to include guest tracking removal for Search.jsx
6. Added TASK-143-145 for complete Profile.jsx integration (3 tasks)
7. Added TASK-146-148 for complete UserList.jsx integration (3 tasks)
8. Added TASK-149-150 for complete AdminStats.jsx integration (2 tasks)
9. Added TASK-151-153 for complete AdminRecipes.jsx integration (3 tasks)
10. Renumbered Phase 6 tasks from TASK-158 to TASK-181

**No Further Gaps Identified** - Implementation plan is now complete and ready for execution.

---

### Recommendations for Next Implementation Session (UPDATED)

1. ✅ **COMPLETED:** Add missing backend endpoints (search history GET/DELETE) - Added as TASK-098, TASK-099
2. ✅ **COMPLETED:** Add missing frontend tasks (Profile page, Admin pages) - Added as TASK-143-153
3. **OPTIONAL:** Consider adding `GET /api/recipes/categories` and `GET /api/recipes/difficulties` for dynamic reference data
4. ✅ **COMPLETED:** Explicitly document guest tracking removal in frontend tasks - Updated TASK-140, TASK-142
5. **READY:** Begin Phase 1 implementation following the complete 181-task plan

---

## Next Steps for Future Sessions

1. ✅ **COMPLETED:** Add missing tasks to implementation plan (11 tasks added + Phase 6 renumbered)
2. ✅ **COMPLETED:** Phase 1-3 SQL scripts (14 files in database/ folder, 2026-02-07)
3. ✅ **COMPLETED:** guides/SQL_SCRIPTS.md consolidated reference
4. ✅ **COMPLETED:** Notion child page with SQL scripts reference
5. ✅ **COMPLETED:** Implementation plan updated (53 tasks marked ✅)
6. **START HERE:** Begin Phase 4 - PHP Backend API Development (TASK-056+)
7. Follow the complete task sequence in `upgrade-database-integration-1.md`
8. Reference `guides/database_implementation_logic_explanation.md` for design decisions
9. Implement one phase at a time, testing each before proceeding

## Important Reminders

- Follow `sql-sp-generation.instructions.md` for all SQL code
- Use prepared statements (PDO) in PHP for security
- Test each phase before moving to the next
- Keep existing React frontend working during migration
- **All frontend components MUST connect to backend** - no localStorage calls should remain
- **Remove all guest tracking code** per REQ-MIG-003
