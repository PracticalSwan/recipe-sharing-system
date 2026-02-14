<?php
// ============================================================================
// Authentication Helper
// Session validation via HttpOnly cookie + session table
// ============================================================================

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
        // Clear expired/invalid cookie
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

function requireAuth(PDO $pdo): array {
    $user = getCurrentUser($pdo);
    if (!$user) {
        http_response_code(401);
        echo json_encode(['error' => 'Authentication required']);
        exit;
    }
    return $user;
}

function requireAdmin(PDO $pdo): array {
    $user = requireAuth($pdo);
    if ($user['role'] !== 'admin') {
        http_response_code(403);
        echo json_encode(['error' => 'Admin access required']);
        exit;
    }
    return $user;
}

function createSession(PDO $pdo, int $userId): string {
    $token = bin2hex(random_bytes(32));
    $expiresAt = date('Y-m-d H:i:s', time() + 86400); // 24 hours

    // Remove any existing sessions for this user
    $stmt = $pdo->prepare("DELETE FROM session WHERE user_id = :user_id");
    $stmt->execute([':user_id' => $userId]);

    // Create new session
    $stmt = $pdo->prepare("
        INSERT INTO session (user_id, session_token, expires_at)
        VALUES (:user_id, :token, :expires_at)
    ");
    $stmt->execute([
        ':user_id'    => $userId,
        ':token'      => $token,
        ':expires_at' => $expiresAt,
    ]);

    // Set HttpOnly cookie
    setcookie('cookhub_session', $token, [
        'expires'  => time() + 86400,
        'path'     => '/',
        'httponly'  => true,
        'samesite' => 'Lax',
    ]);

    return $token;
}

function destroySession(PDO $pdo): void {
    $token = $_COOKIE['cookhub_session'] ?? null;
    if ($token) {
        $stmt = $pdo->prepare("DELETE FROM session WHERE session_token = :token");
        $stmt->execute([':token' => $token]);
    }

    setcookie('cookhub_session', '', [
        'expires'  => time() - 3600,
        'path'     => '/',
        'httponly'  => true,
        'samesite' => 'Lax',
    ]);
}
