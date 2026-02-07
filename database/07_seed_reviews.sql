-- ============================================================================
-- Script:      07_seed_reviews.sql
-- Description: Seed data for review, like_record, and favorite tables
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Reviews: 20+ reviews across various recipes with 1-5 star ratings
-- Likes: Derived from storage.js recipe.likedBy arrays
-- Favorites: Derived from storage.js user.favorites arrays
--
-- User ID mapping:
--   4=John, 5=Maria, 6=Tom, 7=Amy, 8=Kevin, 9=Sarah, 10=Daniel, 11=Lina, 12=Omar
-- Recipe ID mapping:
--   1=Carbonara, 2=Pancakes, 3=Thai Curry, 4=Avocado Toast, 5=Lava Cake,
--   6=Burger, 7=Mango Rice, 8=Salmon, 9=Chickpea Wrap, 10=Overnight Oats,
--   11=Tofu Stir-Fry, 12=Tomato Soup, 13=Fish Tacos
-- ============================================================================

USE cookhub;

-- ============================================================================
-- REVIEWS (20+ reviews with varied ratings and comments)
-- ============================================================================
INSERT INTO review (user_id, recipe_id, rating, comment, created_at) VALUES
-- Reviews for Recipe 1: Classic Spaghetti Carbonara
(5,  1, 5, 'Absolutely authentic! Reminds me of the carbonara I had in Rome. The egg sauce was perfectly creamy.', '2025-12-05 14:30:00'),
(6,  1, 4, 'Great recipe. I added a bit more parmesan than suggested and it turned out amazing.', '2025-12-08 18:45:00'),
(9,  1, 5, 'My family loved this! Simple ingredients but incredible flavor.', '2025-12-15 20:00:00'),
(10, 1, 4, 'Solid carbonara recipe. The key is really taking it off the heat before mixing the eggs.', '2025-12-20 12:15:00'),

-- Reviews for Recipe 3: Thai Green Curry
(4,  3, 5, 'Best green curry recipe I have found online. Perfectly balanced flavors!', '2025-11-25 19:30:00'),
(9,  3, 4, 'Very aromatic and flavorful. I used tofu instead of chicken and it worked great.', '2025-12-01 17:00:00'),
(10, 3, 4, 'Good recipe but I would recommend adding more vegetables for a heartier meal.', '2025-12-10 13:45:00'),

-- Reviews for Recipe 4: Avocado Toast
(4,  4, 4, 'Simple but delicious. The poached eggs make all the difference.', '2025-10-20 08:30:00'),
(9,  4, 3, 'Good basic recipe. I added some everything bagel seasoning on top.', '2025-11-05 09:15:00'),

-- Reviews for Recipe 5: Chocolate Lava Cake
(5,  5, 5, 'Decadent and absolutely divine! The molten center was perfect.', '2025-09-10 21:00:00'),
(4,  5, 4, 'Tricky timing but worth it. Mine came out slightly overcooked the first time.', '2025-09-15 20:30:00'),
(9,  5, 5, 'Restaurant-quality dessert at home. My guests were thoroughly impressed.', '2025-10-02 19:45:00'),

-- Reviews for Recipe 6: Classic Beef Burger
(4,  6, 5, 'Juicy and flavorful! The secret is not overworking the beef.', '2025-08-15 13:00:00'),
(5,  6, 4, 'Really good homemade burger. I added caramelized onions.', '2025-08-20 12:30:00'),
(9,  6, 5, 'Best burger recipe! Simple but the result is amazing.', '2025-09-01 18:00:00'),

-- Reviews for Recipe 7: Mango Sticky Rice
(4,  7, 4, 'Beautiful Thai dessert. Make sure to use ripe mangoes for best results.', '2025-08-01 15:30:00'),
(10, 7, 5, 'Authentic and delicious! Soaking the rice overnight is essential.', '2025-08-10 16:00:00'),

-- Reviews for Recipe 8: Lemon Garlic Salmon
(4,  8, 5, 'Quick and healthy dinner. The lemon garlic combo is perfect with salmon.', '2026-01-08 19:00:00'),
(10, 8, 4, 'Easy to make and tastes great. I served it with roasted asparagus.', '2026-01-12 18:30:00'),

