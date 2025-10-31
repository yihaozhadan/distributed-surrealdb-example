-- Contract: Create Post
-- Creates a new post record with author reference

CREATE post CONTENT {
    title: $title,
    content: $content,
    author: $author_id
};

-- Parameters:
-- $title: string (5-200 chars)
-- $content: string (min 10 chars)
-- $author_id: record<user> (must exist)

-- Response: Post record with generated ID and timestamps
-- Example: { id: "post:1", title: "My First Post", content: "Hello world!", author: "user:1", created_at: "2025-10-30T20:05:00Z", updated_at: "2025-10-30T20:05:00Z" }
