<?php
// ============================================================================
// Search API Endpoints
// GET    /api/search             - Search recipes
// GET    /api/search/history     - Get user's search history
// POST   /api/search/history     - Save search term
// DELETE /api/search/history     - Clear search history
// DELETE /api/search/history/{id} - Delete single history entry
// ============================================================================

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/cors.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/../helpers/response.php';

setCorsHeaders();

$pdo = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$route = $_GET['route'] ?? '';

$segments = $route ? array_values(array_filter(explode('/', $route))) : [];

if (empty($segments)) {
    handleSearch($pdo, $method);
} elseif ($segments[0] === 'history') {
    if (count($segments) === 1) {
        handleSearchHistory($pdo, $method);
    } elseif (count($segments) === 2 && is_numeric($segments[1])) {
        handleDeleteHistoryItem($pdo, $method, (int) $segments[1]);
    } else {
        errorResponse('Not found', 404);
    }
} else {
    errorResponse('Not found', 404);
}

// ============================================================================
// GET /api/search - Search recipes
// ============================================================================
function handleSearch(PDO $pdo, string $method): void {
    if ($method !== 'GET') {
        errorResponse('Method not allowed', 405);
    }

    $query      = trim($_GET['q'] ?? '');
    $category   = $_GET['category'] ?? null;
    $difficulty  = $_GET['difficulty'] ?? null;
    $page       = max(1, (int) ($_GET['page'] ?? 1));
    $limit      = min(50, max(1, (int) ($_GET['limit'] ?? 20)));
    $offset     = ($page - 1) * $limit;

    $where = ["r.status = 'published'"];
    $params = [];

    if ($query !== '') {
        $where[] = "(r.title LIKE :q1 OR r.description LIKE :q2)";
        $params[':q1'] = '%' . $query . '%';
        $params[':q2'] = '%' . $query . '%';
    }
    if ($category) {
        $where[] = "r.category LIKE :cat";
        $params[':cat'] = '%' . $category . '%';
    }
    if ($difficulty) {
        $where[] = "r.difficulty = :diff";
        $params[':diff'] = $difficulty;
    }

    $whereClause = 'WHERE ' . implode(' AND ', $where);

    // Count
    $countStmt = $pdo->prepare("SELECT COUNT(*) FROM recipe r $whereClause");
    $countStmt->execute($params);
    $total = (int) $countStmt->fetchColumn();

    // Results with stats
    $sql = "
        SELECT r.*, u.username AS author_name, u.avatar_url AS author_avatar,
               u.first_name AS author_first_name, u.last_name AS author_last_name,
               COALESCE(lc.like_count, 0) AS like_count,
               COALESCE(vc.view_count, 0) AS view_count,
               COALESCE(rvc.review_count, 0) AS review_count,
               COALESCE(rvc.avg_rating, 0) AS avg_rating,
               (SELECT image_url FROM recipe_image WHERE recipe_id = r.id ORDER BY display_order ASC LIMIT 1) AS main_image
        FROM recipe r
        JOIN user u ON u.id = r.author_id
        LEFT JOIN (SELECT recipe_id, COUNT(*) AS like_count FROM like_record GROUP BY recipe_id) lc ON lc.recipe_id = r.id
        LEFT JOIN (SELECT recipe_id, COUNT(*) AS view_count FROM recipe_view GROUP BY recipe_id) vc ON vc.recipe_id = r.id
        LEFT JOIN (SELECT recipe_id, COUNT(*) AS review_count, AVG(rating) AS avg_rating FROM review GROUP BY recipe_id) rvc ON rvc.recipe_id = r.id
        $whereClause
        ORDER BY r.created_at DESC
        LIMIT :limit OFFSET :offset
    ";

    $stmt = $pdo->prepare($sql);
    foreach ($params as $k => $v) {
        $stmt->bindValue($k, $v);
    }
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();
    $recipes = $stmt->fetchAll();

    $user = getCurrentUser($pdo);
    $likedMap = [];
    $favMap = [];
    if ($user) {
        $recipeIds = array_map(fn($r) => (int)$r['id'], $recipes);
        if (!empty($recipeIds)) {
            $ph = implode(',', array_fill(0, count($recipeIds), '?'));
            $ls = $pdo->prepare("SELECT recipe_id FROM like_record WHERE user_id = ? AND recipe_id IN ($ph)");
            $ls->execute(array_merge([$user['id']], $recipeIds));
            $likedMap = array_flip($ls->fetchAll(PDO::FETCH_COLUMN));

            $fs = $pdo->prepare("SELECT recipe_id FROM favorite WHERE user_id = ? AND recipe_id IN ($ph)");
            $fs->execute(array_merge([$user['id']], $recipeIds));
            $favMap = array_flip($fs->fetchAll(PDO::FETCH_COLUMN));
        }
    }

    $formatted = array_map(fn($r) => [
        'id'          => (int) $r['id'],
        'title'       => $r['title'],
        'description' => $r['description'],
        'categories'  => $r['category'] ? array_map('trim', explode(',', $r['category'])) : [],
        'category'    => $r['category'],
        'difficulty'  => $r['difficulty'],
        'prepTime'    => (int) $r['prep_time'],
        'cookTime'    => (int) $r['cook_time'],
        'servings'    => (int) $r['servings'],
        'status'      => $r['status'],
        'createdAt'   => $r['created_at'],
        'author'      => [
            'id'        => (int) $r['author_id'],
            'username'  => $r['author_name'],
            'avatarUrl' => $r['author_avatar'],
            'firstName' => $r['author_first_name'],
            'lastName'  => $r['author_last_name'],
        ],
        'image'       => $r['main_image'] ?? null,
        'likeCount'   => (int) $r['like_count'],
        'viewCount'   => (int) $r['view_count'],
        'reviewCount' => (int) $r['review_count'],
        'avgRating'   => round((float) $r['avg_rating'], 1),
        'isLiked'     => isset($likedMap[$r['id']]),
        'isFavorited' => isset($favMap[$r['id']]),
    ], $recipes);

    jsonResponse([
        'recipes'    => $formatted,
        'query'      => $query,
        'pagination' => [
            'page'       => $page,
            'limit'      => $limit,
            'total'      => $total,
            'totalPages' => (int) ceil($total / $limit),
        ],
    ]);
}

