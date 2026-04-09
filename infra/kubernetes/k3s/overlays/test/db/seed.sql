-- 1) create seed user
INSERT INTO users (name, surname, preg_week, email, password_hash)
VALUES (
  'Test',
  'User',
  12,
  'seed@test.local',
  'pbkdf2:sha256:600000$q0MQxlE3KJsUcJmI$d7440c232112473f9c5a96d9deb97e1255655ef0de45592fa0547b5c513f1b87'
)
ON CONFLICT (email) DO NOTHING;

-- seed@test.local
-- Test123!

-- 2) pills for that user
INSERT INTO pills (name, type_pill, amount, user_id)
SELECT 'Aspirin', 'default', 1, id
FROM users
WHERE email = 'seed@test.local';

INSERT INTO pills (name, type_pill, amount, user_id)
SELECT 'Ibuprofen', 'default', 1, id
FROM users
WHERE email = 'seed@test.local';
