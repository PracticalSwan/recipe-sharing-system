<?php
// Recipes API: CRUD + like, favorite, view actions
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/cors.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/../helpers/response.php';

setCorsHeaders();
initializeErrorHandling();

$pdo = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$route = $_GET['route'] ?? '';

// Parse route: "5/like" → ['5', 'like']
$segments = $route ? array_filter(explode('/', $route)) : [];
$segments = array_values($segments);

// Route dispatcher
if (empty($segments)) {
    handleRecipesList($pdo, $method);
} elseif (count($segments) === 1 && is_numeric($segments[0])) {
    handleRecipeById($pdo, $method, (int) $segments[0]);
} elseif (count($segments) === 2 && is_numeric($segments[0])) {
    $recipeId = (int) $segments[0];
    switch ($segments[1]) {
        case 'status':   handleRecipeStatus($pdo, $method, $recipeId);   break;
        case 'like':     handleRecipeLike($pdo, $method, $recipeId);     break;
        case 'favorite': handleRecipeFavorite($pdo, $method, $recipeId); break;
        case 'view':     handleRecipeView($pdo, $method, $recipeId);     break;
        default:         errorResponse('Not found', 404);
    }
} else {
    errorResponse('Not found', 404);
}

// GET /api/recipes — List with filters, sorting, pagination
// POST /api/recipes — Create new recipe
function handleRecipesList(PDO $pdo, string $method): void {
    if ($method === 'POST') {
        handleCreateRecipe($pdo);
        return;
    }
    if ($method !== 'GET') {
        errorResponse('Method not allowed', 405);
    }

    $currentUser = getCurrentUser($pdo);
    $currentUserId = $currentUser ? (int) $currentUser['id'] : null;

    $status      = $_GET['status'] ?? 'published';
    $category    = $_GET['category'] ?? null;
    $difficulty  = $_GET['difficulty'] ?? null;
    $authorId    = isset($_GET['authorId']) ? (int) $_GET['authorId'] : null;
    $sort        = $_GET['sort'] ?? 'newest';
    $page        = max(1, (int) ($_GET['page'] ?? 1));
    $limit       = min(50, max(1, (int) ($_GET['limit'] ?? 12)));
    $offset      = ($page - 1) * $limit;

    $where = [];
    $params = [];

    $isAdmin = $currentUser && $currentUser['role'] === 'admin';
    $isOwnAuthorView = $authorId && $currentUserId && $authorId === $currentUserId;

    // Non-admin, non-owner can only see published
    if (!$isAdmin && !$isOwnAuthorView && $status !== 'published') {
        $status = 'published';
    }

    if ($status !== 'all') {
        $where[] = "r.status = :status";
        $params[':status'] = $status;
    }

    if ($category) {
        $where[] = "r.category LIKE :category";
        $params[':category'] = '%' . $category . '%';
    }
    if ($difficulty) {
        $where[] = "r.difficulty = :difficulty";
        $params[':difficulty'] = $difficulty;
    }
    if ($authorId) {
        $where[] = "r.author_id = :author_id";
        $params[':author_id'] = $authorId;
    }

    $orderBy = match ($sort) {
        'oldest'   => 'r.created_at ASC',
        'popular'  => 'like_count DESC, r.created_at DESC',
        'rating'   => 'avg_rating DESC, r.created_at DESC',
        default    => 'r.created_at DESC',
    };

    $whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

    $countSql = "SELECT COUNT(*) FROM recipe r $whereClause";
    $countStmt = $pdo->prepare($countSql);
    $countStmt->execute($params);
    $total = (int) $countStmt->fetchColumn();

    $sql = "
        SELECT r.*,
               u.username AS author_username, u.avatar_url AS author_avatar,
               u.first_name AS author_first_name, u.last_name AS author_last_name,
               COALESCE(lc.like_count, 0) AS like_count,
               COALESCE(vc.view_count, 0) AS view_count,
               COALESCE(rc.review_count, 0) AS review_count,
               COALESCE(rc.avg_rating, 0) AS avg_rating,
               (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order ASC LIMIT 1) AS main_image
        FROM recipe r
        JOIN user u ON r.author_id = u.id
        LEFT JOIN (SELECT recipe_id, COUNT(*) AS like_count FROM like_record GROUP BY recipe_id) lc ON lc.recipe_id = r.id
        LEFT JOIN (SELECT recipe_id, COUNT(*) AS view_count FROM recipe_view GROUP BY recipe_id) vc ON vc.recipe_id = r.id
        LEFT JOIN (SELECT recipe_id, COUNT(*) AS review_count, AVG(rating) AS avg_rating FROM review GROUP BY recipe_id) rc ON rc.recipe_id = r.id
        $whereClause
        ORDER BY $orderBy
        LIMIT :limit OFFSET :offset
    ";

    $stmt = $pdo->prepare($sql);
    foreach ($params as $key => $val) {
        $stmt->bindValue($key, $val);
    }
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();
    $recipes = $stmt->fetchAll();

    // Batch-fetch like/favorite status (avoid N+1)
    $likedSet = [];
    $favoritedSet = [];
    if ($currentUserId && !empty($recipes)) {
        $recipeIds = array_column($recipes, 'id');
        $placeholders = implode(',', array_fill(0, count($recipeIds), '?'));

        $likeStmt = $pdo->prepare("SELECT recipe_id FROM like_record WHERE user_id = ? AND recipe_id IN ($placeholders)");
        $likeStmt->execute(array_merge([$currentUserId], $recipeIds));
        $likedSet = array_flip($likeStmt->fetchAll(PDO::FETCH_COLUMN));

        $favStmt = $pdo->prepare("SELECT recipe_id FROM favorite WHERE user_id = ? AND recipe_id IN ($placeholders)");
        $favStmt->execute(array_merge([$currentUserId], $recipeIds));
        $favoritedSet = array_flip($favStmt->fetchAll(PDO::FETCH_COLUMN));
    }

    $items = array_map(function ($r) use ($likedSet, $favoritedSet) {
        return formatRecipeListItem($r, $likedSet, $favoritedSet);
    }, $recipes);

    jsonResponse([
        'recipes'    => $items,
        'pagination' => [
            'page'       => $page,
            'limit'      => $limit,
            'total'      => $total,
            'totalPages' => (int) ceil($total / $limit),
        ],
    ]);
}

