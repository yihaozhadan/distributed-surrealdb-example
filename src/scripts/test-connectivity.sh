#!/bin/bash

# Test script for basic connectivity of SurrealDB distributed cluster
# Tests HTTP endpoints, basic API functionality, and cross-node connectivity

set -e

echo "=== SurrealDB Cluster Connectivity Test ==="
echo

# Check if cluster is running
echo "Checking cluster status..."
cd "$(dirname "$0")/.."

if ! docker-compose ps | grep -q "surrealdb-node1"; then
    echo "ERROR: Cluster is not running. Please run ./scripts/setup.sh first."
    exit 1
fi

echo "✓ Cluster appears to be running"
echo

# Test HTTP endpoints
echo "Testing HTTP endpoints..."

endpoints=("http://localhost:8000" "http://localhost:8001")
for endpoint in "${endpoints[@]}"; do
    echo "Testing $endpoint..."

    # Test /health
    if curl -f -s "$endpoint/health" > /dev/null; then
        echo "  ✓ $endpoint/health - OK"
    else
        echo "  ✗ $endpoint/health - FAILED"
        exit 1
    fi

    # Test /status
    if curl -f -s "$endpoint/status" > /dev/null; then
        echo "  ✓ $endpoint/status - OK"
    else
        echo "  ✗ $endpoint/status - FAILED"
        exit 1
    fi

    # Test /version
    version=$(curl -f -s "$endpoint/version")
    if [ $? -eq 0 ] && [ -n "$version" ]; then
        echo "  ✓ $endpoint/version - $version"
    else
        echo "  ✗ $endpoint/version - FAILED"
        exit 1
    fi
done

echo
echo "✓ All HTTP endpoints responding correctly"
echo

# Test TiKV cluster status
echo "Testing TiKV cluster status..."

# Check PD stores
stores=$(curl -f -s "http://localhost:2379/pd/api/v1/stores" | jq '.stores | length' 2>/dev/null)
if [ $? -eq 0 ] && [ "$stores" -eq 3 ]; then
    echo "✓ TiKV cluster has $stores stores (expected: 3)"
else
    echo "✗ TiKV cluster status check failed (stores: $stores)"
    exit 1
fi

# Check PD cluster status
cluster_id=$(curl -f -s "http://localhost:2379/pd/api/v1/cluster" | jq -r '.id' 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$cluster_id" ] && [ "$cluster_id" != "null" ]; then
    echo "✓ PD cluster is initialized (ID: $cluster_id)"
else
    echo "✗ PD cluster not properly initialized"
    exit 1
fi

echo
echo "✓ TiKV cluster status verified"
echo

echo "=== All Connectivity Tests Passed ==="
echo
echo "SurrealDB distributed cluster is properly connected."
echo "Both nodes are responding to HTTP requests and TiKV cluster is operational."
