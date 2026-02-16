<?php
// ============================================================================
// Reviews API Endpoints
// File: backend/api/reviews.php
//
// CRUD operations for recipe reviews. Each user can have exactly one review
// per recipe (enforced via upsert in create). Reviews include a 1-5 star
// rating and optional comment text.
//
// Routes:
//   GET    /api/reviews?recipeId={id} - Get all reviews for a recipe
//   POST   /api/reviews               - Create or update a review (upsert)
//   PUT    /api/reviews/{id}          - Update an existing review
//   DELETE /api/reviews/{id}          - Delete a review
//
// Related tables: review, user
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

// Route dispatcher: /api/reviews or /api/reviews/{id}
if (empty($segments)) {
    if ($method === 'GET') {
        handleGetReviews($pdo);       // List reviews for a recipe
    } elseif ($method === 'POST') {
        handleCreateReview($pdo);     // Create/upsert a review
    } else {
        errorResponse('Method not allowed', 405);
    }
} elseif (count($segments) === 1 && is_numeric($segments[0])) {
    $reviewId = (int) $segments[0];
    if ($method === 'PUT') {
        handleUpdateReview($pdo, $reviewId);   // Edit review
    } elseif ($method === 'DELETE') {
        handleDeleteReview($pdo, $reviewId);   // Remove review
    } else {
        errorResponse('Method not allowed', 405);
    }
} else {
    errorResponse('Not found', 404);
}

// ============================================================================
// GET /api/reviews?recipeId={id} — Fetch all reviews for a specific recipe
// Returns reviews sorted newest-first, each with the reviewer's profile info.
// ============================================================================
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

// ============================================================================
// POST /api/reviews — Create or update a review (upsert pattern)
// Each user may have at most one review per recipe. If a review already
// exists, it is updated instead of creating a duplicate.
// ============================================================================
function handleCreateReview(PDO $pdo): void {
    $user = requireAuth($pdo);
    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data) {
        errorResponse('Invalid JSON body');
    }

    // Validate required fields
    if (empty($data['recipeId']) || empty($data['rating'])) {
        errorResponse('recipeId and rating are required');
    }

    // Rating must be 1-5 stars
    $rating = (int) $data['rating'];
    if ($rating < 1 || $rating > 5) {
        errorResponse('Rating must be between 1 and 5');
    }

    $recipeId = (int) $data['recipeId'];

    // Verify the recipe exists before allowing a review
    $stmt = $pdo->prepare("SELECT id FROM recipe WHERE id = :id");
    $stmt->execute([':id' => $recipeId]);
    if (!$stmt->fetch()) {
        errorResponse('Recipe not found', 404);
    }

    $comment = trim($data['comment'] ?? '');

    // Check if user already reviewed this recipe (upsert: update if exists)
    $stmt = $pdo->prepare("SELECT id FROM review WHERE user_id = :uid AND recipe_id = :rid");
    $stmt->execute([':uid' => $user['id'], ':rid' => $recipeId]);
    $existing = $stmt->fetch();

    $statusCode = 201;
    if ($existing) {
        // Existing review found → update it (200 OK)
        $reviewId = (int) $existing['id'];
        $stmt = $pdo->prepare("
            UPDATE review
            SET rating = :rating, comment = :comment
            WHERE id = :id
        ");
        $stmt->execute([
            ':rating' => $rating,
            ':comment' => $comment,
            ':id' => $reviewId,
        ]);
        $statusCode = 200;
    } else {
        // No existing review → create new (201 Created)
        $stmt = $pdo->prepare("
            INSERT INTO review (user_id, recipe_id, rating, comment)
            VALUES (:user_id, :recipe_id, :rating, :comment)
        ");
        $stmt->execute([
            ':user_id'   => $user['id'],
            ':recipe_id' => $recipeId,
            ':rating'    => $rating,
            ':comment'   => $comment,
        ]);
        $reviewId = (int) $pdo->lastInsertId();
    }

    // Re-fetch the review with user info to return in response
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

// ============================================================================
// PUT /api/reviews/{id} — Update an existing review (owner or admin)
// ============================================================================
function handleUpdateReview(PDO $pdo, int $id): void {
    $user = requireAuth($pdo);
    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data) {
        errorResponse('Invalid JSON body');
    }

    // Verify review exists and check ownership
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

    $stmt = $pdo->prepare("UPDATE review SET rating = :rating, comment = :comment WHERE id = :id");
    $stmt->execute([
        ':rating'  => $rating,
        ':comment' => trim($data['comment'] ?? $review['comment']),
        ':id'      => $id,
    ]);

    successResponse(null, 'Review updated');
}

// ============================================================================
// DELETE /api/reviews/{id} — Remove a review (owner or admin)
// ============================================================================
function handleDeleteReview(PDO $pdo, int $id): void {
    $user = requireAuth($pdo);

    // Verify review exists and check ownership or admin privileges
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
