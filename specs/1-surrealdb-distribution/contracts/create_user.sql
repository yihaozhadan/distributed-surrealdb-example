-- Contract: Create User
-- Creates a new user record with validation

CREATE user CONTENT {
    name: $name,
    email: $email
};

-- Parameters:
-- $name: string (2-50 chars)
-- $email: string (valid email)

-- Response: User record with generated ID and timestamps
-- Example: { id: "user:1", name: "John Doe", email: "john@example.com", created_at: "2025-10-30T20:00:00Z" }
