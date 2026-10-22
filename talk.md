# Bringing Type Systems into the Graph World
### 35 min · slides with code snippets · ecommerce examples throughout

**Running example:** `user` (email, name, address) — `transaction` (user + goods; amount, payment-method, date) — `good` (price)

---

# ARC 1 — Programming is moving to type-safe languages

## 1. Programming is moving to type-safe languages (0:00–7:00) — 7 min

**1a. The problem: contracts (3 min)**
- Every boundary in a system is a contract: a function signature, an API payload, a row in a database. The question is never *whether* you have a contract — it's *where it lives and who enforces it*.
- Untyped systems keep the contract in docs, naming conventions, and people's heads. Enforcement is hope plus runtime errors in production.
- Quote Martin Fowler: *"schemaless structures still have an implicit schema"* — the contract exists either way; unenforced just means violated silently.

**1b. The solution: type safety (4 min)**
- Make the contract machine-checked. The industry keeps choosing this, voluntarily:
  - **Frontend:** JavaScript → TypeScript.
  - **Backend:** plain Python → Python with type hints (+ mypy in CI).
  - **Modern languages designed around modern type systems:** Haskell, Rust.
- Shown on a quadrant chart — x: not type-safe → type-safe, y: verbose → not verbose. Roster: Python (no hints), Python (hints), JavaScript, TypeScript, Java, Haskell, Rust. JavaScript/Python sit top-left (loose, concise), 2005-era Java bottom-right (safe, ceremonial), TypeScript/Haskell/Rust top-right.
- **The challenge: verbosity.** Types used to cost ceremony — that's why people resisted. Modern type systems answered with inference: safety without the boilerplate. The industry is migrating up and to the right.
- Nobody was forced. Untyped is fine until the system gets big — then teams pay for the migration because the contract-checking pays more.

# ARC 2 — Now it's time for the database

## 2. The pivot (7:00–8:00) — 1 min

