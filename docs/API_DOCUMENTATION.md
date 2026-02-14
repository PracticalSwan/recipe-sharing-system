# CookHub API Documentation

REST API reference for the CookHub Recipe Sharing System.

## Base URL

```
Development: http://localhost:5173/api
Production:  http://<host>/recipe-sharing-system/backend/api
```

## Authentication

Session-based authentication using HttpOnly cookies.

- **Cookie Name**: `cookhub_session`
- **Session Expiry**: 24 hours
- **Auth Header**: Not required (cookies are sent automatically with `credentials: 'include'`)

## Response Format

All successful responses are wrapped in a `data` envelope:

```json
{
  "data": { ... }
}
```

Error responses:

```json
{
  "error": "Error message"
}
```

Success messages:

```json
{
  "message": "Action completed",
  "data": { ... }
}
```

---

## Authentication Endpoints

### POST `/auth/register`

Register a new user account. New users start with `pending` status.

**Auth Required**: No

**Request Body**:
```json
{
  "email": "john@example.com",
  "password": "securepassword",
  "firstName": "John",
  "lastName": "Doe",
  "username": "John Doe",
  "birthday": "2000-01-15",
  "avatar": "https://example.com/avatar.svg"
}
```

**Response** `201`:
```json
{
  "data": {
    "user": {
      "id": 1,
      "username": "John Doe",
      "firstName": "John",
      "lastName": "Doe",
      "email": "john@example.com",
      "role": "user",
      "status": "pending",
      "avatarUrl": "https://example.com/avatar.svg"
    }
  }
}
```

### POST `/auth/login`

Login with email and password. Creates a session cookie.
If the user is currently `inactive`, login promotes the account to `active` and refreshes `last_active`.

**Auth Required**: No

**Request Body**:
```json
{
  "email": "admin@cookhub.com",
  "password": "admin"
}
```

**Response** `200`:
```json
{
  "data": {
    "user": {
      "id": 1,
      "username": "Admin Chef",
      "email": "admin@cookhub.com",
      "role": "admin",
      "status": "active",
      ...
    }
  }
}
```

### POST `/auth/logout`

Destroy the current session and clear the cookie.
For `active`/`inactive` users, logout also sets account status to `inactive` and updates `last_active`.

**Auth Required**: Yes

**Response** `200`:
```json
{
  "message": "Logged out successfully"
}
```

### GET `/auth/me`

Get the currently authenticated user's profile with favorites.

**Auth Required**: Yes

**Response** `200`:
```json
{
  "data": {
    "user": {
      "id": 1,
      "username": "Admin Chef",
      "email": "admin@cookhub.com",
      "role": "admin",
      "status": "active",
      "favorites": [3, 7, 12]
    }
  }
}
```

### POST `/auth/heartbeat`

Update the user's `last_active` timestamp and extend the session.

**Auth Required**: Yes

**Response** `200`:
```json
{
  "message": "Heartbeat recorded"
}
```

---

## Recipes Endpoints

### GET `/recipes`

List recipes with optional filters and pagination.

**Auth Required**: No (but `isLiked`/`isFavorited` fields require auth)

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `status` | string | `published` | Filter by status: `published`, `pending`, `rejected`, `all` (`all` is allowed for admins, or when `authorId` matches the current user) |
| `category` | string | — | Filter by category |
| `difficulty` | string | — | Filter by difficulty: Easy, Medium, Hard |
| `authorId` | int | — | Filter by author |
| `sort` | string | `newest` | Sort: newest, oldest, popular, rating |
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page (max 50) |

**Response** `200`:
```json
{
  "data": {
    "recipes": [
      {
        "id": 1,
        "title": "Classic Spaghetti",
        "description": "...",
        "categories": ["Italian", "Pasta"],
        "difficulty": "Easy",
        "prepTime": 15,
        "cookTime": 25,
        "servings": 4,
        "status": "published",
        "createdAt": "2025-06-15 10:30:00",
        "author": {
          "id": 4,
          "username": "John Doe",
          "avatarUrl": "..."
        },
        "likeCount": 10,
        "viewCount": 50,
        "reviewCount": 3,
        "avgRating": 4.5,
        "isLiked": false,
        "isFavorited": true,
        "image": "https://..."
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 10,
      "totalPages": 1
    }
  }
}
```

### POST `/recipes`

Create a new recipe. New recipes start with `pending` status.

**Auth Required**: Yes (active users only)

