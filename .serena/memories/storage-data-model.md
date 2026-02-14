# Storage & Data Model

**Last Updated**: 2026-02-14

## Current State: API-Based (Migration Complete)

The application has been fully migrated from `storage.js` (localStorage) to `api.js` (REST API).

### `src/lib/api.js` — Active Service Layer (~220 lines)
- **apiFetch(endpoint, options)**: Base wrapper with `credentials: 'include'`, auto JSON, error handling
- **ApiError class**: Custom error with status code and parsed message
- **DEFAULT_AVATARS**: Array of 6 default avatar URLs (exported)

#### API Namespaces:
| Namespace | Methods |
|-----------|---------|
| `api.auth` | `login(email, pw)`, `register(data)`, `logout()`, `me()` |
| `api.recipes` | `list(params)`, `get(id)`, `create(data)`, `update(id, data)`, `delete(id)`, `updateStatus(id, status)`, `like(id)`, `favorite(id)`, `recordView(id)` |
| `api.reviews` | `list(recipeId)`, `create(recipeId, data)`, `update(id, data)`, `delete(id)` |
| `api.users` | `list(params)`, `get(id)`, `update(id, data)`, `delete(id)`, `updateStatus(id, status)` |
| `api.search` | `recipes(params)`, `saveHistory(query)`, `getHistory()`, `clearHistory()` |
| `api.stats` | `dashboard()`, `daily(days)` |
| `api.activity` | `recent(params)` |

### `src/lib/storage.js` — DEAD CODE
- Zero imports remain across all frontend files
- Pending deletion (TASK-114)
- Was the original localStorage-based data layer with mock data

### API Response Data Shapes (key patterns)
- **Recipes**: `recipe.author` is a nested object `{id, username, avatarUrl}`
- **Recipe images**: `recipe.images` array, main image via `recipe.image` (main_image subquery)
- **Instructions**: Array of `{id, stepNumber, instructionText}` objects (not plain strings)
- **Stats dashboard**: Returns `{totalUsers, totalRecipes, totalReviews, totalViews, todayViews, todayUsers, todayRecipes, usersByStatus, recipesByStatus, dailyStats}`

### Vite Proxy Configuration
```js
// vite.config.js
server: {
  proxy: { '/api': { target: 'http://localhost', changeOrigin: true } }
}
```
