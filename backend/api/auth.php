<?php
// ============================================================================
// Auth API Endpoints
// File: backend/api/auth.php
//
// Handles all authentication routes for the CookHub application:
//   POST /api/auth/register  - Register a new user account
//   POST /api/auth/login     - Login with email & password
//   POST /api/auth/logout    - Logout and destroy server session
//   GET  /api/auth/me        - Get the currently authenticated user
//   POST /api/auth/heartbeat - Keep session alive & update last_active
//
// Authentication uses HttpOnly session cookies (see helpers/auth.php).
// New users start with status='pending' until approved by an admin.
// ============================================================================

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/cors.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/../helpers/response.php';

// Apply CORS and security headers to all auth responses
setCorsHeaders();

// Initialize database connection and extract request info
$pdo = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$route = $_GET['route'] ?? '';

// ----- Route dispatcher: maps ?route=xxx to handler functions -----
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
// POST /api/auth/register — Create a new user account
// ============================================================================
function handleRegister(PDO $pdo, string $method): void {
    if ($method !== 'POST') {
        errorResponse('Method not allowed', 405);
    }

    // Parse JSON body from the request
    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data) {
        errorResponse('Invalid JSON body');
    }

    // Validate that all required fields are present
    $required = ['email', 'password', 'firstName', 'lastName', 'username'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            errorResponse("Field '$field' is required");
        }
    }

    // Sanitize and validate email format
    $email = filter_var(trim($data['email']), FILTER_VALIDATE_EMAIL);
    if (!$email) {
        errorResponse('Invalid email format');
    }

    // Enforce minimum password length
    if (strlen($data['password']) < 6) {
        errorResponse('Password must be at least 6 characters');
    }

    // Check if email is already registered (generic error to prevent user enumeration)
    $stmt = $pdo->prepare("SELECT id FROM user WHERE email = :email");
    $stmt->execute([':email' => $email]);
    if ($stmt->fetch()) {
        errorResponse('Registration failed. Please try again.');
    }

    // Hash the password using bcrypt before storing
    $passwordHash = password_hash($data['password'], PASSWORD_BCRYPT);

    // Insert new user with role='user' and status='pending' (requires admin approval)
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

    // Auto-login: create session immediately after registration
    $userId = (int) $pdo->lastInsertId();
    createSession($pdo, $userId);

    // Fetch the full user record to return in the response
    $stmt = $pdo->prepare("
        SELECT id, username, first_name, last_name, email, birthday, role, status,
               joined_date, last_active, avatar_url, bio, location, cooking_level,
               created_at, updated_at
        FROM user WHERE id = :id
    ");
    $stmt->execute([':id' => $userId]);
    $user = $stmt->fetch();

    jsonResponse(['user' => formatUserResponse($user)], 201);
}

// ============================================================================
// POST /api/auth/login — Authenticate user with email & password
// ============================================================================
function handleLogin(PDO $pdo, string $method): void {
    if ($method !== 'POST') {
        errorResponse('Method not allowed', 405);
    }

    $data = json_decode(file_get_contents('php://input'), true);
    if (!$data || empty($data['email']) || empty($data['password'])) {
        errorResponse('Email and password are required');
    }

    // Look up user by email
    $stmt = $pdo->prepare("SELECT * FROM user WHERE email = :email");
    $stmt->execute([':email' => trim($data['email'])]);
    $user = $stmt->fetch();

    // Verify password against stored bcrypt hash (generic error for security)
    if (!$user || !password_verify($data['password'], $user['password_hash'])) {
        errorResponse('Invalid credentials', 401);
    }

    // Reactivate user if they were marked inactive (auto-set after 5min idle)
    if ($user['status'] === 'inactive') {
        $stmt = $pdo->prepare("UPDATE user SET status = 'active', last_active = NOW() WHERE id = :id");
        $stmt->execute([':id' => $user['id']]);
    } else {
        // Just update the last_active timestamp for active/pending/suspended users
        $stmt = $pdo->prepare("UPDATE user SET last_active = NOW() WHERE id = :id");
        $stmt->execute([':id' => $user['id']]);
    }

    // Create a new server-side session and set the HttpOnly cookie
    createSession($pdo, (int) $user['id']);

    // Refresh user data to include updated last_active / status
    $stmt = $pdo->prepare("
        SELECT id, username, first_name, last_name, email, birthday, role, status,
               joined_date, last_active, avatar_url, bio, location, cooking_level,
               created_at, updated_at
        FROM user WHERE id = :id
    ");
    $stmt->execute([':id' => $user['id']]);
    $user = $stmt->fetch();

    jsonResponse(['user' => formatUserResponse($user)]);
}

// ============================================================================
// POST /api/auth/logout — End user session
// ============================================================================
function handleLogout(PDO $pdo, string $method): void {
    if ($method !== 'POST') {
        errorResponse('Method not allowed', 405);
    }

    // Mark the user as inactive before destroying the session
    $currentUser = getCurrentUser($pdo);
    if ($currentUser && in_array($currentUser['status'], ['active', 'inactive'], true)) {
        $stmt = $pdo->prepare("UPDATE user SET status = 'inactive', last_active = NOW() WHERE id = :id");
        $stmt->execute([':id' => $currentUser['id']]);
    }

    // Remove session from DB and clear cookie
    destroySession($pdo);
    successResponse(null, 'Logged out successfully');
}

// ============================================================================
// GET /api/auth/me — Return the currently authenticated user profile
// ============================================================================
function handleMe(PDO $pdo, string $method): void {
    if ($method !== 'GET') {
        errorResponse('Method not allowed', 405);
    }

    // Validate session cookie and retrieve user data
    $user = getCurrentUser($pdo);
    if (!$user) {
        errorResponse('Not authenticated', 401);
    }

    // Also fetch the user's favorited recipe IDs (displayed on profile page)
    $stmt = $pdo->prepare("SELECT recipe_id FROM favorite WHERE user_id = :user_id");
    $stmt->execute([':user_id' => $user['id']]);
    $favorites = $stmt->fetchAll(PDO::FETCH_COLUMN);

    $response = formatUserResponse($user);
    $response['favorites'] = array_map('intval', $favorites);

    jsonResponse(['user' => $response]);
}

// ============================================================================
// POST /api/auth/heartbeat — Keep session alive (called every 60s by frontend)
// ============================================================================
function handleHeartbeat(PDO $pdo, string $method): void {
    if ($method !== 'POST') {
        errorResponse('Method not allowed', 405);
    }

    $user = requireAuth($pdo);

    // Update last_active timestamp to show the user is still online
    $stmt = $pdo->prepare("UPDATE user SET last_active = NOW() WHERE id = :id");
    $stmt->execute([':id' => $user['id']]);

    // Extend the session expiry by another 24 hours (sliding window)
    $token = $_COOKIE['cookhub_session'] ?? null;
    if ($token) {
        $newExpiry = date('Y-m-d H:i:s', time() + 86400);
        $stmt = $pdo->prepare("UPDATE session SET expires_at = :expires_at WHERE session_token = :token");
        $stmt->execute([':expires_at' => $newExpiry, ':token' => $token]);
    }

    successResponse(null, 'Heartbeat recorded');
}

// ============================================================================
// Helper: Format user data for API response
// Converts snake_case DB column names to camelCase for the React frontend.
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
