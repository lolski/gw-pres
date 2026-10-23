# Neo4j e-commerce demo

Domain (see ../CLAUDE.md): `user` (email, address, optional phone) — `transaction` (amount, payment-method, date; a buyer, goods) — `good` (price), either a `book` (+isbn) or an `electronic` (+warranty-expired-date).

The queries live in `queries/*.cypher`, **one file per query**. The deck (`../index.html`) fetches these exact files into its code blocks, so what's on the slides is literally what gets tested here — edit the `.cypher` file and both update.

## Run the server

Two editions in this folder; run ONE at a time (same port). Community shows the loose behavior the deck criticizes; Enterprise 2026.09 (free 30-day eval license) additionally runs graph types (`01`), which are GA since 2026.06, Enterprise-only.

```sh
# Community (default)
echo "dbms.security.auth_enabled=false" >> neo4j-community-2025.09.0/conf/neo4j.conf
./neo4j-community-2025.09.0/bin/neo4j console

# Enterprise (license step is one-time; already accepted in this checkout)
./neo4j-enterprise-2026.09.0/bin/neo4j-admin server license --accept-evaluation
echo "dbms.security.auth_enabled=false" >> neo4j-enterprise-2026.09.0/conf/neo4j.conf
./neo4j-enterprise-2026.09.0/bin/neo4j console
```

## Test all queries

```sh
./test.sh                                          # against Community
NEO4J_DIST=neo4j-enterprise-2026.09.0 ./test.sh    # against Enterprise
```

On Enterprise, clear a previously-set graph type with `CYPHER 25 ALTER CURRENT GRAPH TYPE SET { }` (there is no DROP ALL).

## The queries

Both columns verified by running `test.sh` against each edition.

| File | Deck slide | Community 2025.09 | Enterprise 2026.09 (graph type from `01` active) |
|---|---|---|---|
| `00-reset.cypher` | — | OK (wipes the database) | OK |
| `01-schema-graph-type.cypher` | Arc 3 · Modeling the schema | **FAILS** — graph types are Cypher 25, Neo4j 2026.02+, Enterprise only | OK — schema set |
| `02-schema-constraint.cypher` | Arc 3 (caption) | OK — the entire Community constraint vocabulary | SKIPPED by `test.sh` — `IS KEY` (01) and a manual UNIQUE constraint conflict both ways (22N66); 01 and 02 are alternative schemas, not a sequence |
| `03-insert-goods.cypher` | Arc 3 · Inserting goods | OK | OK |
| `04-insert-user-transaction.cypher` | Arc 3 · Inserting a user and a transaction | OK | OK |
| `05-insert-two-emails.cypher` | Arc 4 · Two email addresses | OK (that's the problem — list-valued email commits, and a list wrapping an existing email slips past the uniqueness constraint) | **FAILS** (22N78) — `email` must be STRING |
| `06-insert-duplicate-email.cypher` | — (live-demo extra) | **FAILS** — exact scalar duplicate, the one error Community can give us | **FAILS** — via `IS KEY` |
| `07-query-all-goods.cypher` | Arc 4 · Querying all goods | OK, but the bare `:Book` is silently missing from the results | **FAILS** (22NB3) — `Book` must have label `Good`, so the forgotten-label bug can't even be inserted |
| `08-query-phone-null.cypher` | Arc 4 · Phone may be null | OK, but the no-phone user appears in *neither* filtered query — three-valued logic | OK — same null behavior; graph types don't change query semantics |
| `09-graph-type-catches.cypher` | (Enterprise follow-up) | OK — commits silently, same bug as `07` | **FAILS** (22NB3) — the write is rejected |
| `10-graph-type-open.cypher` | (Enterprise follow-up) | OK — commits | OK — **still commits**: graph types are *open* (undeclared rel types like `LIKES` are unconstrained) and have no cardinality, so a goods-less transaction and a stray `User→Good` edge get through even here |

Narrative note: with the graph type active, Enterprise kills the arc-4 demos in `05` and `07` — which is itself the story: Neo4j 2026 fixes property types and label implication, while `10` shows what only a closed schema with cardinality (TypeDB) catches.

Note: when served over http (GitHub Pages, `python3 -m http.server`) the deck fetches these files live; from `file://` it falls back to embedded copies in `../snippets.js` — run `../build-snippets.sh` after editing any query file to refresh them.
