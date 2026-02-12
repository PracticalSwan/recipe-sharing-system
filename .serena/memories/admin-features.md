## Admin Features — Current & Planned (February 13, 2026)

### Current Frontend Components

**AdminStats.jsx (`src/pages/Admin/AdminStats.jsx`):**
- Aggregates database statistics (users/recipes/engagement metrics)
- Displays recent activity feed (from `activity_log` table)
- Listens to `statsUpdated` and `recipeUpdated` events
- Real-time dashboard updates

**AdminRecipes.jsx (`src/pages/Admin/AdminRecipes.jsx`):**
- Tab views: "Pending Queue", "Published", "Rejected"
- Recipe preview modal for detailed review
- Approve/Reject/Delete actions
- Logs admin actions to activity log for audit trail
- Dispatches `recipeUpdated` and `statsUpdated` events

**UserList.jsx (`src/pages/Admin/UserList.jsx`):**
- Search by username or email
- Filter by status (active, pending, suspended)
- Display user role, status, last active timestamp
- Status display uses session timeout logic (5 min) + stored status
- Actions: Approve (set to active), Suspend, Delete account
- Logs admin actions and updates stats

---

## Backend Admin API (Phase 4 — Pending)

### Admin-Only Endpoints (Requires is_admin = 1)

**1. GET /api/admin/pending-recipes [Require Admin]**

Lists all recipes with `status = 'pending'` for moderation.

```php
$session = validateSession($pdo);
if (!$session || !$session['is_admin']) send403Forbidden('Admin access required');

$stmt = $pdo->prepare("SELECT r.*, u.username, u.first_name, u.last_name,
                            COALESCE(d.view_count, 0) AS view_count,
                            COALESCE(d.like_count, 0) AS like_count,
                            COALESCE(d.favorite_count, 0) AS favorite_count,
                            COALESCE(d.review_count, 0) AS review_count
                       FROM recipe r
                       LEFT JOIN user u ON r.author_id = u.id
                       LEFT JOIN vw_recipe_with_stat d ON r.id = d.id
                       WHERE r.status = 'pending'
                       ORDER BY r.created_at DESC");

$stmt->execute([]);
echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
```

**2. POST /api/admin/approve-recipe [Require Admin]**

Approves or rejects a pending recipe using stored procedure.

```php
$session = validateSession($pdo);
if (!$session || !$session['is_admin']) send403Forbidden('Admin access required');

$recipeId = (int) $_POST['recipe_id'];
$action = $_POST['action']; // 'approve' or 'reject'
$reason = $_POST['reason'] ?? null;

// Validate action
if (!in_array($action, ['approve', 'reject'])) {
    send422UnprocessableEntity(['action' => 'Invalid action. Must be approve or reject']);
}

// Call stored procedure with admin logging
$pdo->prepare("CALL usp_ApproveRecipe(?, ?, ?, ?)")
    ->execute([$recipeId, $session['user_id'], $action, $reason]);

$verb = ($action === 'approve') ? 'approved' : 'rejected';
echo json_encode(['message' => "Recipe $verb successfully"]);
```

**3. GET /api/admin/users [Require Admin]**

Lists all users with filtering and statistics.

```php
$session = validateSession($pdo);
if (!$session || !$session['is_admin']) send403Forbidden('Admin access required');

$status = $_GET['status'] ?? null;
$search = $_GET['search'] ?? null;

// Build WHERE conditions
$where = [];
$params = [];

if ($status) {
    $where[] = "u.status = ?";
    $params[] = $status;
}

if ($search) {
    $where[] = "(u.username LIKE ? OR u.email LIKE ? OR u.first_name LIKE ?)";
    $param = "%$search%";
    $params[] = $param; $params[] = $param; $params[] = $param;
}

$sql = "SELECT u.id, u.username, u.email, u.first_name, u.last_name,
            u.is_admin, u.status, u.joined_date, u.last_active,
            COUNT(DISTINCT r.id) AS recipe_count,
            COALESCE(d.review_count, 0) AS review_count
         FROM user u
         LEFT JOIN recipe r ON u.id = r.author_id
         LEFT JOIN vw_user_dashboard_stat d ON u.id = d.user_id";

if (!empty($where)) {
    $sql .= " WHERE " . implode(' AND ', $where);
}

$sql .= " GROUP BY u.id ORDER BY u.joined_date DESC";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
```