**Request Body**:
```json
{
  "title": "My Recipe",
  "description": "A delicious meal",
  "categories": ["Italian"],
  "difficulty": "Medium",
  "prepTime": 15,
  "cookTime": 30,
  "servings": 4,
  "ingredients": [
    { "name": "Pasta", "quantity": "200", "unit": "g" }
  ],
  "instructions": [
    { "text": "Boil the pasta" }
  ],
  "images": [
    { "url": "https://example.com/photo.jpg" }
  ]
}
```

**Response** `201`:
```json
{
  "data": { ... full recipe object }
}
```

### GET `/recipes/{id}`

Get full recipe detail including ingredients, instructions, images, and reviews.

**Auth Required**: No (auth adds `isLiked`/`isFavorited` fields)

**Response** `200`:
```json
{
  "data": {
    "recipe": {
      "id": 1,
      "title": "Classic Spaghetti",
      "ingredients": [{ "name": "Pasta", "quantity": "200", "unit": "g" }],
      "instructions": [{ "stepNumber": 1, "text": "Boil water" }],
      "images": [{ "url": "https://..." }],
      "reviews": [{ "id": 1, "rating": 5, "comment": "Great!", "user": {...} }],
      "isLiked": false,
      "isFavorited": false,
      "likeCount": 10,
      "viewCount": 50
    }
  }
}
```

### PUT `/recipes/{id}`

Update a recipe. Only the recipe owner or an admin can update.

**Auth Required**: Yes (owner or admin)

**Request Body**: Same as POST

**Status behavior**:
- Owner edits preserve the recipe's current status by default.
- Admin can set `status` in the same update request (`published`, `pending`, `rejected`).

**Response** `200`:
```json
{
  "data": { ... updated recipe }
}
```

### DELETE `/recipes/{id}`

Delete a recipe and all related data.

**Auth Required**: Yes (owner or admin)

**Response** `200`:
```json
{
  "message": "Recipe deleted"
}
```

### PUT `/recipes/{id}/status`

Approve or reject a pending recipe. Admin only.

**Auth Required**: Admin

**Request Body**:
```json
{
  "status": "published"
}
```

**Response** `200`:
```json
{
  "message": "Recipe status updated to published"
}
```

### POST `/recipes/{id}/like`

Toggle like on a recipe.

**Auth Required**: Yes (active users only)

**Response** `200`:
```json
{
  "data": {
    "liked": true,
    "likeCount": 11
  }
}
```

### POST `/recipes/{id}/favorite`

Toggle favorite/bookmark on a recipe.

**Auth Required**: Yes (active users only)

**Response** `200`:
```json
{
  "data": {
    "favorited": true
  }
}
```

### POST `/recipes/{id}/view`

Record a recipe view for analytics.
View counting is deduplicated per `(recipe_id, user_id)` so each authenticated user increments a recipe only once.

**Auth Required**: Yes

**Response** `200`:
```json
{
  "data": {
    "viewRecorded": true,
    "viewCount": 51
  }
}
```

---

## Reviews Endpoints

### GET `/reviews?recipeId={id}`

Get all reviews for a recipe.

**Auth Required**: No

**Response** `200`:
```json
{
  "data": {
    "reviews": [
      {
        "id": 1,
        "rating": 5,
        "comment": "Amazing recipe!",
        "createdAt": "2025-06-15",
        "user": {
          "id": 4,
          "username": "John Doe",
          "avatarUrl": "..."
        }
      }
    ]
  }
}
```

### POST `/reviews`

Create or update the caller's review for a recipe (upsert). One review per user per recipe.

**Auth Required**: Yes (active users only)

**Request Body**:
```json
{
  "recipeId": 1,
  "rating": 5,
  "comment": "Loved this recipe!"
}
```

**Response** `201` (created) or `200` (updated):
```json
{
  "data": {
    "id": 1,
    "rating": 5,
    "comment": "Loved this recipe!",
    "createdAt": "2025-06-15",
    "user": { ... }
  }
}
```

### PUT `/reviews/{id}`

Update a review. Owner or admin only.

**Auth Required**: Yes (owner or admin)

**Request Body**:
```json
{
  "rating": 4,
  "comment": "Updated comment"
}
```

### DELETE `/reviews/{id}`

Delete a review. Owner or admin only.

**Auth Required**: Yes (owner or admin)

**Response** `200`:
```json
{
  "message": "Review deleted"
}
```

---

## Search Endpoints

### GET `/search`

Search published recipes by keyword, category, and difficulty.

