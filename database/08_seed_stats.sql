-- ============================================================================
-- Script:      08_seed_stats.sql
-- Description: Seed data for daily_stat, recipe_view, search_history, activity_log
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- - daily_stat: 30 days of historical statistics
-- - recipe_view: View tracking records for authenticated users
-- - search_history: Sample search queries
-- - activity_log: Admin action history
-- ============================================================================

USE cookhub;

-- ============================================================================
-- RECIPE VIEWS (derived from storage.js recipe.viewedBy arrays)
-- User ID mapping: 4=John, 5=Maria, 6=Tom, 9=Sarah, 10=Daniel, 11=Lina
-- ============================================================================
INSERT INTO recipe_view (recipe_id, user_id, viewed_at) VALUES
-- Recipe 1 (Carbonara): viewedBy user-1(4), user-2(5), user-3(6)
(1, 4, '2025-12-01 10:00:00'),
(1, 5, '2025-12-03 14:00:00'),
(1, 6, '2025-12-07 16:00:00'),

-- Recipe 3 (Thai Green Curry): viewedBy user-1(4)
(3, 4, '2025-11-21 18:00:00'),

-- Recipe 4 (Avocado Toast): viewedBy user-2(5)
(4, 5, '2025-10-16 09:00:00'),

-- Recipe 5 (Chocolate Lava Cake): viewedBy user-3(6)
(5, 6, '2025-09-06 20:00:00'),

-- Recipe 6 (Classic Beef Burger): viewedBy user-1(4), user-2(5), user-3(6)
(6, 4, '2025-08-11 12:00:00'),
(6, 5, '2025-08-18 13:30:00'),
(6, 6, '2025-08-22 15:00:00'),

-- Recipe 7 (Mango Sticky Rice): viewedBy user-2(5)
(7, 5, '2025-07-26 17:00:00'),

-- Recipe 8 (Lemon Garlic Salmon): viewedBy user-1(4), user-6(9)
(8, 4, '2026-01-06 19:00:00'),
(8, 9, '2026-01-07 10:00:00'),

-- Recipe 9 (Chickpea Salad Wrap): viewedBy user-2(5), user-6(9), user-7(10)
(9, 5, '2025-12-13 11:00:00'),
(9, 9, '2025-12-17 14:00:00'),
(9, 10, '2025-12-12 16:00:00'),

-- Recipe 11 (Spicy Tofu Stir-Fry): viewedBy user-7(10)
(11, 10, '2025-11-23 13:00:00'),

-- Recipe 12 (Tomato Basil Soup): viewedBy user-1(4), user-3(6), user-6(9)
(12, 4, '2025-10-31 18:00:00'),
(12, 6, '2025-11-03 19:00:00'),
(12, 9, '2025-11-14 17:00:00'),

-- Recipe 13 (Crispy Fish Tacos): viewedBy user-2(5), user-6(9), user-7(10)
(13, 5, '2026-01-11 12:00:00'),
(13, 9, '2026-01-16 14:00:00'),
(13, 10, '2026-01-10 16:00:00'),

-- Recipe 2 (Fluffy Pancakes): viewedBy user-8(11)
(2, 11, '2026-01-16 08:00:00');

-- ============================================================================
-- DAILY STATS (last 30 days of historical data)
-- ============================================================================
INSERT INTO daily_stat (stat_date, page_view_count, active_user_count, new_user_count, recipe_view_count) VALUES
('2026-01-08', 145, 8,  0, 32),
('2026-01-09', 132, 7,  0, 28),
('2026-01-10', 156, 9,  0, 35),
('2026-01-11', 168, 10, 0, 40),
('2026-01-12', 142, 7,  0, 30),
('2026-01-13', 98,  5,  0, 18),
('2026-01-14', 110, 6,  0, 22),
('2026-01-15', 175, 11, 0, 42),
('2026-01-16', 160, 9,  0, 38),
('2026-01-17', 148, 8,  0, 33),
('2026-01-18', 190, 12, 0, 45),
('2026-01-19', 135, 7,  0, 29),
('2026-01-20', 205, 13, 1, 48),
('2026-01-21', 180, 10, 1, 42),
('2026-01-22', 165, 9,  0, 37),
('2026-01-23', 152, 8,  0, 34),
('2026-01-24', 140, 7,  0, 30),
('2026-01-25', 118, 6,  0, 25),
('2026-01-26', 105, 5,  0, 20),
('2026-01-27', 172, 10, 0, 40),
('2026-01-28', 185, 11, 0, 43),
('2026-01-29', 195, 12, 0, 46),
('2026-01-30', 160, 9,  0, 36),
('2026-01-31', 148, 8,  0, 33),
('2026-02-01', 210, 14, 0, 50),
('2026-02-02', 178, 10, 0, 41),
('2026-02-03', 192, 12, 0, 45),
('2026-02-04', 165, 9,  0, 38),
('2026-02-05', 188, 11, 0, 44),
('2026-02-06', 200, 13, 0, 47);

