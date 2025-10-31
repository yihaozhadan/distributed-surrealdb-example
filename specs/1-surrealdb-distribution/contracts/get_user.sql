-- Contract: Get User by ID
-- Retrieves a user record by ID

SELECT * FROM user WHERE id = $user_id;

-- Parameters:
-- $user_id: record<user> (e.g., "user:1")

-- Response: User record or empty result
-- Example: { id: "user:1", name: "John Doe", email: "john@example.com", created_at: "2025-10-30T20:00:00Z" }
