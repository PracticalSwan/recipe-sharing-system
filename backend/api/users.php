<?php
// ============================================================================
// Users API Endpoints
// File: backend/api/users.php
//
// Admin-facing user management plus public profile retrieval and self-update.
// Includes an auto-inactivity check: users idle for >5 minutes are marked
// 'inactive' on each admin list/stats request.
//
// Routes:
//   GET    /api/users             - List all users (admin, paginated + search)
//   GET    /api/users/{id}        - Get user profile (public fields + favorites)
//   PUT    /api/users/{id}        - Update user profile (self or admin)
//   DELETE /api/users/{id}        - Delete user and all related data (admin)
//   PUT    /api/users/{id}/status - Change user status (admin: approve/suspend)
//
// Related tables: user, recipe, review, like_record, favorite, recipe_view,
//                 search_history, session, activity_log
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

// Route dispatcher
if (empty($segments)) {
    handleUsersList($pdo, $method);                        // /api/users
} elseif (count($segments) === 1 && is_numeric($segments[0])) {
    handleUserById($pdo, $method, (int) $segments[0]);     // /api/users/{id}
} elseif (count($segments) === 2 && is_numeric($segments[0]) && $segments[1] === 'status') {
    handleUserStatus($pdo, $method, (int) $segments[0]);   // /api/users/{id}/status
} else {
    errorResponse('Not found', 404);
}

