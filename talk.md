# Bringing Type Systems into the Graph World — talking points
### 35 min · the slides show only figures and code; everything to SAY is here, per slide

**Domain:** `user` (email, address, optional phone) — `transaction` (a buyer + goods; amount, date) — `good` (price), either a `book` (isbn) or an `electronic` (warranty-expired-date)

**Snippet discipline:** every code block is fetched from `neo4j/queries/*.cypher` or `typedb/queries/*.tql` — tested against real servers (`neo4j/test.sh` for both editions, `typedb/test.sh` against the 3.14.1 folder distribution). Edit a file → slide and test both update (`./build-snippets.sh` refreshes the `file://` fallback).

---

## Title slide (0:00–1:00)

- Who I am; the promise from the abstract: graphs are great at connections and terrible at guarantees — we'll make a graph database behave like a typed language.

# ARC 1 — Neo4j and the property graph

## Slide: "A graph: nodes and edges" (1:00–3:00)

- This is the whole data model: nodes and *directed* edges. That's it.
- The power: relationships are first-class — no join tables, no foreign keys; the connection *is* the data.
- The poverty: the graph says nothing *about* the nodes and edges. Which circle is the user? What does this arrow mean? The picture is mute.

## Slide: "Neo4j: the labeled property graph" (3:00–5:00)

- Same picture, now in property-graph notation. Neo4j adds exactly three things:
  1. **Labels** on nodes — `:User`, `:Transaction`, multi-labels like `:Good:Book`;
  2. **key-value properties** on nodes and relationships;
  3. **typed, directed relationships** — `:BUYER`, `:CONTAINS`.
- Now the picture has names: you can ask "all users", "everything this transaction contains".
- Plant the seed: labels and properties *describe* the data. Do they *constrain* it? Hold that question.

# ARC 2 — Ecommerce in Neo4j: the happy path

## Slide: "Modeling the schema: graph types" (5:00–8:00)

- This is Neo4j's best effort, and genuinely a big step: **graph types** — typed properties (`:: STRING`), required fields (`NOT NULL`), keys (`IS KEY`), implied labels (`:Book => :Good`), declared relationship endpoints.
- The fine print to land verbally: **Cypher 25, Enterprise only, GA 2026.06**. On Community — what most people run, and anything pre-2026 — the entire schema vocabulary is one line: `CREATE CONSTRAINT … REQUIRE u.email IS UNIQUE`.
- Also note: `price` is re-declared on both `Book` and `Electronic` — there's no shared supertype attribute, no abstract type.
- Ref if asked: https://neo4j.com/docs/cypher-manual/current/schema/

## Slide: "Inserting a user and a transaction" (8:00–9:30)

- Walk the pattern: `(u)<-[:BUYER]-(t:Transaction)-[:CONTAINS]->(b)`.
- Be fair to Neo4j: Cypher's ASCII-art pattern syntax is genuinely pleasant to read and write.

## Slide: "Inserting goods" (9:30–11:00)

- `:Good:Book` — the multi-label stands in for "a book *is a* good". By **convention, not by rule**: nothing anywhere says a `:Book` must also be `:Good`. Hold that thought — it returns in the next arc.

# ARC 3 — Ecommerce in Neo4j: the unhappy path

## Slide: "The unhappy path" (11:00–11:30)

- Framing: same shop, three operations any ecommerce backend does every day. Running on **Community** — where graph types don't exist (equally: any Neo4j below 2026). Verified outcome table: `neo4j/queries.md`.

## Slide: "1 · Inserting two email addresses" (11:30–13:30)

- The domain says one email per user. This insert gives it a **list** of two — and it commits: any property can silently become a list.
- Worse: the uniqueness constraint compares whole values, so a *list wrapping an existing email* also slips past it.
- A graph type's `email :: STRING` would catch this (verified: fails with 22N78 on Enterprise) — but that's the Enterprise price of admission; everywhere else the "schema" can't even say *one email per user*.

## Slide: "2 · Querying for all goods" (13:30–15:30)

