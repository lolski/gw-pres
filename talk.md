# Bringing Type Systems into the Graph World
### 35 min · slides with code snippets · ecommerce examples throughout

**Running example:** `user` (email, name, address) — `transaction` (user + goods; amount, payment-method, date) — `good` (price)

---

## 1. Why do we keep moving to stricter types? (0:00–5:00) — 5 min

- Graph databases excel at representing complex connections — but raw nodes and edges offer virtually no structural enforcement. Property graphs add labels and key-value properties, yet still can't guarantee integrity at scale.
- Meanwhile, look at programming languages:
  - Python — dynamic by design — added type hints; now standard in serious codebases.
  - TypeScript overtook JavaScript. Nobody was forced; teams *chose* the stricter language.
- Why? Untyped is fine until the system gets big: then you want errors at compile time, tooling that understands your model, refactors that can't silently break callers.
- Quote Martin Fowler: *"schemaless structures still have an implicit schema"* — it lives in your app code, unenforced, duplicated in every service.
- **Thesis:** TypeDB brings type-system concepts — inheritance, cardinality, type inference — into the graph world. Strong structure, graph expressiveness.

## 2. Type safety benefits (5:00–11:00) — 6 min

**2a. For developers (2 min)**
- Schema = executable documentation of the domain.
- Errors move left: a modeling mistake fails at commit in dev, not in production three services downstream.
- Validation lives in the one place every write passes through — the database — instead of being re-implemented (and drifting) across N microservices.
- Strictness is a spectrum, not a toggle (blog #1): dial it up per use case without re-platforming.

**2b. For AI agents (4 min)** — blog #2 benchmark:
- Setup: Reactome dataset in MySQL, Neo4j, TypeDB; Claude Sonnet 5 + DeepSeek V4 Pro; 42 questions, 3,024 runs.
- Zero-shot: SQL ~60%, Cypher ~60%, TypeQL 25% (training-data volume wins).
- With in-context docs + examples: all converge to ~75–84%.
- **With retries: TypeQL hits 92% — best of all three.** The type system returns *real errors*; a wrong Cypher query silently returns empty, so the agent can't tell "no data" from "bad query". A wrong TypeQL query fails loudly → self-correction works.
- The same strictness that protects developers is what makes agents reliable.

## 3. Null-safety with optionals (11:00–16:00) — 5 min

**The rule we want:** not every user has an address (digital-only customers) — but absence must be explicit, never a silent `null`.

- Tony Hoare called null his "billion-dollar mistake." Languages fixed it with types: Rust's `Option<T>`, Kotlin's `String?`, Haskell's `Maybe`. TypeQL follows the same lineage: **there is no null in TypeDB.**
- Optionality is declared in the schema (`owns address @card(0..3)`) and handled explicitly in queries with `try`:

```typeql
match
  $u isa user, has name $n;
  try { $u has address $a; };   # $a bound if present, absent otherwise
```

- Functions are null-safe too — an optional return is part of the typed signature:

```typeql
define
fun shipping_address($u: user) -> address?:
  match $u has address $a;
  return first $a;
```

**Cypher:** a missing property silently returns `null`, and null propagates — `WHERE u.address = "..."` is neither true nor false, `WHERE NOT u.address = "..."` silently drops the row too. Three-valued logic bugs that no tool warns you about.

**The benefit:** absence is a type-level concept checked by the query compiler, not a sentinel value that leaks through your results and blows up in app code.

## 4. Cardinality: TypeQL vs Cypher (16:00–22:00) — 6 min

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

**Cypher / Neo4j — the closest you can get:**
```cypher
CREATE CONSTRAINT user_email FOR (u:User) REQUIRE u.email IS UNIQUE;
CREATE CONSTRAINT user_name  FOR (u:User) REQUIRE u.name IS NOT NULL;
// addresses "at most 3"?          — not expressible
// transaction has exactly 1 buyer? — not expressible
// transaction has ≥1 good?         — not expressible
```
Neo4j constraints cover property uniqueness/existence only. **There is no cardinality constraint on relationships at all** — a `(:Transaction)` with zero goods or two buyers commits happily; you police it in app code or a nightly audit query.

**The benefit, live on a slide:** insert a transaction with no good →
- Cypher: commits. Bug discovered whenever someone notices the revenue report is off.
- TypeQL: `commit` fails with a cardinality violation naming the relation and role.

## 5. Inheritance: TypeQL vs Cypher (22:00–28:00) — 6 min

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

**Cypher — inheritance by convention:**
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

## 6. Functions: extract the complicated query (28:00–32:00) — 4 min

Big queries rot. TypeQL lets you name them, type them, and reuse them — in the schema:

```typeql
define
fun total_spend($u: user) -> double:
  match
    $t isa transaction (buyer: $u);
    $t has amount $a;
  return sum($a);
```
```typeql
match
  $u isa user, has name $n;
  let $s = total_spend($u);
  $s > 1000;               # big spenders, one line
```
- Typed signature: takes a `user`, returns a `double` — the query compiler checks call sites, like a function in your codebase.
- Logic defined once in the schema; every service and every agent calls the same definition instead of pasting a subquery.
- Cypher's equivalent: copy-paste the subquery, or write a custom procedure in Java/APOC and deploy it to the server.

## 7. Close (32:00–35:00) — 3 min

- We type-checked our code (TypeScript, Python hints). TypeDB type-checks the data layer — the last untyped layer.
- Recap: no null to blow up in app code, cardinality the database enforces, inheritance that's real instead of label convention, functions instead of copy-paste — and agents that go from 25% to 92% because errors are loud.
- Sources: typedb.com/blog — *How strict should your schema be?* · *Benchmarking LLM query generation across SQL, Cypher and TypeQL*.
- Q&A.

---

## Speaker notes
- Timing checkpoint: be starting section 5 (inheritance) by minute 22, or compress its Cypher half.
- Every comparison slide: TypeQL left, Cypher right, same ecommerce example — the visual rhythm is the argument.