// ============================================================================
// GET /api/users — List users with search & status filters (admin only)
// Also auto-marks users inactive if idle > 5 minutes.
// ============================================================================
function handleUsersList(PDO $pdo, string $method): void {
    if ($method !== 'GET') {
        errorResponse('Method not allowed', 405);
    }

    requireAdmin($pdo);

    // Auto-inactivity: mark users idle for >5 min as 'inactive'
    $pdo->exec("
        UPDATE user
        SET status = 'inactive'
        WHERE role = 'user'
          AND status = 'active'
          AND last_active IS NOT NULL
          AND last_active < DATE_SUB(NOW(), INTERVAL 5 MINUTE)
    ");

    // Pagination parameters
    $page  = max(1, (int) ($_GET['page'] ?? 1));
    $limit = min(50, max(1, (int) ($_GET['limit'] ?? 20)));
    $offset = ($page - 1) * $limit;
    $search = $_GET['search'] ?? null;
    $status = $_GET['status'] ?? null;

    // Build dynamic WHERE clause for search and status filters
    $where = [];
    $params = [];

    if ($search) {
        // Search across multiple user fields (username, email, name)
        $where[] = "(u.username LIKE :search OR u.email LIKE :search2 OR u.first_name LIKE :search3 OR u.last_name LIKE :search4)";
        $searchTerm = '%' . $search . '%';
        $params[':search'] = $searchTerm;
        $params[':search2'] = $searchTerm;
        $params[':search3'] = $searchTerm;
        $params[':search4'] = $searchTerm;
    }
    if ($status) {
        $where[] = "u.status = :status";
        $params[':status'] = $status;
    }

    $whereClause = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

    // Count total matching users for pagination metadata
    $countStmt = $pdo->prepare("SELECT COUNT(*) FROM user u $whereClause");
    $countStmt->execute($params);
    $total = (int) $countStmt->fetchColumn();

    // Fetch users with aggregated recipe/review counts
    $sql = "
        SELECT u.id, u.username, u.first_name, u.last_name, u.email, u.birthday,
               u.role, u.status, u.joined_date, u.last_active, u.avatar_url,
               u.bio, u.location, u.cooking_level, u.created_at, u.updated_at,
               COALESCE(rc.recipe_count, 0) AS recipe_count,
               COALESCE(rvc.review_count, 0) AS review_count
        FROM user u
        LEFT JOIN (SELECT author_id, COUNT(*) AS recipe_count FROM recipe GROUP BY author_id) rc ON rc.author_id = u.id
        LEFT JOIN (SELECT user_id, COUNT(*) AS review_count FROM review GROUP BY user_id) rvc ON rvc.user_id = u.id
        $whereClause
        ORDER BY u.created_at DESC
        LIMIT :limit OFFSET :offset
    ";

    $stmt = $pdo->prepare($sql);
    foreach ($params as $key => $val) {
        $stmt->bindValue($key, $val);
    }
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();
    $users = $stmt->fetchAll();

    // Format response: convert snake_case DB columns to camelCase
    $formatted = array_map(fn($u) => [
        'id'           => (int) $u['id'],
        'username'     => $u['username'],
        'firstName'    => $u['first_name'],
        'lastName'     => $u['last_name'],
        'email'        => $u['email'],
        'birthday'     => $u['birthday'],
        'role'         => $u['role'],
        'status'       => $u['status'],
        'joinedDate'   => $u['joined_date'],
        'lastActive'   => $u['last_active'],
        'avatarUrl'    => $u['avatar_url'],
        'bio'          => $u['bio'],
        'location'     => $u['location'],
        'cookingLevel' => $u['cooking_level'],
        'recipeCount'  => (int) $u['recipe_count'],
        'reviewCount'  => (int) $u['review_count'],
        'createdAt'    => $u['created_at'],
        'updatedAt'    => $u['updated_at'],
    ], $users);

    jsonResponse([
        'users'      => $formatted,
        'pagination' => [
            'page'       => $page,
            'limit'      => $limit,
            'total'      => $total,
            'totalPages' => (int) ceil($total / $limit),
        ],
    ]);
}

// ============================================================================
// GET/PUT/DELETE /api/users/{id} — Dispatch by HTTP method
// ============================================================================
function handleUserById(PDO $pdo, string $method, int $id): void {
    switch ($method) {
        case 'GET':
            handleGetUser($pdo, $id);
            break;
        case 'PUT':
            handleUpdateUser($pdo, $id);
            break;
        case 'DELETE':
            handleDeleteUser($pdo, $id);
            break;
        default:
            errorResponse('Method not allowed', 405);
    }
}

// ============================================================================
// GET /api/users/{id} — Get user profile with recipe/review counts & favorites
// ============================================================================
function handleGetUser(PDO $pdo, int $id): void {
    // Fetch user with aggregated stats (only published recipes for public count)
    $stmt = $pdo->prepare("
        SELECT u.id, u.username, u.first_name, u.last_name, u.email, u.birthday,
               u.role, u.status, u.joined_date, u.last_active, u.avatar_url,
               u.bio, u.location, u.cooking_level, u.created_at, u.updated_at,
               COALESCE(rc.recipe_count, 0) AS recipe_count,
               COALESCE(rvc.review_count, 0) AS review_count
        FROM user u
        LEFT JOIN (SELECT author_id, COUNT(*) AS recipe_count FROM recipe WHERE status = 'published' GROUP BY author_id) rc ON rc.author_id = u.id
        LEFT JOIN (SELECT user_id, COUNT(*) AS review_count FROM review GROUP BY user_id) rvc ON rvc.user_id = u.id
        WHERE u.id = :id
    ");
    $stmt->execute([':id' => $id]);
    $u = $stmt->fetch();

    if (!$u) {
        errorResponse('User not found', 404);
    }

    // Get user's favorite recipe IDs
    $stmt = $pdo->prepare("SELECT recipe_id FROM favorite WHERE user_id = :id");
    $stmt->execute([':id' => $id]);
    $favorites = $stmt->fetchAll(PDO::FETCH_COLUMN);

    jsonResponse([
        'id'           => (int) $u['id'],
        'username'     => $u['username'],
        'firstName'    => $u['first_name'],
        'lastName'     => $u['last_name'],
        'email'        => $u['email'],
        'birthday'     => $u['birthday'],
        'role'         => $u['role'],
        'status'       => $u['status'],
        'joinedDate'   => $u['joined_date'],
        'lastActive'   => $u['last_active'],
        'avatarUrl'    => $u['avatar_url'],
        'bio'          => $u['bio'],
        'location'     => $u['location'],
        'cookingLevel' => $u['cooking_level'],
        'recipeCount'  => (int) $u['recipe_count'],
        'reviewCount'  => (int) $u['review_count'],
        'favorites'    => array_map('intval', $favorites),
        'createdAt'    => $u['created_at'],
        'updatedAt'    => $u['updated_at'],
    ]);
}

// ============================================================================
// PUT /api/users/{id} — Update user profile (self or admin)
// Supports dynamic field updates from an allow-list of editable fields.
// ============================================================================
function handleUpdateUser(PDO $pdo, int $id): void {
    $user = requireAuth($pdo);

    // Authorization: users can only edit their own profile; admins can edit any
    if ((int) $user['id'] !== $id && $user['role'] !== 'admin') {
        errorResponse('Not authorized', 403);
    }

    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data) {
        errorResponse('Invalid JSON body');
    }

    // Build dynamic SET clause from allowed fields only (whitelist approach)
    $fields = [];
    $params = [':id' => $id];

    // Map camelCase frontend keys to snake_case DB columns
    $allowedFields = [
        'username'     => 'username',
        'firstName'    => 'first_name',
        'lastName'     => 'last_name',
        'email'        => 'email',
        'birthday'     => 'birthday',
        'avatarUrl'    => 'avatar_url',
        'avatar'       => 'avatar_url',
        'bio'          => 'bio',
        'location'     => 'location',
        'cookingLevel' => 'cooking_level',
    ];

    foreach ($allowedFields as $camelCase => $dbField) {
        if (array_key_exists($camelCase, $data)) {
            $fields[] = "$dbField = :$dbField";
            $params[":$dbField"] = is_string($data[$camelCase]) ? trim($data[$camelCase]) : $data[$camelCase];
        }
    }

    // Password change: hash with bcrypt before storing
    if (!empty($data['password'])) {
        $fields[] = "password_hash = :password_hash";
        $params[':password_hash'] = password_hash($data['password'], PASSWORD_BCRYPT);
    }

    if (empty($fields)) {
        errorResponse('No fields to update');
    }

    $fieldStr = implode(', ', $fields);
    $stmt = $pdo->prepare("UPDATE user SET $fieldStr WHERE id = :id");
    $stmt->execute($params);

    // Return updated user
    $stmt = $pdo->prepare("
        SELECT id, username, first_name, last_name, email, birthday, role, status,
               joined_date, last_active, avatar_url, bio, location, cooking_level,
               created_at, updated_at
        FROM user WHERE id = :id
    ");
    $stmt->execute([':id' => $id]);
    $updated = $stmt->fetch();

    // Include favorites
    $favStmt = $pdo->prepare("SELECT recipe_id FROM favorite WHERE user_id = :id");
    $favStmt->execute([':id' => $id]);
    $favorites = $favStmt->fetchAll(PDO::FETCH_COLUMN);

    jsonResponse([
        'id'           => (int) $updated['id'],
        'username'     => $updated['username'],
        'firstName'    => $updated['first_name'],
        'lastName'     => $updated['last_name'],
        'email'        => $updated['email'],
        'birthday'     => $updated['birthday'],
        'role'         => $updated['role'],
        'status'       => $updated['status'],
        'joinedDate'   => $updated['joined_date'],
        'lastActive'   => $updated['last_active'],
        'avatarUrl'    => $updated['avatar_url'],
        'bio'          => $updated['bio'],
        'location'     => $updated['location'],
        'cookingLevel' => $updated['cooking_level'],
        'favorites'    => array_map('intval', $favorites),
        'createdAt'    => $updated['created_at'],
        'updatedAt'    => $updated['updated_at'],
    ]);
}

// ============================================================================
// DELETE /api/users/{id} — Admin only: delete user and all related data
// Explicitly removes all child records (sessions, reviews, likes, favorites,
// views, search history, recipes + their sub-records) before deleting the user.
// ============================================================================
function handleDeleteUser(PDO $pdo, int $id): void {
    $admin = requireAdmin($pdo);

    $stmt = $pdo->prepare("SELECT id, username FROM user WHERE id = :id");
    $stmt->execute([':id' => $id]);
    $target = $stmt->fetch();
    if (!$target) {
        errorResponse('User not found', 404);
    }

    $pdo->beginTransaction();
    try {
        // Delete user's sessions
        $pdo->prepare("DELETE FROM session WHERE user_id = :id")->execute([':id' => $id]);
        // Delete user's reviews
        $pdo->prepare("DELETE FROM review WHERE user_id = :id")->execute([':id' => $id]);
        // Delete user's likes
        $pdo->prepare("DELETE FROM like_record WHERE user_id = :id")->execute([':id' => $id]);
        // Delete user's favorites
        $pdo->prepare("DELETE FROM favorite WHERE user_id = :id")->execute([':id' => $id]);
        // Delete user's recipe views
        $pdo->prepare("DELETE FROM recipe_view WHERE user_id = :id")->execute([':id' => $id]);
        // Delete user's search history
        $pdo->prepare("DELETE FROM search_history WHERE user_id = :id")->execute([':id' => $id]);
        // Delete user's recipes and related data
        $recipeStmt = $pdo->prepare("SELECT id FROM recipe WHERE author_id = :id");
        $recipeStmt->execute([':id' => $id]);
        $recipeIds = $recipeStmt->fetchAll(PDO::FETCH_COLUMN);
        foreach ($recipeIds as $rid) {
            $pdo->prepare("DELETE FROM ingredient WHERE recipe_id = :rid")->execute([':rid' => $rid]);
            $pdo->prepare("DELETE FROM instruction WHERE recipe_id = :rid")->execute([':rid' => $rid]);
            $pdo->prepare("DELETE FROM recipe_image WHERE recipe_id = :rid")->execute([':rid' => $rid]);
            $pdo->prepare("DELETE FROM review WHERE recipe_id = :rid")->execute([':rid' => $rid]);
            $pdo->prepare("DELETE FROM like_record WHERE recipe_id = :rid")->execute([':rid' => $rid]);
            $pdo->prepare("DELETE FROM favorite WHERE recipe_id = :rid")->execute([':rid' => $rid]);
            $pdo->prepare("DELETE FROM recipe_view WHERE recipe_id = :rid")->execute([':rid' => $rid]);
        }
        if (!empty($recipeIds)) {
            $placeholders = implode(',', array_fill(0, count($recipeIds), '?'));
            $pdo->prepare("DELETE FROM recipe WHERE id IN ($placeholders)")->execute($recipeIds);
        }
        // Delete user
        $pdo->prepare("DELETE FROM user WHERE id = :id")->execute([':id' => $id]);

        // Log activity
        $pdo->prepare("
            INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
            VALUES (:admin_id, 'user_delete', 'user', :target_id, :description)
        ")->execute([
            ':admin_id'    => $admin['id'],
            ':target_id'   => $id,
            ':description' => "Deleted user: {$target['username']}",
        ]);

        $pdo->commit();
        successResponse(null, 'User deleted');
    } catch (\Exception $e) {
        $pdo->rollBack();
        errorResponse('Failed to delete user: ' . $e->getMessage(), 500);
    }
}

// ============================================================================
// PUT /api/users/{id}/status — Admin: change user status
// Supports: active, inactive, pending, suspended.
// Logs moderation events (pending/suspended) to activity_log for audit.
// ============================================================================
function handleUserStatus(PDO $pdo, string $method, int $id): void {
    if ($method !== 'PUT') {
        errorResponse('Method not allowed', 405);
    }

    $admin = requireAdmin($pdo);
    $data = json_decode(file_get_contents('php://input'), true);

    $validStatuses = ['active', 'inactive', 'pending', 'suspended'];
    if (empty($data['status']) || !in_array($data['status'], $validStatuses)) {
        errorResponse('Valid status required: ' . implode(', ', $validStatuses));
    }

    $stmt = $pdo->prepare("SELECT id, username FROM user WHERE id = :id");
    $stmt->execute([':id' => $id]);
    $target = $stmt->fetch();
    if (!$target) {
        errorResponse('User not found', 404);
    }

    if ($data['status'] === 'active') {
        // When activating, also refresh last_active timestamp
        $stmt = $pdo->prepare("UPDATE user SET status = :status, last_active = NOW() WHERE id = :id");
        $stmt->execute([':status' => $data['status'], ':id' => $id]);
    } else {
        $stmt = $pdo->prepare("UPDATE user SET status = :status WHERE id = :id");
        $stmt->execute([':status' => $data['status'], ':id' => $id]);
    }

    // Only log moderation events (not routine active/inactive transitions)
    if (!in_array($data['status'], ['active', 'inactive'], true)) {
        $pdo->prepare("
            INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
            VALUES (:admin_id, 'user_update', 'user', :target_id, :description)
        ")->execute([
            ':admin_id'    => $admin['id'],
            ':target_id'   => $id,
            ':description' => "Changed status of {$target['username']} to {$data['status']}",
        ]);
    }

    successResponse(null, "User status updated to {$data['status']}");
}
