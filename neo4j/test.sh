#!/bin/sh
# Run every demo query against the local Neo4j (auth disabled, see queries.md).
# 01 (Enterprise graph type) and 06 (duplicate email) are EXPECTED to fail.
cd "$(dirname "$0")"
for f in queries/*.cypher; do
  printf '=== %s\n' "$f"
  if ./neo4j-community-2025.09.0/bin/cypher-shell -f "$f"; then
    echo "--- OK"
  else
    echo "--- FAILED"
  fi
done
