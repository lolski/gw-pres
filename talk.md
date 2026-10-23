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

# ARC 3 — Ecommerce in Neo4j

## 3. Building the shop (7:00–11:00)

**3a. Modeling the schema — if such a thing exists:**
```cypher
CREATE CONSTRAINT user_email FOR (u:User) REQUIRE u.email IS UNIQUE;
// that's it — that's the whole schema.
// (property existence constraints: Enterprise-only)
```
Community edition can declare **uniqueness**; that's the entire vocabulary. Labels, properties, relationship endpoints — declared nowhere; the model lives in your head.

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

# ARC 4 — Can we model this in Neo4j?

## 4. Three modeling questions (11:00–17:00) — each gets a slide, each answer is "no"

**4a. A null-safe query for the user's optional phone?**
```cypher
MATCH (u:User) RETURN u.phone              // no phone → null; typo'd u.phoen → ALSO null
MATCH (u:User) WHERE u.phone = "..."       // null: row silently dropped
MATCH (u:User) WHERE NOT u.phone = "..."   // null: ALSO silently dropped
```
**No.** "Optional" is declared nowhere — every property is optional everywhere; absence and typo are indistinguishable; null propagates through three-valued logic. Bugs no tool warns about.

**4b. Cardinality — exactly 1 buyer, at least 1 good?**
```cypher
// a transaction with NO goods — commits
MATCH (u:User {email: "ganesh@typedb.com"})
CREATE (u)<-[:BUYER]-(:Transaction {amount: 42.0, paymentMethod: "card"});

// a transaction with TWO buyers — commits
MATCH (u:User {email: "ganesh@typedb.com"})
CREATE (v:User {email: "mallory@example.com"})
CREATE (u)<-[:BUYER]-(t:Transaction {amount: 7.0})
CREATE (v)<-[:BUYER]-(t);
```
**No.** No cardinality constraints on relationships in any edition. The rule lives in app code, a nightly audit query, or nowhere.

**4c. A good is either a book (isbn) or an electronic (warranty-expired-date)?**
```cypher
CREATE (:Good:Book {price: 5.0, warrantyExpiredDate: date("2028-01-01")});  // book with warranty — commits
CREATE (:Book {price: 8.0, isbn: "978-1593272821"});  // forgot :Good — invisible to MATCH (g:Good)
CREATE (:Good:User {email: "ghost@example.com", price: 1.0});  // both Good and User — commits
```
**No.** Labels carry no attributes and no rules: nothing ties `isbn` to books, nothing makes book-or-electronic exclusive, nothing makes either one a good.

→ This is the cliffhanger the TypeDB arcs resolve.

---

## Speaker notes
- The deck shows a persistent arc badge (top-right) so listeners know which arc we're in.
- Deck is styled to typedb.com's brand: official logo (inline SVG, title slide + top-left corner), purple background `#1a182a`, green/red/blue accents (`#02dac9`/`#e96464`/`#7ba0ff`), Monaco for code. Their "Darkmode" webfont is licensed, so the deck falls back to Helvetica.
- All arc 3/4 Cypher is runnable against the local demo in `neo4j/` (auth disabled, `cypher-shell`); `neo4j/queries.md` has the full script — note it still uses the old domain (user has `name`, electronics with `warrantyMonths`) and should be refreshed before a live run.
- No TypeQL in the deck yet; when it returns, validate every snippet with `typeql-check`.