- Six months ago someone wrote `CREATE (:Book {...})` and forgot `:Good`. It committed fine.
- Today the revenue report does `MATCH (g:Good)` — and that book is simply not in the results. No error, no warning; it quietly doesn't count.
- Multi-labels are convention: "all goods" is only as complete as everyone's memory. (Graph types' implied labels fix this — again Enterprise; verified 22NB3.)

## Slide: "3 · Querying a user whose phone may be null" (15:30–17:30)

- "Optional" is declared nowhere — every property is optional everywhere.
- A user without a phone returns `null`. A **typo'd property** (`u.phoen`) also returns `null`. Absence and mistake are indistinguishable.
- Null propagates through three-valued logic: `WHERE u.phone = …` drops the no-phone user, and `WHERE NOT u.phone = …` *also* drops them — they're in neither result. Excluded middle, violated. No tool warns you.
- If asked about Enterprise: graph types don't change query semantics — null behaves identically there (verified). And `queries/10` shows what even graph types allow: they're *open* (undeclared relationship types unconstrained) with no cardinality — a goods-less transaction still commits. That's the segue.

# ARC 4 — Ecommerce in TypeDB: the happy path

## Slide: transition — TypeDB logo (17:30–18:00)

- Beat of silence, let the logo land. One line: "Same shop, same three unhappy operations coming back — but first, let's rebuild the model in a database that borrows from type systems."

## Slide: "Modeling the schema" (18:00–21:00)

- The same domain in TypeQL — enforced in **any edition**. Walk it top to bottom:
  - attributes are typed values, declared once;
  - `email @key` — exactly one, unique, the identity;
  - **cardinality**: `phone @card(0..1)` (optionality is a schema fact), `relates item @card(1..)` (a transaction has at least one good), `relates buyer @card(1..1)`;
  - **inheritance**: `good @abstract`, `book sub good`, `electronic sub good` — `price` declared *once* on the supertype; a bare "good" can't exist because it's abstract.
- Contrast with the graph type slide: no re-declared `price`, no convention — the hierarchy is a schema object.

## Slide: "Inserting goods" (21:00–22:00)

- A `book` *is* a `good` by schema — there's no second label to remember, so there's nothing to forget. The entire class of "forgot the label" bugs doesn't exist.

## Slide: "Inserting a user and a transaction" (22:00–24:00)

- Insert user, then match-insert the transaction with roles: `(buyer: $u, item: $b)`.
- Note what the schema is silently checking here: buyer must be a `user`, item must be a `good`, at least one item, exactly one buyer, amount and date present.

# ARC 5 — TypeDB: type safety

## Slide: "The unhappy path, revisited" (24:00–24:30)

- The same three operations that silently misbehaved in Neo4j. Same keystrokes, different database.

## Slide: "1 · Inserting two email addresses" (24:30–26:00)

- Two queries on the slide: first insert the user with an email (the one from the happy path), then a **match-insert** adding a second email to that same user.
- The second query is **rejected at commit**: `email` is `@key` — exactly one. Verified live: `[DVL9] key constraint violation … of 'email'`.
- The invalid state *cannot be stored*, so no downstream code, report, or agent ever sees it. The error surfaces at the database boundary — not in next quarter's revenue report.

## Slide: "2 · Phone may be absent" — side by side vs Cypher (26:00–28:00)

- Left, TypeQL: there is no null. Optionality lives in the schema (`@card(0..1)`) and is **explicit in the query**: `try { $u has phone $p; }` — `$p` bound if present, absent otherwise. No propagation, no three-valued logic. A typo'd attribute name is a **type error**, not an empty column.
- Right, Cypher (same slide): the arc-3 queries again — missing phone and typo'd property both silently `null`; the no-phone user falls out of both `WHERE u.phone = …` *and* `WHERE NOT u.phone = …`.

## Slide: "3 · Just electronics, just books, all goods" (28:00–29:00)

- Narrow by subtype (`isa book`, `isa electronic`) or query the supertype (`isa good`) — polymorphic, one query, no UNION.
- The polymorphic result is **guaranteed complete**: every book and electronic is a good by schema. Add `furniture sub good` next sprint — this query already covers it.

## Slide: "price: declared once" — side by side vs Cypher (29:00–30:00)

