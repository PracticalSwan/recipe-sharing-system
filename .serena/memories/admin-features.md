# Admin Features

**Last Updated**: 2026-02-14
**Status**: ✅ Fully migrated to API-based

## Admin Pages — Current Implementation

### UserList (`src/pages/Admin/UserList.jsx`)
- Fetches users via `api.users.list()` (async, paginated)
- Status changes: `api.users.updateStatus(id, status)` — active/inactive/suspended
- Delete users: `api.users.delete(id)` — CASCADE removes all user data
- Displays `avatarUrl` for user avatars
- Loading state, error handling

### AdminStats (`src/pages/Admin/AdminStats.jsx`)
- Dashboard data via `api.stats.dashboard()`
- Maps API response to UI: totalUsers, totalRecipes, totalReviews, totalViews
- Today-specific metrics: todayViews, todayUsers, todayRecipes
- User/recipe breakdowns by status from `usersByStatus`, `recipesByStatus`
- Activity log via `api.activity.recent()`

### AdminRecipes (`src/pages/Admin/AdminRecipes.jsx`)
- Fetches all recipes: `api.recipes.list({ status: 'all' })` (includes pending/rejected)
- Approve/reject: `api.recipes.updateStatus(id, 'published'|'rejected')`
- Delete recipes: `api.recipes.delete(id)`
- Activity logging handled automatically by backend (no manual `storage.addActivity()` calls)

## Backend Admin Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Admin: list all users with pagination |
| PUT | `/api/users/{id}/status` | Admin: change user status + log activity |
| DELETE | `/api/users/{id}` | Admin: delete user + CASCADE + log activity |
| PUT | `/api/recipes/{id}/status` | Admin: approve/reject recipe + log activity |
| GET | `/api/stats/dashboard` | Admin: aggregated dashboard stats |
| GET | `/api/stats/daily` | Daily stats for charting |
| GET | `/api/activity` | Admin: activity log with pagination |

## Key Implementation Notes
- All activity logging (user_create, recipe_approve, etc.) is handled by the PHP backend
- Frontend no longer calls `storage.addActivity()` — removed during migration
- Admin role check done server-side in `helpers/auth.php` via `requireAdmin()`
- `stats.php` includes today-specific metrics not in original plan (enhancement)
- `recipes.php` accepts `status=all` parameter for admin recipe list view
