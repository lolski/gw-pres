# Neo4j e-commerce demo

Domain (see ../CLAUDE.md): `user` (email, address, optional phone) — `transaction` (amount, payment-method, date; a buyer, goods) — `good` (price), either a `book` (+isbn) or an `electronic` (+warranty-expired-date).

The queries live in `queries/*.cypher`, **one file per query**. The deck (`../index.html`) fetches these exact files into its code blocks, so what's on the slides is literally what gets tested here — edit the `.cypher` file and both update.

## Run the server

```sh
# disable auth for the demo, then start
echo "dbms.security.auth_enabled=false" >> neo4j-community-2025.09.0/conf/neo4j.conf
./neo4j-community-2025.09.0/bin/neo4j console
```

## Test all queries

```sh
./test.sh   # pipes each queries/*.cypher through cypher-shell in order
```

## The queries

| File | Deck slide | Expected on Community 2025.09 |
|---|---|---|
| `00-reset.cypher` | — | OK (wipes the database) |
| `01-schema-graph-type.cypher` | Arc 3 · Modeling the schema | **FAILS** — graph types are Cypher 25, Neo4j 2026.02+, Enterprise only; on the slide as Neo4j's best effort |
| `02-schema-constraint.cypher` | Arc 3 (caption) | OK — the entire Community constraint vocabulary |
| `03-insert-goods.cypher` | Arc 3 · Inserting goods | OK |
| `04-insert-user-transaction.cypher` | Arc 3 · Inserting a user and a transaction | OK |
| `05-insert-two-emails.cypher` | Arc 4 · Two email addresses | OK (that's the problem — list-valued email commits, and a list wrapping an existing email slips past the uniqueness constraint) |
| `06-insert-duplicate-email.cypher` | — (live-demo extra) | **FAILS** — exact scalar duplicate, the one error Neo4j can give us |
| `07-query-all-goods.cypher` | Arc 4 · Querying all goods | OK, but the bare `:Book` is silently missing from the results |
| `08-query-phone-null.cypher` | Arc 4 · Phone may be null | OK, but the no-phone user appears in *neither* filtered query — three-valued logic |

Note: viewing the deck from `file://` can't fetch the snippets — serve it with `python3 -m http.server` from the repo root (GitHub Pages serves them fine).
