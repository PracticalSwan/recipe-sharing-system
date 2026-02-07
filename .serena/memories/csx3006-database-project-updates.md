# CSX3006 Database Project - Implementation Updates

**Last Updated:** February 5, 2026

---

## Project Summary

**Course:** CSX3006 Database Systems  
**Project:** Recipe Sharing System - MySQL Database Integration  
**Status:** Database Design Complete - Full Documentation Integrated to Notion

---

## Key Design Updates

### Recipe View Table - Authenticated Users Only (Updated)

The `recipe_view` table has been redesigned to track **only authenticated users** (removed guest tracking):

**Updated Schema:**
```sql
CREATE TABLE recipe_view (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id        INT NOT NULL,
    user_id          INT NOT NULL,  -- REQUIRED (no guest tracking)
    viewed_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_recipe_view_recipe 
        FOREIGN KEY (recipe_id) REFERENCES recipe(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_recipe_view_user 
        FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
        
    INDEX idx_recipe_viewed (recipe_id, viewed_at),
    INDEX idx_user_viewed (user_id, viewed_at)
);
```

**Changes Made:**
- ✅ Removed `viewer_type` column (tracked guest vs user)
- ✅ Removed `guest_identifier` column (for anonymous guests)
- ✅ Made `user_id` NOT NULL (only authenticated users)
- ✅ Changed foreign key behavior to CASCADE DELETE
- ✅ Updated analytics impact analysis

**Rationale:**
- More accurate user engagement metrics (no bot/crawler noise)
- Simplified privacy compliance (all views tied to consented users)
- Enables personalized recommendations based on authenticated user history
- Stricter data retention policy when users are deleted

---

## Database Architecture

### Core Components

| Component | Count | Details |
|-----------|-------|---------|
| **Tables** | 13 | user, recipe, ingredient, instruction, recipe_image, review, favorite, like_record, recipe_view, search_history, daily_stat, activity_log, session |
| **Views** | 2 | vw_recipe_with_stat, vw_user_dashboard_stat |
| **Stored Procedures** | 5 | usp_CreateRecipe, usp_DeleteRecipe, usp_ApproveRecipe, usp_GetRecipeStat, fn_CalculateAvgRating |
| **Triggers** | 6 | Automatic maintenance and statistics updates |
| **Indexes** | 7+ | Foreign key, search, composite, and date-based indexes |

### Table List

1. **user** - Account information, authentication, profile data
2. **recipe** - Recipe metadata, author link, publication status
3. **ingredient** - Individual ingredients with quantity and unit
4. **instruction** - Step-by-step cooking instructions
5. **recipe_image** - Multiple images per recipe with display order
6. **review** - User reviews with ratings (1-5 stars)
7. **favorite** - N:M junction for saved recipes
8. **like_record** - N:M junction for recipe likes
9. **recipe_view** - View tracking for authenticated users only (UPDATED)
10. **search_history** - User search query history
11. **daily_stat** - Pre-aggregated daily statistics
12. **activity_log** - Admin action audit trail
13. **session** - Server-side session management

### Design Principles

- **3NF Normalization** - Eliminates redundancy and update anomalies
- **Singular Table Names** - Consistent naming convention (user, recipe, not users, recipes)
- **Surrogate Keys** - Auto-incrementing INT primary keys for efficiency
- **Cascade Deletes** - Parent deletion removes related children
- **Constraints at DB Level** - Business rules enforced at database
- **UPPERCASE SQL** - Consistent keyword capitalization
- **Comprehensive Indexing** - Optimized for read-heavy recipe browsing

---

## Documentation Status

### Local Files
- ✅ `/guides/database_implementation_logic_explanation.md` - Updated with recipe_view changes
  - 1418 lines of comprehensive documentation
  - All 13 tables fully documented
  - Views, stored procedures, and triggers explained
  - Security and performance guidelines included

### Notion Integration
- ✅ Main Implementation Plan Page
  - URL: https://www.notion.so/2fde35b852f08152b4ade1f4b1233c38
  - Contains 171 implementation tasks across 6 phases
  - Includes summary section of database logic