-- Reviews for Recipe 9: Chickpea Salad Wrap
(5,  9, 4, 'Fresh and filling! Great healthy lunch option.', '2025-12-15 12:00:00'),
(9,  9, 4, 'Love the crunch. I added some red onion and it was even better.', '2025-12-20 12:45:00'),

-- Reviews for Recipe 12: Tomato Basil Soup
(6,  12, 4, 'Comfort food at its best. Pairs perfectly with grilled cheese.', '2025-11-05 19:00:00'),
(9,  12, 5, 'Creamy and rich. Fresh basil makes a huge difference over dried.', '2025-11-15 18:30:00'),

-- Reviews for Recipe 13: Crispy Fish Tacos
(5,  13, 5, 'Incredible tacos! The slaw and lime crema bring everything together.', '2026-01-15 13:00:00'),
(9,  13, 4, 'Really tasty. I used cod and it worked perfectly.', '2026-01-20 12:30:00');

-- ============================================================================
-- LIKE_RECORD (derived from storage.js likedBy arrays)
-- ============================================================================
INSERT INTO like_record (user_id, recipe_id, created_at) VALUES
-- Recipe 1 (Carbonara): likedBy user-2 (Maria=5), user-3 (Tom=6)
(5,  1, '2025-12-03 10:00:00'),
(6,  1, '2025-12-07 14:00:00'),

-- Recipe 3 (Thai Green Curry): likedBy user-1 (John=4)
(4,  3, '2025-11-22 16:00:00'),

-- Recipe 5 (Chocolate Lava Cake): likedBy user-3 (Tom=6)
(6,  5, '2025-09-08 20:00:00'),

-- Recipe 6 (Classic Beef Burger): likedBy user-1 (John=4), user-2 (Maria=5), user-3 (Tom=6)
(4,  6, '2025-08-12 11:00:00'),
(5,  6, '2025-08-18 13:00:00'),
(6,  6, '2025-08-25 15:00:00'),

-- Recipe 7 (Mango Sticky Rice): likedBy user-2 (Maria=5)
(5,  7, '2025-07-28 17:00:00'),

-- Recipe 8 (Lemon Garlic Salmon): likedBy user-1 (John=4)
(4,  8, '2026-01-06 19:00:00'),

-- Recipe 9 (Chickpea Salad Wrap): likedBy user-2 (Maria=5), user-6 (Sarah=9)
(5,  9, '2025-12-14 11:00:00'),
(9,  9, '2025-12-18 14:00:00'),

-- Recipe 12 (Tomato Basil Soup): likedBy user-3 (Tom=6)
(6,  12, '2025-11-02 18:00:00'),

-- Recipe 13 (Crispy Fish Tacos): likedBy user-2 (Maria=5), user-6 (Sarah=9)
(5,  13, '2026-01-12 12:00:00'),
(9,  13, '2026-01-18 15:00:00');

-- ============================================================================
-- FAVORITES (derived from storage.js user.favorites arrays)
-- ============================================================================
INSERT INTO favorite (user_id, recipe_id, created_at) VALUES
-- John (4): favorites recipe-3 (Thai Green Curry = recipe 3)
(4,  3, '2025-11-23 10:00:00'),

-- Maria (5): favorites recipe-1 (Carbonara = recipe 1)
(5,  1, '2025-12-02 09:00:00'),

-- Tom (6): favorites recipe-1 (Carbonara = recipe 1), recipe-5 (Lava Cake = recipe 5)
(6,  1, '2025-12-06 11:00:00'),
(6,  5, '2025-09-07 15:00:00'),

-- Sarah (9): favorites recipe-1 (Carbonara = recipe 1), recipe-3 (Thai Curry = recipe 3)
(9,  1, '2025-12-10 08:00:00'),
(9,  3, '2025-12-05 14:00:00'),

-- Daniel (10): favorites recipe-5 (Lava Cake = recipe 5)
(10, 5, '2025-09-10 20:00:00');

-- Verify seeded data
SELECT 'Reviews' AS data_type, COUNT(*) AS count FROM review
UNION ALL
SELECT 'Likes', COUNT(*) FROM like_record
UNION ALL
SELECT 'Favorites', COUNT(*) FROM favorite;
