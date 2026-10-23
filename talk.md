# Bringing Type Systems into the Graph World
### Target 35 min · current outline covers the opening four arcs (~17 min) — more to come as CLAUDE.md grows

**Running example:** `user` (email, address, optional phone) — `transaction` (user + goods; amount, payment-method, date) — `good` (price), either a `book` (isbn) or an `electronic` (warranty-expired-date)

---

# ARC 1 — A graph: nodes and edges

## 1. What a graph is (0:00–3:00)

- The purest model: **nodes** and **edges**. Dots and lines. That's the whole data model.
- On the slide: the ecommerce domain drawn in plain directed-graph notation — anonymous circles, arrows showing edge direction, nothing else.
- The power: relationships are first-class. No join tables, no foreign keys — the connection *is* the data.
- The poverty: a plain graph says nothing *about* the dots and lines. Which circle is the user? What does this edge mean?

# ARC 2 — Neo4j's property graph

## 2. What Neo4j adds on top (3:00–7:00)

Same picture, redrawn in property-graph notation (labels inside nodes, property maps beside them, typed directed edges). Neo4j's **labeled property graph** adds three things:

1. **Labels** on nodes: `:User`, `:Transaction`, multi-labels like `:Good:Book`.
2. **Key-value properties** on nodes and relationships: `{email: "...", amount: 12.99}`.
3. **Typed, directed relationships**: `(:Transaction)-[:BUYER]->(:User)`, `-[:CONTAINS]->`.

The picture now has names: you can ask "all users", "everything this transaction contains".

# ARC 3 — Ecommerce in Neo4j: the happy path

## 3. Building the shop (7:00–11:00)

**3a. Modeling the schema — graph types** (Cypher 25, Neo4j 2026.02+, Enterprise only):
```cypher
ALTER CURRENT GRAPH TYPE SET {
  (:User => {email :: STRING IS KEY,
             address :: STRING NOT NULL,
             phone :: STRING}),
  (:Book => :Good {price :: FLOAT NOT NULL, isbn :: STRING NOT NULL}),
  (:Electronic => :Good {price :: FLOAT NOT NULL,
                         warrantyExpiredDate :: DATE NOT NULL}),
  (:Transaction => {amount :: FLOAT NOT NULL,
                    paymentMethod :: STRING NOT NULL,
                    date :: DATE NOT NULL}),
  (:Transaction)-[:BUYER =>]->(:User),
  (:Transaction)-[:CONTAINS =>]->(:Good)
}
```
Neo4j's best effort, and genuinely a big step: typed properties, `NOT NULL`, keys, implied labels (`:Book => :Good`), relationship endpoints. Caveats to land verbally: Enterprise-only, brand new (2026.02), opt-in — and on Community the entire vocabulary is `CREATE CONSTRAINT … REQUIRE u.email IS UNIQUE`. Note `price` must be re-declared on each kind: no shared supertype attribute, no abstractness. Ref: https://neo4j.com/docs/cypher-manual/current/schema/

**3b. Inserting a user and a transaction:**
```cypher
CREATE (:User {email: "ganesh@typedb.com",
               address: "1 Example St, London",
               phone: "+44 20 7946 0000"});

MATCH (u:User {email: "ganesh@typedb.com"}),
      (b:Book {isbn: "978-0135957059"})
CREATE (u)<-[:BUYER]-(:Transaction {amount: 12.99,
        paymentMethod: "card", date: date("2026-10-23")})
       -[:CONTAINS]->(b);
```
Be fair to Neo4j here: the pattern syntax is genuinely nice to read and write.

**3c. Inserting goods:**
```cypher
CREATE (:Good:Book {price: 12.99, isbn: "978-0135957059"});
CREATE (:Good:Electronic {price: 299.0,
        warrantyExpiredDate: date("2028-10-23")});
```
Multi-labels stand in for "a book *is a* good" — by convention, not by rule. Hold that thought.

# ARC 4 — Ecommerce in Neo4j: the unhappy path

## 4. Same shop, three everyday operations (11:00–17:00)

Framing: these run on **Community edition** (like the local demo), where graph types don't exist — which is also every Neo4j below 2026.02. Where a graph type *would* catch the problem, say so and note the price of admission (Enterprise, opt-in).

**4a. Inserting a user with two email addresses:**
```cypher
// the domain says: a user has ONE email.
CREATE (:User {email: ["ganesh@typedb.com", "ganesh2@typedb.com"],
               address: "1 Example St, London"});
// commits — any property can silently become a list

// and the uniqueness constraint? it compares whole values,
// so a list containing an existing email ALSO commits:
CREATE (:User {email: ["ganesh@typedb.com"], address: "2 Example St, London"});
```
The uniqueness constraint doesn't even see it. A graph type's `email :: STRING` would catch this — but that's Enterprise 2026.02+; everywhere else the "schema" can't say *one email per user*.

**4b. Querying for all goods:**
```cypher
// six months ago, someone forgot a label:
CREATE (:Book {price: 8.0, isbn: "978-1593272821"});

// today, revenue report:
MATCH (g:Good) RETURN g;
// that book is not in the results. No error, no warning.
```
Multi-labels are convention: nothing makes a `:Book` a `:Good` (graph types' implied labels fix this — again Enterprise 2026.02+), so "all goods" is only as complete as everyone's memory.

**4c. Querying a user whose phone may be null:**
```cypher
MATCH (u:User) RETURN u.phone              // no phone → null; typo'd u.phoen → ALSO null
MATCH (u:User) WHERE u.phone = "..."       // null: row silently dropped
MATCH (u:User) WHERE NOT u.phone = "..."   // null: ALSO silently dropped
```
"Optional" is declared nowhere — absence and typo are indistinguishable; null propagates through three-valued logic. Bugs no tool warns about.

→ This is the cliffhanger the TypeDB arcs resolve.

---

## Speaker notes
- The deck shows a persistent arc badge (top-right) so listeners know which arc we're in.
- Deck is styled to typedb.com's brand: official logo (inline SVG, title slide + top-left corner), purple background `#1a182a`, green/red/blue accents (`#02dac9`/`#e96464`/`#7ba0ff`), Monaco for code. Their "Darkmode" webfont is licensed, so the deck falls back to Helvetica.
- All arc 3/4 Cypher is runnable against the local demo in `neo4j/` (auth disabled, `cypher-shell`); `neo4j/queries.md` has the full script — note it still uses the old domain (user has `name`, electronics with `warrantyMonths`) and should be refreshed before a live run.
- No TypeQL in the deck yet; when it returns, validate every snippet with `typeql-check`.
- Cypher semantics reference: https://neo4j.com/docs/cypher-manual/current/ (constraints, null behavior, list properties).
