USE cookhub;

SET @PREV_DISABLE_TRIGGERS = @DISABLE_TRIGGERS;

SET @DISABLE_TRIGGERS = 1;

INSERT INTO `user` (
    username, first_name, last_name, email, password_hash,
    birthday, role, status, joined_date, last_active,
    avatar_url, bio, location, cooking_level
) VALUES
(
    'Admin User', 'Admin', 'User', 'admin@cookhub.com',
    '$2y$10$mcxuNIpFb723w0ajx/qqmu1beF2vHilnDJV2nP4zJN./OJ4ZqxfK.',
    '1990-01-01', 'admin', 'active',
    '2025-06-01 00:00:00', NOW(),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=admin',
    'System Administrator', 'Server Room', 'Professional'
),
(
    'Olivia Admin', 'Olivia', 'Nguyen', 'olivia@cookhub.com',
    '$2y$10$mcxuNIpFb723w0ajx/qqmu1beF2vHilnDJV2nP4zJN./OJ4ZqxfK.',
    '1986-04-12', 'admin', 'active',
    '2025-09-01 00:00:00', DATE_SUB(NOW(), INTERVAL 2 HOUR),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=olivia-admin',
    'Content moderation lead.', 'Boston', 'Advanced'
),
(
    'Marcus Admin', 'Marcus', 'Lee', 'marcus@cookhub.com',
    '$2y$10$mcxuNIpFb723w0ajx/qqmu1beF2vHilnDJV2nP4zJN./OJ4ZqxfK.',
    '1983-11-22', 'admin', 'active',
    '2025-10-05 00:00:00', DATE_SUB(NOW(), INTERVAL 90 MINUTE),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=marcus-admin',
    'Operations admin.', 'Seattle', 'Intermediate'
);

INSERT INTO `user` (
    username, first_name, last_name, email, password_hash,
    birthday, role, status, joined_date, last_active,
    avatar_url, bio, location, cooking_level
) VALUES
(
    'John Doe', 'John', 'Doe', 'user@cookhub.com',
    '$2y$10$0FkkS.pxqerygxx6sAoTS.h7xUSpR8Q5ylEl5m.Z2egmqvRgSF3tm',
    '1995-06-15', 'user', 'active',
    '2025-06-15 00:00:00', DATE_SUB(NOW(), INTERVAL 1 HOUR),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=john',
    'Love cooking italian food!', 'New York', 'Intermediate'
),
(
    'Maria Garcia', 'Maria', 'Garcia', 'maria@cookhub.com',
    '$2y$10$/krNSQraXnfh.w7pEX..qO05AnuI5b/ZZ7ztujYnYuQE4mQD0yHpu',
    '1988-03-20', 'user', 'inactive',
    '2025-03-20 00:00:00', DATE_SUB(NOW(), INTERVAL 7 DAY),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=maria',
    'Professional chef specializing in Mediterranean cuisine.', 'Los Angeles', 'Professional'
),
(
    'Tom Baker', 'Tom', 'Baker', 'tom@cookhub.com',
    '$2y$10$tPd/M7Lxwt0gdiMTv4CWZ.8a/Tnwg.O/mx6F2Qf6lO4tzaPvU9oAC',
    '1992-08-01', 'user', 'suspended',
    '2025-08-01 00:00:00', DATE_SUB(NOW(), INTERVAL 30 DAY),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=tom',
    'Passionate about baking and desserts!', 'Chicago', 'Intermediate'
),
(
    'Amy Wilson', 'Amy', 'Wilson', 'amy@cookhub.com',
    '$2y$10$FeWJR/4XiMBG5rY11HKqrOOn/VmM050gty3UcmZVXnQurYKabcitW',
    '1998-11-10', 'user', 'pending',
    '2025-11-10 00:00:00', NULL,
    'https://api.dicebear.com/7.x/avataaars/svg?seed=amy',
    'New to the platform.', 'Denver', 'Beginner'
),
(
    'Kevin Tran', 'Kevin', 'Tran', 'kevin@cookhub.com',
    '$2y$10$FFGPYQRBe.yVD6ijmn0iVucxrCTahAZ.V8mo.vG7z0n6sEDUOxLQe',
    '1996-02-18', 'user', 'pending',
    '2026-01-20 00:00:00', NULL,
    'https://api.dicebear.com/7.x/avataaars/svg?seed=kevin',
    'Here to learn quick meals.', 'Austin', 'Beginner'
),
(
    'Sarah Kim', 'Sarah', 'Kim', 'sarah@cookhub.com',
    '$2y$10$ODml9vH4OizBFVCANWhzsu7kZQean0aEfOQ2WcC70DM7TQyYa6yJa',
    '1991-07-09', 'user', 'active',
    '2025-12-28 00:00:00', DATE_SUB(NOW(), INTERVAL 30 MINUTE),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
    'Healthy meal prep enthusiast.', 'San Diego', 'Intermediate'
),
(
    'Daniel Rivera', 'Daniel', 'Rivera', 'daniel@cookhub.com',
    '$2y$10$LElRgwvLzgYmpTI/eR4TbukMq9lwPCAkq03xjgHSgPThoARpD7h/q',
    '1989-05-30', 'user', 'active',
    '2025-12-05 00:00:00', DATE_SUB(NOW(), INTERVAL 67 MINUTE),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=daniel',
    'Street food lover.', 'Miami', 'Advanced'
),
(
    'Lina Patel', 'Lina', 'Patel', 'lina@cookhub.com',
    '$2y$10$OrJ0UJZWdUcYvdDDVIrHa.JrZE1wIpZw6YQHLLzIORLwZ7KjGVYdq',
    '2000-09-14', 'user', 'inactive',
    '2025-11-01 00:00:00', DATE_SUB(NOW(), INTERVAL 10 DAY),
    'https://api.dicebear.com/7.x/avataaars/svg?seed=lina',
    'Baking beginner.', 'Portland', 'Beginner'
),
(
    'Omar Hassan', 'Omar', 'Hassan', 'omar@cookhub.com',
    '$2y$10$lGIy0Zzzec/.stSuWDXk3eEJlVQMOHt2qY10nunlFPRJsLzllDZgq',
    '1993-03-03', 'user', 'pending',
    '2026-01-21 00:00:00', NULL,
    'https://api.dicebear.com/7.x/avataaars/svg?seed=omar',
    'Trying new cuisines.', 'Phoenix', 'Beginner'
);

SET @DISABLE_TRIGGERS = @PREV_DISABLE_TRIGGERS;
SET @PREV_DISABLE_TRIGGERS = NULL;

SELECT id, username, email, role, status, joined_date
FROM `user`
ORDER BY id;
