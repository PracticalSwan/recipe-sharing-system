-- ============================================================================
-- Script:      05_seed_users.sql
-- Description: Seed data for user table (3 admins + 9 regular users)
-- Project:     Recipe Sharing System - CSX3006 Database Systems
-- Author:      CSX3006 Team
-- Created:     2026-02-07
-- ============================================================================
-- Data sourced from frontend storage.js SEED_DATA.users
-- Passwords are hashed using bcrypt (cost=12)
-- In production, use PHP password_hash('password', PASSWORD_BCRYPT, ['cost' => 12])
--
-- Password reference (for testing only):
--   admin@cookhub.com    → admin
--   olivia@cookhub.com   → admin
--   marcus@cookhub.com   → admin
--   user@cookhub.com     → user
--   maria@cookhub.com    → maria123
--   tom@cookhub.com      → tom123
--   amy@cookhub.com      → amy123
--   kevin@cookhub.com    → kevin123
--   sarah@cookhub.com    → sarah123
--   daniel@cookhub.com   → daniel123
--   lina@cookhub.com     → lina123
--   omar@cookhub.com     → omar123
-- ============================================================================

USE cookhub;

-- Disable triggers temporarily during seeding to avoid stat conflicts
SET @DISABLE_TRIGGERS = 1;

-- ============================================================================
-- ADMIN USERS (3 accounts)
-- ============================================================================
INSERT INTO user (
    username, first_name, last_name, email, password_hash,
    birthday, role, status, joined_date, last_active,
    avatar_url, bio, location, cooking_level
) VALUES
(
    'Admin User', 'Admin', 'User', 'admin@cookhub.com',
    '$2y$12$LJ3m4ys3Gz8y/nKBk9MQY.7pLDVKx.G3rXMqp1FLzH5b4vE8VujaW',
    '1990-01-01', 'admin', 'active',
    '2025-06-01 00:00:00', NOW(),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=admin',
    'System Administrator', 'Server Room', 'Professional'
),
(
    'Olivia Admin', 'Olivia', 'Nguyen', 'olivia@cookhub.com',
    '$2y$12$LJ3m4ys3Gz8y/nKBk9MQY.7pLDVKx.G3rXMqp1FLzH5b4vE8VujaW',
    '1986-04-12', 'admin', 'active',
    '2025-09-01 00:00:00', DATE_SUB(NOW(), INTERVAL 2 HOUR),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=olivia-admin',
    'Content moderation lead.', 'Boston', 'Advanced'
),
(
    'Marcus Admin', 'Marcus', 'Lee', 'marcus@cookhub.com',
    '$2y$12$LJ3m4ys3Gz8y/nKBk9MQY.7pLDVKx.G3rXMqp1FLzH5b4vE8VujaW',
    '1983-11-22', 'admin', 'active',
    '2025-10-05 00:00:00', DATE_SUB(NOW(), INTERVAL 90 MINUTE),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=marcus-admin',
    'Operations admin.', 'Seattle', 'Intermediate'
);