**4. POST /api/admin/update-user-status [Require Admin]**

Updates user status to 'active', 'pending', or 'suspended'.

```php
$session = validateSession($pdo);
if (!$session || !$session['is_admin']) send403Forbidden('Admin access required');

$userId = (int) $_POST['user_id'];
$newStatus = $_POST['status'];

// Validate status
if (!in_array($newStatus, ['active', 'pending', 'suspended'])) {
    send422UnprocessableEntity(['status' => 'Invalid status value']);
}

// Update user status
$stmt = $pdo->prepare("UPDATE user SET status = ?, updated_at = NOW() WHERE id = ?");
$stmt->execute([$newStatus, $userId]);

// Log admin action for audit trail
$message = "Updated user $userId status to $newStatus";
$pdo->prepare("INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
                                VALUES (?, 'user_status_update', 'user', ?, ?)")
    ->execute([$session['user_id'], $userId, $message]);

echo json_encode(['message' => 'User status updated']);
```

**5. DELETE /api/admin/users/:id [Require Admin]**

Deletes a user account with cascade to all user data.

```php
$session = validateSession($pdo);
if (!$session || !$session['is_admin']) send403Forbidden('Admin access required');

$userId = (int) $_GET['id'];

// Prevent self-deletion
if ($userId === $session['user_id']) {
    send400BadRequest('Cannot delete your own admin account');
}

// Cascade deletes: user's recipes, reviews, favorites, likes, sessions, stats
$stmt = $pdo->prepare("DELETE FROM user WHERE id = ?");
$stmt->execute([$userId]);

// Log deletion
$pdo->prepare("INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
                                VALUES (?, 'user_delete', 'user', ?, 'Deleted user account')")
    ->execute([$session['user_id'], $userId]);

echo json_encode(['message' => 'User deleted successfully']);
```

---

## Stored Procedures (Corrected — Script 12)

### usp_ApproveRecipe (Lines 158-229)

Approves or rejects a pending recipe with complete audit logging.

**Parameters:**
- `pRecipeId INT` — Recipe to approve/reject
- `pAdminId INT` — Admin performing action
- `pAction VARCHAR(10)` — 'approve' or 'reject'
- `pReason VARCHAR(500)` — Optional rejection reason

**Logic:**
1. Validate recipe exists and is in 'pending' status
2. Validate action is 'approve' or 'reject'
3. Determine new status: 'published' if approve, 'rejected' if reject
4. Set action type and description for logging
5. Update `recipe.status` with `updated_at = NOW()`
6. Insert audit record into `activity_log`

**FK Fix Applied (February 13):**
- Changed `WHERE recipe_id = pRecipeId` → `WHERE id = pRecipeId` (parent table PK)

---

### usp_DeleteRecipe (Lines 110-153)

Deletes a recipe and all related data, logs admin action for audit trail.

**Parameters:**
- `pRecipeId INT` — Recipe to delete
- `pAdminId INT` — Admin performing deletion

**Logic:**
1. Execute in transaction with error handling
2. Verify recipe exists via `WHERE id = pRecipeId` (parent table PK)
3. Fetch recipe title and author_id for logging
4. Delete child records manually (FK cascade handles most, explicit for clarity):
   - `recipe_view` WHERE `recipe_id = pRecipeId`
   - `review` WHERE `recipe_id = pRecipeId`
   - `like_record` WHERE `recipe_id = pRecipeId`
   - `favorite` WHERE `recipe_id = pRecipeId`
   - `recipe_image` WHERE `recipe_id = pRecipeId`
   - `instruction` WHERE `recipe_id = pRecipeId`
   - `ingredient` WHERE `recipe_id = pRecipeId`
5. Delete the recipe itself via `WHERE id = pRecipeId` (parent table PK)
6. Insert audit record into `activity_log`

**FK Fix Applied (February 13):**
- Changed `WHERE recipe_id = pRecipeId` → `WHERE id = pRecipeId` on recipe table
- Child table references remain `WHERE recipe_id = pRecipeId` (correct FK usage)