-- ============================================================================
-- SEARCH HISTORY (sample search queries from various users)
-- ============================================================================
INSERT INTO search_history (user_id, query, searched_at) VALUES
(4,  'carbonara', '2025-12-01 09:30:00'),
(4,  'italian pasta', '2025-12-01 09:32:00'),
(4,  'quick dinner', '2026-01-05 18:00:00'),
(5,  'green curry', '2025-11-20 17:00:00'),
(5,  'dessert chocolate', '2025-09-10 20:00:00'),
(5,  'fish tacos', '2026-01-11 12:00:00'),
(9,  'healthy breakfast', '2026-01-18 07:00:00'),
(9,  'salmon recipe', '2026-01-07 09:30:00'),
(9,  'meal prep', '2025-12-28 10:00:00'),
(10, 'tofu stir fry', '2025-11-22 12:00:00'),
(10, 'street food', '2025-12-05 14:00:00'),
(10, 'wrap recipes', '2025-12-12 11:00:00'),
(6,  'burger recipe', '2025-08-10 12:00:00'),
(6,  'chocolate cake', '2025-09-05 19:00:00'),
(11, 'pancakes easy', '2026-01-15 08:00:00');

-- ============================================================================
-- ACTIVITY LOG (admin actions history)
-- ============================================================================
INSERT INTO activity_log (admin_id, action_type, target_type, target_id, description, created_at) VALUES
-- Recipe approvals
(1, 'recipe_approve', 'recipe', 1,  'Approved recipe: Classic Spaghetti Carbonara', '2025-12-01 10:00:00'),
(1, 'recipe_approve', 'recipe', 3,  'Approved recipe: Thai Green Curry', '2025-11-20 11:00:00'),
(2, 'recipe_approve', 'recipe', 4,  'Approved recipe: Avocado Toast', '2025-10-15 09:00:00'),
(2, 'recipe_approve', 'recipe', 5,  'Approved recipe: Chocolate Lava Cake', '2025-09-05 14:00:00'),
(3, 'recipe_approve', 'recipe', 6,  'Approved recipe: Classic Beef Burger', '2025-08-10 15:00:00'),
(1, 'recipe_approve', 'recipe', 7,  'Approved recipe: Mango Sticky Rice', '2025-07-25 12:00:00'),
(2, 'recipe_approve', 'recipe', 8,  'Approved recipe: Lemon Garlic Salmon', '2026-01-05 16:00:00'),
(3, 'recipe_approve', 'recipe', 9,  'Approved recipe: Chickpea Salad Wrap', '2025-12-12 13:00:00'),
(1, 'recipe_approve', 'recipe', 12, 'Approved recipe: Tomato Basil Soup', '2025-10-30 11:00:00'),
(2, 'recipe_approve', 'recipe', 13, 'Approved recipe: Crispy Fish Tacos', '2026-01-10 14:00:00'),

-- Recipe rejection
(3, 'recipe_reject', 'recipe', 11, 'Rejected recipe: Spicy Tofu Stir-Fry - Missing detailed instructions', '2025-11-23 10:00:00'),

-- User management actions
(1, 'user_create', 'user', 7,  'New user registration: Amy Wilson (pending)', '2025-11-10 00:00:00'),
(1, 'user_create', 'user', 8,  'New user registration: Kevin Tran (pending)', '2026-01-20 00:00:00'),
(1, 'user_create', 'user', 12, 'New user registration: Omar Hassan (pending)', '2026-01-21 00:00:00'),
(2, 'user_update', 'user', 6,  'Suspended user: Tom Baker - Violation of community guidelines', '2025-10-15 14:00:00'),

-- Recent admin activity
(1, 'recipe_approve', 'recipe', 8,  'Approved recipe: Lemon Garlic Salmon', '2026-02-01 10:00:00'),
(2, 'user_update', 'user', 11, 'Updated user status: Lina Patel set to inactive', '2026-02-02 14:00:00'),
(3, 'recipe_reject', 'recipe', 11, 'Re-reviewed and confirmed rejection: Spicy Tofu Stir-Fry', '2026-02-03 09:00:00');

-- Verify seeded data
SELECT 'Recipe Views' AS data_type, COUNT(*) AS count FROM recipe_view
UNION ALL
SELECT 'Daily Stats', COUNT(*) FROM daily_stat
UNION ALL
SELECT 'Search History', COUNT(*) FROM search_history
UNION ALL
SELECT 'Activity Logs', COUNT(*) FROM activity_log;