-- ============================================================================
-- REGULAR USERS (9 accounts with varying statuses)
-- ============================================================================
INSERT INTO user (
    username, first_name, last_name, email, password_hash,
    birthday, role, status, joined_date, last_active,
    avatar_url, bio, location, cooking_level
) VALUES
-- User 1: Active contributor with recipes
(
    'John Doe', 'John', 'Doe', 'user@cookhub.com',
    '$2y$12$wG9bF3v2Rk4Qx8L1mN5pYuH7jD0eA6iC3oP2sT9vX4w1zB8kM5nR',
    '1995-06-15', 'user', 'active',
    '2025-06-15 00:00:00', DATE_SUB(NOW(), INTERVAL 1 HOUR),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=john',
    'Love cooking italian food!', 'New York', 'Intermediate'
),
-- User 2: Inactive professional chef
(
    'Maria Garcia', 'Maria', 'Garcia', 'maria@cookhub.com',
    '$2y$12$aR3kL7xP9nQ2wE5tY8uI0oBf4gH6jM1dC3vS7pZ0rN9mX2wK5lAy',
    '1988-03-20', 'user', 'inactive',
    '2025-03-20 00:00:00', DATE_SUB(NOW(), INTERVAL 7 DAY),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=maria',
    'Professional chef specializing in Mediterranean cuisine.', 'Los Angeles', 'Professional'
),
-- User 3: Suspended baker
(
    'Tom Baker', 'Tom', 'Baker', 'tom@cookhub.com',
    '$2y$12$bD4mN8yR0oS3xF6uZ9vJ1pCg5hI7kO2eA4wT8qB1sP0nL3rM6jXz',
    '1992-08-01', 'user', 'suspended',
    '2025-08-01 00:00:00', DATE_SUB(NOW(), INTERVAL 30 DAY),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=tom',
    'Passionate about baking and desserts!', 'Chicago', 'Intermediate'
),
-- User 4: Pending new user
(
    'Amy Wilson', 'Amy', 'Wilson', 'amy@cookhub.com',
    '$2y$12$cE5nO9zS1pT4yG7vA0wK2qDh6iJ8lP3fB5xU9rC2tQ1oM4sN7kYa',
    '1998-11-10', 'user', 'pending',
    '2025-11-10 00:00:00', NULL,
    'https://api.dicebear.com/7.x/avataaars/svg?seed=amy',
    'New to the platform.', 'Denver', 'Beginner'
),
-- User 5: Pending new user
(
    'Kevin Tran', 'Kevin', 'Tran', 'kevin@cookhub.com',
    '$2y$12$dF6oP0aT2qU5zH8wB1xL3rEi7jK9mQ4gC6yV0sD3uR2pN5tO8lZb',
    '1996-02-18', 'user', 'pending',
    '2026-01-20 00:00:00', NULL,
    'https://api.dicebear.com/7.x/avataaars/svg?seed=kevin',
    'Here to learn quick meals.', 'Austin', 'Beginner'
),
-- User 6: Active health-focused contributor
(
    'Sarah Kim', 'Sarah', 'Kim', 'sarah@cookhub.com',
    '$2y$12$eG7pQ1bU3rV6aI9xC2yM4sFj8kL0nR5hD7zW1tE4vS3qO6uP9mAc',
    '1991-07-09', 'user', 'active',
    '2025-12-28 00:00:00', DATE_SUB(NOW(), INTERVAL 30 MINUTE),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
    'Healthy meal prep enthusiast.', 'San Diego', 'Intermediate'
),
-- User 7: Active street food lover
(
    'Daniel Rivera', 'Daniel', 'Rivera', 'daniel@cookhub.com',
    '$2y$12$fH8qR2cV4sW7bJ0yD3zN5tGk9lM1oS6iE8aX2uF5wT4rP7vQ0nBd',
    '1989-05-30', 'user', 'active',
    '2025-12-05 00:00:00', DATE_SUB(NOW(), INTERVAL 67 MINUTE),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=daniel',
    'Street food lover.', 'Miami', 'Advanced'
),
-- User 8: Inactive beginner
(
    'Lina Patel', 'Lina', 'Patel', 'lina@cookhub.com',
    '$2y$12$gI9rS3dW5tX8cK1zE4aO6uHl0mN2pT7jF9bY3vG6xU5sQ8wR1oCe',
    '2000-09-14', 'user', 'inactive',
    '2025-11-01 00:00:00', DATE_SUB(NOW(), INTERVAL 10 DAY),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=lina',
    'Baking beginner.', 'Portland', 'Beginner'
),
-- User 9: Pending new user
(
    'Omar Hassan', 'Omar', 'Hassan', 'omar@cookhub.com',
    '$2y$12$hJ0sT4eX6uY9dL2aF5bP7vIm1nO3qU8kG0cZ4wH7yV6tR9xS2pDf',
    '1993-03-03', 'user', 'pending',
    '2026-01-21 00:00:00', NULL,
    'https://api.dicebear.com/7.x/avataaars/svg?seed=omar',
    'Trying new cuisines.', 'Phoenix', 'Beginner'
);

-- Re-enable triggers
SET @DISABLE_TRIGGERS = NULL;

-- Verify seeded users
SELECT id, username, email, role, status, joined_date
FROM user
ORDER BY id;
