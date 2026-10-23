# TypeDB e-commerce demo

Domain (see ../CLAUDE.md): `user` (email, address, optional phone) — `transaction` (amount, date; a buyer, goods) — `good` (price), either a `book` (+isbn) or an `electronic` (+warranty-expired-date).

The queries live in `queries/*.tql`, **one file per query**. The deck (`../index.html`) fetches these exact files into its code blocks, so what's on the slides is literally what gets tested here — edit the `.tql` file and both update (run `../build-snippets.sh` after edits for the `file://` fallback).

## Run the server

Uses the distribution in this folder (mirroring the `neo4j/` setup):

```sh
./typedb-all-mac-arm64-3.14.1/typedb server
```

## Test all queries

```sh
./test.sh                                      # distribution in this folder, localhost:1729
TYPEDB_DIST=… TYPEDB_ADDRESS=… ./test.sh       # other distribution / server
```

Recreates the `ecommerce` database, then runs each file in the right transaction type (schema/write/read). Syntax-only validation without a server: `typeql-check < queries/<file>.tql`.

## The queries

Outcomes verified by running `test.sh` against the folder distribution (TypeDB 3.14.1).

| File | Deck slide | Transaction | Outcome |
|---|---|---|---|
| `01-schema.tql` | Arc 4 · Modeling the schema | schema | OK — keys, cardinality, inheritance, in any edition |
| `02-insert-goods.tql` | Arc 4 · Inserting goods | write | OK |
| `03-insert-user.tql` | Arc 4 · Inserting a user | write | OK |
| `04-insert-transaction.tql` | Arc 4 · Inserting a transaction | write | OK |
| `05-insert-second-email.tql` | Arc 5 · Two email addresses | write | **FAILS at commit, by design** — match-insert of a second email hits `[DVL9]` key constraint violation (`email` @key = exactly one). The invalid state can't be stored |
| `06-query-phone-optional.tql` | Arc 5 · Phone may be absent (side-by-side vs Cypher `08`) | read | OK — `try` binds `$p` only when present; no null anywhere |
| `07-query-books.tql` | Arc 5 · Just books | read | OK |
| `08-query-electronics.tql` | Arc 5 · Just electronics | read | OK |
| `09-query-all-goods.tql` | Arc 5 · All goods | read | OK — polymorphic over `good`, guaranteed complete |
| `10-query-good-warranty.tql` | Arc 5 · Type system knows each kind | read | **FAILS by design** — `[QUA4]` type-inference error: fetch of `warranty-expired-date` on `good`, which doesn't own it |
| `11-query-electronic-fields.tql` | Arc 5 · Type system knows each kind | read | OK — on `electronic`, inherited `price` and own `warranty-expired-date` both fetchable |

`fragments/price-once.tql` is a schema excerpt for the "price: declared once" side-by-side slide (vs `neo4j/queries/fragments/price-twice.cypher`) — not a runnable query, excluded from `test.sh`.

Narrative note: `05` is the mirror image of Neo4j's `05` — same operation, but the error happens at the database boundary instead of in next quarter's revenue report.