- Left, TypeQL: `price` is declared exactly once, on abstract `good`; `book` and `electronic` inherit it.
- Right, the Neo4j graph type fragment: `price` re-declared on `Book` *and* `Electronic` — no abstract supertype, no shared attribute, and nothing stops the two declarations drifting apart (FLOAT here, INTEGER there).

## Slide: "The type system knows what each kind has" (30:00–31:00)

- Top query: fetch `warranty-expired-date` off a `good` → **type error before touching data** (verified: `[QUA4]` type-inference error) — `good` doesn't own it, only `electronic` does. Compare: Neo4j returns a column of nulls.
- Bottom query: narrow to `electronic` → both `price` (inherited) and `warranty-expired-date` are available. The schema tells you *and the query compiler* exactly what each kind has.

## Slide: "Type safety without verbosity: inference" (31:00–31:45)

- The classic objection to strict typing: verbosity — 2005-Java flashbacks. Type **inference** is the answer, in TypeQL as in modern languages.
- Left: the query with every variable explicitly typed. Right: the exact same query with `$u isa user` and `$g isa good` deleted — the schema already knows a `buyer` must be a user and an `item` must be a good, so the compiler infers them.
- Same answers, same type checking (both run verified against the server) — you only annotate where it adds meaning, the machine fills in the rest. Safety is not a tax paid in keystrokes.

# ARC 6 — The database landscape

## Slide: "Type safety of modern databases" (31:45–32:30)

- Zoom out from the two databases we've compared to the whole landscape. Two axes: type safety and verbosity.
- MongoDB top-left: schemaless, frictionless, zero guarantees. Neo4j, JanusGraph nearby; Amazon Neptune lower (verbose, still loose).
- TigerGraph and Stardog: typed-ish, but ceremonial. PostgreSQL bottom-right: enforced schema at the cost of DDL/JOIN ceremony — the classic trade.
- **TypeDB top-right**: enforced schema without SQL's ceremony — the same migration programming languages made (dynamic → typed-with-inference), one layer down. Strictness is a dial, not a binary — blog: *How strict should your schema be?*

# ARC 7 — Benefits

## Slide: "For developers" (32:30–33:15)

- **Easier to review**: a PR's queries and schema changes carry their contract with them — the reviewer reads the types instead of tracing the whole codebase.
- **Verify correctness by looking at the types**: if a query compiles against the schema, whole bug classes (wrong role, missing attribute, forgotten label, accidental list) are already ruled out — we watched each of them die in arcs 4–5.
- Plus: the error surfaces at commit time in dev, not in production three services downstream; validation lives in the one place every write passes through instead of drifting across N microservices.

## Slide: "For AI agents" (33:15–33:50)

- The division of labor: **the LLM generates the query, the database validates it**. The schema bounds what an agent can express; errors tell it when it's left the road.
- The stricter the type system, the more reliable the agent — a wrong Cypher query silently returns empty (the agent can't tell "no data" from "bad query"); a wrong TypeQL query fails loudly, so self-correction works.

## Slide: "The benchmark" (33:50–34:30)

- Blog #2: Reactome in MySQL/Neo4j/TypeDB, Claude Sonnet 5 + DeepSeek V4 Pro, 42 questions, 3,024 runs.
- Zero-shot, SQL and Cypher win on training data (~60% vs TypeQL's 25%). In-context docs close the gap. **With retries TypeQL comes out on top at 92%** — because its loud, precise errors are exactly the feedback a retry loop needs.
- Source: *Benchmarking LLM query generation across SQL, Cypher and TypeQL* (typedb.com/blog).

## Close (34:30–35:00)

- One line: we type-checked our code years ago — TypeDB type-checks the data. Thank you; Q&A.

---

## Logistics
- Arc badge top-right tracks the five arcs; TypeDB logo + brand styling from typedb.com.
- Serve the deck over http (`python3 -m http.server`) or rely on the `snippets.js` fallback for `file://`.
- Demos: `neo4j/` (Community 2025.09 + Enterprise 2026.09, one at a time, `NEO4J_DIST=…`), `typedb/` (3.14.1 folder distribution). Both `test.sh` suites verified green as documented in each folder's `queries.md`.
- Re-validate TypeQL after edits with `typeql-check`.
