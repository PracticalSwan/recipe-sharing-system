# Database Implementation Logic & Constraints Explanation

## Document Information

| Property | Value |
|----------|-------|
| **Document Title** | Database Implementation Logic Explanation |
| **Project** | Recipe Sharing System - MySQL Database Integration |
| **Course** | CSX3006 Database Systems |
| **Created** | 2026-02-04 |
| **Author** | AI Assistant (GitHub Copilot) |
| **Related Plan** | [upgrade-database-integration-1.md](./upgrade-database-integration-1.md) |

---

## Table of Contents

1. [Overview](#1-overview)
2. [Database Design Philosophy](#2-database-design-philosophy)
3. [Entity-Relationship Model](#3-entity-relationship-model)
4. [Table Design & Schema Logic](#4-table-design--schema-logic)
5. [Naming Conventions](#5-naming-conventions)
6. [Constraints & Data Integrity](#6-constraints--data-integrity)
7. [Indexing Strategy](#7-indexing-strategy)
8. [Views Logic](#8-views-logic)
9. [Stored Procedures Logic](#9-stored-procedures-logic)
10. [Triggers Logic](#10-triggers-logic)
11. [Data Seeding Strategy](#11-data-seeding-strategy)
12. [Query Patterns & Examples](#12-query-patterns--examples)
13. [Security Considerations](#13-security-considerations)
14. [Performance Optimization](#14-performance-optimization)

---

## 1. Overview

### Purpose

This document explains the **logic, rationale, and constraints** behind the database design for the Recipe Sharing System migration from localStorage to MySQL. It serves as a comprehensive reference for understanding:

- Why each table exists and its purpose
- How tables relate to each other
- What constraints enforce data integrity
- How stored procedures and triggers automate complex operations
- Query patterns for common operations

### Scope

The database design covers:

- **13 core tables** for the recipe sharing functionality
- **2 database views** for commonly accessed aggregated data
- **5 stored procedures** for complex transactional operations
- **6 triggers** for automatic data maintenance
- **7+ indexes** for query optimization

### Design Goals

| Goal | Description |
|------|-------------|
| **Data Integrity** | Ensure all data relationships are valid and consistent |
| **Normalization** | Minimize redundancy through proper 3NF normalization |
| **Performance** | Optimize for read-heavy workloads (browsing recipes) |
| **Security** | Prevent SQL injection, enforce access control |
| **Auditability** | Track changes and admin actions |
| **Scalability** | Support growth to 10,000+ recipes, 100,000+ users |

---

## 2. Database Design Philosophy

### 2.1 Normalization to Third Normal Form (3NF)

The schema follows **Third Normal Form (3NF)** to eliminate data redundancy and ensure data integrity:

```
1NF: All columns contain atomic (indivisible) values
     ↓
2NF: All non-key columns depend on the entire primary key
     ↓
3NF: No transitive dependencies (non-key columns don't depend on other non-key columns)
```

**Example of 3NF Application:**

Instead of storing recipe author name directly in the `recipe` table (which would be denormalized):

```sql
-- ❌ BAD (Denormalized - author name repeated, update anomaly risk)
CREATE TABLE recipe (
    id INT PRIMARY KEY,
    title VARCHAR(200),
    author_name VARCHAR(100),  -- Redundant! What if user changes name?
    author_email VARCHAR(100)  -- Redundant!
);

-- ✅ GOOD (3NF - author info stored once in user table)
CREATE TABLE recipe (
    id INT PRIMARY KEY,
    title VARCHAR(200),
    author_id INT,  -- Foreign key to user table
    FOREIGN KEY (author_id) REFERENCES user(id)
);
```

### 2.2 Singular Table Names

All table names use **singular form** following the convention that each row represents one entity:

| ✅ Correct | ❌ Incorrect |
|-----------|-------------|
| `user` | `users` |
| `recipe` | `recipes` |
| `ingredient` | `ingredients` |
| `review` | `reviews` |

**Rationale:**
- Each row in `user` table represents ONE user
- SQL reads more naturally: `SELECT * FROM user WHERE id = 1`
- Consistent with ORM conventions (User model → user table)

### 2.3 Surrogate Primary Keys

All tables use **auto-incrementing integer surrogate keys** (`id INT AUTO_INCREMENT PRIMARY KEY`):

**Benefits:**
- Unique, immutable identifier for each row
- No business meaning (won't need to change if business rules change)
- Efficient for indexing and foreign key relationships
- Simple JOIN conditions (`user.id = recipe.author_id`)

**Alternative Considered but Rejected:**
- Natural keys (e.g., email as PK for user) - problematic if email changes
- UUIDs - larger storage, slower indexing, harder to debug

---

## 3. Entity-Relationship Model

### 3.1 Core Entities

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ENTITY RELATIONSHIPS                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│    ┌──────────┐         creates          ┌──────────┐               │
│    │   USER   │ ─────────────────────────│  RECIPE  │               │
│    └──────────┘         1:N              └──────────┘               │
│         │                                      │                     │
│         │ writes                    contains   │                     │
│         │ 1:N                          1:N     │                     │
│         ▼                                      ▼                     │
│    ┌──────────┐                         ┌─────────────┐             │
│    │  REVIEW  │                         │ INGREDIENT  │             │
│    └──────────┘                         └─────────────┘             │
│         │                                      │                     │
│         │ rates                                │                     │
│         │ N:1                                  │                     │
│         ▼                                      ▼                     │
│    ┌──────────┐                         ┌─────────────┐             │
│    │  RECIPE  │◄────────────────────────│ INSTRUCTION │             │
│    └──────────┘                         └─────────────┘             │
│                                                                      │
│    ENGAGEMENT ENTITIES:                                              │
│    ┌──────────┐  ┌──────────┐  ┌─────────────┐  ┌──────────────┐   │
│    │   LIKE   │  │ FAVORITE │  │ RECIPE_VIEW │  │ SEARCH_HIST  │   │
│    └──────────┘  └──────────┘  └─────────────┘  └──────────────┘   │
│                                                                      │
│    ADMIN/SYSTEM ENTITIES:                                            │
│    ┌──────────┐  ┌──────────┐  ┌─────────────┐                      │
│    │ SESSION  │  │DAILY_STAT│  │ ACTIVITY_LOG│                      │
│    └──────────┘  └──────────┘  └─────────────┘                      │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Cardinality Summary

| Relationship | Cardinality | Description |
|--------------|-------------|-------------|
| User → Recipe | 1:N | One user creates many recipes |
| Recipe → Ingredient | 1:N | One recipe has many ingredients |
| Recipe → Instruction | 1:N | One recipe has many instructions |
| Recipe → Recipe_Image | 1:N | One recipe has many images |
| User → Review | 1:N | One user writes many reviews |
| Recipe → Review | 1:N | One recipe receives many reviews |
| User ↔ Recipe (via Like) | N:M | Many users like many recipes |
| User ↔ Recipe (via Favorite) | N:M | Many users favorite many recipes |
| User → Session | 1:N | One user can have multiple sessions |
| User → Search_History | 1:N | One user has many search queries |
| User → Activity_Log | 1:N | One admin logs many activities |

---

## 4. Table Design & Schema Logic

### 4.1 `user` Table

**Purpose:** Stores all user account information including authentication credentials, profile data, and account status.

```sql
CREATE TABLE user (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(100) NOT NULL,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    email           VARCHAR(100) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    birthday        DATE,
    role            ENUM('admin', 'user') DEFAULT 'user',
    status          ENUM('active', 'inactive', 'pending', 'suspended') DEFAULT 'pending',
    joined_date     DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_active     DATETIME,
    avatar_url      TEXT,
    bio             TEXT,
    location        VARCHAR(100),
    cooking_level   VARCHAR(50),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Column Logic:**

| Column | Type | Rationale |
|--------|------|-----------|
| `id` | INT AUTO_INCREMENT | Surrogate PK, efficient for FKs |
| `email` | VARCHAR(100) UNIQUE | Natural identifier, used for login, must be unique |
| `password_hash` | VARCHAR(255) | Stores bcrypt hash (60 chars min, 255 for future algorithms) |
| `role` | ENUM | Restricted values prevent invalid roles, efficient storage |
| `status` | ENUM | Four states map to application workflow: pending→active→inactive/suspended |
| `avatar_url` | TEXT | URLs can be long, TEXT allows flexibility |
| `created_at/updated_at` | TIMESTAMP | Audit trail, automatic updates via ON UPDATE |

**Constraints:**
- `UNIQUE(email)` - Prevents duplicate accounts
- `NOT NULL(email, password_hash, username)` - Required for authentication
- `ENUM` for role/status - Restricts to valid values only

**Status State Machine:**
```
┌─────────┐   Admin Approves   ┌────────┐
│ pending │ ─────────────────► │ active │
└─────────┘                    └────────┘
                                   │
                  ┌────────────────┼────────────────┐
                  ▼                ▼                ▼
            ┌──────────┐    ┌───────────┐    ┌───────────┐
            │ inactive │    │ suspended │    │  (delete) │
            └──────────┘    └───────────┘    └───────────┘
```

---

### 4.2 `recipe` Table

**Purpose:** Stores recipe metadata and links to author. Acts as the central entity connecting ingredients, instructions, images, reviews, likes, and views.

```sql
CREATE TABLE recipe (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(200) NOT NULL,
    description     TEXT,
    category        VARCHAR(50),
    difficulty      ENUM('Easy', 'Medium', 'Hard'),
    prep_time       INT,
    cook_time       INT,
    servings        INT,
    author_id       INT NOT NULL,
    status          ENUM('published', 'pending', 'rejected') DEFAULT 'pending',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_recipe_author 
        FOREIGN KEY (author_id) REFERENCES user(id) ON DELETE CASCADE
);
```

**Column Logic:**

| Column | Type | Rationale |
|--------|------|-----------|
| `title` | VARCHAR(200) | Reasonable limit for recipe names |
| `description` | TEXT | Long descriptions allowed |
| `category` | VARCHAR(50) | Flexible categories (Italian, Mexican, etc.) |
| `difficulty` | ENUM | Three fixed levels, consistent across app |
| `prep_time/cook_time` | INT | Minutes as integer, allows calculations |
| `servings` | INT | Whole number of servings |
| `status` | ENUM | Workflow: pending → published/rejected |

**Foreign Key Behavior:**
- `ON DELETE CASCADE` on `author_id`: If user is deleted, their recipes are also deleted
- This matches the application logic where deleting a user removes all their content

**Status Workflow:**
```
User Creates Recipe    Admin Reviews
       │                    │
       ▼                    ▼
   ┌─────────┐         ┌─────────┐
   │ pending │ ───────►│published│ (visible to all users)
   └─────────┘    │    └─────────┘
                  │
                  │    ┌──────────┐
                  └───►│ rejected │ (visible only to author)
                       └──────────┘
```

---

### 4.3 `ingredient` Table

**Purpose:** Stores individual ingredients for each recipe with quantity and unit information.

```sql
CREATE TABLE ingredient (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id       INT NOT NULL,
    name            VARCHAR(200) NOT NULL,
    quantity        VARCHAR(50),
    unit            VARCHAR(50),

**Purpose (updated):** Tracks recipe views for analytics, associated only with authenticated users.

```sql
CREATE TABLE recipe_view (
        id               INT AUTO_INCREMENT PRIMARY KEY,
        recipe_id        INT NOT NULL,
        user_id          INT NOT NULL,
        viewed_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_recipe_viewed (recipe_id, viewed_at),
        INDEX idx_user_viewed (user_id, viewed_at),
        CONSTRAINT fk_recipe_view_recipe FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT fk_recipe_view_user FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
);
```

**Design for Authenticated User-Only Tracking:**

- `recipe_view` now requires a non-NULL `user_id` to associate each view with an authenticated user; guest/session-based tracking has been removed per project decision.
- There is no `viewer_type` or `guest_identifier` column in this design; all analytics and personalization are derived from authenticated-user activity only.

**Why use `ON DELETE CASCADE` for `user_id`?**

- The chosen behavior is to cascade-delete views when a user is removed, aligning with stricter data-retention and user-deletion policies (removes user-related history). If the project prefers to retain anonymous analytics while removing personal identifiers, consider `ON DELETE SET NULL` and allow `user_id` to be nullable instead.

**Indexing:**

- `idx_recipe_viewed (recipe_id, viewed_at)` supports fast aggregation of views per recipe and time-range queries.
- `idx_user_viewed (user_id, viewed_at)` supports user activity queries (recent views, history).
```

**Column Logic:**

| Column | Type | Rationale |
|--------|------|-----------|
| `quantity` | VARCHAR(50) | Allows "1/2", "2-3", "to taste" - not just numbers |
| `unit` | VARCHAR(50) | Flexible units: cups, g, tbsp, pinch, etc. |
| `sort_order` | INT | Maintains display order, allows reordering |

**Cascade Delete:** When recipe is deleted, all its ingredients are automatically deleted.

---

### 4.4 `instruction` Table

**Purpose:** Stores step-by-step cooking instructions with explicit ordering.

```sql
CREATE TABLE instruction (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id        INT NOT NULL,
    step_number      INT NOT NULL,
    instruction_text TEXT NOT NULL,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_instruction_recipe 
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE
);
```

**Column Logic:**

| Column | Type | Rationale |
|--------|------|-----------|
| `step_number` | INT NOT NULL | Explicit ordering, allows gaps for insertion |
| `instruction_text` | TEXT NOT NULL | Long instructions possible |

**Why step_number instead of sort_order?**
- Semantically meaningful: "Step 1", "Step 2"
- Displayed to user as part of the instruction
- `sort_order` would be metadata only

---

### 4.5 `recipe_image` Table

**Purpose:** Stores multiple image URLs per recipe with display ordering.

```sql
CREATE TABLE recipe_image (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id       INT NOT NULL,
    image_url       TEXT NOT NULL,
    display_order   INT DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_image_recipe 
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE
);
```

**Design Decision:**
- Supports multiple images per recipe (gallery)
- `display_order` determines which image shows first (main image)
- Images stored as URLs (not BLOBs) - follows best practice of storing files externally

---

### 4.6 `review` Table

**Purpose:** Stores user reviews with ratings for recipes. Enforces one review per user per recipe.

```sql
CREATE TABLE review (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    recipe_id       INT NOT NULL,
    rating          INT NOT NULL,
    comment         TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_review_user 
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    CONSTRAINT fk_review_recipe 
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE,
    CONSTRAINT chk_rating 
        CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT unique_user_recipe 
        UNIQUE (user_id, recipe_id)
);
```

**Critical Constraints:**

1. **CHECK (rating >= 1 AND rating <= 5)**
   - Enforces valid rating range at database level
   - Application validation is first line of defense, DB constraint is second

2. **UNIQUE (user_id, recipe_id)**
   - Prevents user from submitting multiple reviews for same recipe
   - Application shows "Edit Review" instead of "Add Review" if review exists

**Cascade Behavior:**
- If user deleted → their reviews deleted
- If recipe deleted → all reviews for that recipe deleted

---

### 4.7 `favorite` Table (Junction/Bridge Table)

**Purpose:** Implements many-to-many relationship between users and recipes for favorites/saved recipes.

```sql
CREATE TABLE favorite (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    recipe_id       INT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_favorite_user 
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    CONSTRAINT fk_favorite_recipe 
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE,
    CONSTRAINT unique_user_recipe_favorite 
        UNIQUE (user_id, recipe_id)
);
```

**Junction Table Pattern:**
```
┌──────┐           ┌──────────┐           ┌────────┐
│ USER │ ──1:N──►  │ FAVORITE │  ◄──N:1── │ RECIPE │
└──────┘           └──────────┘           └────────┘
   │                    │                      │
   └────────────── N:M ─┴──────────────────────┘
```

**Why separate table instead of array in user table?**
- Proper 1NF (no arrays in columns)
- Queryable: "Find all users who favorited recipe X"
- Timestamped: "When did user favorite this recipe?"

---

### 4.8 `like_record` Table

**Purpose:** Tracks recipe likes (similar to favorites but semantically different).

```sql
CREATE TABLE like_record (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    recipe_id       INT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_like_user 
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
    CONSTRAINT fk_like_recipe 
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE,
    CONSTRAINT unique_user_recipe_like 
        UNIQUE (user_id, recipe_id)
);
```

**Why `like_record` instead of `like`?**
- `LIKE` is a SQL reserved keyword
- Using `like_record` avoids escaping issues: `` `like` `` vs `like_record`

**Difference from Favorites:**
- **Like**: Quick engagement, shows appreciation (heart icon)
- **Favorite**: Saves recipe for later (bookmark icon)
- Users can like AND favorite the same recipe

---

### 4.9 `recipe_view` Table

**Purpose:** Tracks recipe views for analytics, supporting both authenticated users and guests.

```sql
CREATE TABLE recipe_view (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id        INT NOT NULL,
    viewer_type      ENUM('user', 'guest') NOT NULL,
    viewer_id        INT,
    guest_identifier VARCHAR(100),
    viewed_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_view_recipe 
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE,
    CONSTRAINT fk_view_user 
        FOREIGN KEY (viewer_id) REFERENCES user(id) ON DELETE SET NULL,
        
    INDEX idx_recipe_viewed (recipe_id, viewed_at)
);
```

**Design for Guest Tracking:**

```
Authenticated User View:
  viewer_type = 'user'
  viewer_id = user.id (FK)
  guest_identifier = NULL

Guest View:
  viewer_type = 'guest'
  viewer_id = NULL
  guest_identifier = 'guest:abc123...' (session-based ID)
```

**Why ON DELETE SET NULL for viewer_id?**
- Preserve view history even if user is deleted
- Analytics remain accurate (view count doesn't decrease)
- Contrast with recipe FK which cascades (no orphan views for deleted recipes)

---

### 4.10 `search_history` Table

**Purpose:** Stores user search queries for personalization and analytics.

```sql
CREATE TABLE search_history (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    query           TEXT NOT NULL,
    searched_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_search_user 
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
);
```

**Use Cases:**
- Show recent searches to user
- Suggest popular searches
- Analytics: "What are users searching for?"
- Personalization: "Based on your searches..."

---

### 4.11 `daily_stat` Table

**Purpose:** Pre-aggregated daily statistics for admin dashboard performance.

```sql
CREATE TABLE daily_stat (
    id                 INT AUTO_INCREMENT PRIMARY KEY,
    stat_date          DATE UNIQUE NOT NULL,
    page_view_count    INT DEFAULT 0,
    active_user_count  INT DEFAULT 0,
    new_user_count     INT DEFAULT 0,
    recipe_view_count  INT DEFAULT 0,
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Why Pre-Aggregated Stats?**

```
Option A (Slow): Calculate on every dashboard load
  SELECT COUNT(*) FROM user WHERE DATE(joined_date) = CURDATE()
  SELECT COUNT(*) FROM recipe_view WHERE DATE(viewed_at) = CURDATE()
  -- Multiple slow queries every time

Option B (Fast): Use pre-aggregated daily_stat table
  SELECT * FROM daily_stat WHERE stat_date = CURDATE()
  -- Single fast query, triggers keep it updated
```

**UNIQUE(stat_date):** Ensures one row per day, simplifies updates.

---

### 4.12 `activity_log` Table

**Purpose:** Audit trail for admin actions (user management, recipe moderation).

```sql
CREATE TABLE activity_log (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    admin_id        INT,
    action_type     ENUM('user_create', 'user_update', 'user_delete', 
                         'recipe_approve', 'recipe_reject', 'recipe_delete') NOT NULL,
    target_type     VARCHAR(50),
    target_id       INT,
    description     TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_activity_admin 
        FOREIGN KEY (admin_id) REFERENCES user(id) ON DELETE SET NULL
);
```

**Design Decisions:**

1. **ON DELETE SET NULL for admin_id**
   - Preserve audit history even if admin account is deleted
   - Historical records show "action performed" even without who

2. **ENUM for action_type**
   - Restricts to known action types
   - Easier filtering: `WHERE action_type = 'recipe_approve'`

3. **target_type + target_id pattern**
   - Polymorphic reference: can link to user OR recipe
   - `target_type = 'user', target_id = 5` → refers to user with id=5
   - `target_type = 'recipe', target_id = 12` → refers to recipe with id=12

---

### 4.13 `session` Table

**Purpose:** Server-side session management for authentication.

```sql
CREATE TABLE session (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    session_token   VARCHAR(255) UNIQUE NOT NULL,
    expires_at      DATETIME NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_session_user 
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
);
```

**Session vs JWT Decision:**

| Aspect | Server Sessions (This Design) | JWT Tokens |
|--------|------------------------------|------------|
| Storage | Database | Client-side |
| Revocation | Easy (delete row) | Hard (need blacklist) |
| Scalability | Needs DB access | Stateless |
| Security | Server controls validity | Token can't be revoked until expiry |

**Chosen: Server Sessions** because:
- Easier to implement for course project
- Instant logout/revocation capability
- Simpler security model

---

## 5. Naming Conventions

### 5.1 Summary Table

| Element | Convention | Example |
|---------|------------|---------|
| Tables | singular, snake_case | `user`, `recipe_view`, `daily_stat` |
| Columns | singular, snake_case | `first_name`, `author_id`, `created_at` |
| Primary Keys | `id` | `user.id`, `recipe.id` |
| Foreign Keys | `{referenced_table}_id` | `author_id`, `recipe_id` |
| Indexes | `idx_{table}_{column(s)}` | `idx_recipe_author_status` |
| Views | `vw_{description}` | `vw_recipe_with_stat` |
| Stored Procedures | `usp_{Action}{Entity}` | `usp_CreateRecipe`, `usp_ApproveRecipe` |
| Functions | `fn_{Action}{Entity}` | `fn_CalculateAvgRating` |
| Triggers | `trg_{Table}_{Event}` | `trg_User_NewUserStat` |
| Constraints | `chk_{column}`, `unique_{description}` | `chk_rating`, `unique_user_recipe` |
| FK Constraints | `fk_{table}_{referenced}` | `fk_recipe_author` |

### 5.2 SQL Keyword Capitalization

All SQL keywords must be UPPERCASE for readability:

```sql
-- ✅ Correct
SELECT u.id, u.username, COUNT(r.id) AS recipe_count
FROM user u
LEFT JOIN recipe r ON u.id = r.author_id
WHERE u.status = 'active'
GROUP BY u.id
HAVING recipe_count > 5
ORDER BY recipe_count DESC
LIMIT 10;

-- ❌ Incorrect
select u.id, u.username, count(r.id) as recipe_count
from user u
left join recipe r on u.id = r.author_id
where u.status = 'active'
group by u.id
having recipe_count > 5
order by recipe_count desc
limit 10;
```

---

## 6. Constraints & Data Integrity

### 6.1 Constraint Types Used

| Constraint Type | Purpose | Example |
|-----------------|---------|---------|
| PRIMARY KEY | Unique row identifier | `id INT PRIMARY KEY` |
| FOREIGN KEY | Referential integrity | `FOREIGN KEY (author_id) REFERENCES user(id)` |
| UNIQUE | Prevent duplicates | `UNIQUE (user_id, recipe_id)` |
| NOT NULL | Required fields | `email VARCHAR(100) NOT NULL` |
| CHECK | Value validation | `CHECK (rating >= 1 AND rating <= 5)` |
| DEFAULT | Automatic values | `DEFAULT CURRENT_TIMESTAMP` |
| ENUM | Restricted values | `ENUM('admin', 'user')` |

### 6.2 Referential Integrity Actions

| Action | When Used | Effect |
|--------|-----------|--------|
| `ON DELETE CASCADE` | Parent-child relationships | Delete children when parent deleted |
| `ON DELETE SET NULL` | Preserve history | Set FK to NULL, keep record |
| `ON UPDATE CASCADE` | If PK changes (rare) | Update FK values automatically |

**Cascade Delete Chain Example:**
```
DELETE FROM user WHERE id = 5
    ├── CASCADE → DELETE FROM recipe WHERE author_id = 5
    │       ├── CASCADE → DELETE FROM ingredient WHERE recipe_id IN (...)
    │       ├── CASCADE → DELETE FROM instruction WHERE recipe_id IN (...)
    │       ├── CASCADE → DELETE FROM recipe_image WHERE recipe_id IN (...)
    │       ├── CASCADE → DELETE FROM review WHERE recipe_id IN (...)
    │       ├── CASCADE → DELETE FROM like_record WHERE recipe_id IN (...)
    │       ├── CASCADE → DELETE FROM favorite WHERE recipe_id IN (...)
    │       └── CASCADE → DELETE FROM recipe_view WHERE recipe_id IN (...)
    ├── CASCADE → DELETE FROM review WHERE user_id = 5
    ├── CASCADE → DELETE FROM like_record WHERE user_id = 5
    ├── CASCADE → DELETE FROM favorite WHERE user_id = 5
    ├── CASCADE → DELETE FROM search_history WHERE user_id = 5
    └── CASCADE → DELETE FROM session WHERE user_id = 5
```

### 6.3 Business Rule Enforcement

| Rule | Enforcement Method |
|------|-------------------|
| User can't review same recipe twice | `UNIQUE(user_id, recipe_id)` on review |
| Rating must be 1-5 | `CHECK(rating >= 1 AND rating <= 5)` |
| Email must be unique | `UNIQUE(email)` on user |
| Role must be valid | `ENUM('admin', 'user')` |
| Status must be valid | `ENUM('active', 'inactive', 'pending', 'suspended')` |
| Recipe must have author | `NOT NULL` on author_id |

---

## 7. Indexing Strategy

### 7.1 Index Types and Usage

```sql
-- Primary key index (automatic)
-- Created automatically for id columns

-- Foreign key indexes (for JOIN performance)
CREATE INDEX idx_recipe_author ON recipe(author_id);
CREATE INDEX idx_ingredient_recipe ON ingredient(recipe_id);
CREATE INDEX idx_review_recipe ON review(recipe_id);
CREATE INDEX idx_review_user ON review(user_id);

-- Search/filter indexes
CREATE INDEX idx_user_email ON user(email);
CREATE INDEX idx_recipe_status ON recipe(status);
CREATE INDEX idx_recipe_category ON recipe(category);

-- Composite indexes (for common query patterns)
CREATE INDEX idx_recipe_author_status ON recipe(author_id, status);
CREATE INDEX idx_recipe_view_date ON recipe_view(recipe_id, viewed_at);

-- Date-based indexes (for analytics)
CREATE INDEX idx_daily_stat_date ON daily_stat(stat_date);
CREATE INDEX idx_activity_created ON activity_log(created_at);
```

### 7.2 Index Selection Rationale

| Query Pattern | Index Needed | Why |
|--------------|--------------|-----|
| Login by email | `idx_user_email` | O(log n) vs O(n) lookup |
| Get recipes by author | `idx_recipe_author` | Fast JOIN with user table |
| Filter published recipes | `idx_recipe_status` | Quick filtering |
| Get reviews for recipe | `idx_review_recipe` | Fast lookup for recipe detail page |
| View count by date range | `idx_recipe_view_date` | Analytics queries |

### 7.3 When NOT to Index

- Columns rarely used in WHERE/JOIN/ORDER BY
- Tables with <1000 rows (full scan is fast enough)
- Columns with low cardinality (e.g., boolean flags with 50/50 distribution)
- Columns frequently updated (index maintenance overhead)

---

## 8. Views Logic

### 8.1 `vw_recipe_with_stat`

**Purpose:** Combines recipe data with aggregated statistics (likes, views, rating) in a single query.

```sql
CREATE VIEW vw_recipe_with_stat AS
SELECT 
    r.id,
    r.title,
    r.description,
    r.category,
    r.difficulty,
    r.prep_time,
    r.cook_time,
    r.servings,
    r.author_id,
    r.status,
    r.created_at,
    u.username AS author_name,
    u.avatar_url AS author_avatar,
    COALESCE(like_counts.like_count, 0) AS like_count,
    COALESCE(view_counts.view_count, 0) AS view_count,
    COALESCE(review_stats.avg_rating, 0) AS avg_rating,
    COALESCE(review_stats.review_count, 0) AS review_count
FROM recipe r
JOIN user u ON r.author_id = u.id
LEFT JOIN (
    SELECT recipe_id, COUNT(*) AS like_count 
    FROM like_record 
    GROUP BY recipe_id
) like_counts ON r.id = like_counts.recipe_id
LEFT JOIN (
    SELECT recipe_id, COUNT(*) AS view_count 
    FROM recipe_view 
    GROUP BY recipe_id
) view_counts ON r.id = view_counts.recipe_id
LEFT JOIN (
    SELECT recipe_id, 
           AVG(rating) AS avg_rating, 
           COUNT(*) AS review_count 
    FROM review 
    GROUP BY recipe_id
) review_stats ON r.id = review_stats.recipe_id;
```

**Why a View?**
- Encapsulates complex JOIN logic
- Reusable: `SELECT * FROM vw_recipe_with_stat WHERE status = 'published'`
- Single source of truth for "recipe with stats" query pattern
- Can be indexed (materialized view in some databases)

### 8.2 `vw_user_dashboard_stat`

**Purpose:** Aggregates user activity statistics for profile/dashboard display.

```sql
CREATE VIEW vw_user_dashboard_stat AS
SELECT 
    u.id AS user_id,
    u.username,
    u.avatar_url,
    u.cooking_level,
    COUNT(DISTINCT r.id) AS recipe_count,
    COUNT(DISTINCT f.id) AS favorite_count,
    COUNT(DISTINCT rv.id) AS review_count,
    COALESCE(SUM(recipe_likes.like_count), 0) AS total_likes_received
FROM user u
LEFT JOIN recipe r ON u.id = r.author_id AND r.status = 'published'
LEFT JOIN favorite f ON u.id = f.user_id
LEFT JOIN review rv ON u.id = rv.user_id
LEFT JOIN (
    SELECT recipe_id, COUNT(*) AS like_count 
    FROM like_record 
    GROUP BY recipe_id
) recipe_likes ON r.id = recipe_likes.recipe_id
GROUP BY u.id, u.username, u.avatar_url, u.cooking_level;
```

---

## 9. Stored Procedures Logic

### 9.1 `usp_CreateRecipe`

**Purpose:** Creates a recipe with all related data (ingredients, instructions, images) in a single transaction.

```sql
DELIMITER //

CREATE PROCEDURE usp_CreateRecipe(
    IN p_title VARCHAR(200),
    IN p_description TEXT,
    IN p_category VARCHAR(50),
    IN p_difficulty ENUM('Easy', 'Medium', 'Hard'),
    IN p_prep_time INT,
    IN p_cook_time INT,
    IN p_servings INT,
    IN p_author_id INT,
    IN p_ingredients JSON,     -- JSON array of ingredients
    IN p_instructions JSON,    -- JSON array of instructions
    IN p_images JSON,          -- JSON array of image URLs
    OUT p_recipe_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_recipe_id = -1;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Insert recipe
    INSERT INTO recipe (title, description, category, difficulty, 
                       prep_time, cook_time, servings, author_id, status)
    VALUES (p_title, p_description, p_category, p_difficulty,
            p_prep_time, p_cook_time, p_servings, p_author_id, 'pending');
    
    SET p_recipe_id = LAST_INSERT_ID();
    
    -- Insert ingredients from JSON array
    INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order)
    SELECT p_recipe_id,
           JSON_UNQUOTE(JSON_EXTRACT(ingredient, '$.name')),
           JSON_UNQUOTE(JSON_EXTRACT(ingredient, '$.quantity')),
           JSON_UNQUOTE(JSON_EXTRACT(ingredient, '$.unit')),
           idx
    FROM JSON_TABLE(p_ingredients, '$[*]' COLUMNS (
        idx FOR ORDINALITY,
        ingredient JSON PATH '$'
    )) AS jt;
    
    -- Insert instructions from JSON array
    INSERT INTO instruction (recipe_id, step_number, instruction_text)
    SELECT p_recipe_id,
           idx,
           JSON_UNQUOTE(JSON_EXTRACT(instruction, '$.text'))
    FROM JSON_TABLE(p_instructions, '$[*]' COLUMNS (
        idx FOR ORDINALITY,
        instruction JSON PATH '$'
    )) AS jt;
    
    -- Insert images from JSON array
    INSERT INTO recipe_image (recipe_id, image_url, display_order)
    SELECT p_recipe_id,
           JSON_UNQUOTE(image_url),
           idx
    FROM JSON_TABLE(p_images, '$[*]' COLUMNS (
        idx FOR ORDINALITY,
        image_url VARCHAR(500) PATH '$'
    )) AS jt;
    
    COMMIT;
END //

DELIMITER ;
```

**Transaction Logic:**
- All inserts succeed or all fail (atomicity)
- Error handler rolls back on any failure
- Returns recipe_id on success, -1 on failure

### 9.2 `usp_ApproveRecipe`

**Purpose:** Changes recipe status to 'published' and logs the admin action.

```sql
DELIMITER //

CREATE PROCEDURE usp_ApproveRecipe(
    IN p_recipe_id INT,
    IN p_admin_id INT
)
BEGIN
    DECLARE v_recipe_title VARCHAR(200);
    
    -- Get recipe title for logging
    SELECT title INTO v_recipe_title 
    FROM recipe 
    WHERE id = p_recipe_id;
    
    -- Update recipe status
    UPDATE recipe 
    SET status = 'published', 
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_recipe_id;
    
    -- Log admin action
    INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description)
    VALUES (p_admin_id, 'recipe_approve', 'recipe', p_recipe_id, 
            CONCAT('Approved recipe: ', v_recipe_title));
END //

DELIMITER ;
```

### 9.3 `fn_CalculateAvgRating`

**Purpose:** Returns the average rating for a recipe.

```sql
DELIMITER //

CREATE FUNCTION fn_CalculateAvgRating(p_recipe_id INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avg_rating DECIMAL(3,2);
    
    SELECT COALESCE(AVG(rating), 0.00)
    INTO v_avg_rating
    FROM review
    WHERE recipe_id = p_recipe_id;
    
    RETURN v_avg_rating;
END //

DELIMITER ;
```

**Usage:**
```sql
SELECT id, title, fn_CalculateAvgRating(id) AS avg_rating
FROM recipe
WHERE status = 'published';
```

---

## 10. Triggers Logic

### 10.1 `trg_User_NewUserStat`

**Purpose:** Automatically increments new user count in daily_stat when a user registers.

```sql
DELIMITER //

CREATE TRIGGER trg_User_NewUserStat
AFTER INSERT ON user
FOR EACH ROW
BEGIN
    -- Insert today's stat row if not exists, then increment
    INSERT INTO daily_stat (stat_date, new_user_count)
    VALUES (CURDATE(), 1)
    ON DUPLICATE KEY UPDATE 
        new_user_count = new_user_count + 1,
        updated_at = CURRENT_TIMESTAMP;
END //

DELIMITER ;
```

**Trigger Logic:**
```
User Registration
       │
       ▼
  INSERT INTO user
       │
       ▼ (AFTER INSERT trigger fires)
       │
  ┌────┴────┐
  │ Does    │ NO ──► INSERT new row with new_user_count = 1
  │ today's │
  │ stat    │ YES ─► UPDATE new_user_count = new_user_count + 1
  │ exist?  │
  └─────────┘
```

### 10.2 `trg_RecipeView_UpdateStat`

**Purpose:** Increments recipe view count in daily_stat when a view is recorded.

```sql
DELIMITER //

CREATE TRIGGER trg_RecipeView_UpdateStat
AFTER INSERT ON recipe_view
FOR EACH ROW
BEGIN
    INSERT INTO daily_stat (stat_date, recipe_view_count)
    VALUES (CURDATE(), 1)
    ON DUPLICATE KEY UPDATE 
        recipe_view_count = recipe_view_count + 1,
        updated_at = CURRENT_TIMESTAMP;
END //

DELIMITER ;
```

### 10.3 `trg_Recipe_DeleteCleanup`

**Purpose:** Logs admin action before recipe deletion.

```sql
DELIMITER //

CREATE TRIGGER trg_Recipe_DeleteCleanup
BEFORE DELETE ON recipe
FOR EACH ROW
BEGIN
    -- Note: admin_id would need to be passed via session variable
    -- or this trigger may just log without admin attribution
    INSERT INTO activity_log (action_type, target_type, target_id, description)
    VALUES ('recipe_delete', 'recipe', OLD.id, 
            CONCAT('Recipe deleted: ', OLD.title));
END //

DELIMITER ;
```

---

## 11. Data Seeding Strategy

### 11.1 Seed Data Mapping from localStorage

The existing `storage.js` contains seed data that must be migrated:

| localStorage | MySQL Table | Notes |
|--------------|-------------|-------|
| `SEED_DATA.users` | `user` | Hash passwords with bcrypt |
| `SEED_DATA.recipes` | `recipe` + `ingredient` + `instruction` + `recipe_image` | Split into normalized tables |
| Recipe `likedBy` array | `like_record` | Convert to junction table rows |
| Recipe `viewedBy` array | `recipe_view` | Convert to view records |
| User `favorites` array | `favorite` | Convert to junction table rows |

### 11.2 Seed Order (Foreign Key Dependencies)

```
1. 01_create_database.sql
2. 02_create_tables.sql
3. 03_create_indexes.sql
4. 04_create_views.sql
5. 05_seed_users.sql       ← Users first (no FK dependencies)
6. 06_seed_recipes.sql     ← Recipes need user.id (author_id)
7. 07_seed_reviews.sql     ← Reviews need user.id and recipe.id
8. 08_seed_stats.sql       ← Can be seeded last
```

### 11.3 Password Handling

```sql
-- In seed script, use PHP's password_hash equivalent
-- MySQL doesn't have bcrypt, so passwords must be pre-hashed

-- Option 1: Pre-hash in SQL (not recommended - weak)
INSERT INTO user (email, password_hash) 
VALUES ('admin@cookhub.com', SHA2('admin', 256));

-- Option 2: Pre-hash in PHP and insert (recommended)
-- PHP: $hash = password_hash('admin', PASSWORD_BCRYPT);
-- Then insert the $hash value in SQL
INSERT INTO user (email, password_hash) 
VALUES ('admin@cookhub.com', '$2y$10$...');  -- bcrypt hash
```

---

## 12. Query Patterns & Examples

### 12.1 Common Query Patterns

**Get Published Recipes with Author (JOIN):**
```sql
SELECT 
    r.id,
    r.title,
    r.category,
    r.difficulty,
    u.username AS author_name
FROM recipe r
INNER JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
ORDER BY r.created_at DESC;
```

**Get Full Recipe Details (Multiple JOINs):**
```sql
SELECT 
    r.*,
    u.username AS author_name,
    u.avatar_url AS author_avatar
FROM recipe r
JOIN user u ON r.author_id = u.id
WHERE r.id = ?;

-- Separate queries for nested data (avoids cartesian product)
SELECT * FROM ingredient WHERE recipe_id = ? ORDER BY sort_order;
SELECT * FROM instruction WHERE recipe_id = ? ORDER BY step_number;
SELECT * FROM recipe_image WHERE recipe_id = ? ORDER BY display_order;
```

**Search Recipes (LIKE with wildcards):**
```sql
SELECT r.*, u.username AS author_name
FROM recipe r
JOIN user u ON r.author_id = u.id
WHERE r.status = 'published'
  AND (r.title LIKE CONCAT('%', ?, '%') 
       OR r.description LIKE CONCAT('%', ?, '%'))
ORDER BY r.created_at DESC
LIMIT 20;
```

**Top Recipes by Likes (Subquery + ORDER BY):**
```sql
SELECT 
    r.id,
    r.title,
    (SELECT COUNT(*) FROM like_record WHERE recipe_id = r.id) AS like_count
FROM recipe r
WHERE r.status = 'published'
ORDER BY like_count DESC
LIMIT 10;
```

**User Activity Stats (Aggregation):**
```sql
SELECT 
    u.id,
    u.username,
    COUNT(DISTINCT r.id) AS recipe_count,
    COUNT(DISTINCT rv.id) AS review_count,
    COUNT(DISTINCT f.id) AS favorite_count
FROM user u
LEFT JOIN recipe r ON u.id = r.author_id
LEFT JOIN review rv ON u.id = rv.user_id
LEFT JOIN favorite f ON u.id = f.user_id
WHERE u.id = ?
GROUP BY u.id, u.username;
```

---

## 13. Security Considerations

### 13.1 SQL Injection Prevention

**Always use prepared statements:**

```php
// ❌ VULNERABLE
$email = $_POST['email'];
$query = "SELECT * FROM user WHERE email = '$email'";
// Attacker: email = "' OR '1'='1"

// ✅ SECURE
$stmt = $pdo->prepare("SELECT * FROM user WHERE email = ?");
$stmt->execute([$email]);
```

### 13.2 Password Storage

```php
// Registration: Hash password
$hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);

// Login: Verify password
if (password_verify($inputPassword, $storedHash)) {
    // Login successful
}
```

### 13.3 Access Control

```sql
-- Check user owns resource before UPDATE/DELETE
UPDATE recipe 
SET title = ?
WHERE id = ? AND author_id = ?;  -- Ensures ownership

-- Check admin role before sensitive operations
SELECT role FROM user WHERE id = ?;
-- PHP: if ($user['role'] !== 'admin') throw new ForbiddenException();
```

---

## 14. Performance Optimization

### 14.1 Query Optimization Tips

1. **Use indexes on filtered/joined columns**
2. **Avoid SELECT * in production** - specify needed columns
3. **Use LIMIT for paginated results**
4. **Use EXPLAIN to analyze slow queries**
5. **Consider caching for frequently-accessed data**

### 14.2 Example EXPLAIN Analysis

```sql
EXPLAIN SELECT r.*, u.username 
FROM recipe r 
JOIN user u ON r.author_id = u.id 
WHERE r.status = 'published';

-- Look for:
-- - type: 'ref' or 'eq_ref' (good) vs 'ALL' (bad - full scan)
-- - key: Should show index being used
-- - rows: Estimate of rows examined (lower is better)
```

### 14.3 N+1 Query Problem

```php
// ❌ N+1 Problem (1 query + N queries)
$recipes = $pdo->query("SELECT * FROM recipe")->fetchAll();
foreach ($recipes as $recipe) {
    $ingredients = $pdo->query(
        "SELECT * FROM ingredient WHERE recipe_id = " . $recipe['id']
    )->fetchAll();
}

// ✅ Solution: Batch query
$recipes = $pdo->query("SELECT * FROM recipe")->fetchAll();
$recipeIds = array_column($recipes, 'id');
$placeholders = implode(',', array_fill(0, count($recipeIds), '?'));
$ingredients = $pdo->prepare(
    "SELECT * FROM ingredient WHERE recipe_id IN ($placeholders)"
);
$ingredients->execute($recipeIds);
// Then group ingredients by recipe_id in PHP
```

---

## Summary

This document provides the complete logical foundation for implementing the Recipe Sharing System database. Key takeaways:

1. **Normalization (3NF)** eliminates redundancy and ensures data integrity
2. **Naming conventions** ensure consistency and readability
3. **Constraints** enforce business rules at the database level
4. **Indexes** optimize query performance for common access patterns
5. **Views** encapsulate complex queries for reusability
6. **Stored procedures** ensure atomic multi-step operations
7. **Triggers** automate data maintenance tasks
8. **Security** must be implemented at every layer (prepared statements, hashing, access control)

This documentation should be referenced throughout implementation to ensure consistency with the design decisions made herein.