- ✅ **NEW: Complete Database Reference Page**
  - URL: https://www.notion.so/2fee35b852f081f3a208f2436961d94f
  - Full child page under Implementation Plan
  - Comprehensive database design documentation
  - All tables, views, constraints, and indexing explained
  - Security and performance best practices
  - Data seeding strategy and query patterns

---

## Implementation Plan (171 Tasks)

### Phase Breakdown

| Phase | Tasks | Status |
|-------|-------|--------|
| Phase 1: Database Design | 21 | Planned |
| Phase 2: SQL Scripts | 21 | Planned |
| Phase 3: Advanced SQL | 13 | Planned |
| Phase 4: PHP Backend | 46 | Planned |
| Phase 5: Frontend Integration | 56 | Planned |
| Phase 6: Testing | 13 | Planned |

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| **Database** | MySQL/MariaDB 5.7+ |
| **Server Environment** | XAMPP (Apache + MySQL + PHP) |
| **Backend API** | PHP RESTful API (planned) |
| **Frontend** | React + Vite + TypeScript |
| **Session Management** | Server-side sessions in `session` table |
| **Authentication** | Email/password with bcrypt hashing |
| **Password Hashing** | bcrypt with cost=12 |

---

## Security & Performance

### Security Measures

1. **SQL Injection Prevention** - Prepared statements for all queries
2. **Password Storage** - bcrypt hashing with cost=12
3. **Access Control** - Row-level ownership checks
4. **Audit Trail** - activity_log tracks all admin actions
5. **User Deletion** - Cascade deletes remove all user data

### Performance Optimizations

1. **Indexes** - 7+ indexes on FK, search, and composite columns
2. **Pre-aggregated Stats** - daily_stat for fast dashboard queries
3. **Views** - Encapsulate complex multi-table queries
4. **Composite Indexes** - recipe_view(recipe_id, viewed_at) for analytics
5. **Batch Queries** - Avoid N+1 problem with IN clauses

---

## Naming Conventions Reference

| Element | Convention | Example |
|---------|------------|---------|
| Tables | singular, snake_case | user, recipe_view |
| Columns | singular, snake_case | first_name, author_id |
| Primary Keys | id | user.id, recipe.id |
| Foreign Keys | {table}_id | author_id, recipe_id |
| Indexes | idx_{table}_{cols} | idx_recipe_author_status |
| Views | vw_{description} | vw_recipe_with_stat |
| Procedures | usp_{Action}{Entity} | usp_CreateRecipe |
| Triggers | trg_{Table}_{Event} | trg_User_NewUserStat |

---

## Constraints & Data Integrity

### Referential Integrity Actions

| Scenario | Action Used |
|----------|------------|
| Delete user with recipes | CASCADE - removes all user content |
| Delete recipe | CASCADE - removes ingredients, instructions, images, reviews, etc. |
| Delete admin from activity_log | SET NULL - preserves audit history |
| User reviews same recipe twice | UNIQUE constraint prevents duplicate |
| Invalid rating submitted | CHECK (1-5) constraint enforces valid values |

---

## Key Implementation Notes

1. **Recipe View Tracking Decision** - Only authenticated users generate view records
   - Improves analytics accuracy
   - Simplifies privacy compliance
   - Enables personalization
   - Removes bot/crawler noise

2. **User Deletion Cascade** - Complete data removal
   - Recipes, reviews, likes, favorites all deleted
   - Views and search history deleted
   - Sessions invalidated
   - Activity log preserved (admin_id = NULL)

3. **Session Management** - Server-side for instant revocation
   - Alternative considered: JWT tokens
   - Chosen for better security and logout capability

4. **Pre-aggregated Statistics** - For dashboard performance
   - daily_stat table updated by triggers
   - Fast queries instead of real-time calculations

---

## Project Files Referenced

