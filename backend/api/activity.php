<?php
// Activity Log API (admin): paginated admin activity logs
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/cors.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/../helpers/response.php';

setCorsHeaders();

$pdo = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];

if ($method !== 'GET') {
    errorResponse('Method not allowed', 405);
}

requireAdmin($pdo);

$page   = max(1, (int) ($_GET['page'] ?? 1));
$limit  = min(50, max(1, (int) ($_GET['limit'] ?? 20)));
$offset = ($page - 1) * $limit;
$actionType = $_GET['actionType'] ?? null;

// Exclude routine active/inactive transitions (clutter the log)
$where = [
    "NOT (
        al.action_type = 'user_update'
        AND (
            LOWER(al.description) LIKE '% to active'
            OR LOWER(al.description) LIKE '% to inactive'
        )
    )",
];
$params = [];

if ($actionType) {
    $where[] = "al.action_type = :actionType";
    $params[':actionType'] = $actionType;
}

$whereClause = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

$countStmt = $pdo->prepare("SELECT COUNT(*) FROM activity_log al $whereClause");
$countStmt->execute($params);
$total = (int) $countStmt->fetchColumn();

$sql = "
    SELECT al.id, al.action_type AS actionType, al.target_type AS targetType,
           al.target_id AS targetId, al.description, al.created_at AS createdAt,
           u.username AS adminUsername, u.avatar_url AS adminAvatar
    FROM activity_log al
    JOIN user u ON u.id = al.admin_id
    $whereClause
    ORDER BY al.created_at DESC
    LIMIT :limit OFFSET :offset
";

$stmt = $pdo->prepare($sql);
foreach ($params as $k => $v) {
    $stmt->bindValue($k, $v);
}
$stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
$stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
$stmt->execute();

jsonResponse([
    'activities' => $stmt->fetchAll(),
    'pagination' => [
        'page'       => $page,
        'limit'      => $limit,
        'total'      => $total,
        'totalPages' => (int) ceil($total / $limit),
    ],
]);
