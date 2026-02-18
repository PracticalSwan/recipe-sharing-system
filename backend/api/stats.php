<?php
// Stats API (admin): dashboard statistics and analytics
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/cors.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/../helpers/response.php';

setCorsHeaders();
initializeErrorHandling();

$pdo = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$route = $_GET['route'] ?? '';
$segments = $route ? array_values(array_filter(explode('/', $route))) : [];

if ($method !== 'GET') {
    errorResponse('Method not allowed', 405);
}

// Route dispatcher
if (empty($segments) || $segments[0] === 'dashboard') {
    handleDashboardStats($pdo);
} elseif ($segments[0] === 'daily') {
    handleDailyStats($pdo);
} else {
    errorResponse('Not found', 404);
}

// ============================================================================
// GET /api/stats — Dashboard summary with totals, breakdowns, top recipes,
//                  recent activity, and category distribution.
// ============================================================================
function handleDashboardStats(PDO $pdo): void {
    requireAdmin($pdo);

    // Auto-inactivity check: mark users idle >5 min as 'inactive'
    $pdo->exec("
        UPDATE user
        SET status = 'inactive'
        WHERE role = 'user'
          AND status = 'active'
          AND last_active IS NOT NULL
          AND last_active < DATE_SUB(NOW(), INTERVAL 5 MINUTE)
    ");

    // ----- Total counts across all records -----
    $totalUsers   = (int) $pdo->query("SELECT COUNT(*) FROM user")->fetchColumn();
    $totalRecipes = (int) $pdo->query("SELECT COUNT(*) FROM recipe")->fetchColumn();
    $totalReviews = (int) $pdo->query("SELECT COUNT(*) FROM review")->fetchColumn();
    $totalViews   = (int) $pdo->query("SELECT COUNT(*) FROM recipe_view")->fetchColumn();

    // ----- Status breakdowns (for pie charts / status badges) -----
    $usersByStatus = $pdo->query("SELECT status, COUNT(*) AS count FROM user GROUP BY status")->fetchAll();
    $recipesByStatus = $pdo->query("SELECT status, COUNT(*) AS count FROM recipe GROUP BY status")->fetchAll();

    // ----- "This week" metrics (last 7 days) -----
    $newUsersWeek   = (int) $pdo->query("SELECT COUNT(*) FROM user WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)")->fetchColumn();
    $newRecipesWeek = (int) $pdo->query("SELECT COUNT(*) FROM recipe WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)")->fetchColumn();
    $newReviewsWeek = (int) $pdo->query("SELECT COUNT(*) FROM review WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)")->fetchColumn();

    // ----- "Today" metrics -----
    $newUsersToday        = (int) $pdo->query("SELECT COUNT(*) FROM user WHERE DATE(created_at) = CURDATE()")->fetchColumn();
    $newContributorsToday = (int) $pdo->query("SELECT COUNT(*) FROM user WHERE DATE(created_at) = CURDATE() AND role = 'user' AND status != 'pending'")->fetchColumn();
    $contributors         = (int) $pdo->query("SELECT COUNT(*) FROM user WHERE role = 'user' AND status != 'pending'")->fetchColumn();
    $dailyViews           = (int) $pdo->query("SELECT COUNT(*) FROM recipe_view WHERE DATE(viewed_at) = CURDATE()")->fetchColumn();
    $dailyActiveUsers     = (int) $pdo->query("SELECT COUNT(DISTINCT id) FROM user WHERE DATE(last_active) = CURDATE()")->fetchColumn();

    // ----- Recent admin activity (last 10 actions, excluding routine status transitions) -----
    $recentActivity = $pdo->query("
        SELECT al.id, al.action_type AS actionType, al.target_type AS targetType,
               al.target_id AS targetId, al.description, al.created_at AS createdAt,
               u.username AS adminUsername
        FROM activity_log al
        JOIN user u ON u.id = al.admin_id
        WHERE NOT (
            al.action_type = 'user_update'
            AND (
                LOWER(al.description) LIKE '% to active'
                OR LOWER(al.description) LIKE '% to inactive'
            )
        )
        ORDER BY al.created_at DESC
        LIMIT 10
    ")->fetchAll();

    // ----- Top 5 recipes by total views -----
    $topRecipes = $pdo->query("
        SELECT r.id, r.title,
               (SELECT ri.image_url FROM recipe_image ri WHERE ri.recipe_id = r.id ORDER BY ri.display_order ASC LIMIT 1) AS main_image,
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

    // Convert status query results into key-value maps
    $userStatusMap = [];
    foreach ($usersByStatus as $row) {
        $userStatusMap[$row['status']] = (int) $row['count'];
    }
    $recipeStatusMap = [];
    foreach ($recipesByStatus as $row) {
        $recipeStatusMap[$row['status']] = (int) $row['count'];
    }

    // ----- Category distribution (for charts) -----
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
            'imageUrl'   => $r['main_image'],
            'viewCount'  => (int) $r['viewCount'],
            'authorName' => $r['authorName'],
        ], $topRecipes),
        'recentActivity' => $recentActivity,
    ]);
}

// GET /api/stats/daily — Daily time-series stats (default: 30 days)
function handleDailyStats(PDO $pdo): void {
    requireAdmin($pdo);

    $days = min(90, max(1, (int) ($_GET['days'] ?? 30)));

    $stmt = $pdo->prepare("
        SELECT
            ds.stat_date AS statDate,
            ds.new_user_count AS newUsers,
            ds.page_view_count AS totalViews,
            ds.active_user_count AS activeUsers,
            ds.recipe_view_count AS recipeViews,
            (SELECT COUNT(*) FROM recipe r WHERE DATE(r.created_at) = ds.stat_date) AS newRecipes,
            (SELECT COUNT(*) FROM review rv WHERE DATE(rv.created_at) = ds.stat_date) AS newReviews
        FROM daily_stat ds
        WHERE ds.stat_date >= DATE_SUB(CURDATE(), INTERVAL :days DAY)
        ORDER BY ds.stat_date ASC
    ");
    $stmt->bindValue(':days', $days, PDO::PARAM_INT);
    $stmt->execute();

    $rows = $stmt->fetchAll();
    $formatted = array_map(fn($row) => [
        'statDate'   => $row['statDate'],
        'newUsers'   => (int) $row['newUsers'],
        'newRecipes' => (int) $row['newRecipes'],
        'newReviews' => (int) $row['newReviews'],
        'totalViews' => (int) $row['totalViews'],
        'activeUsers' => (int) $row['activeUsers'],
        'recipeViews' => (int) $row['recipeViews'],
    ], $rows);

    jsonResponse($formatted);
}