// POST /api/recipes — Create recipe (status='pending', requires approval)
function handleCreateRecipe(PDO $pdo): void {
    $user = requireAuth($pdo);
    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data) {
        errorResponse('Invalid JSON body');
    }

    if (empty($data['title'])) {
        errorResponse('Title is required');
    }

    // Categories: array → comma-separated string
    $category = '';
    if (!empty($data['categories'])) {
        $cats = is_array($data['categories']) ? $data['categories'] : [$data['categories']];
        $category = implode(',', array_map('trim', $cats));
    } elseif (!empty($data['category'])) {
        $category = trim($data['category']);
    }

    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare("
            INSERT INTO recipe (title, description, category, difficulty, prep_time, cook_time, servings, author_id, status)
            VALUES (:title, :description, :category, :difficulty, :prep_time, :cook_time, :servings, :author_id, :status)
        ");
        $stmt->execute([
            ':title'       => trim($data['title']),
            ':description' => trim($data['description'] ?? ''),
            ':category'    => $category,
            ':difficulty'  => $data['difficulty'] ?? 'Easy',
            ':prep_time'   => (int) ($data['prepTime'] ?? 0),
            ':cook_time'   => (int) ($data['cookTime'] ?? 0),
            ':servings'    => (int) ($data['servings'] ?? 1),
            ':author_id'   => $user['id'],
            ':status'      => 'pending',
        ]);

        $recipeId = (int) $pdo->lastInsertId();

        // Insert ingredients with sort_order
        if (!empty($data['ingredients']) && is_array($data['ingredients'])) {
            $ingStmt = $pdo->prepare("
                INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order)
                VALUES (:recipe_id, :name, :quantity, :unit, :sort_order)
            ");
            foreach ($data['ingredients'] as $i => $ing) {
                $ingStmt->execute([
                    ':recipe_id'  => $recipeId,
                    ':name'       => trim($ing['name'] ?? ''),
                    ':quantity'   => trim($ing['quantity'] ?? ''),
                    ':unit'       => trim($ing['unit'] ?? ''),
                    ':sort_order' => $i + 1,
                ]);
            }
        }

        // Insert instructions
        if (!empty($data['instructions']) && is_array($data['instructions'])) {
            $insStmt = $pdo->prepare("
                INSERT INTO instruction (recipe_id, step_number, instruction_text)
                VALUES (:recipe_id, :step_number, :instruction_text)
            ");
            foreach ($data['instructions'] as $i => $text) {
                $instruction = is_array($text) ? ($text['text'] ?? $text['instruction'] ?? '') : $text;
                $insStmt->execute([
                    ':recipe_id'        => $recipeId,
                    ':step_number'      => $i + 1,
                    ':instruction_text' => trim($instruction),
                ]);
            }
        }

        // Insert images
        if (!empty($data['images']) && is_array($data['images'])) {
            $imgStmt = $pdo->prepare("
                INSERT INTO recipe_image (recipe_id, image_url, display_order)
                VALUES (:recipe_id, :image_url, :display_order)
            ");
            foreach ($data['images'] as $i => $img) {
                $url = is_array($img) ? ($img['url'] ?? $img['image_url'] ?? '') : $img;
                $imgStmt->execute([
                    ':recipe_id'     => $recipeId,
                    ':image_url'     => trim($url),
                    ':display_order' => $i + 1,
                ]);
            }
        }

        $pdo->commit();

        $recipe = fetchFullRecipe($pdo, $recipeId, (int) $user['id']);
        jsonResponse($recipe, 201);

    } catch (\Exception $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        errorResponse('Failed to create recipe', 500, 'recipe_create_failed');
    }
}

// GET/PUT/DELETE /api/recipes/{id} dispatcher
function handleRecipeById(PDO $pdo, string $method, int $id): void {
    switch ($method) {
        case 'GET':    handleGetRecipe($pdo, $id);     break;
        case 'PUT':    handleUpdateRecipe($pdo, $id);  break;
        case 'DELETE': handleDeleteRecipe($pdo, $id);  break;
        default:       errorResponse('Method not allowed', 405);
    }
}

// GET /api/recipes/{id} — Full recipe detail
function handleGetRecipe(PDO $pdo, int $id): void {
    $currentUser = getCurrentUser($pdo);
    $currentUserId = $currentUser ? (int) $currentUser['id'] : null;

    $recipe = fetchFullRecipe($pdo, $id, $currentUserId);
    if (!$recipe) {
        errorResponse('Recipe not found', 404);
    }

    // Authorization: non-published recipes only visible to author/admin
    if ($recipe['status'] !== 'published') {
        $isAdmin = $currentUser && $currentUser['role'] === 'admin';
        $isAuthor = $currentUserId && (int)$recipe['author']['id'] === $currentUserId;
        if (!$isAdmin && !$isAuthor) {
            errorResponse('Recipe not found', 404);
        }
    }

    jsonResponse($recipe);
}

// PUT /api/recipes/{id} — Update recipe (owner or admin)
function handleUpdateRecipe(PDO $pdo, int $id): void {
    $user = requireAuth($pdo);
    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data) {
        errorResponse('Invalid JSON body');
    }

    $stmt = $pdo->prepare("SELECT author_id, status FROM recipe WHERE id = :id");
    $stmt->execute([':id' => $id]);
    $recipe = $stmt->fetch();
    if (!$recipe) {
        errorResponse('Recipe not found', 404);
    }
    // Only the recipe author can edit (admins cannot edit content)
    if ((int) $recipe['author_id'] !== (int) $user['id']) {
        errorResponse('Not authorized', 403);
    }

    // Explicitly block admins from editing recipe content
    if ($user['role'] === 'admin') {
        errorResponse('Admins cannot edit recipe content. Use the status endpoint to approve/reject.', 403);
    }

    // Always require re-approval when recipe is edited
    $nextStatus = 'pending';

    $category = '';
    if (!empty($data['categories'])) {
        $cats = is_array($data['categories']) ? $data['categories'] : [$data['categories']];
        $category = implode(',', array_map('trim', $cats));
    } elseif (!empty($data['category'])) {
        $category = trim($data['category']);
    }

    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare("
            UPDATE recipe SET
                title = :title, description = :description, category = :category,
                difficulty = :difficulty, prep_time = :prep_time, cook_time = :cook_time,
                servings = :servings, status = :status
            WHERE id = :id
        ");
        $stmt->execute([
            ':title'       => trim($data['title'] ?? ''),
            ':description' => trim($data['description'] ?? ''),
            ':category'    => $category,
            ':difficulty'  => $data['difficulty'] ?? 'Easy',
            ':prep_time'   => (int) ($data['prepTime'] ?? 0),
            ':cook_time'   => (int) ($data['cookTime'] ?? 0),
            ':servings'    => (int) ($data['servings'] ?? 1),
            ':status'      => $nextStatus,
            ':id'          => $id,
        ]);

        // Replace ingredients (delete + re-insert)
        $pdo->prepare("DELETE FROM ingredient WHERE recipe_id = :id")->execute([':id' => $id]);
        if (!empty($data['ingredients']) && is_array($data['ingredients'])) {
            $ingStmt = $pdo->prepare("
                INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order)
                VALUES (:recipe_id, :name, :quantity, :unit, :sort_order)
            ");
            foreach ($data['ingredients'] as $i => $ing) {
                $ingStmt->execute([
                    ':recipe_id'  => $id,
                    ':name'       => trim($ing['name'] ?? ''),
                    ':quantity'   => trim($ing['quantity'] ?? ''),
                    ':unit'       => trim($ing['unit'] ?? ''),
                    ':sort_order' => $i + 1,
                ]);
            }
        }

        // Replace instructions
        $pdo->prepare("DELETE FROM instruction WHERE recipe_id = :id")->execute([':id' => $id]);
        if (!empty($data['instructions']) && is_array($data['instructions'])) {
            $insStmt = $pdo->prepare("
                INSERT INTO instruction (recipe_id, step_number, instruction_text)
                VALUES (:recipe_id, :step_number, :instruction_text)
            ");
            foreach ($data['instructions'] as $i => $text) {
                $instruction = is_array($text) ? ($text['text'] ?? $text['instruction'] ?? '') : $text;
                $insStmt->execute([
                    ':recipe_id'        => $id,
                    ':step_number'      => $i + 1,
                    ':instruction_text' => trim($instruction),
                ]);
            }
        }

        // Replace images
        $pdo->prepare("DELETE FROM recipe_image WHERE recipe_id = :id")->execute([':id' => $id]);
        if (!empty($data['images']) && is_array($data['images'])) {
            $imgStmt = $pdo->prepare("
                INSERT INTO recipe_image (recipe_id, image_url, display_order)
                VALUES (:recipe_id, :image_url, :display_order)
            ");
            foreach ($data['images'] as $i => $img) {
                $url = is_array($img) ? ($img['url'] ?? $img['image_url'] ?? '') : $img;
                $imgStmt->execute([
                    ':recipe_id'     => $id,
                    ':image_url'     => trim($url),
                    ':display_order' => $i + 1,
                ]);
            }
        }

        $pdo->commit();
        $recipe = fetchFullRecipe($pdo, $id, (int) $user['id']);
        jsonResponse($recipe);

    } catch (\Exception $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        errorResponse('Failed to update recipe', 500, 'recipe_update_failed');
    }
}

// DELETE /api/recipes/{id} — Delete recipe and related data
function handleDeleteRecipe(PDO $pdo, int $id): void {
    $user = requireAuth($pdo);

    $stmt = $pdo->prepare("SELECT author_id FROM recipe WHERE id = :id");
    $stmt->execute([':id' => $id]);
    $recipe = $stmt->fetch();
    if (!$recipe) {
        errorResponse('Recipe not found', 404);
    }
    if ((int) $recipe['author_id'] !== (int) $user['id'] && $user['role'] !== 'admin') {
        errorResponse('Not authorized', 403);
    }

    $pdo->beginTransaction();
    try {
        $pdo->prepare("DELETE FROM ingredient WHERE recipe_id = :id")->execute([':id' => $id]);
        $pdo->prepare("DELETE FROM instruction WHERE recipe_id = :id")->execute([':id' => $id]);
        $pdo->prepare("DELETE FROM recipe_image WHERE recipe_id = :id")->execute([':id' => $id]);
        $pdo->prepare("DELETE FROM review WHERE recipe_id = :id")->execute([':id' => $id]);
        $pdo->prepare("DELETE FROM like_record WHERE recipe_id = :id")->execute([':id' => $id]);
        $pdo->prepare("DELETE FROM favorite WHERE recipe_id = :id")->execute([':id' => $id]);
        $pdo->prepare("DELETE FROM recipe_view WHERE recipe_id = :id")->execute([':id' => $id]);
        $pdo->prepare("DELETE FROM recipe WHERE id = :id")->execute([':id' => $id]);
        $pdo->commit();
        successResponse(null, 'Recipe deleted');
    } catch (\Exception $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        errorResponse('Failed to delete recipe', 500, 'recipe_delete_failed');
    }
}

// PUT /api/recipes/{id}/status — Admin: approve/reject recipe
function handleRecipeStatus(PDO $pdo, string $method, int $recipeId): void {
    if ($method !== 'PUT') {
        errorResponse('Method not allowed', 405);
    }

    $user = requireAdmin($pdo);
    $data = json_decode(file_get_contents('php://input'), true);

    if (empty($data['status']) || !in_array($data['status'], ['published', 'pending', 'rejected'])) {
        errorResponse('Valid status required (published, pending, rejected)');
    }

    $stmt = $pdo->prepare("SELECT id FROM recipe WHERE id = :id");
    $stmt->execute([':id' => $recipeId]);
    if (!$stmt->fetch()) {
        errorResponse('Recipe not found', 404);
    }

    $pdo->prepare("UPDATE recipe SET status = :status WHERE id = :id")
        ->execute([':status' => $data['status'], ':id' => $recipeId]);

    // Log admin activity
    $actionType = $data['status'] === 'published' ? 'recipe_approve' : ($data['status'] === 'rejected' ? 'recipe_reject' : 'recipe_approve');
    $pdo->prepare("
        INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
        VALUES (:admin_id, :action_type, 'recipe', :target_id, :description)
    ")->execute([
        ':admin_id'    => $user['id'],
        ':action_type' => $actionType,
        ':target_id'   => $recipeId,
        ':description' => "Recipe status changed to {$data['status']}",
    ]);

    successResponse(null, "Recipe status updated to {$data['status']}");
}

// POST /api/recipes/{id}/like — Toggle like
function handleRecipeLike(PDO $pdo, string $method, int $recipeId): void {
    if ($method !== 'POST') {
        errorResponse('Method not allowed', 405);
    }

    $user = requireAuth($pdo);

    $stmt = $pdo->prepare("SELECT id FROM recipe WHERE id = :id");
    $stmt->execute([':id' => $recipeId]);
    if (!$stmt->fetch()) {
        errorResponse('Recipe not found', 404);
    }

    // Toggle: check if exists
    $stmt = $pdo->prepare("SELECT id FROM like_record WHERE user_id = :user_id AND recipe_id = :recipe_id");
    $stmt->execute([':user_id' => $user['id'], ':recipe_id' => $recipeId]);
    $existing = $stmt->fetch();

    if ($existing) {
        $pdo->prepare("DELETE FROM like_record WHERE id = :id")->execute([':id' => $existing['id']]);
        $liked = false;
    } else {
        $pdo->prepare("INSERT INTO like_record (user_id, recipe_id) VALUES (:user_id, :recipe_id)")
            ->execute([':user_id' => $user['id'], ':recipe_id' => $recipeId]);
        $liked = true;
    }

    $stmt = $pdo->prepare("SELECT COUNT(*) FROM like_record WHERE recipe_id = :recipe_id");
    $stmt->execute([':recipe_id' => $recipeId]);
    $likeCount = (int) $stmt->fetchColumn();

    jsonResponse(['liked' => $liked, 'likeCount' => $likeCount]);
}

// POST /api/recipes/{id}/favorite — Toggle bookmark
function handleRecipeFavorite(PDO $pdo, string $method, int $recipeId): void {
    if ($method !== 'POST') {
        errorResponse('Method not allowed', 405);
    }

    $user = requireAuth($pdo);

    $stmt = $pdo->prepare("SELECT id FROM recipe WHERE id = :id");
    $stmt->execute([':id' => $recipeId]);
    if (!$stmt->fetch()) {
        errorResponse('Recipe not found', 404);
    }

    $stmt = $pdo->prepare("SELECT id FROM favorite WHERE user_id = :user_id AND recipe_id = :recipe_id");
    $stmt->execute([':user_id' => $user['id'], ':recipe_id' => $recipeId]);
    $existing = $stmt->fetch();

    if ($existing) {
        $pdo->prepare("DELETE FROM favorite WHERE id = :id")->execute([':id' => $existing['id']]);
        $favorited = false;
    } else {
        $pdo->prepare("INSERT INTO favorite (user_id, recipe_id) VALUES (:user_id, :recipe_id)")
            ->execute([':user_id' => $user['id'], ':recipe_id' => $recipeId]);
        $favorited = true;
    }

    jsonResponse(['favorited' => $favorited]);
}

// POST /api/recipes/{id}/view — Record unique view per user (any authenticated user, including pending/suspended)
function handleRecipeView(PDO $pdo, string $method, int $recipeId): void {
    if ($method !== 'POST') {
        errorResponse('Method not allowed', 405);
    }

    $user = getCurrentUser($pdo);
    if (!$user) {
        errorResponse('Authentication required', 401);
    }
    $userId = (int) $user['id'];

    $stmt = $pdo->prepare("SELECT id FROM recipe WHERE id = :id");
    $stmt->execute([':id' => $recipeId]);
    if (!$stmt->fetch()) {
        errorResponse('Recipe not found', 404);
    }

    // Only record if not viewed before by this user
    $stmt = $pdo->prepare("SELECT id FROM recipe_view WHERE recipe_id = :recipe_id AND user_id = :user_id LIMIT 1");
    $stmt->execute([':recipe_id' => $recipeId, ':user_id' => $userId]);
    $existingView = $stmt->fetch();

    $viewRecorded = false;
    if (!$existingView) {
        $pdo->prepare("INSERT INTO recipe_view (recipe_id, user_id, viewed_at) VALUES (:recipe_id, :user_id, NOW())")
            ->execute([':recipe_id' => $recipeId, ':user_id' => $userId]);
        $viewRecorded = true;
    }

    $stmt = $pdo->prepare("SELECT COUNT(*) FROM recipe_view WHERE recipe_id = :recipe_id");
    $stmt->execute([':recipe_id' => $recipeId]);
    $viewCount = (int) $stmt->fetchColumn();

    jsonResponse(['viewRecorded' => $viewRecorded, 'viewCount' => $viewCount]);
}

// Fetch full recipe with all relations
function fetchFullRecipe(PDO $pdo, int $id, ?int $currentUserId): ?array {
    $stmt = $pdo->prepare("
        SELECT r.*,
               u.username AS author_username, u.avatar_url AS author_avatar,
               u.first_name AS author_first_name, u.last_name AS author_last_name,
               COALESCE(lc.like_count, 0) AS like_count,
               COALESCE(vc.view_count, 0) AS view_count
        FROM recipe r
        JOIN user u ON r.author_id = u.id
        LEFT JOIN (SELECT recipe_id, COUNT(*) AS like_count FROM like_record GROUP BY recipe_id) lc ON lc.recipe_id = r.id
        LEFT JOIN (SELECT recipe_id, COUNT(*) AS view_count FROM recipe_view GROUP BY recipe_id) vc ON vc.recipe_id = r.id
        WHERE r.id = :id
    ");
    $stmt->execute([':id' => $id]);
    $recipe = $stmt->fetch();

    if (!$recipe) {
        return null;
    }

    // Ingredients
    $stmt = $pdo->prepare("SELECT id, name, quantity, unit, sort_order FROM ingredient WHERE recipe_id = :id ORDER BY sort_order");
    $stmt->execute([':id' => $id]);
    $ingredients = $stmt->fetchAll();

    // Instructions
    $stmt = $pdo->prepare("SELECT id, step_number, instruction_text FROM instruction WHERE recipe_id = :id ORDER BY step_number");
    $stmt->execute([':id' => $id]);
    $instructions = $stmt->fetchAll();

    // Images
    $stmt = $pdo->prepare("SELECT id, image_url, display_order FROM recipe_image WHERE recipe_id = :id ORDER BY display_order");
    $stmt->execute([':id' => $id]);
    $images = $stmt->fetchAll();

    // Reviews with user info
    $stmt = $pdo->prepare("
        SELECT rv.id, rv.rating, rv.comment, rv.created_at, rv.updated_at,
               u.id AS user_id, u.username, u.avatar_url, u.first_name, u.last_name
        FROM review rv
        JOIN user u ON rv.user_id = u.id
        WHERE rv.recipe_id = :id
        ORDER BY rv.created_at DESC
    ");
    $stmt->execute([':id' => $id]);
    $reviews = $stmt->fetchAll();

    // Check like/favorite status
    $isLiked = false;
    $isFavorited = false;
    if ($currentUserId) {
        $stmt = $pdo->prepare("SELECT id FROM like_record WHERE user_id = :uid AND recipe_id = :rid");
        $stmt->execute([':uid' => $currentUserId, ':rid' => $id]);
        $isLiked = (bool) $stmt->fetch();

        $stmt = $pdo->prepare("SELECT id FROM favorite WHERE user_id = :uid AND recipe_id = :rid");
        $stmt->execute([':uid' => $currentUserId, ':rid' => $id]);
        $isFavorited = (bool) $stmt->fetch();
    }

    // Calculate average rating
    $avgRating = 0;
    if (!empty($reviews)) {
        $avgRating = array_sum(array_column($reviews, 'rating')) / count($reviews);
    }

    return formatRecipeDetail($recipe, $ingredients, $instructions, $images, $reviews, $isLiked, $isFavorited, $avgRating);
}

// Format recipe for list view (compact)
function formatRecipeListItem(array $r, array $likedSet, array $favoritedSet): array {
    $categories = $r['category'] ? array_map('trim', explode(',', $r['category'])) : [];
    return [
        'id'          => (int) $r['id'],
        'title'       => $r['title'],
        'description' => $r['description'],
        'categories'  => $categories,
        'category'    => $r['category'],
        'difficulty'  => $r['difficulty'],
        'prepTime'    => (int) $r['prep_time'],
        'cookTime'    => (int) $r['cook_time'],
        'servings'    => (int) $r['servings'],
        'status'      => $r['status'],
        'createdAt'   => $r['created_at'],
        'updatedAt'   => $r['updated_at'],
        'author'      => [
            'id'        => (int) $r['author_id'],
            'username'  => $r['author_username'],
            'avatarUrl' => $r['author_avatar'],
            'firstName' => $r['author_first_name'],
            'lastName'  => $r['author_last_name'],
        ],
        'likeCount'    => (int) $r['like_count'],
        'viewCount'    => (int) $r['view_count'],
        'reviewCount'  => (int) $r['review_count'],
        'avgRating'    => round((float) $r['avg_rating'], 1),
        'isLiked'      => isset($likedSet[(int) $r['id']]),
        'isFavorited'  => isset($favoritedSet[(int) $r['id']]),
        'image'        => $r['main_image'] ?? null,
    ];
}

// Format recipe for detail view (full)
function formatRecipeDetail(
    array $recipe, array $ingredients, array $instructions, array $images,
    array $reviews, bool $isLiked, bool $isFavorited, float $avgRating
): array {
    $categories = $recipe['category'] ? array_map('trim', explode(',', $recipe['category'])) : [];

    return [
        'id'          => (int) $recipe['id'],
        'title'       => $recipe['title'],
        'description' => $recipe['description'],
        'categories'  => $categories,
        'category'    => $recipe['category'],
        'difficulty'  => $recipe['difficulty'],
        'prepTime'    => (int) $recipe['prep_time'],
        'cookTime'    => (int) $recipe['cook_time'],
        'servings'    => (int) $recipe['servings'],
        'status'      => $recipe['status'],
        'createdAt'   => $recipe['created_at'],
        'updatedAt'   => $recipe['updated_at'],
        'author'      => [
            'id'        => (int) $recipe['author_id'],
            'username'  => $recipe['author_username'],
            'avatarUrl' => $recipe['author_avatar'],
            'firstName' => $recipe['author_first_name'],
            'lastName'  => $recipe['author_last_name'],
        ],
        'ingredients' => array_map(fn($i) => [
            'id'        => (int) $i['id'],
            'name'      => $i['name'],
            'quantity'  => $i['quantity'],
            'unit'      => $i['unit'],
            'sortOrder' => (int) $i['sort_order'],
        ], $ingredients),
        'instructions' => array_map(fn($i) => [
            'id'         => (int) $i['id'],
            'stepNumber' => (int) $i['step_number'],
            'text'       => $i['instruction_text'],
        ], $instructions),
        'images' => array_map(fn($i) => [
            'id'           => (int) $i['id'],
            'url'          => $i['image_url'],
            'displayOrder' => (int) $i['display_order'],
        ], $images),
        'reviews' => array_map(fn($rv) => [
            'id'        => (int) $rv['id'],
            'rating'    => (int) $rv['rating'],
            'comment'   => $rv['comment'],
            'createdAt' => $rv['created_at'],
            'updatedAt' => $rv['updated_at'],
            'user'      => [
                'id'        => (int) $rv['user_id'],
                'username'  => $rv['username'],
                'avatarUrl' => $rv['avatar_url'],
                'firstName' => $rv['first_name'],
                'lastName'  => $rv['last_name'],
            ],
        ], $reviews),
        'likeCount'    => (int) $recipe['like_count'],
        'viewCount'    => (int) $recipe['view_count'],
        'reviewCount'  => count($reviews),
        'avgRating'    => round($avgRating, 1),
        'isLiked'      => $isLiked,
        'isFavorited'  => $isFavorited,
    ];
}
