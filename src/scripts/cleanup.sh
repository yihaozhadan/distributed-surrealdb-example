#!/bin/bash

# Cleanup script for SurrealDB distributed cluster
# This script tears down the TiKV + SurrealDB cluster and cleans up resources

set -e

echo "=== SurrealDB Distributed Cluster Cleanup ==="
echo

# Change to the script's directory (src/)
cd "$(dirname "$0")/.."

echo "Stopping Docker Compose services..."
docker-compose down

echo
echo "Removing Docker volumes..."
docker-compose down -v

echo
echo "Cleaning up dangling resources..."
docker system prune -f

echo
echo "=== Cleanup Complete ==="
echo "All containers, networks, and volumes have been removed."
echo "Note: Persistent data in named volumes has been deleted."