---

### usp_GetRecipeStat (Lines 233-262)

Returns aggregated statistics for a specific recipe.

**Parameters:**
- `pRecipeId INT` — Recipe to get stats for

**Returns:** Single row with all recipe metrics

**Columns Returned:**
- `recipe_id`, `title`, `status`, `author_name`, `created_date`
- `total_views`, `total_likes`, `total_favorites`, `total_reviews`
- `avg_rating`, `min_rating`, `max_rating`
- `unique_viewers`

**FK Fixes Applied (February 13):**
- Changed `r.recipe_id` → `r.id` (parent table PK alias)
- Changed `u.display_name` → `u.username` (display_name doesn't exist)
- Changed `u.user_id` → `u.id` (parent table PK)
- Changed `WHERE r.recipe_id = pRecipeId` → `WHERE r.id = pRecipeId`

---

## Database Triggers (Corrected — Script 13)

### trg_Recipe_SetTimestamp (Lines 41-47)

**Event:** BEFORE INSERT on `recipe`
**Purpose:** Auto-set `created_at` and `updated_at` timestamps

```sql
CREATE TRIGGER trg_Recipe_SetTimestamp
BEFORE INSERT ON recipe
FOR EACH ROW
BEGIN
    SET NEW.created_at = NOW();
    SET NEW.updated_at = NOW();
END
```

**Status:** ✅ No changes needed (correctly uses NEW keyword)

---

### trg_User_SetTimestamp (Lines 49-56)

**Event:** BEFORE INSERT on `user`
**Purpose:** Auto-set `joined_date` timestamp for new users

```sql
CREATE TRIGGER trg_User_SetTimestamp
BEFORE INSERT ON user
FOR EACH ROW
BEGIN
    SET NEW.joined_date = NOW();
END
```

**Status:** ✅ No changes needed

---

### trg_User_UpdateLastActive (Lines 58-67 — **FIXED Feb 13**)

**Event:** BEFORE UPDATE on `user`
**Purpose:** Update `last_active` timestamp for activity tracking

**Original Bug:**
```sql
-- WRONG: user_id column doesn't exist on user table
WHERE user_id = NEW.user_id
```

**Fixed (February 13):**
```sql
-- CORRECT: Use parent table PK 'id'
-- Changed user_id → id on parent table
CREATE TRIGGER trg_User_UpdateLastActive
BEFORE UPDATE ON user
FOR EACH ROW
BEGIN
    SET NEW.last_active = NOW();
END

-- Removed incorrect WHERE clause (trigger already targets user row via ON UPDATE)
```

**Frontend Integration:** Called by `AuthContext.updateLastActive()` every minute via API ping.

---

### trg_Recipe_DeleteCleanup (Lines 69-84 — **FIXED Feb 13**)

**Event:** AFTER DELETE on `recipe`
**Purpose:** Manually cascade delete children that may not have FK constraints

**Original Bug (Used OLD.recipe_id):**
```sql
-- WRONG: recipe_id column doesn't exist on recipe table
DELETE FROM recipe_view WHERE recipe_id = OLD.recipe_id;
DELETE FROM recipe_image WHERE recipe_id = OLD.recipe_id;
DELETE FROM ingredient WHERE recipe_id = OLD.recipe_id;
```

**Fixed (February 13):**
```sql
-- CORRECT: Use parent table PK 'id'
-- Changed OLD.recipe_id → OLD.id (3 occurrences)
CREATE TRIGGER trg_Recipe_DeleteCleanup
AFTER DELETE ON recipe
FOR EACH ROW
BEGIN
    DELETE FROM recipe_view WHERE recipe_id = OLD.id;
    DELETE FROM recipe_image WHERE recipe_id = OLD.id;
    DELETE FROM ingredient WHERE recipe_id = OLD.id;
END
```

**Status:** ✅ Corrected to query child tables using parent PK reference

---

### trg_User_NewUserStat (Lines 104-118)

**Event:** AFTER INSERT on `user`
**Purpose:** Create initial `daily_stat` entry for new users

```sql
CREATE TRIGGER trg_User_NewUserStat
AFTER INSERT ON user
FOR EACH ROW
BEGIN
    INSERT INTO daily_stat (stat_date, user_id, recipes, reviews, views, likes, favorites)
    VALUES (CURDATE(), NEW.id, 0, 0, 0, 0, 0);
END
```

**Status:** ✅ No changes needed

---

### trg_RecipeView_UpdateStat (Lines 120-138)

**Event:** AFTER INSERT on `recipe_view`
**Purpose:** Increment daily view count in `daily_stat` table

```sql
CREATE TRIGGER trg_RecipeView_UpdateStat
AFTER INSERT ON recipe_view
FOR EACH ROW
BEGIN
    INSERT INTO daily_stat (stat_date, user_id, recipes, reviews, views, likes, favorites)
    VALUES (CURDATE(), NEW.user_id, 0, 0, 1, 0, 0)
    ON DUPLICATE KEY UPDATE views = views + 1;
END
```

**Status:** ✅ No changes needed

---

## Activity Logging System

### Purpose
Track all administrative actions, recipe status changes, and user deletions for complete audit trail.

### activity_log Schema (Script 02, lines 271-291)

| Column | Type | Description |
|---------|--------|-------------|
| `id` | INT AUTO_INCREMENT PK | Log entry ID |
| `admin_id` | INT | FK to user.id (admin performing action) |
| `action_type` | VARCHAR(50) | Action type: 'recipe_approve', 'recipe_reject', 'recipe_delete', 'user_status_update', 'user_delete' |
| `target_type` | VARCHAR(20) | Target type: 'recipe', 'user' |
| `target_id` | INT | ID of the affected entity |
| `description` | TEXT | Human-readable action description |
| `created_at` | TIMESTAMP DEFAULT NOW() | When action occurred |

### Activity Log API (Pending — Phase 4)

**GET /api/admin/activity-log [Require Admin]**

```php
$session = validateSession($pdo);
if (!$session || !$session['is_admin']) send403Forbidden('Admin access required');

$limit = $_GET['limit'] ?? 50;
$stmt = $pdo->prepare("SELECT al.*, u.username, u.first_name, u.last_name
                          FROM activity_log al
                          LEFT JOIN user u ON al.admin_id = u.id
                          ORDER BY al.created_at DESC
                          LIMIT ?");
$stmt->execute([$limit]);
echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
```

---

## Frontend Integration (Phase 5)

### AdminStats.jsx Updates

**Current:** Uses localStorage for mock statistics
**Target:** Query admin statistics from API

```javascript
// Fetch dashboard stats
const fetchStats = async () => {
    const response = await fetchWithAuth('/api/admin/stats');
    const data = await response.json();
    setStats(data);
};

// Fetch recent activity
const fetchActivity = async () => {
    const response = await fetchWithAuth('/api/admin/activity-log?limit=10');
    const activity = await response.json();
    setRecentActivity(activity);
};
```

---

### AdminRecipes.jsx Updates

**Pending Queue Implementation:**

```javascript
// Fetch pending recipes
useEffect(() => {
    const fetchPending = async () => {
        const response = await fetchWithAuth('/api/admin/pending-recipes');
        const recipes = await response.json();
        setPendingRecipes(recipes);
    };
    fetchPending();
}, []);

// Approve action
const handleApprove = async (recipeId) => {
    await fetchWithAuth('/api/admin/approve-recipe', {
        method: 'POST',
        body: JSON.stringify({ recipe_id: recipeId, action: 'approve' })
    });
    // Refresh pending queue
    fetchPending();
    // Dispatch stats update
    dispatch({ type: 'STATS_UPDATED' });
};

// Reject action with reason
const handleReject = async (recipeId, reason) => {
    await fetchWithAuth('/api/admin/approve-recipe', {
        method: 'POST',
        body: JSON.stringify({
            recipe_id: recipeId,
            action: 'reject',
            reason: reason
        })
    });
    fetchPending();
    dispatch({ type: 'STATS_UPDATED' });
};
```

**Recipe Preview Modal:**

```javascript
<RecipePreviewModal recipe={selectedRecipe}>
    <RecipeCard recipe={recipe} showFullDetails={true} />
    <Actions>
        <Button onClick={() => handleApprove(recipe.id)}>Approve</Button>
        <Button variant="danger"
                onClick={() => setShowRejectModal(true)}>Reject</Button>
    </Actions>
</RecipePreviewModal>

<RejectReasonModal isOpen={showRejectModal}
                    onSubmit={(reason) => handleReject(recipe.id, reason)} />
```

---

### UserList.jsx Updates

**User Filtering + Actions:**

```javascript
// Filter users
useEffect(() => {
    const fetchUsers = async () => {
        const params = new URLSearchParams();
        if (currentStatus) params.set('status', currentStatus);
        if (searchQuery) params.set('search', searchQuery);

        const response = await fetchWithAuth(`/api/admin/users?${params}`);
        const users = await response.json();
        setUsers(users);
    };
    fetchUsers();
}, [currentStatus, searchQuery]);

// Status update actions
const handleStatusUpdate = async (userId, newStatus) => {
    await fetchWithAuth('/api/admin/update-user-status', {
        method: 'POST',
        body: JSON.stringify({ user_id: userId, status: newStatus })
    });
    // Refresh user list
    fetchUsers();
};

// Delete user action
const handleDeleteUser = async (userId, username) => {
    if (window.confirm(`Delete user ${username}? This action cannot be undone.`)) {
        await fetchWithAuth(`/api/admin/users/${userId}`, { method: 'DELETE' });
        fetchUsers();
    }
};

// Session timeout display (5 min)
const isSessionActive = useMemo(() => {
    const fiveMinutesAgo = Date.now() - (5 * 60 * 1000);
    return new Date(user.last_active) > fiveMinutesAgo;
}, [user.last_active]);
```

 **User Row Component:**

```javascript
<UserRow user={user} isSessionActive={isSessionActive}>
    <Actions>
        {user.status !== 'active' && (
            <Button onClick={() => handleStatusUpdate(user.id, 'active')}>
                Approve
            </Button>
        )}
        {user.status === 'active' && (
            <Button variant="warn"
                    onClick={() => handleStatusUpdate(user.id, 'suspended')}>
                Suspend
            </Button>
        )}
        <Button variant="danger"
                onClick={() => handleDeleteUser(user.id, user.username)}>
            Delete
        </Button>
    </Actions>
</UserRow>
```

---

## Related Files

**Database (Schema Corrected February 13, 2026):**
- [database/02_create_tables.sql](../../database/02_create_tables.sql) — user (lines 34-59), recipe (79-101), activity_log (271-291)
- [database/12_stored_procedures.sql](../../database/12_stored_procedures.sql) — usp_ApproveRecipe, usp_DeleteRecipe, usp_GetRecipeStat
- [database/13_triggers.sql](../../database/13_triggers.sql) — All 6 triggers (trg_User_UpdateLastActive, trg_Recipe_DeleteCleanup fixed)

**Queries:**
- [database/10_admin_queries.sql](../../database/10_admin_queries.sql) — Admin query library (5 queries, fully rewritten Feb 13)

**Components:**
- [AdminStats.jsx](../../src/pages/Admin/AdminStats.jsx) — Dashboard statistics component
- [AdminRecipes.jsx](../../src/pages/Admin/AdminRecipes.jsx) — Pending queue + moderation component
- [UserList.jsx](../../src/pages/Admin/UserList.jsx) — User management component

---

## Next Steps

### Phase 4: Admin Backend Tasks
1. ⏳ Implement `/api/admin/pending-recipes` GET endpoint
2. ⏳ Implement `/api/admin/approve-recipe` POST endpoint (uses stored procedure)
3. ⏳ Implement `/api/admin/users` GET endpoint with filtering
4. ⏳ Implement `/api/admin/update-user-status` POST endpoint
5. ⏳ Implement `/api/admin/users/:id` DELETE endpoint
6. ⏳ Implement `/api/admin/activity-log` GET endpoint

### Phase 5: Admin Frontend Integration
1. ⏳ Update AdminStats.jsx to fetch stats from API
2. ⏳ Update AdminRecipes.jsx to fetch pending queue from API
3. ⏳ Add rejection reason modal to AdminRecipes.jsx
4. ⏳ Update UserList.jsx to fetch users from API with filters
5. ⏳ Implement activity log viewer component for audit trail