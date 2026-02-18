<?php
// Session-based authentication with HttpOnly cookies

// Get current user from session cookie, or null if not authenticated
function getCurrentUser(PDO $pdo): ?array {
    $token = $_COOKIE['cookhub_session'] ?? null;
    if (!$token) {
        return null;
    }

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
        // Clear invalid/expired cookie
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

// Require authentication and active account (exit if fails)
function requireAuth(PDO $pdo): array {
    $user = getCurrentUser($pdo);
    if (!$user) {
        errorResponse('Authentication required', 401, 'authentication_required');
    }

    if ($user['status'] === 'suspended') {
        errorResponse('Your account has been suspended. Please contact support.', 403, 'account_suspended');
    }

    if ($user['status'] === 'pending') {
        errorResponse('Your account is pending approval.', 403, 'account_pending');
    }

    return $user;
}

// Require admin role (exits if not admin)
function requireAdmin(PDO $pdo): array {
    $user = requireAuth($pdo);
    if ($user['role'] !== 'admin') {
        errorResponse('Admin access required', 403, 'admin_access_required');
    }
    return $user;
}

// Create new session and set HttpOnly cookie (24-hour expiry)
function createSession(PDO $pdo, int $userId): string {
    $token = bin2hex(random_bytes(32)); // 64-char secure token
    $expiresAt = date('Y-m-d H:i:s', time() + 86400);

    // Remove old sessions (single session per user)
    $pdo->prepare("DELETE FROM session WHERE user_id = :user_id")->execute([':user_id' => $userId]);

    // Store new session
    $pdo->prepare("
        INSERT INTO session (user_id, session_token, expires_at)
        VALUES (:user_id, :token, :expires_at)
    ")->execute([':user_id' => $userId, ':token' => $token, ':expires_at' => $expiresAt]);

    setcookie('cookhub_session', $token, [
        'expires'  => time() + 86400,
        'path'     => '/',
        'httponly'  => true,
        'samesite' => 'Lax',
    ]);

    return $token;
}

// Destroy current session (logout)
function destroySession(PDO $pdo): void {
    $token = $_COOKIE['cookhub_session'] ?? null;
    if ($token) {
        $pdo->prepare("DELETE FROM session WHERE session_token = :token")->execute([':token' => $token]);
    }

    setcookie('cookhub_session', '', [
        'expires'  => time() - 3600,
        'path'     => '/',
        'httponly'  => true,
        'samesite' => 'Lax',
    ]);
}