| File | Purpose |
|------|---------|
| `/guides/database_implementation_logic_explanation.md` | Comprehensive database design documentation |
| `/plan/upgrade-database-integration-1.md` | Database upgrade plan |
| Notion: Implementation Plan | Task tracking and project overview |
| Notion: Database Reference | Complete database documentation (NEW) |

---

## Next Steps

1. **Implement SQL Scripts**
   - Create database and tables
   - Create indexes and views
   - Create stored procedures and triggers
   - Seed initial data from localStorage

2. **PHP Backend Development**
   - User authentication endpoints
   - Recipe CRUD operations
   - Search and filtering
   - Admin moderation endpoints

3. **Frontend Integration**
   - Replace localStorage with API calls
   - Implement authentication flow
   - Add recipe creation/editing
   - Admin dashboard

4. **Testing & Deployment**
   - Unit tests for stored procedures
   - Integration tests for API
   - User acceptance testing
   - Performance benchmarking

---

## Documentation Links

- **Notion Implementation Plan:** https://www.notion.so/2fde35b852f08152b4ade1f4b1233c38
- **Notion Database Reference:** https://www.notion.so/2fee35b852f081f3a208f2436961d94f
- **Local Database Guide:** `/guides/database_implementation_logic_explanation.md`

---

---

## Notion Documentation Status - FINAL UPDATE

### Completion Timeline

**February 5, 2026 - Final Completion**

✅ **Notion Page Fully Completed**
- URL: https://www.notion.so/Database-Implementation-Logic-Constraints-Explanation-Complete-Documentation-2fee35b852f081d381fdf5e9800d66b3
- Title: Database Implementation Logic & Constraints Explanation - Complete Documentation
- Status: FULLY DOCUMENTED AND COMPLETE

**Sections Added:**

1. Overview & Design Goals ✅
2. Database Design Philosophy ✅
3. Entity-Relationship Model ✅
4. Tables Overview (13 Core Tables) ✅
5. Detailed Column Logic & Rationale ✅
6. Naming Conventions ✅
7. Constraints & Data Integrity ✅
8. Indexing Strategy ✅
9. Views (2 Database Views) ✅
10. Security Considerations ✅
11. Performance Optimization ✅
12. Data Migration Strategy ✅
13. Stored Procedures & Triggers ✅
14. Query Patterns & Examples ✅
15. Key Design Decisions Summary ✅

### Documentation Completeness

**Total Coverage:**
- 13 core tables fully documented with schemas and rationale
- 2 database views with complete SQL definitions
- 5 stored procedures with transaction logic
- 6 triggers with automatic maintenance patterns
- 7+ indexes with selection rationale
- 3NF normalization strategy explained
- Complete constraint system documented
- Security best practices with code examples
- Performance optimization patterns
- Migration strategy from localStorage
- Query patterns for common operations
- User status state machine
- Recipe workflow design
- Cascade delete chain
- Activity audit trail design
- Session management strategy

### Critical Design Updates Documented

✅ **Recipe View Table (Authenticated Users Only)**
- Removed `viewer_type` and `guest_identifier` columns
- Changed `user_id` to NOT NULL (required)
- Changed from `ON DELETE SET NULL` to `ON DELETE CASCADE`
- Documented impact on analytics (more accurate, no bot noise)
- Simplified privacy compliance

✅ **Column Logic Documentation**
- Every table column documented with type and rationale
- Design decisions explained for each field
- Constraint strategies detailed
- Performance implications noted

✅ **Query Examples**
- Published recipes with author JOIN
- Full recipe detail queries
- Search recipes with text patterns
- Top recipes by engagement
- User activity statistics
- N+1 problem solutions

✅ **Security Implementation**
- SQL injection prevention with prepared statements
- Password storage with bcrypt
- Access control patterns
- Audit trail design

**Status Summary:** ✅ Database design COMPLETELY documented in Notion. All 14+ major sections included. Ready for implementation phase.

### Next Action Items

1. Create SQL migration scripts (01-08)
2. Implement stored procedures and triggers
3. Set up PHP backend API endpoints
4. Integrate with React frontend
5. Perform testing and validation