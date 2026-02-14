# Recipe Features

**Last Updated**: 2026-02-14
**Status**: ✅ Fully migrated to API-based

## Recipe Pages — Current Implementation

### Home (`src/pages/Recipe/Home.jsx`)
- Fetches recipes via `api.recipes.list()` on mount
- Loading spinner during fetch, error state on failure
- Renders `RecipeCard` components

### RecipeCard (`src/components/recipe/RecipeCard.jsx`)
- Displays: `recipe.image`, `recipe.title`, `recipe.author?.username`, stats
- Async like/favorite toggles via `api.recipes.like(id)` / `api.recipes.favorite(id)`
- Uses `recipe.author?.avatarUrl` for avatar display

### RecipeDetail (`src/pages/Recipe/RecipeDetail.jsx`)
- Fetches full recipe via `api.recipes.get(id)` with nested data
- Data shape: `recipe.author` (nested object), `recipe.images` (array), `recipe.instructions` (array of objects with `stepNumber`, `instructionText`), `recipe.ingredients` (array)
- Records views via `api.recipes.recordView(id)`
- Reviews: `api.reviews.list(recipeId)`, `api.reviews.create(recipeId, data)`
- Like/favorite toggles, stats display

### CreateRecipe (`src/pages/Recipe/CreateRecipe.jsx`)
- Creates via `api.recipes.create(data)`, updates via `api.recipes.update(id, data)`
- Submits: title, description, category, difficulty, prepTime, cookTime, servings, ingredients, instructions, images
- Loading state during submission, API validation error handling
- New recipes get `status: 'pending'`

### Search (`src/pages/Recipe/Search.jsx`)
- Searches via `api.recipes.list({ search, category, difficulty, sort })`
- Search history: `api.search.saveHistory(query)`, `api.search.getHistory()`, `api.search.clearHistory()`

### Profile (`src/pages/Recipe/Profile.jsx`)
- User data: `api.users.get(id)` with `avatarUrl` field
- User's recipes: `api.recipes.list({ author_id })`
- Recipe deletion: `api.recipes.delete(id)`

## Backend Recipe Endpoints
| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/api/recipes` | Filters: category, difficulty, search, sort, page, limit, status=all (admin) |
| GET | `/api/recipes/{id}` | Full recipe with nested ingredients/instructions/images/author/stats |
| POST | `/api/recipes` | Creates with status=pending |
| PUT | `/api/recipes/{id}` | Owner or admin only |
| DELETE | `/api/recipes/{id}` | Owner or admin, CASCADE |
| PUT | `/api/recipes/{id}/status` | Admin only (publish/reject) |
| POST | `/api/recipes/{id}/like` | Toggle like |
| POST | `/api/recipes/{id}/favorite` | Toggle favorite |
| POST | `/api/recipes/{id}/view` | Records view (non-admin users only) |
