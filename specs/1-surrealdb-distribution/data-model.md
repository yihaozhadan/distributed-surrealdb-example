# Data Model: SurrealDB Distribution POC

**Feature**: SurrealDB Distribution POC
**Date**: 2025-10-30

## Overview

This data model defines the basic entities for demonstrating SurrealDB distribution through a simple blog-like application. The model includes users, posts, and instance metadata to showcase CRUD operations across distributed nodes.

## Entities

### User
Represents a system user who can create posts.

**Fields**:
- `id`: string (SurrealDB record ID, e.g., "user:1")
- `name`: string (required, 2-50 characters)
- `email`: string (required, valid email format)
- `created_at`: datetime (auto-generated)

**Validation Rules**:
- Name: Required, minimum 2 characters, maximum 50 characters
- Email: Required, must match email regex pattern
- Created_at: Auto-set on creation

**Relationships**:
- One-to-many with Post (author relationship)

### Post
Represents a blog post created by a user.

**Fields**:
- `id`: string (SurrealDB record ID, e.g., "post:1")
- `title`: string (required, 5-200 characters)
- `content`: string (required, minimum 10 characters)
- `author`: record<User> (required, reference to User)
- `created_at`: datetime (auto-generated)
- `updated_at`: datetime (auto-updated on changes)

**Validation Rules**:
- Title: Required, 5-200 characters
- Content: Required, minimum 10 characters
- Author: Must reference existing User record
- Timestamps: Auto-managed

**Relationships**:
- Many-to-one with User (author relationship)

### Instance
Metadata about each SurrealDB instance in the cluster.

**Fields**:
- `id`: string (SurrealDB record ID, e.g., "instance:1")
- `host`: string (hostname or IP)
- `port`: int (port number)
- `status`: string (enum: "active", "inactive", "failed")
- `started_at`: datetime
- `last_heartbeat`: datetime

**Validation Rules**:
- Host: Required, valid hostname/IP
- Port: Required, 1024-65535
- Status: Must be one of allowed values

## Schema Definition (SurrealQL)

```sql
-- Define User table
DEFINE TABLE user SCHEMAFULL;
DEFINE FIELD name ON user TYPE string ASSERT $value.len() >= 2 AND $value.len() <= 50;
DEFINE FIELD email ON user TYPE string ASSERT is::email($value);
DEFINE FIELD created_at ON user TYPE datetime VALUE time::now() DEFAULT time::now();

-- Define Post table
DEFINE TABLE post SCHEMAFULL;
DEFINE FIELD title ON post TYPE string ASSERT $value.len() >= 5 AND $value.len() <= 200;
DEFINE FIELD content ON post TYPE string ASSERT $value.len() >= 10;
DEFINE FIELD author ON post TYPE record<user> ASSERT $value EXISTS;
DEFINE FIELD created_at ON post TYPE datetime VALUE time::now() DEFAULT time::now();
DEFINE FIELD updated_at ON post TYPE datetime VALUE time::now() DEFAULT time::now();

-- Define Instance table
DEFINE TABLE instance SCHEMAFULL;
DEFINE FIELD host ON instance TYPE string;
DEFINE FIELD port ON instance TYPE int ASSERT $value >= 1024 AND $value <= 65535;
DEFINE FIELD status ON instance TYPE string ASSERT $value IN ['active', 'inactive', 'failed'];
DEFINE FIELD started_at ON instance TYPE datetime;
DEFINE FIELD last_heartbeat ON instance TYPE datetime;

-- Create indexes for performance
DEFINE INDEX user_email_idx ON user COLUMNS email UNIQUE;
DEFINE INDEX post_author_idx ON post COLUMNS author;
DEFINE INDEX instance_status_idx ON instance COLUMNS status;
```

## Data Flow

1. **User Creation**: New users are created on any node, replicated via TiKV
2. **Post Creation**: Posts reference users, ensuring referential integrity
3. **Instance Tracking**: Each node updates its instance record for monitoring
4. **Consistency**: TiKV ensures all nodes see consistent data

## Migration Strategy

- Initial schema deployed via SurrealQL scripts
- Future changes use SurrealDB's migration features
- Rolling updates to maintain availability during schema changes

## Testing Considerations

- Create test data with known relationships
- Validate constraints across distributed nodes
- Test referential integrity during failover scenarios
- Performance testing with realistic data volumes
