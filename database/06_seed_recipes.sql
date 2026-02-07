-- ============================================================================
-- Script:      06_seed_recipes.sql
-- Description: Seed data for recipe, ingredient, instruction, recipe_image tables
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Data sourced from frontend storage.js SEED_DATA.recipes
-- 13 recipes with varying categories, difficulties, and statuses
--
-- User ID mapping (from 05_seed_users.sql auto-increment):
--   1  = Admin User       (admin)
--   2  = Olivia Admin     (admin)
--   3  = Marcus Admin     (admin)
--   4  = John Doe         (user-1)
--   5  = Maria Garcia     (user-2)
--   6  = Tom Baker        (user-3)
--   7  = Amy Wilson       (user-4)
--   8  = Kevin Tran       (user-5)
--   9  = Sarah Kim        (user-6)
--   10 = Daniel Rivera    (user-7)
--   11 = Lina Patel       (user-8)
--   12 = Omar Hassan      (user-9)
-- ============================================================================

USE cookhub;

-- ============================================================================
-- RECIPES (13 recipes)
-- ============================================================================
INSERT INTO recipe (id, title, description, category, difficulty, prep_time, cook_time, servings, author_id, status, created_at) VALUES
(1,  'Classic Spaghetti Carbonara', 'A traditional Italian pasta dish from Rome with creamy egg sauce and crispy pancetta.', 'Italian', 'Medium', 15, 20, 4, 4, 'published', '2025-12-01 00:00:00'),
(2,  'Fluffy Pancakes', 'Light and fluffy pancakes perfect for a weekend breakfast.', 'Breakfast', 'Easy', 10, 15, 2, 4, 'pending', '2026-01-15 00:00:00'),
(3,  'Thai Green Curry', 'Aromatic and spicy Thai green curry with vegetables and coconut milk.', 'Asian', 'Medium', 20, 25, 4, 5, 'published', '2025-11-20 00:00:00'),
(4,  'Avocado Toast', 'Simple yet delicious avocado toast with poached eggs and chili flakes.', 'Breakfast', 'Easy', 5, 10, 2, 5, 'published', '2025-10-15 00:00:00'),
(5,  'Chocolate Lava Cake', 'Decadent chocolate cake with a molten center. Perfect for dessert lovers.', 'Dessert', 'Hard', 15, 12, 4, 6, 'published', '2025-09-05 00:00:00'),
(6,  'Classic Beef Burger', 'Juicy homemade beef burger with all the fixings.', 'Dinner', 'Medium', 20, 15, 4, 6, 'published', '2025-08-10 00:00:00'),
(7,  'Mango Sticky Rice', 'Traditional Thai dessert with sweet coconut sticky rice and fresh mango.', 'Dessert', 'Medium', 30, 25, 4, 5, 'published', '2025-07-25 00:00:00'),
(8,  'Lemon Garlic Salmon', 'Oven-baked salmon with lemon, garlic, and fresh herbs.', 'Dinner', 'Easy', 10, 18, 2, 9, 'published', '2026-01-05 00:00:00'),
(9,  'Chickpea Salad Wrap', 'Fresh and crunchy chickpea salad wrapped in a tortilla.', 'Lunch', 'Easy', 12, 0, 2, 10, 'published', '2025-12-12 00:00:00'),
(10, 'Blueberry Overnight Oats', 'No-cook breakfast with oats, yogurt, and blueberries.', 'Breakfast', 'Easy', 8, 0, 1, 9, 'pending', '2026-01-18 00:00:00'),
(11, 'Spicy Tofu Stir-Fry', 'Quick stir-fry with tofu, bell peppers, and spicy sauce.', 'Asian', 'Medium', 15, 10, 3, 10, 'rejected', '2025-11-22 00:00:00'),
(12, 'Tomato Basil Soup', 'Creamy tomato soup with fresh basil and croutons.', 'Dinner', 'Easy', 10, 25, 4, 4, 'published', '2025-10-30 00:00:00'),
(13, 'Crispy Fish Tacos', 'Crispy fish with slaw and lime crema in warm tortillas.', 'Dinner', 'Medium', 20, 15, 3, 10, 'published', '2026-01-10 00:00:00');

-- ============================================================================
-- INGREDIENTS (3-4 per recipe, with sort_order)
-- ============================================================================

-- Recipe 1: Classic Spaghetti Carbonara
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(1, 'Spaghetti', '400', 'g', 1),
(1, 'Eggs', '4', '', 2),
(1, 'Pancetta', '200', 'g', 3),
(1, 'Parmesan', '100', 'g', 4);

