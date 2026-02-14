USE cookhub;

INSERT INTO review (user_id, recipe_id, rating, comment, created_at) VALUES
(5,  1, 5, 'Absolutely authentic! Reminds me of the carbonara I had in Rome. The egg sauce was perfectly creamy.', '2025-12-05 14:30:00'),
(6,  1, 4, 'Great recipe. I added a bit more parmesan than suggested and it turned out amazing.', '2025-12-08 18:45:00'),
(9,  1, 5, 'My family loved this! Simple ingredients but incredible flavor.', '2025-12-15 20:00:00'),
(10, 1, 4, 'Solid carbonara recipe. The key is really taking it off the heat before mixing the eggs.', '2025-12-20 12:15:00'),

(4,  3, 5, 'Best green curry recipe I have found online. Perfectly balanced flavors!', '2025-11-25 19:30:00'),
(9,  3, 4, 'Very aromatic and flavorful. I used tofu instead of chicken and it worked great.', '2025-12-01 17:00:00'),
(10, 3, 4, 'Good recipe but I would recommend adding more vegetables for a heartier meal.', '2025-12-10 13:45:00'),

(4,  4, 4, 'Simple but delicious. The poached eggs make all the difference.', '2025-10-20 08:30:00'),
(9,  4, 3, 'Good basic recipe. I added some everything bagel seasoning on top.', '2025-11-05 09:15:00'),

(5,  5, 5, 'Decadent and absolutely divine! The molten center was perfect.', '2025-09-10 21:00:00'),
(4,  5, 4, 'Tricky timing but worth it. Mine came out slightly overcooked the first time.', '2025-09-15 20:30:00'),
(9,  5, 5, 'Restaurant-quality dessert at home. My guests were thoroughly impressed.', '2025-10-02 19:45:00'),

(4,  6, 5, 'Juicy and flavorful! The secret is not overworking the beef.', '2025-08-15 13:00:00'),
(5,  6, 4, 'Really good homemade burger. I added caramelized onions.', '2025-08-20 12:30:00'),
(9,  6, 5, 'Best burger recipe! Simple but the result is amazing.', '2025-09-01 18:00:00'),

(4,  7, 4, 'Beautiful Thai dessert. Make sure to use ripe mangoes for best results.', '2025-08-01 15:30:00'),
(10, 7, 5, 'Authentic and delicious! Soaking the rice overnight is essential.', '2025-08-10 16:00:00'),

(4,  8, 5, 'Quick and healthy dinner. The lemon garlic combo is perfect with salmon.', '2026-01-08 19:00:00'),
(10, 8, 4, 'Easy to make and tastes great. I served it with roasted asparagus.', '2026-01-12 18:30:00'),

(5,  9, 4, 'Fresh and filling! Great healthy lunch option.', '2025-12-15 12:00:00'),
(9,  9, 4, 'Love the crunch. I added some red onion and it was even better.', '2025-12-20 12:45:00'),

(6,  12, 4, 'Comfort food at its best. Pairs perfectly with grilled cheese.', '2025-11-05 19:00:00'),
(9,  12, 5, 'Creamy and rich. Fresh basil makes a huge difference over dried.', '2025-11-15 18:30:00'),

(5,  13, 5, 'Incredible tacos! The slaw and lime crema bring everything together.', '2026-01-15 13:00:00'),
(9,  13, 4, 'Really tasty. I used cod and it worked perfectly.', '2026-01-20 12:30:00');

INSERT INTO like_record (user_id, recipe_id, created_at) VALUES
(5,  1, '2025-12-03 10:00:00'),
(6,  1, '2025-12-07 14:00:00'),

(4,  3, '2025-11-22 16:00:00'),

(6,  5, '2025-09-08 20:00:00'),

(4,  6, '2025-08-12 11:00:00'),
(5,  6, '2025-08-18 13:00:00'),
(6,  6, '2025-08-25 15:00:00'),

(5,  7, '2025-07-28 17:00:00'),

(4,  8, '2026-01-06 19:00:00'),

(5,  9, '2025-12-14 11:00:00'),
(9,  9, '2025-12-18 14:00:00'),

(6,  12, '2025-11-02 18:00:00'),

(5,  13, '2026-01-12 12:00:00'),
(9,  13, '2026-01-18 15:00:00');

INSERT INTO favorite (user_id, recipe_id, created_at) VALUES
(4,  3, '2025-11-23 10:00:00'),

(5,  1, '2025-12-02 09:00:00'),

(6,  1, '2025-12-06 11:00:00'),
(6,  5, '2025-09-07 15:00:00'),

(9,  1, '2025-12-10 08:00:00'),
(9,  3, '2025-12-05 14:00:00'),

(10, 5, '2025-09-10 20:00:00');

SELECT 'Reviews' AS data_type, COUNT(*) AS count FROM review
UNION ALL
SELECT 'Likes', COUNT(*) FROM like_record
UNION ALL
SELECT 'Favorites', COUNT(*) FROM favorite;
