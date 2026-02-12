## Current Frontend Features (React Components)

### Recipe UX Components

**Home Page (`Home.jsx`):**
- Displays published recipes (`status = 'published'`)
- Search bar for keyword, category, difficulty filtering
- Updates on `recipeUpdated` and `favoriteToggled` events
- Pagination support for large recipe lists
- Sort options: newest, rating, difficulty

**Search Page (`Search.jsx`):**
- Uses URL query parameters for filters (keyword, category, difficulty, sort)
- Multi-select category filter (user can select multiple)
- Debounced search history logging (300ms delay)
- Constant definitions: `RECIPE_CATEGORIES`, `DIFFICULTIES`
- Sort by: newest, rating (likes), difficulty

**Recipe Detail (`RecipeDetail.jsx`):**
- View full recipe with ingredients and instructions
- Record recipe views in localStorage (`recipe_view` tracking)
- Like/favorite toggle buttons (stateful)
- Reviews list (max 1 review per user per recipe)
- Review deletion (own reviews only)
- Ingredient checklist (interactive)
- Owner edit/delete buttons (if `author_id === user.id`)
- Pending/suspended users: Read-only (can't interact)

**Create Recipe (`CreateRecipe.jsx`):**
- Create new recipe with server-side validation
- Multi-select category (1-3 categories allowed)
- Dynamic ingredients list (add/remove rows)
- Dynamic instructions list (add/remove steps)
- New recipes automatically set `status = 'pending'` (requires admin approval)
- Edit mode: keeps recipe status unless rejected (then resets to pending)

**Profile Page (`Profile.jsx`):**
- View own profile or other user's profile
- Two tab views: "My Recipes" and "My Favorites"
- Edit profile modal with avatar selection
- Delete own recipes with confirmation
- Respect `status` restrictions (pending/suspended users limited)

---

## Current Storage (localStorage)

**Data in `lib/storage.js` operations:**
- Recipe CRUD operations (array push/shift/filter)
- Like/favorite toggle (add/remove from arrays)
- Review submission (append to reviews array)
- View tracking (record timestamped view entries)

**Limitations:**
- No cross-device sync
- No real-time collaboration
- No server-side validation
- No activity tracking across users
- No search history persistence

---

## Migration Target (Phase 4 + 5)

### Backend Schema (MySQL — 14 Tables Complete)

**Recipe-Related Tables:**

| Table | Purpose | Key Columns |
|--------|---------|-------------|
| `recipe` | Main recipe entity | id, author_id, title, description, category, difficulty, prep_time, cook_time, servings, status |
| `ingredient` | Recipe ingredients (one-to-many) | id, recipe_id, name, quantity, unit, sort_order |
| `instruction` | Recipe steps (one-to-many) | id, recipe_id, step_number, instruction_text |
| `recipe_image` | Recipe images (one-to-many) | id, recipe_id, image_url, display_order |
| `recipe_view` | View tracking | id, user_id, recipe_id, viewed_at |
| `favorite` | Favorite bookmarks | id, user_id, recipe_id, created_at |
| `like_record` | Like toggles | id, user_id, recipe_id, created_at |
| `review` | User reviews | id, user_id, recipe_id, rating, comment, created_at |

**Data Normalization Benefits:**
- **Efficient queries** — Load recipes without ingredients/instructions unless needed
- **Indexable FK columns** — Fast joins via `recipe_id`
- **Cascade deletes** — Deleting recipe auto-cleans ingredients, instructions, images
- **Independent access** — Query ingredients alone for shopping lists

---

## Backend API Implementation (Phase 4)

### Recipe CRUD Endpoints (`api/recipes.php`)

**1. GET /api/recipes — List published recipes**
```php
// Optional query params: page, limit, category, difficulty, search, sort, order
$params = [
    'page' => $_GET['page'] ?? 1,
    'limit' => $_GET['limit'] ?? 20,
    'category' => $_GET['category'] ?? null,
    'difficulty' => $_GET['difficulty'] ?? null,
    'search' => $_GET['search'] ?? null,
    'sort' => $_GET['sort'] ?? 'created_at',
    'order' => $_GET['order'] ?? 'DESC'
];

// Build dynamic WHERE clause
$where = ["r.status = 'published'"];
if ($params['category']) $where[] = "r.category = ?";
if ($params['difficulty']) $where[] = "r.difficulty = ?";
if ($params['search']) $where[] = "(r.title LIKE ? OR r.description LIKE ?)";

$sql = "SELECT r.*, u.username, u.first_name, u.last_name,
            COALESCE(d.rating_count, 0) AS rating_count,
            COALESCE(d.avg_rating, 0) AS avg_rating
         FROM recipe r
         LEFT JOIN user u ON r.author_id = u.id
         LEFT JOIN vw_recipe_with_stat d ON r.id = d.id
         WHERE " . implode(' AND ', $where) . "
         ORDER BY {$params['sort']} {$params['order']}
         LIMIT ? OFFSET ?";

$stmt = $pdo->prepare($sql);
$stmt->execute([...$where, $params['limit'], ($params['page'] - 1) * $params['limit']]);
echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
```

**2. POST /api/recipes — Submit new recipe**
```php
$session = validateSession($pdo);
if (!$session) send401Unauthorized();

$data = json_decode(file_get_contents('php://input'), true);

// Validate
$errors = validateRecipeData($data);
if (!empty($errors)) send422UnprocessableEntity($errors);

// Insert recipe
$stmt = $pdo->prepare("INSERT INTO recipe (author_id, title, description, category, difficulty,
                                               prep_time, cook_time, servings, status)
                                    VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')");
$stmt->execute([$session['user_id'], $data['title'], $data['description'], $data['category'],
                $data['difficulty'], $data['prep_time'], $data['cook_time'], $data['servings']]);

$recipeId = $pdo->lastInsertId();

// Insert ingredients (batch)
$ingStmt = $pdo->prepare("INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order)
                                  VALUES (?, ?, ?, ?, ?)");
foreach ($data['ingredients'] as $index => $ing) {
    $ingStmt->execute([$recipeId, $ing['name'], $ing['quantity'], $ing['unit'], $index + 1]);
}

// Insert instructions (batch)
$insStmt = $pdo->prepare("INSERT INTO instruction (recipe_id, step_number, instruction_text)
                                     VALUES (?, ?, ?)");
foreach ($data['instructions'] as $index => $ins) {
    $insStmt->execute([$recipeId, $index + 1, $ins['instruction_text']]);
}

// Insert primary image if provided
if (!empty($data['image_url'])) {
    $imgStmt = $pdo->prepare("INSERT INTO recipe_image (recipe_id, image_url, display_order)
                                      VALUES (?, ?, 1)");
    $imgStmt->execute([$recipeId, $data['image_url']]);
}

echo json_encode(['id' => $recipeId, 'status' => 'pending', 'message' => 'Recipe submitted for approval']);
```

**3. GET /api/recipes/:id — Get single recipe with full details**
```php
$recipeId = (int) $_GET['id'];

$recipe = $pdo->prepare("SELECT r.*, u.username, u.first_name, u.last_name
                          FROM recipe r
                          LEFT JOIN user u ON r.author_id = u.id
                          WHERE r.id = ?");
$recipe->execute([$recipeId]);
$recipeRow = $recipe->fetch(PDO::FETCH_ASSOC);

if (!$recipeRow) send404NotFound('Recipe not found');

// Get ingredients
$ings = $pdo->prepare("SELECT * FROM ingredient WHERE recipe_id = ? ORDER BY sort_order");
$ings->execute([$recipeId]);
$recipeRow['ingredients'] = $ings->fetchAll(PDO::FETCH_ASSOC);

// Get instructions
$inst = $pdo->prepare("SELECT * FROM instruction WHERE recipe_id = ? ORDER BY step_number");
$inst->execute([$recipeId]);
$recipeRow['instructions'] = $inst->fetchAll(PDO::FETCH_ASSOC);

// Get images
$imgs = $pdo->prepare("SELECT * FROM recipe_image WHERE recipe_id = ? ORDER BY display_order");
$imgs->execute([$recipeId]);
$recipeRow['images'] = $imgs->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($recipeRow);
```

**4. PUT /api/recipes/:id — Update recipe**
```php
$session = validateSession($pdo);
$recipeId = (int) $_GET['id'];

// Verify ownership
$check = $pdo->prepare("SELECT author_id, status FROM recipe WHERE id = ?");
$check->execute([$recipeId]);
$recipe = $check->fetch();

if (!$recipe || $recipe['author_id'] !== $session['user_id']) {
    send403Forbidden('You can only edit your own recipes');
}

$data = json_decode(file_get_contents('php://input'), true);
$errors = validateRecipeData($data);
if (!empty($errors)) send422UnprocessableEntity($errors);

// If rejected, reset to pending for re-review
$status = ($recipe['status'] === 'rejected' || $data['status'] === 'pending') ? 'pending' : $recipe['status'];

$stmt = $pdo->prepare("UPDATE recipe
                        SET title = ?, description = ?, category = ?, difficulty = ?,
                            prep_time = ?, cook_time = ?, servings = ?, status = ?, updated_at = NOW()
                        WHERE id = ?");
$stmt->execute([$data['title'], $data['description'], $data['category'], $data['difficulty'],
                $data['prep_time'], $data['cook_time'], $data['servings'], $status, $recipeId]);

// Replace ingredients (DELETE + INSERT)
$pdo->prepare("DELETE FROM ingredient WHERE recipe_id = ?")->execute([$recipeId]);
$ingStmt = $pdo->prepare("INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order)
                                  VALUES (?, ?, ?, ?, ?)");
foreach ($data['ingredients'] as $index => $ing) {
    $ingStmt->execute([$recipeId, $ing['name'], $ing['quantity'], $ing['unit'], $index + 1]);
}

// Replace instructions (DELETE + INSERT)
$pdo->prepare("DELETE FROM instruction WHERE recipe_id = ?")->execute([$recipeId]);
$insStmt = $pdo->prepare("INSERT INTO instruction (recipe_id, step_number, instruction_text)
                                     VALUES (?, ?, ?)");
foreach ($data['instructions'] as $index => $ins) {
    $insStmt->execute([$recipeId, $index + 1, $ins['instruction_text']]);
}

echo json_encode(['message' => 'Recipe updated successfully']);
```

**5. DELETE /api/recipes/:id — Delete recipe**
```php
$session = validateSession($pdo);
$recipeId = (int) $_GET['id'];

// Verify ownership
$check = $pdo->prepare("SELECT author_id FROM recipe WHERE id = ?");
$check->execute([$recipeId]);
$recipe = $check->fetch();

if (!$recipe || $recipe['author_id'] !== $session['user_id']) {
    send403Forbidden('You can only delete your own recipes');
}

// CASCADE deletes ingredient, instruction, recipe_image, review, favorite, like_record
$stmt = $pdo->prepare("DELETE FROM recipe WHERE id = ?");
$stmt->execute([$recipeId]);

echo json_encode(['message' => 'Recipe deleted successfully']);
```

### Helper Functions

**Recipe Validation:**
```php
function validateRecipeData($data) {
    $errors = [];

    if (empty($data['title']))
        $errors['title'] = 'Title is required';
    if (strlen($data['title']) > 200)
        $errors['title'] = 'Title must be 200 characters or less';

    if (empty($data['category']))
        $errors['category'] = 'Category is required';
    $validCategories = ['Italian', 'Mexican', 'Asian', 'American', 'Mediterranean',
                      'Vegetarian', 'Quick Meals', 'Dessert', 'Comfort Food'];
    if (!in_array($data['category'], $validCategories))
        $errors['category'] = 'Invalid category';

    if (empty($data['difficulty']))
        $errors['difficulty'] = 'Difficulty is required';
    if (!in_array($data['difficulty'], ['Easy', 'Medium', 'Hard']))
        $errors['difficulty'] = 'Difficulty must be Easy, Medium, or Hard';

    if (!is_array($data['ingredients']) || empty($data['ingredients']))
        $errors['ingredients'] = 'At least one ingredient is required';

    if (!is_array($data['instructions']) || empty($data['instructions']))
        $errors['instructions'] = 'At least one instruction step is required';

    return $errors;
}
```

---

## Frontend Integration (Phase 5)

### Component Updates Required

**1. Home.jsx — Use API for recipe listing**
```javascript
// Before: localStorage
const recipes = storage.loadRecipes();

// After: API call
const response = await fetchWithAuth('/api/recipes', {
    method: 'GET'
});
const recipes = await response.json();
```

**2. Search.jsx — URL params + API**
```javascript
// Current: localStorage filtering
const filtered = recipes.filter(r => ...);

// After: Server-side filtering
const params = new URLSearchParams({
    search: keyword,
    category: selectedCategories.join(','),
    difficulty: difficulty,
    sort: sortOrder,
    order: 'DESC'
});
const response = await fetchWithAuth(`/api/recipes?${params}`);
```

**3. RecipeDetail.jsx — View tracking + interactions**
```javascript
// View tracking
useEffect(() => {
    fetchWithAuth('/api/recipes/view', {
        method: 'POST',
        body: JSON.stringify({ recipe_id: recipe.id })
    });
}, [recipe.id]);

// Like toggle
const toggleLike = async () => {
    await fetchWithAuth('/api/likes/toggle', {
        method: 'POST',
        body: JSON.stringify({ recipe_id: recipe.id })
    });
    // Re-fetch recipe to get updated like count
};

// Favorite toggle
const toggleFavorite = async () => {
    await fetchWithAuth('/api/favorites/toggle', {
        method: 'POST',
        body: JSON.stringify({ recipe_id: recipe.id })
    });
};
```

**4. CreateRecipe.jsx — Form submission to API**
```javascript
const handleSubmit = async (e) => {
    e.preventDefault();

    // Collect form data
    const recipeData = {
        title,
        description,
        category,
        difficulty,
        prep_time: parseInt(prepTime),
        cook_time: parseInt(cookTime),
        servings: parseInt(servings),
        ingredients: ingredients.map(i => ({
            name: i.name,
            quantity: i.quantity,
            unit: i.unit
        })),
        instructions: instructions.map((ins, idx) => ({
            instruction_text: ins.text
        }))
    };

    const response = await fetchWithAuth('/api/recipes', {
        method: 'POST',
        body: JSON.stringify(recipeData)
    });

    if (response.ok) {
        const result = await response.json();
        navigate(`/recipe/${result.id}`); // Redirect to recipe detail
    }
};
```

**5. Profile.jsx — API data fetching**
```javascript
// My Recipes tab
const recipesResponse = await fetchWithAuth(`/api/user/recipes`);
const recipes = await recipesResponse.json();

// My Favorites tab
const favoritesResponse = await fetchWithAuth(`/api/user/favorites`);
const favorites = await favoritesResponse.json();
```

---

## Related Files

**Database Schema:**
- [database/02_create_tables.sql](../../database/02_create_tables.sql) — Recipe tables lines 79-155
- [database/06_seed_recipes.sql](../../database/06_seed_recipes.sql) — Sample data (13 recipes)
- [database/09_common_queries.sql](../../database/09_common_queries.sql) — Query-1, Query-2 for listing

**Components:**
- [Home.jsx](../../src/pages/Recipe/Home.jsx) — Recipe cards component
- [Search.jsx](../../src/pages/Recipe/Search.jsx) — Search + filter component
- [RecipeDetail.jsx](../../src/pages/Recipe/RecipeDetail.jsx) — Full recipe view
- [CreateRecipe.jsx](../../src/pages/Recipe/CreateRecipe.jsx) — Recipe form component
- [Profile.jsx](../../src/pages/Recipe/Profile.jsx) — User profile component

**Storage:**
- [lib/storage.js](../../src/lib/storage.js) — Current localStorage implementation (to be removed)
- [context/AuthContext.jsx](../../src/context/AuthContext.jsx) — Session auth integration

---

## Next Steps

### Phase 4: Backend Tasks
1. ✅ Execute SQL scripts 01-14 (completed Feb 13, 2026)
2. **NEXT:** Implement `api/recipes.php` with GET/POST/PUT/DELETE endpoints
3. Implement `api/likes.php` with toggle endpoint
4. Implement `api/favorites.php` with toggle endpoint
5. Implement `api/reviews.php` with submit/delete endpoints

### Phase 5: Frontend Tasks
1. Create `src/api.js` helper file with `fetchWithAuth()` function
2. Update `Home.jsx` to use API recipe listing
3. Update `Search.jsx` to use API with URL params
4. Update `RecipeDetail.jsx` for view tracking + interactions
5. Update `CreateRecipe.jsx` for form submission
6. Update `Profile.jsx` for API data fetching
7. Remove `lib/storage.js` after migration complete