-- Recipe 2: Fluffy Pancakes
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(2, 'Flour', '200', 'g', 1),
(2, 'Milk', '250', 'ml', 2),
(2, 'Eggs', '2', '', 3),
(2, 'Sugar', '2', 'tbsp', 4);

-- Recipe 3: Thai Green Curry
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(3, 'Green curry paste', '3', 'tbsp', 1),
(3, 'Coconut milk', '400', 'ml', 2),
(3, 'Chicken breast', '500', 'g', 3),
(3, 'Thai basil', '1', 'bunch', 4);

-- Recipe 4: Avocado Toast
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(4, 'Avocado', '2', '', 1),
(4, 'Sourdough bread', '4', 'slices', 2),
(4, 'Eggs', '4', '', 3),
(4, 'Chili flakes', '1', 'tsp', 4);

-- Recipe 5: Chocolate Lava Cake
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(5, 'Dark chocolate', '200', 'g', 1),
(5, 'Butter', '100', 'g', 2),
(5, 'Eggs', '4', '', 3),
(5, 'Sugar', '100', 'g', 4);

-- Recipe 6: Classic Beef Burger
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(6, 'Ground beef', '500', 'g', 1),
(6, 'Burger buns', '4', '', 2),
(6, 'Cheese slices', '4', '', 3),
(6, 'Lettuce', '4', 'leaves', 4);

-- Recipe 7: Mango Sticky Rice
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(7, 'Sticky rice', '300', 'g', 1),
(7, 'Coconut milk', '400', 'ml', 2),
(7, 'Ripe mango', '2', '', 3),
(7, 'Palm sugar', '100', 'g', 4);

-- Recipe 8: Lemon Garlic Salmon
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(8, 'Salmon fillets', '2', '', 1),
(8, 'Lemon', '1', '', 2),
(8, 'Garlic', '3', 'cloves', 3),
(8, 'Olive oil', '2', 'tbsp', 4);

-- Recipe 9: Chickpea Salad Wrap
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(9, 'Chickpeas', '200', 'g', 1),
(9, 'Greek yogurt', '3', 'tbsp', 2),
(9, 'Celery', '2', 'stalks', 3),
(9, 'Tortillas', '2', '', 4);

-- Recipe 10: Blueberry Overnight Oats
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(10, 'Rolled oats', '50', 'g', 1),
(10, 'Greek yogurt', '120', 'ml', 2),
(10, 'Blueberries', '80', 'g', 3),
(10, 'Honey', '1', 'tsp', 4);

-- Recipe 11: Spicy Tofu Stir-Fry
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(11, 'Tofu', '400', 'g', 1),
(11, 'Bell peppers', '2', '', 2),
(11, 'Soy sauce', '2', 'tbsp', 3),
(11, 'Chili sauce', '1', 'tbsp', 4);

-- Recipe 12: Tomato Basil Soup
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(12, 'Tomatoes', '800', 'g', 1),
(12, 'Onion', '1', '', 2),
(12, 'Cream', '100', 'ml', 3),
(12, 'Basil', '1', 'bunch', 4);

-- Recipe 13: Crispy Fish Tacos
INSERT INTO ingredient (recipe_id, name, quantity, unit, sort_order) VALUES
(13, 'White fish', '400', 'g', 1),
(13, 'Tortillas', '6', '', 2),
(13, 'Cabbage', '150', 'g', 3),
(13, 'Lime', '1', '', 4);

-- ============================================================================
-- INSTRUCTIONS (4-5 steps per recipe)
-- ============================================================================

-- Recipe 1: Classic Spaghetti Carbonara
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(1, 1, 'Boil water and cook pasta al dente'),
(1, 2, 'Fry pancetta until crispy'),
(1, 3, 'Mix eggs with grated parmesan'),
(1, 4, 'Combine hot pasta with egg mixture off heat'),
(1, 5, 'Add pancetta and serve immediately');

-- Recipe 2: Fluffy Pancakes
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(2, 1, 'Mix dry ingredients'),
(2, 2, 'Add wet ingredients and whisk'),
(2, 3, 'Cook on medium heat until bubbles form'),
(2, 4, 'Flip and cook other side');

-- Recipe 3: Thai Green Curry
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(3, 1, 'Fry curry paste in oil'),
(3, 2, 'Add coconut milk and bring to simmer'),
(3, 3, 'Add chicken and vegetables'),
(3, 4, 'Cook until chicken is done'),
(3, 5, 'Garnish with Thai basil');

