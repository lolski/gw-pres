#!/bin/sh
# Run every demo query against the local Neo4j (auth disabled, see queries.md).
# Default: Community — 01 (graph type) and 06 (duplicate email) EXPECTED to fail.
# Enterprise: NEO4J_DIST=neo4j-enterprise-2026.09.0 ./test.sh
#   — there 01 succeeds, and 05/07/09 fail instead (the graph type catches them).
cd "$(dirname "$0")"
DIST="${NEO4J_DIST:-neo4j-community-2025.09.0}"
for f in queries/*.cypher; do
  # 01 (IS KEY) and 02 (manual UNIQUE) conflict both ways (22N66): they are
  # alternative schemas, not a sequence. On Enterprise, 01 is the schema.
  case "$DIST:$f" in *enterprise*:*02-schema-constraint*)
    printf '=== %s\n--- SKIPPED (01 IS KEY already covers it)\n' "$f"; continue;;
  esac
  printf '=== %s\n' "$f"
  if "./$DIST/bin/cypher-shell" -f "$f"; then
    echo "--- OK"
  else
    echo "--- FAILED"
  fi
done
