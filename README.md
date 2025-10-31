# Distributed SurrealDB Example

A hands-on Proof of Concept (POC) for learning SurrealDB in a distributed environment. This project demonstrates how to set up and interact with SurrealDB using TiKV as the distributed storage backend, showcasing data consistency, replication, and failover across multiple instances.

## Overview

SurrealDB is a multi-model database that supports SQL-like queries, graph operations, and real-time subscriptions. When combined with TiKV (a distributed key-value store), it provides a powerful distributed database solution. This POC helps developers understand:

- Setting up multi-node SurrealDB clusters
- Data distribution and consistency
- Failover behavior
- Performance characteristics
- Schema design for distributed systems

## Prerequisites

- Docker Desktop (or Docker Engine)
- At least 8GB RAM available
- Git
- Basic command-line knowledge

## Quick Start

### 1. Clone the Repository

```bash
git clone git@github.com:yihaozhadan/distributed-surrealdb-example.git
cd distributed-surrealdb-example
```

### 2. Start the Distributed Cluster

Navigate to the source directory and start the services:

```bash
cd src
docker-compose up -d
```

This command will:
- Start 1 Placement Driver (PD) for TiKV coordination
- Start 3 TiKV nodes for distributed storage
- Start 2 SurrealDB instances connected to the TiKV cluster

### 3. Verify Cluster Health

Check that all services are running:

```bash
docker-compose ps
```

You should see all 6 services in "Up" status.

### 4. Test Basic Connectivity

Test the first SurrealDB instance:

```bash
curl http://localhost:8000/version
```

Expected response: SurrealDB version information

Test the second instance:

```bash
curl http://localhost:8001/version
```

### 5. Basic Data Operations
Create namespace _test_ and database _test_.

Create a test record on instance 1:

```bash
curl -X POST http://localhost:8000/sql \
  -H "Accept: application/json" \
  -H "Authorization: Basic cm9vdDpyb290" \
  -H "Content-Type: text/plain" \
  -H "Surreal-NS: test" \
  -H "Surreal-DB: test" \
  -d 'CREATE user CONTENT { name: "Alice", email: "alice@example.com" }'
```

Query the same data from instance 2:

```bash
curl -X POST http://localhost:8001/sql \
  -H "Accept: application/json" \
  -H "Authorization: Basic cm9vdDpyb290" \
  -H "Content-Type: text/plain" \
  -H "Surreal-NS: test" \
  -H "Surreal-DB: test" \
  -d 'SELECT * FROM user'
```

You should see the user record created on instance 1 accessible from instance 2, demonstrating data distribution.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   SurrealDB     │    │   SurrealDB     │
│   Instance 1    │    │   Instance 2    │
│   (Port 8000)   │    │   (Port 8001)   │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
          ┌─────────────────────┐
          │      TiKV Cluster    │
          │  ┌─────────┐         │
          │  │   PD    │         │
          │  │ (2379)  │         │
          │  └─────────┘         │
          │         │            │
          │  ┌──────┴──────┐     │
          │  │   TiKV      │     │
          │  │   Nodes     │     │
          │  │ (20160-20162)│    │
          │  └─────────────┘     │
          └─────────────────────┘
```

## Development Phases

This POC is structured in phases for incremental learning:

1. **Setup**: Docker Compose POC (✅ Completed)
2. **Connect & Test**: Basic connectivity validation
3. **Multi-Instance Writes**: Cross-instance write testing
4. **Third Node & Load**: 3-node cluster + k6 load testing
5. **Schema & Permissions**: SurrealQL schema implementation
6. **Metrics & Consistency**: Monitoring and latency measurement
7. **Bank Transfer Workflow**: Distributed consistency testing
8. **K6 Test Suite**: Comprehensive REST/GraphQL load testing
9. **Polish**: Documentation and optimization

## Key Features Demonstrated

- **Distributed Storage**: TiKV provides automatic sharding and replication
- **Data Consistency**: ACID transactions across the cluster
- **Horizontal Scalability**: Add more nodes for increased capacity
- **High Availability**: Survive node failures
- **Multi-Model Queries**: SQL, GraphQL, and custom query support

## Contributing

This is a learning POC. Contributions that enhance the educational value or demonstrate additional distributed database concepts are welcome.

## Resources

- [SurrealDB Documentation](https://surrealdb.com/docs)
- [TiKV Documentation](https://tikv.org/)
- [Docker Compose Guide](https://docs.docker.com/compose/)

## License

See LICENSE file for details.
