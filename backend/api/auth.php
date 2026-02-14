<?php
// ============================================================================
// Auth API Endpoints
// POST /api/auth/register - Register new user
// POST /api/auth/login    - Login with email/password
// POST /api/auth/logout   - Logout (destroy session)
// GET  /api/auth/me       - Get current authenticated user
// POST /api/auth/heartbeat - Update last_active timestamp
// ============================================================================

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/cors.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/../helpers/response.php';

setCorsHeaders();

$pdo = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$route = $_GET['route'] ?? '';

switch ($route) {
    case 'register':
        handleRegister($pdo, $method);
        break;
    case 'login':
        handleLogin($pdo, $method);
        break;
    case 'logout':
        handleLogout($pdo, $method);
        break;
    case 'me':
        handleMe($pdo, $method);
        break;
    case 'heartbeat':
        handleHeartbeat($pdo, $method);
        break;
    default:
        errorResponse('Not found', 404);
}

// ============================================================================
// POST /api/auth/register
// ============================================================================
function handleRegister(PDO $pdo, string $method): void {
    if ($method !== 'POST') {
        errorResponse('Method not allowed', 405);
    }

    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data) {
        errorResponse('Invalid JSON body');
    }

    $required = ['email', 'password', 'firstName', 'lastName', 'username'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            errorResponse("Field '$field' is required");
        }
    }

    $email = filter_var(trim($data['email']), FILTER_VALIDATE_EMAIL);
    if (!$email) {
        errorResponse('Invalid email format');
    }

    // Check email uniqueness
    $stmt = $pdo->prepare("SELECT id FROM user WHERE email = :email");
    $stmt->execute([':email' => $email]);
    if ($stmt->fetch()) {
        errorResponse('Email already registered');
    }

    $passwordHash = password_hash($data['password'], PASSWORD_BCRYPT);

    $stmt = $pdo->prepare("
        INSERT INTO user (username, first_name, last_name, email, password_hash, birthday, role, status, avatar_url, joined_date)
        VALUES (:username, :first_name, :last_name, :email, :password_hash, :birthday, 'user', 'pending', :avatar_url, NOW())
    ");
    $stmt->execute([
        ':username'      => trim($data['username']),
        ':first_name'    => trim($data['firstName']),
        ':last_name'     => trim($data['lastName']),
        ':email'         => $email,
        ':password_hash' => $passwordHash,
        ':birthday'      => !empty($data['birthday']) ? $data['birthday'] : null,
        ':avatar_url'    => !empty($data['avatar']) ? $data['avatar'] : null,
    ]);

    $userId = (int) $pdo->lastInsertId();
    createSession($pdo, $userId);

    // Fetch created user
    $stmt = $pdo->prepare("
        SELECT id, username, first_name, last_name, email, birthday, role, status,
               joined_date, last_active, avatar_url, bio, location, cooking_level,
               created_at, updated_at
        FROM user WHERE id = :id
    ");
    $stmt->execute([':id' => $userId]);
    $user = $stmt->fetch();

    jsonResponse(formatUserResponse($user), 201);
}

// ============================================================================
// POST /api/auth/login
// ============================================================================
function handleLogin(PDO $pdo, string $method): void {
    if ($method !== 'POST') {
        errorResponse('Method not allowed', 405);
    }

    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data || empty($data['email']) || empty($data['password'])) {
        errorResponse('Email and password are required');
    }

    $stmt = $pdo->prepare("SELECT * FROM user WHERE email = :email");
    $stmt->execute([':email' => trim($data['email'])]);
    $user = $stmt->fetch();

    if (!$user || !password_verify($data['password'], $user['password_hash'])) {
        errorResponse('Invalid credentials', 401);
    }

    // Update last_active
    $stmt = $pdo->prepare("UPDATE user SET last_active = NOW() WHERE id = :id");
    $stmt->execute([':id' => $user['id']]);

    createSession($pdo, (int) $user['id']);

    // Refresh user data
    $stmt = $pdo->prepare("
        SELECT id, username, first_name, last_name, email, birthday, role, status,
               joined_date, last_active, avatar_url, bio, location, cooking_level,
               created_at, updated_at
        FROM user WHERE id = :id
    ");
    $stmt->execute([':id' => $user['id']]);
    $user = $stmt->fetch();

    jsonResponse(formatUserResponse($user));
}

// ============================================================================
// POST /api/auth/logout
// ============================================================================
function handleLogout(PDO $pdo, string $method): void {
    if ($method !== 'POST') {
        errorResponse('Method not allowed', 405);
    }

    destroySession($pdo);
    successResponse(null, 'Logged out successfully');
}

// ============================================================================
// GET /api/auth/me
// ============================================================================
function handleMe(PDO $pdo, string $method): void {
    if ($method !== 'GET') {
        errorResponse('Method not allowed', 405);
    }

    $user = getCurrentUser($pdo);
    if (!$user) {
        errorResponse('Not authenticated', 401);
    }

    // Get favorites list for the user
    $stmt = $pdo->prepare("SELECT recipe_id FROM favorite WHERE user_id = :user_id");
    $stmt->execute([':user_id' => $user['id']]);
    $favorites = $stmt->fetchAll(PDO::FETCH_COLUMN);

    $response = formatUserResponse($user);
    $response['favorites'] = array_map('intval', $favorites);

    jsonResponse($response);
}

// ============================================================================
// POST /api/auth/heartbeat
// ============================================================================
function handleHeartbeat(PDO $pdo, string $method): void {
    if ($method !== 'POST') {
        errorResponse('Method not allowed', 405);
    }

    $user = requireAuth($pdo);

    $stmt = $pdo->prepare("UPDATE user SET last_active = NOW() WHERE id = :id");
    $stmt->execute([':id' => $user['id']]);

    // Extend session expiry
    $token = $_COOKIE['cookhub_session'] ?? null;
    if ($token) {
        $newExpiry = date('Y-m-d H:i:s', time() + 86400);
        $stmt = $pdo->prepare("UPDATE session SET expires_at = :expires_at WHERE session_token = :token");
        $stmt->execute([':expires_at' => $newExpiry, ':token' => $token]);
    }

    successResponse(null, 'Heartbeat recorded');
}

// ============================================================================
// Helper: Format user data for API response (camelCase keys)
// ============================================================================
function formatUserResponse(array $user): array {
    return [
        'id'           => (int) $user['id'],
        'username'     => $user['username'],
        'firstName'    => $user['first_name'],
        'lastName'     => $user['last_name'],
        'email'        => $user['email'],
        'birthday'     => $user['birthday'],
        'role'         => $user['role'],
        'status'       => $user['status'],
        'joinedDate'   => $user['joined_date'],
        'lastActive'   => $user['last_active'],
        'avatarUrl'    => $user['avatar_url'],
        'bio'          => $user['bio'],
        'location'     => $user['location'],
        'cookingLevel' => $user['cooking_level'],
        'createdAt'    => $user['created_at'],
        'updatedAt'    => $user['updated_at'],
    ];
}
