<?php
// ============================================================================
// Authentication Helper
// File: backend/helpers/auth.php
//
// Session-based authentication using HttpOnly cookies + database session table.
// Flow: Client sends cookie → server looks up session → returns user or null.
// ============================================================================

/**
 * Retrieves the currently authenticated user from the session cookie.
 * Looks up the 'cookhub_session' cookie token in the session table,
 * joins with the user table, and returns user data if the session is valid.
 * Returns null and clears the cookie if the session is expired or invalid.
 */
function getCurrentUser(PDO $pdo): ?array {
    // Read the session token from the HttpOnly cookie
    $token = $_COOKIE['cookhub_session'] ?? null;
    if (!$token) {
        return null;
    }

    // Join session + user tables; only valid (non-expired) sessions match
    $stmt = $pdo->prepare("
        SELECT u.id, u.username, u.first_name, u.last_name, u.email,
               u.birthday, u.role, u.status, u.joined_date, u.last_active,
               u.avatar_url, u.bio, u.location, u.cooking_level,
               u.created_at, u.updated_at
        FROM session s
        JOIN user u ON s.user_id = u.id
        WHERE s.session_token = :token AND s.expires_at > NOW()
    ");
    $stmt->execute([':token' => $token]);
    $user = $stmt->fetch();

    if (!$user) {
        // Session expired or token invalid — clear the stale cookie
        setcookie('cookhub_session', '', [
            'expires'  => time() - 3600,
            'path'     => '/',
            'httponly'  => true,
            'samesite' => 'Lax',
        ]);
        return null;
    }

    return $user;
}

/**
 * Requires authentication. Returns user data or sends 401 and exits.
 * Used as a guard at the top of protected API endpoints.
 */
function requireAuth(PDO $pdo): array {
    $user = getCurrentUser($pdo);
    if (!$user) {
        http_response_code(401);
        echo json_encode(['error' => 'Authentication required']);
        exit;
    }
    return $user;
}

/**
 * Requires admin role. Returns admin user data or sends 403 and exits.
 * Calls requireAuth() first, then checks the user's role.
 */
function requireAdmin(PDO $pdo): array {
    $user = requireAuth($pdo);
    if ($user['role'] !== 'admin') {
        http_response_code(403);
        echo json_encode(['error' => 'Admin access required']);
        exit;
    }
    return $user;
}

/**
 * Creates a new session for the given user.
 * Generates a cryptographically secure 64-char hex token,
 * removes any existing sessions for the user (single-session enforcement),
 * stores the new session in the database, and sets the HttpOnly cookie.
 *
 * @return string The generated session token
 */
function createSession(PDO $pdo, int $userId): string {
    $token = bin2hex(random_bytes(32));             // 64-character hex token
    $expiresAt = date('Y-m-d H:i:s', time() + 86400); // Expires in 24 hours

    // Remove any existing sessions for this user (enforce single active session)
    $stmt = $pdo->prepare("DELETE FROM session WHERE user_id = :user_id");
    $stmt->execute([':user_id' => $userId]);

    // Insert the new session record
    $stmt = $pdo->prepare("
        INSERT INTO session (user_id, session_token, expires_at)
        VALUES (:user_id, :token, :expires_at)
    ");
    $stmt->execute([
        ':user_id'    => $userId,
        ':token'      => $token,
        ':expires_at' => $expiresAt,
    ]);

    // Set HttpOnly cookie (not accessible via JavaScript for security)
    setcookie('cookhub_session', $token, [
        'expires'  => time() + 86400,
        'path'     => '/',
        'httponly'  => true,
        'samesite' => 'Lax',
    ]);

    return $token;
}

/**
 * Destroys the current session (logout).
 * Deletes the session record from the database and clears the cookie.
 */
function destroySession(PDO $pdo): void {
    $token = $_COOKIE['cookhub_session'] ?? null;
    if ($token) {
        // Remove session from database
        $stmt = $pdo->prepare("DELETE FROM session WHERE session_token = :token");
        $stmt->execute([':token' => $token]);
    }

    // Clear the session cookie by setting expiry in the past
    setcookie('cookhub_session', '', [
        'expires'  => time() - 3600,
        'path'     => '/',
        'httponly'  => true,
        'samesite' => 'Lax',
    ]);
}
