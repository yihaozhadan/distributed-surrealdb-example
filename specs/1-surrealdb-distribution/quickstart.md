# Quickstart: SurrealDB Distribution POC

**Feature**: SurrealDB Distribution POC
**Date**: 2025-10-30

## Prerequisites

- Docker Desktop installed and running
- At least 4GB RAM available
- Git for cloning repositories
- Basic command line knowledge

## Setup Instructions

### 1. Clone and Navigate to Project

```bash
git clone <repository-url>
cd distributed-surrealdb-example
git checkout 1-surrealdb-distribution
```

### 2. Start the Distributed Cluster

```bash
cd src
docker-compose up -d
```

This will start:
- 3 TiKV nodes (distributed storage)
- 1 Placement Driver (TiKV coordinator)
- 2 SurrealDB instances (query engines)

### 3. Wait for Cluster to Initialize

```bash
# Check cluster health
docker-compose ps

# Wait for services to be healthy (may take 30-60 seconds)
```

### 4. Initialize Database Schema

```bash
# Connect to first SurrealDB instance
docker exec -it src_surrealdb_1_1 /surreal sql --conn http://localhost:8000 --user root --pass root

# Run schema setup (inside container)
/surreal import --conn http://localhost:8000 --user root --pass root --ns test --db test ../schemas/blog.sql
```

### 5. Test Basic Operations

```bash
# Create a test user
curl -X POST http://localhost:8000/sql/test/test \
  -H "Content-Type: application/json" \
  -d '{
    "sql": "CREATE user CONTENT { name: \"John Doe\", email: \"john@example.com\" }"
  }'

# Verify user exists (query different instance)
curl -X POST http://localhost:8001/sql/test/test \
  -H "Content-Type: application/json" \
  -d '{
    "sql": "SELECT * FROM user"
  }'
```

## Validation Steps

### Check Data Consistency
1. Create data on instance 1 (port 8000)
2. Query same data from instance 2 (port 8001)
3. Verify identical results

### Test Failover
1. Stop one SurrealDB instance: `docker-compose stop surrealdb-1`
2. Verify operations still work through remaining instance
3. Restart instance: `docker-compose start surrealdb-1`

### Performance Testing
```bash
# Run performance tests
./scripts/benchmark_queries.sh
```

## Expected Results

- **Startup Time**: <60 seconds for full cluster
- **Query Latency**: <100ms for basic operations
- **Consistency**: Immediate data visibility across nodes
- **Failover**: No data loss, continued operation during node failure

## Troubleshooting

### Common Issues

**Cluster won't start**: Check Docker resources and increase RAM allocation

**Connection refused**: Wait longer for services to initialize, check `docker-compose logs`

**Data not consistent**: Ensure TiKV cluster is healthy with `docker-compose logs tikv`

### Reset Everything

```bash
# Stop and remove all containers/volumes
docker-compose down -v

# Restart fresh
docker-compose up -d
```

## Next Steps

1. Explore advanced queries in the documentation
2. Add more nodes to the cluster
3. Experiment with different failure scenarios
4. Integrate with application code

## Resources

- [SurrealDB Documentation](https://surrealdb.com/docs)
- [TiKV Documentation](https://tikv.org/)
- [Docker Compose Guide](https://docs.docker.com/compose/)