- Programming languages have evolved: null-safety, generics, gradual typing — every decade, stricter. Your code is typed, your API contracts are typed… your database still takes whatever you throw at it.
- **Programming languages have evolved. Now it's time for the database.**
- Graphs are the sharpest case: great at representing connections, virtually no structural enforcement — even property graphs' labels and properties can't guarantee integrity at scale.
- The rest of the talk: three type-system concepts in TypeDB, each shown against Cypher, then what you buy with them. (Strictness is a spectrum you can dial — blog #1.)

# ARC 3 — Null-safety with optionals

## 3. Null-safety with optionals (8:00–14:00) — 6 min

**The rule we want:** not every user has an address (digital-only customers) — but absence must be explicit, never a silent `null`.

- Tony Hoare called null his "billion-dollar mistake." Languages fixed it with types: Rust's `Option<T>`, Kotlin's `String?`, Haskell's `Maybe`. TypeQL follows the same lineage: **there is no null in TypeDB.**
- Shown side by side on one slide — TypeQL left (schema + query), Cypher right. Optionality is declared in the schema and handled explicitly in queries with `try`:

```typeql
define
  entity user,
    owns name @card(1..1),     # required
    owns address @card(0..3); # optional
```
```typeql
match
  $u isa user, has name $n;
  try { $u has address $a; };   # $a bound if present, absent otherwise
```

- Spoken aside (not on slide): functions are null-safe too — an optional return is part of the typed signature (`fun shipping_address($u: user) -> address?`).

**Cypher (right column):** no schema — every property is optional everywhere. A missing property silently returns `null`, and null propagates — `WHERE u.address = "..."` is neither true nor false, `WHERE NOT u.address = "..."` silently drops the row too. Three-valued logic bugs that no tool warns you about.

**The benefit:** absence is a type-level concept checked by the query compiler, not a sentinel value that leaks through your results and blows up in app code.

# ARC 4 — Cardinality

## 4. Cardinality: TypeQL vs Cypher (14:00–21:00) — 7 min

**The rule we want:** every transaction has exactly one buyer and at least one good; a user has at most 3 addresses.

**TypeQL:**
```typeql
define
  entity user,
    owns email @key,
    owns name @card(1..1),
    owns address @card(0..3),
    plays transaction:buyer;

  entity good, owns price @card(1..1), plays transaction:item;

  relation transaction,
    relates buyer @card(1..1),
    relates item @card(1..),
    owns amount, owns payment-method, owns date;
```

**Cypher / Neo4j — the closest you can get (shown side by side on the slide):**
```cypher
CREATE CONSTRAINT user_email FOR (u:User) REQUIRE u.email IS UNIQUE;
CREATE CONSTRAINT user_name  FOR (u:User) REQUIRE u.name IS NOT NULL;
// addresses "at most 3"?          — not expressible
// transaction has exactly 1 buyer? — not expressible
// transaction has ≥1 good?         — not expressible
```
Neo4j constraints cover property uniqueness/existence only. **There is no cardinality constraint on relationships at all** — a `(:Transaction)` with zero goods or two buyers commits happily; you police it in app code or a nightly audit query.

**The benefit — insert queries, side by side on the slide:** insert a transaction with no good:

```typeql
match
  $u isa user, has email "ganesh@typedb.com";
insert
  $t isa transaction (buyer: $u),
    has amount 42.0,
    has payment-method "card";
```
```cypher
MATCH (u:User {email: "ganesh@typedb.com"})
CREATE (u)<-[:BUYER]-(t:Transaction {amount: 42.0, paymentMethod: "card"})
// no goods attached
```

- Cypher: **commits.** Bug discovered whenever someone notices the revenue report is off.
- TypeQL: `commit` **fails** with a cardinality violation — `transaction:item` requires at least 1 player.

# ARC 5 — Inheritance

## 5. Inheritance: TypeQL vs Cypher (21:00–28:00) — 7 min

**Open with the conceptual problem as a diagram** (hierarchy on the slide): `good` (abstract, has price) at the top, `book` (+ isbn) and `electronics` (+ warranty) below it, "is a" arrows up. The question to the room: can your database *say* this — and enforce it?

**The rule we want:** goods come in kinds (book, electronics); all have a price; queries over "any good" should be one query.

**TypeQL:**
```typeql
define
  entity good @abstract, owns price @card(1..1), plays transaction:item;
  entity book sub good, owns isbn;
  entity electronics sub good, owns warranty-months;
```
```typeql
match
  $t isa transaction (buyer: $u, item: $g);
  $g has price $p;         # matches books AND electronics — polymorphic
```

**Cypher — inheritance by convention (side by side on the slide):**
```cypher
CREATE (b:Good:Book {price: 12.99, isbn: "978-..."})   // multi-label = hope
MATCH (t:Transaction)-[:CONTAINS]->(g:Good) RETURN g    // works only if
                                                        // everyone remembered
                                                        // the :Good label
```
- Nothing stops `CREATE (b:Book {...})` without `:Good` — now it's invisible to every "all goods" query. Nothing stops a `:Good:User`.
- No abstractness: you can create a bare `:Good`, which your domain says shouldn't exist.
- No inherited constraints: `price IS NOT NULL` must be re-declared per label (and still misses the mislabeled ones).

**The benefit:** in TypeDB, `book sub good` is enforced — every book *is* a good, inherits `price @card(1..1)`, `good` is abstract so bare goods can't exist, and the polymorphic query is guaranteed complete. Add `entity furniture sub good` next sprint: every existing query over `good` already covers it.

# ARC 6 — The database landscape

## 6. The database landscape (28:00–29:00) — 1 min

Callback to arc 1's chart, same axes, now with databases:
- Roster: MongoDB, Neo4j, Amazon Neptune, JanusGraph, TigerGraph, Stardog, PostgreSQL, TypeDB.
- MongoDB top-left (schemaless, easy); Neo4j, Neptune, JanusGraph on the loose side; TigerGraph and Stardog typed but ceremonial; PostgreSQL bottom-right (enforced schema, DDL/JOIN ceremony); **TypeDB top-right** — enforced schema without SQL's verbosity.
- Same migration as languages, one layer down.

# ARC 7 — Benefits

## 7. What you buy with all this (29:00–33:00) — 4 min

**7a. For developers (2 min)**
- **Easier to review:** a PR's queries and schema changes carry their contract with them — the reviewer reads the types instead of tracing the whole codebase.
- **Verify correctness simply by looking at the types:** if a query type-checks against the schema, whole classes of bugs (wrong role, missing attribute, impossible join) are already ruled out before review even starts.
- Errors at commit time in dev, not in production three services downstream.
- Validation lives in the one place every write passes through — the database — instead of being re-implemented (and drifting) across N microservices.

**7b. For AI agents: guardrails (2 min)** — blog #2 benchmark:
- The division of labor: **the LLM generates the query, the database validates it.** The schema bounds what agents can express; errors tell them when they've left the road.
- **The stricter the type system, the more reliable the agent** — the benchmark below is the evidence.
- Setup: Reactome dataset in MySQL, Neo4j, TypeDB; Claude Sonnet 5 + DeepSeek V4 Pro; 42 questions, 3,024 runs.
- Zero-shot: SQL ~60%, Cypher ~60%, TypeQL 25% (training-data volume wins).
- With in-context docs + examples: all converge to ~75–84%.
- **With retries: TypeQL hits 92% — best of all three.** A wrong Cypher query silently returns empty — the agent can't tell "no data" from "bad query". A wrong TypeQL query fails loudly → self-correction works. Loud errors are the agent's feedback loop.
- The same strictness that protects developers is what makes agents reliable.

## 8. Close (33:00–35:00) — 2 min

- We type-checked our code (TypeScript, Python hints). TypeDB type-checks the data layer — the last untyped layer.
- Recap: no null to blow up in app code, cardinality the database enforces, inheritance that's real instead of label convention — and agents that go from 25% to 92% because errors are loud.
- Sources: typedb.com/blog — *How strict should your schema be?* · *Benchmarking LLM query generation across SQL, Cypher and TypeQL*.
- Q&A.

---

## Speaker notes
- The deck shows a persistent arc badge (top-right) so listeners always know where they are — seven arcs: type-safe languages, now-the-database, null-safety, cardinality, inheritance, database landscape, benefits. It switches on each arc's first slide and clears on the close.
- Timing checkpoint: be starting arc 5 (inheritance) by minute 21, or compress its Cypher half.
- Every comparison slide: TypeQL left, Cypher right, side by side on one slide, same ecommerce example — the visual rhythm is the argument.
- All TypeQL snippets in this talk and the deck pass `typeql-check`; re-run it after editing any snippet.
