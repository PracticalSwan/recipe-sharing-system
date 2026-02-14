<?php
// ============================================================================
// Stats API Endpoints (Admin)
// GET /api/stats          - Dashboard summary stats
// GET /api/stats/daily    - Daily stats history
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

if ($method !== 'GET') {
    errorResponse('Method not allowed', 405);
}

if (empty($segments)) {
    handleDashboardStats($pdo);
} elseif ($segments[0] === 'daily') {
    handleDailyStats($pdo);
} else {
    errorResponse('Not found', 404);
}

// ============================================================================
// GET /api/stats - Dashboard summary
// ============================================================================
function handleDashboardStats(PDO $pdo): void {
    requireAdmin($pdo);

    // Total counts
    $totalUsers   = (int) $pdo->query("SELECT COUNT(*) FROM user")->fetchColumn();
    $totalRecipes = (int) $pdo->query("SELECT COUNT(*) FROM recipe")->fetchColumn();
    $totalReviews = (int) $pdo->query("SELECT COUNT(*) FROM review")->fetchColumn();
    $totalViews   = (int) $pdo->query("SELECT COUNT(*) FROM recipe_view")->fetchColumn();

    // Status breakdowns
    $usersByStatus = $pdo->query("SELECT status, COUNT(*) AS count FROM user GROUP BY status")->fetchAll();
    $recipesByStatus = $pdo->query("SELECT status, COUNT(*) AS count FROM recipe GROUP BY status")->fetchAll();

    // New this week
    $newUsersWeek   = (int) $pdo->query("SELECT COUNT(*) FROM user WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)")->fetchColumn();
    $newRecipesWeek = (int) $pdo->query("SELECT COUNT(*) FROM recipe WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)")->fetchColumn();
    $newReviewsWeek = (int) $pdo->query("SELECT COUNT(*) FROM review WHERE reviewed_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)")->fetchColumn();

    // Today stats
    $newUsersToday        = (int) $pdo->query("SELECT COUNT(*) FROM user WHERE DATE(created_at) = CURDATE()")->fetchColumn();
    $newContributorsToday = (int) $pdo->query("SELECT COUNT(*) FROM user WHERE DATE(created_at) = CURDATE() AND role = 'user' AND status != 'pending'")->fetchColumn();
    $contributors         = (int) $pdo->query("SELECT COUNT(*) FROM user WHERE role = 'user' AND status != 'pending'")->fetchColumn();
    $dailyViews           = (int) $pdo->query("SELECT COUNT(*) FROM recipe_view WHERE DATE(viewed_at) = CURDATE()")->fetchColumn();
    $dailyActiveUsers     = (int) $pdo->query("SELECT COUNT(DISTINCT id) FROM user WHERE DATE(last_active) = CURDATE()")->fetchColumn();

    // Recent activity (last 10)
    $recentActivity = $pdo->query("
        SELECT al.id, al.action_type AS actionType, al.target_type AS targetType,
               al.target_id AS targetId, al.description, al.created_at AS createdAt,
               u.username AS adminUsername
        FROM activity_log al
        JOIN user u ON u.id = al.admin_id
        ORDER BY al.created_at DESC
        LIMIT 10
    ")->fetchAll();

    // Top recipes by views
    $topRecipes = $pdo->query("
        SELECT r.id, r.title, r.image_url AS imageUrl,
               COUNT(rv.id) AS viewCount,
               u.username AS authorName
        FROM recipe r
        LEFT JOIN recipe_view rv ON rv.recipe_id = r.id
        JOIN user u ON u.id = r.author_id
        WHERE r.status = 'published'
        GROUP BY r.id
        ORDER BY viewCount DESC
        LIMIT 5
    ")->fetchAll();

    // Format status maps
    $userStatusMap = [];
    foreach ($usersByStatus as $row) {
        $userStatusMap[$row['status']] = (int) $row['count'];
    }
    $recipeStatusMap = [];
    foreach ($recipesByStatus as $row) {
        $recipeStatusMap[$row['status']] = (int) $row['count'];
    }

    // Category distribution
    $categoryDist = $pdo->query("
        SELECT category, COUNT(*) AS count
        FROM recipe
        WHERE status = 'published' AND category IS NOT NULL AND category != ''
        GROUP BY category
        ORDER BY count DESC
    ")->fetchAll();

    jsonResponse([
        'totals' => [
            'users'   => $totalUsers,
            'recipes' => $totalRecipes,
            'reviews' => $totalReviews,
            'views'   => $totalViews,
        ],
        'thisWeek' => [
            'newUsers'   => $newUsersWeek,
            'newRecipes' => $newRecipesWeek,
            'newReviews' => $newReviewsWeek,
        ],
        'today' => [
            'newUsers'          => $newUsersToday,
            'newContributors'   => $newContributorsToday,
            'dailyViews'        => $dailyViews,
            'dailyActiveUsers'  => $dailyActiveUsers,
        ],
        'contributors'        => $contributors,
        'usersByStatus'   => $userStatusMap,
        'recipesByStatus' => $recipeStatusMap,
        'categoryDistribution' => array_map(fn($c) => [
            'category' => $c['category'],
            'count'    => (int) $c['count'],
        ], $categoryDist),
        'topRecipes'     => array_map(fn($r) => [
            'id'         => (int) $r['id'],
            'title'      => $r['title'],
            'imageUrl'   => $r['imageUrl'],
            'viewCount'  => (int) $r['viewCount'],
            'authorName' => $r['authorName'],
        ], $topRecipes),
        'recentActivity' => $recentActivity,
    ]);
}

// ============================================================================
// GET /api/stats/daily - Daily stats (last 30 days)
// ============================================================================
function handleDailyStats(PDO $pdo): void {
    requireAdmin($pdo);

    $days = min(90, max(1, (int) ($_GET['days'] ?? 30)));

    $stmt = $pdo->prepare("
        SELECT stat_date AS statDate, new_users AS newUsers, new_recipes AS newRecipes,
               new_reviews AS newReviews, total_views AS totalViews,
               active_users AS activeUsers
        FROM daily_stat
        WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL :days DAY)
        ORDER BY stat_date ASC
    ");
    $stmt->bindValue(':days', $days, PDO::PARAM_INT);
    $stmt->execute();

    jsonResponse($stmt->fetchAll());
}