**Auth Required**: Yes

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `q` | string | — | Search query (title, description, ingredients) |
| `category` | string | — | Filter by category |
| `difficulty` | string | — | Filter by difficulty |
| `sort` | string | `newest` | Sort: newest, oldest, popular, rating |
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page (max 50) |

**Response** `200`:
```json
{
  "data": {
    "recipes": [...],
    "query": "pasta",
    "pagination": { "page": 1, "limit": 20, "total": 5, "totalPages": 1 }
  }
}
```

### GET `/search/history`

Get the user's recent search history (last 20 entries).

**Auth Required**: Yes

### POST `/search/history`

Save a search term to history.

**Auth Required**: Yes

**Request Body**:
```json
{
  "query": "pasta recipes"
}
```

### DELETE `/search/history`

Clear all search history for the current user.

**Auth Required**: Yes

### DELETE `/search/history/{id}`

Delete a single search history entry.

**Auth Required**: Yes

---

## Users Endpoints

### GET `/users`

List all users with pagination. Admin only.

**Auth Required**: Admin

**Status sync behavior**: before listing, stale regular users (`status='active'` with `last_active` older than 5 minutes) are auto-marked `inactive`.

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page |
| `search` | string | — | Search by name/email |
| `status` | string | — | Filter by status |

**Response** `200`:
```json
{
  "data": {
    "users": [
      {
        "id": 1,
        "username": "Admin Chef",
        "email": "admin@cookhub.com",
        "role": "admin",
        "status": "active",
        "recipeCount": 5,
        "reviewCount": 3
      }
    ],
    "pagination": { ... }
  }
}
```

### GET `/users/{id}`

Get a user's public profile.

**Auth Required**: No

### PUT `/users/{id}`

Update a user profile. Owner or admin only.

**Auth Required**: Yes (owner or admin)

**Request Body**:
```json
{
  "username": "New Name",
  "firstName": "John",
  "lastName": "Smith",
  "bio": "I love cooking!",
  "location": "Bangkok",
  "cookingLevel": "Intermediate",
  "password": "newpassword"
}
```

### DELETE `/users/{id}`

Delete a user and all their data. Admin only.

**Auth Required**: Admin

### PUT `/users/{id}/status`

Change a user's status. Admin only.

**Auth Required**: Admin

**Request Body**:
```json
{
  "status": "active"
}
```

**Valid statuses**: `active`, `inactive`, `pending`, `suspended`

**Audit note**: transitions to `active`/`inactive` are intentionally excluded from recent admin activity feeds.

---

## Stats Endpoints (Admin Only)

### GET `/stats` or `/stats/dashboard`

Get dashboard summary statistics.

**Auth Required**: Admin

**Status sync behavior**: before aggregating metrics, stale regular users (`status='active'` with `last_active` older than 5 minutes) are auto-marked `inactive`.

**Response** `200`:
```json
{
  "data": {
    "totals": { "users": 14, "recipes": 10, "reviews": 20, "views": 500 },
    "thisWeek": { "newUsers": 2, "newRecipes": 3, "newReviews": 5 },
    "today": { "newUsers": 0, "newRecipes": 1, "views": 50 },
    "contributors": [...],
    "usersByStatus": { "active": 10, "pending": 2, "suspended": 1 },
    "recipesByStatus": { "published": 8, "pending": 2 },
    "categoryDistribution": [...],
    "topRecipes": [...],
    "recentActivity": [...]
  }
}
```

**Recent activity note**: `user_update` entries that only change status to `active`/`inactive` are excluded.

### GET `/stats/daily`

Get daily statistics for a date range.

**Auth Required**: Admin

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `days` | int | 30 | Number of days (1-90) |

---

## Activity Log Endpoints (Admin Only)

### GET `/activity`

List admin activity logs.

**Auth Required**: Admin

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page |
| `actionType` | string | — | Filter by action type |

**Action Types**: `recipe_approve`, `recipe_reject`, `user_delete`, `user_update`

**Feed note**: active/inactive status-only updates are filtered out from this endpoint.

---

## Error Codes

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (not logged in) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 405 | Method Not Allowed |
| 409 | Conflict (duplicate entry) |
| 500 | Internal Server Error |

## CORS Configuration

- **Allowed Origins**: `http://localhost:5173`, `http://127.0.0.1:5173`
- **Allowed Methods**: GET, POST, PUT, DELETE, OPTIONS
- **Allowed Headers**: Content-Type, Authorization
- **Credentials**: Enabled
