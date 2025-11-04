#!/bin/bash

# Setup script for SurrealDB distributed cluster
# This script initializes the TiKV + SurrealDB cluster using Docker Compose

set -e

echo "=== SurrealDB Distributed Cluster Setup ==="
echo

# Change to the script's directory (src/)
cd "$(dirname "$0")/.."

echo "Starting Docker Compose services..."
docker-compose up -d

echo
echo "Waiting for cluster to initialize..."

# Wait for PD to be ready
echo "Waiting for PD (Placement Driver)..."
timeout=60
while [ $timeout -gt 0 ]; do
    if docker-compose exec -T pd curl -f http://localhost:2379/pd/api/v1/version > /dev/null 2>&1; then
        echo "PD is ready!"
        break
    fi
    echo "Waiting... ($timeout seconds remaining)"
    sleep 5
    timeout=$((timeout - 5))
done

if [ $timeout -le 0 ]; then
    echo "ERROR: PD failed to start within 60 seconds"
    docker-compose logs pd
    exit 1
fi

# Wait for TiKV nodes
echo "Waiting for TiKV nodes..."
for node in tikv1 tikv2 tikv3; do
    echo "Checking $node..."
    timeout=30
    while [ $timeout -gt 0 ]; do
        if docker-compose exec -T pd curl -f "http://localhost:2379/pd/api/v1/stores" | grep -q "$node"; then
            echo "$node is ready!"
            break
        fi
        sleep 2
        timeout=$((timeout - 2))
    done
    if [ $timeout -le 0 ]; then
        echo "WARNING: $node may not be fully ready"
    fi
done

# Wait for SurrealDB nodes
echo "Waiting for SurrealDB nodes..."
for node in surrealdb1 surrealdb2; do
    echo "Checking $node..."
    timeout=30
    while [ $timeout -gt 0 ]; do
        if docker-compose exec -T $node curl -f http://localhost:8000/health > /dev/null 2>&1; then
            echo "$node is ready!"
            break
        fi
        sleep 2
        timeout=$((timeout - 2))
    done
    if [ $timeout -le 0 ]; then
        echo "ERROR: $node failed to start"
        docker-compose logs $node
        exit 1
    fi
done

echo
echo "=== Cluster Status ==="
docker-compose ps

echo
echo "=== Setup Complete ==="
echo "SurrealDB nodes:"
echo "  Node 1: http://localhost:8000"
echo "  Node 2: http://localhost:8001"
echo
echo "TiKV cluster via PD: http://localhost:2379"
echo
echo "You can now connect to the SurrealDB instances using:"
echo "  surreal sql --conn http://localhost:8000 --user root --pass root"
echo "  surreal sql --conn http://localhost:8001 --user root --pass root"
