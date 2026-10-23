# Bringing Type Systems into the Graph World
### 35 min · five arcs: property graphs → Neo4j happy/unhappy → TypeDB happy/type-safe

**Running example:** `user` (email, address, optional phone) — `transaction` (user + goods; amount, date) — `good` (price), either a `book` (isbn) or an `electronic` (warranty-expired-date)

**All snippets live in files** — `neo4j/queries/*.cypher` and `typedb/queries/*.tql` — fetched into the deck at render time and testable (`neo4j/test.sh` against real Community/Enterprise instances, `typedb/test.sh` via `typeql-check`). Edit the file, both update.

---

# ARC 1 — Neo4j and the property graph

## 1. From dots-and-lines to a property graph (0:00–5:00)

- Plain directed graph (figure, graph notation): nodes, directed edges, nothing else. Relationships are first-class — no join tables — but the graph says nothing *about* the nodes and edges.
- Same picture in property-graph notation (figure): Neo4j adds **labels** (`:User`, multi-label `:Good:Book`), **key-value properties**, **typed directed relationships** (`:BUYER`, `:CONTAINS`).
- Now the picture has names: "all users", "everything this transaction contains".

# ARC 2 — Ecommerce in Neo4j: the happy path

## 2. Building the shop (5:00–10:00)

- **Schema with graph types** (`01-schema-graph-type.cypher`) — Neo4j's best effort and genuinely a big step: typed properties, `NOT NULL`, `IS KEY`, implied labels (`:Book => :Good`), relationship endpoints. Land verbally: Cypher 25, **Enterprise only** (GA 2026.06); on Community the entire vocabulary is one uniqueness constraint (`02`). Note `price` re-declared per kind — no shared supertype attribute, no abstractness.
- **Inserting goods** (`03`), **user + transaction** (`04`). Be fair: Cypher's pattern syntax is genuinely pleasant.

# ARC 3 — Ecommerce in Neo4j: the unhappy path

## 3. Same shop, three everyday operations (10:00–17:00)

Framed on **Community** (like the local demo — and any pre-2026 install): see `neo4j/queries.md` for the verified per-edition outcome table.

- **Two email addresses** (`05`): a list-valued `email` commits; a list wrapping an existing email slips past the uniqueness constraint. (Graph type would catch it — Enterprise price of admission.)
- **Querying all goods** (`07`): the `:Book` that forgot `:Good` is silently missing from the revenue report. (Implied labels fix this — again Enterprise.)
- **Phone may be null** (`08`): absence and typo both yield `null`; `WHERE u.phone = …` and `WHERE NOT u.phone = …` both drop the no-phone user — three-valued logic.
- If asked about Enterprise: `09`/`10` show the graph type catching the first two, and what *still* slips through even there — open rel types, no cardinality (a goods-less transaction commits). That's the segue.

# ARC 4 — Ecommerce in TypeDB: the happy path

## 4. The same shop, typed (17:00–24:00)

- **Schema** (`typedb/queries/01-schema.tql`) — the whole domain, enforced in any edition: attributes with value types, `@key` email, **cardinality** (`@card(0..1)` phone, `@card(1..)` items per transaction, exactly one buyer), **inheritance** (`good @abstract`, `book sub good`, `electronic sub good` — `price` declared once on the supertype).
- **Inserting goods** (`02`): a book *is* a good by schema — no label to remember.
- **Inserting user + transaction** (`03`, `04`).

# ARC 5 — TypeDB: type safety

## 5. The unhappy path, revisited (24:00–32:00)

The same operations that silently misbehaved in Neo4j:

- **Two emails** (`05`): **rejected at commit** — `email` is `@key`, exactly one. The invalid state can't be stored; no downstream code ever sees it.
- **Phone may be absent** (`06`): no null exists. Optionality is in the schema (`@card(0..1)`) and explicit in the query (`try { $u has phone $p; }`) — `$p` bound if present, absent otherwise. A typo'd attribute name is a type error, not an empty column.
- **Just electronics, just books, all goods** (`07`–`09`): narrow by subtype or query the supertype — the polymorphic `$g isa good` is **guaranteed complete**; "forgot the label" cannot exist.

Wrap (32:00–35:00): same graph-shaped data, but the contract lives in the database. Blogs to cite: *How strict should your schema be?* · *Benchmarking LLM query generation…* (typedb.com/blog). Q&A.

---

## Speaker notes
- Arc badge top-right tracks the five arcs; TypeDB logo top-left (brand styling from typedb.com).
- Demos: `neo4j/` has Community 2025.09 **and** Enterprise 2026.09 (run one at a time; `NEO4J_DIST=… ./test.sh`). `typedb/test.sh` runs all 9 TypeQL files against a **real TypeDB server** (`typedb server`, brew) — verified: all pass, with `05` failing at commit by design (`[DVL9]` email key violation). Outcome table in `typedb/queries.md`.
- The deck fetches snippets over HTTP — serve locally with `python3 -m http.server` (file:// won't load them).
- Neo4j schema docs: https://neo4j.com/docs/cypher-manual/current/schema/
