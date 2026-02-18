<?php
// Reviews API: CRUD for recipe reviews (one review per user per recipe)
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/cors.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/../helpers/response.php';

setCorsHeaders();
initializeErrorHandling();

$pdo = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$route = $_GET['route'] ?? '';
$segments = $route ? array_values(array_filter(explode('/', $route))) : [];

// Route dispatcher
if (empty($segments)) {
    if ($method === 'GET') {
        handleGetReviews($pdo);
    } elseif ($method === 'POST') {
        handleCreateReview($pdo);
    } else {
        errorResponse('Method not allowed', 405);
    }
} elseif (count($segments) === 1 && is_numeric($segments[0])) {
    $reviewId = (int) $segments[0];
    if ($method === 'PUT') {
        handleUpdateReview($pdo, $reviewId);
    } elseif ($method === 'DELETE') {
        handleDeleteReview($pdo, $reviewId);
    } else {
        errorResponse('Method not allowed', 405);
    }
} else {
    errorResponse('Not found', 404);
}

// GET /api/reviews?recipeId={id} — Get all reviews for a recipe
function handleGetReviews(PDO $pdo): void {
    $recipeId = isset($_GET['recipeId']) ? (int) $_GET['recipeId'] : null;
    if (!$recipeId) {
        errorResponse('recipeId parameter is required');
    }

    $stmt = $pdo->prepare("
        SELECT rv.id, rv.rating, rv.comment, rv.created_at, rv.updated_at,
               u.id AS user_id, u.username, u.avatar_url, u.first_name, u.last_name
        FROM review rv
        JOIN user u ON rv.user_id = u.id
        WHERE rv.recipe_id = :recipe_id
        ORDER BY rv.created_at DESC
    ");
    $stmt->execute([':recipe_id' => $recipeId]);
    $reviews = $stmt->fetchAll();

    $formatted = array_map(fn($rv) => [
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
    ], $reviews);

    jsonResponse(['reviews' => $formatted]);
}

// POST /api/reviews — Create or update review (upsert: one per user per recipe)
function handleCreateReview(PDO $pdo): void {
    $user = requireAuth($pdo);
    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data) {
        errorResponse('Invalid JSON body');
    }

    if (empty($data['recipeId']) || empty($data['rating'])) {
        errorResponse('recipeId and rating are required');
    }

    $rating = (int) $data['rating'];
    if ($rating < 1 || $rating > 5) {
        errorResponse('Rating must be between 1 and 5');
    }

    $recipeId = (int) $data['recipeId'];

    $stmt = $pdo->prepare("SELECT id FROM recipe WHERE id = :id");
    $stmt->execute([':id' => $recipeId]);
    if (!$stmt->fetch()) {
        errorResponse('Recipe not found', 404);
    }

    $comment = trim($data['comment'] ?? '');

    // Check for existing review (upsert pattern)
    $stmt = $pdo->prepare("SELECT id FROM review WHERE user_id = :uid AND recipe_id = :rid");
    $stmt->execute([':uid' => $user['id'], ':rid' => $recipeId]);
    $existing = $stmt->fetch();

    $statusCode = 201;
    if ($existing) {
        $reviewId = (int) $existing['id'];
        $pdo->prepare("UPDATE review SET rating = :rating, comment = :comment WHERE id = :id")
            ->execute([':rating' => $rating, ':comment' => $comment, ':id' => $reviewId]);
        $statusCode = 200;
    } else {
        $pdo->prepare("INSERT INTO review (user_id, recipe_id, rating, comment) VALUES (:user_id, :recipe_id, :rating, :comment)")
            ->execute([':user_id' => $user['id'], ':recipe_id' => $recipeId, ':rating' => $rating, ':comment' => $comment]);
        $reviewId = (int) $pdo->lastInsertId();
    }

    // Fetch updated review with user info
    $stmt = $pdo->prepare("
        SELECT rv.id, rv.rating, rv.comment, rv.created_at, rv.updated_at,
               u.id AS user_id, u.username, u.avatar_url, u.first_name, u.last_name
        FROM review rv
        JOIN user u ON rv.user_id = u.id
        WHERE rv.id = :id
    ");
    $stmt->execute([':id' => $reviewId]);
    $rv = $stmt->fetch();

    jsonResponse([
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
    ], $statusCode);
}

// PUT /api/reviews/{id} — Update review (owner or admin)
function handleUpdateReview(PDO $pdo, int $id): void {
    $user = requireAuth($pdo);
    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data) {
        errorResponse('Invalid JSON body');
    }

    $stmt = $pdo->prepare("SELECT * FROM review WHERE id = :id");
    $stmt->execute([':id' => $id]);
    $review = $stmt->fetch();
    if (!$review) {
        errorResponse('Review not found', 404);
    }
    if ((int) $review['user_id'] !== (int) $user['id'] && $user['role'] !== 'admin') {
        errorResponse('Not authorized', 403);
    }

    $rating = isset($data['rating']) ? (int) $data['rating'] : (int) $review['rating'];
    if ($rating < 1 || $rating > 5) {
        errorResponse('Rating must be between 1 and 5');
    }

    $pdo->prepare("UPDATE review SET rating = :rating, comment = :comment WHERE id = :id")
        ->execute([':rating' => $rating, ':comment' => trim($data['comment'] ?? $review['comment']), ':id' => $id]);

    successResponse(null, 'Review updated');
}

// DELETE /api/reviews/{id} — Delete review (owner or admin)
function handleDeleteReview(PDO $pdo, int $id): void {
    $user = requireAuth($pdo);

    $stmt = $pdo->prepare("SELECT * FROM review WHERE id = :id");
    $stmt->execute([':id' => $id]);
    $review = $stmt->fetch();
    if (!$review) {
        errorResponse('Review not found', 404);
    }
    if ((int) $review['user_id'] !== (int) $user['id'] && $user['role'] !== 'admin') {
        errorResponse('Not authorized', 403);
    }

    $pdo->prepare("DELETE FROM review WHERE id = :id")->execute([':id' => $id]);
    successResponse(null, 'Review deleted');
}