-- Recipe 4: Avocado Toast
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(4, 1, 'Toast the bread until golden'),
(4, 2, 'Mash avocado and season'),
(4, 3, 'Poach eggs in simmering water'),
(4, 4, 'Spread avocado on toast'),
(4, 5, 'Top with poached eggs and chili');

-- Recipe 5: Chocolate Lava Cake
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(5, 1, 'Melt chocolate and butter together'),
(5, 2, 'Whisk eggs and sugar until fluffy'),
(5, 3, 'Fold chocolate into egg mixture'),
(5, 4, 'Pour into ramekins'),
(5, 5, 'Bake at 200°C for 12 minutes');

-- Recipe 6: Classic Beef Burger
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(6, 1, 'Form beef into patties'),
(6, 2, 'Season with salt and pepper'),
(6, 3, 'Grill or pan-fry for 4-5 min per side'),
(6, 4, 'Toast buns'),
(6, 5, 'Assemble with toppings');

-- Recipe 7: Mango Sticky Rice
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(7, 1, 'Soak sticky rice overnight'),
(7, 2, 'Steam rice until tender'),
(7, 3, 'Heat coconut milk with sugar'),
(7, 4, 'Pour half over rice'),
(7, 5, 'Serve with sliced mango and remaining sauce');

-- Recipe 8: Lemon Garlic Salmon
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(8, 1, 'Preheat oven to 200°C'),
(8, 2, 'Season salmon with garlic, lemon, and oil'),
(8, 3, 'Bake for 15-18 minutes'),
(8, 4, 'Serve with herbs');

-- Recipe 9: Chickpea Salad Wrap
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(9, 1, 'Mash chickpeas lightly'),
(9, 2, 'Mix with yogurt and chopped celery'),
(9, 3, 'Wrap in tortilla and serve');

-- Recipe 10: Blueberry Overnight Oats
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(10, 1, 'Mix oats and yogurt'),
(10, 2, 'Top with blueberries'),
(10, 3, 'Chill overnight'),
(10, 4, 'Drizzle honey before serving');

-- Recipe 11: Spicy Tofu Stir-Fry
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(11, 1, 'Press and cube tofu'),
(11, 2, 'Stir-fry tofu until golden'),
(11, 3, 'Add peppers and sauce'),
(11, 4, 'Serve hot');

-- Recipe 12: Tomato Basil Soup
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(12, 1, 'Saute onion'),
(12, 2, 'Add tomatoes and simmer'),
(12, 3, 'Blend and add cream'),
(12, 4, 'Garnish with basil');

-- Recipe 13: Crispy Fish Tacos
INSERT INTO instruction (recipe_id, step_number, instruction_text) VALUES
(13, 1, 'Season and fry fish'),
(13, 2, 'Prepare slaw'),
(13, 3, 'Assemble tacos'),
(13, 4, 'Serve with lime crema');

-- ============================================================================
-- RECIPE IMAGES (1 per recipe from Unsplash)
-- ============================================================================
INSERT INTO recipe_image (recipe_id, image_url, display_order) VALUES
(1,  'https://images.unsplash.com/photo-1612874742237-6526221588e3?auto=format&fit=crop&q=80&w=800', 1),
(2,  'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&q=80&w=800', 1),
(3,  'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?auto=format&fit=crop&q=80&w=800', 1),
(4,  'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?auto=format&fit=crop&q=80&w=800', 1),
(5,  'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?auto=format&fit=crop&q=80&w=800', 1),
(6,  'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=800', 1),
(7,  'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&q=80&w=800', 1),
(8,  'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80&w=800', 1),
(9,  'https://images.unsplash.com/photo-1523986371872-9d3ba2e2f642?auto=format&fit=crop&q=80&w=800', 1),
(10, 'https://images.unsplash.com/photo-1502741126161-b048400dcca2?auto=format&fit=crop&q=80&w=800', 1),
(11, 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&q=80&w=800', 1),
(12, 'https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?auto=format&fit=crop&q=80&w=800', 1),
(13, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=800', 1);

-- Verify seeded data
SELECT r.id, r.title, r.category, r.difficulty, r.status,
       u.username AS author,
       (SELECT COUNT(*) FROM ingredient i WHERE i.recipe_id = r.id) AS ingredient_count,
       (SELECT COUNT(*) FROM instruction ins WHERE ins.recipe_id = r.id) AS step_count
FROM recipe r
    INNER JOIN user u ON r.author_id = u.id
ORDER BY r.id;
