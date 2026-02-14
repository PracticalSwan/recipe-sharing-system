<?php
// ============================================================================
// Users API Endpoints
// GET    /api/users          - List all users (admin, paginated)
// GET    /api/users/{id}     - Get user profile
// PUT    /api/users/{id}     - Update user profile
// DELETE /api/users/{id}     - Delete user (admin)
// PUT    /api/users/{id}/status - Update user status (admin)
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
    handleUsersList($pdo, $method);
} elseif (count($segments) === 1 && is_numeric($segments[0])) {
    handleUserById($pdo, $method, (int) $segments[0]);
} elseif (count($segments) === 2 && is_numeric($segments[0]) && $segments[1] === 'status') {
    handleUserStatus($pdo, $method, (int) $segments[0]);
} else {
    errorResponse('Not found', 404);
}

// ============================================================================
// GET /api/users - List users (admin only, paginated)
// ============================================================================
function handleUsersList(PDO $pdo, string $method): void {
    if ($method !== 'GET') {
        errorResponse('Method not allowed', 405);
    }

    requireAdmin($pdo);

    $page  = max(1, (int) ($_GET['page'] ?? 1));
    $limit = min(50, max(1, (int) ($_GET['limit'] ?? 20)));
    $offset = ($page - 1) * $limit;
    $search = $_GET['search'] ?? null;
    $status = $_GET['status'] ?? null;

    $where = [];
    $params = [];

    if ($search) {
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

    // Count
    $countStmt = $pdo->prepare("SELECT COUNT(*) FROM user u $whereClause");
    $countStmt->execute($params);
    $total = (int) $countStmt->fetchColumn();

    // Users with recipe/review counts
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
// GET/PUT/DELETE /api/users/{id}
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
// GET /api/users/{id}
// ============================================================================
function handleGetUser(PDO $pdo, int $id): void {
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
// PUT /api/users/{id}
// ============================================================================
function handleUpdateUser(PDO $pdo, int $id): void {
    $user = requireAuth($pdo);

    // Can only update own profile or admin can update any
    if ((int) $user['id'] !== $id && $user['role'] !== 'admin') {
        errorResponse('Not authorized', 403);
    }

    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data) {
        errorResponse('Invalid JSON body');
    }

    // Build dynamic update
    $fields = [];
    $params = [':id' => $id];

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

    // Password change
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
        'createdAt'    => $updated['created_at'],
        'updatedAt'    => $updated['updated_at'],
    ]);
}

// ============================================================================
// DELETE /api/users/{id} - Admin only
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
// PUT /api/users/{id}/status - Admin: change user status
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

    $stmt = $pdo->prepare("UPDATE user SET status = :status WHERE id = :id");
    $stmt->execute([':status' => $data['status'], ':id' => $id]);

    // Log activity
    $pdo->prepare("
        INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
        VALUES (:admin_id, 'user_update', 'user', :target_id, :description)
    ")->execute([
        ':admin_id'    => $admin['id'],
        ':target_id'   => $id,
        ':description' => "Changed status of {$target['username']} to {$data['status']}",
    ]);

    successResponse(null, "User status updated to {$data['status']}");
}