// ============================================================================
// Search History
// ============================================================================
function handleSearchHistory(PDO $pdo, string $method): void {
    switch ($method) {
        case 'GET':
            handleGetHistory($pdo);
            break;
        case 'POST':
            handleSaveHistory($pdo);
            break;
        case 'DELETE':
            handleClearHistory($pdo);
            break;
        default:
            errorResponse('Method not allowed', 405);
    }
}

function handleGetHistory(PDO $pdo): void {
    $user = requireAuth($pdo);
    $stmt = $pdo->prepare("
        SELECT id, search_term AS query, results_count AS resultsCount, searched_at AS searchedAt
        FROM search_history
        WHERE user_id = :uid
        ORDER BY searched_at DESC
        LIMIT 20
    ");
    $stmt->execute([':uid' => $user['id']]);
    jsonResponse(['history' => $stmt->fetchAll()]);
}

function handleSaveHistory(PDO $pdo): void {
    $user = requireAuth($pdo);
    $data = json_decode(file_get_contents('php://input'), true);

    $term = trim($data['query'] ?? $data['searchTerm'] ?? '');
    if ($term === '') {
        errorResponse('Search term required');
    }

    $stmt = $pdo->prepare("
        INSERT INTO search_history (user_id, search_term, results_count)
        VALUES (:uid, :term, :count)
    ");
    $stmt->execute([
        ':uid'   => $user['id'],
        ':term'  => $term,
        ':count' => (int) ($data['resultsCount'] ?? 0),
    ]);

    successResponse(null, 'Search saved', 201);
}

function handleClearHistory(PDO $pdo): void {
    $user = requireAuth($pdo);
    $pdo->prepare("DELETE FROM search_history WHERE user_id = :uid")->execute([':uid' => $user['id']]);
    successResponse(null, 'History cleared');
}

function handleDeleteHistoryItem(PDO $pdo, string $method, int $id): void {
    if ($method !== 'DELETE') {
        errorResponse('Method not allowed', 405);
    }
    $user = requireAuth($pdo);
    $stmt = $pdo->prepare("DELETE FROM search_history WHERE id = :id AND user_id = :uid");
    $stmt->execute([':id' => $id, ':uid' => $user['id']]);
    successResponse(null, 'History entry deleted');
}
