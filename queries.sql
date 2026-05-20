INSERT INTO users (login, first_name, last_name, password_hash)
VALUES ($1, $2, $3, $4)
RETURNING id, login, first_name, last_name, created_at;

SELECT id, login, first_name, last_name, password_hash, created_at
FROM users
WHERE login = $1;

SELECT id, login, first_name, last_name, created_at
FROM users
WHERE ($1::text IS NULL OR first_name ILIKE '%' || $1 || '%')
  AND ($2::text IS NULL OR last_name ILIKE '%' || $2 || '%')
ORDER BY last_name, first_name;

WITH new_chat AS (
    INSERT INTO group_chats (name, created_by_id)
    VALUES ($1, $2)
    RETURNING id, name, created_by_id, created_at
),
add_creator AS (
    INSERT INTO group_chat_members (chat_id, user_id)
    SELECT id, created_by_id FROM new_chat
)
SELECT id, name, created_by_id, created_at FROM new_chat;

INSERT INTO group_chat_members (chat_id, user_id)
VALUES ($1, $2)
ON CONFLICT (chat_id, user_id) DO NOTHING
RETURNING chat_id, user_id;

SELECT 1
FROM group_chat_members
WHERE chat_id = $1 AND user_id = $2;

INSERT INTO group_messages (chat_id, sender_id, content)
VALUES ($1, $2, $3)
RETURNING id, chat_id, sender_id, content, created_at;

SELECT id, chat_id, sender_id, content, created_at
FROM group_messages
WHERE chat_id = $1
ORDER BY created_at ASC, id ASC
LIMIT $2 OFFSET $3;

INSERT INTO p2p_messages (sender_id, recipient_id, content)
VALUES ($1, $2, $3)
RETURNING id, sender_id, recipient_id, content, created_at;

SELECT id, sender_id, recipient_id, content, created_at
FROM p2p_messages
WHERE (sender_id = $1 OR recipient_id = $1)
  AND ($2::bigint IS NULL
       OR (sender_id = $1 AND recipient_id = $2)
       OR (sender_id = $2 AND recipient_id = $1))
ORDER BY created_at ASC, id ASC
LIMIT $3 OFFSET $4;

SELECT id, login, first_name, last_name, password_hash, created_at
FROM users
WHERE id = $1;
