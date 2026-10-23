# Neo4j e-commerce demo

Domain (see ../CLAUDE.md): `user` (email, name, address) — `transaction` (amount, payment-method, date; one buyer, ≥1 good) — `good` (price), with `book` (+isbn) and `electronics` (+warranty-months) as kinds of good.

## Run

```sh
# disable auth for the demo, then start
echo "dbms.security.auth_enabled=false" >> neo4j-community-2025.09.0/conf/neo4j.conf
./neo4j-community-2025.09.0/bin/neo4j console
# in another terminal:
./neo4j-community-2025.09.0/bin/cypher-shell
```

## 1. Schema

This is everything Neo4j can enforce about this domain. Community edition supports **uniqueness only**; `IS NOT NULL` existence constraints need Enterprise.

```cypher
CREATE CONSTRAINT user_email FOR (u:User) REQUIRE u.email IS UNIQUE;
```

Not expressible in any edition:

```cypher
// user has exactly 1 name            — Enterprise-only (IS NOT NULL)
// user has at most 3 addresses       — not expressible
// transaction has exactly 1 buyer    — not expressible
// transaction has at least 1 good    — not expressible
// good/book/electronics hierarchy    — not expressible (multi-label = hope)
// book has isbn, electronics has
//   warranty-months, and not vice
//   versa                            — not expressible
```

## 2. Valid inserts

```cypher
// a user
CREATE (:User {email: "ganesh@typedb.com", name: "Ganesh",
               address: "1 Example St, London"});

// a book (multi-label stands in for inheritance)
CREATE (:Good:Book {price: 12.99, isbn: "978-0135957059"});

// an electronics
CREATE (:Good:Electronics {price: 299.0, warrantyMonths: 24});

// a transaction: buyer + one good
MATCH (u:User {email: "ganesh@typedb.com"}),
      (b:Book {isbn: "978-0135957059"})
CREATE (u)<-[:BUYER]-(t:Transaction {amount: 12.99,
        paymentMethod: "card", date: date("2026-10-23")})
       -[:CONTAINS]->(b);
```

## 3. Inserts that violate the domain — Neo4j accepts them all

Only the email-uniqueness violation fails. Everything else commits silently.

```cypher
// transaction with NO goods — commits; revenue report is now wrong
MATCH (u:User {email: "ganesh@typedb.com"})
CREATE (u)<-[:BUYER]-(:Transaction {amount: 42.0, paymentMethod: "card"});

// transaction with TWO buyers — commits
MATCH (u:User {email: "ganesh@typedb.com"})
CREATE (v:User {email: "mallory@example.com", name: "Mallory"})
CREATE (u)<-[:BUYER]-(t:Transaction {amount: 7.0, paymentMethod: "cash"})
CREATE (v)<-[:BUYER]-(t);

// user with no name — commits (existence is Enterprise-only)
CREATE (:User {email: "noname@example.com"});

// user with 4 addresses — commits
CREATE (:User {email: "hoarder@example.com", name: "Ada",
               address: ["a", "b", "c", "d"]});

// a book with a warranty and no isbn — commits; labels carry no attributes
CREATE (:Good:Book {price: 5.0, warrantyMonths: 12});

// a good without a price — commits
CREATE (:Good {});

// a bare :Book that forgot the :Good label — commits,
// and silently disappears from every  MATCH (g:Good)  query
CREATE (:Book {price: 8.0, isbn: "978-1593272821"});

// a node that is both a Good and a User — commits
CREATE (:Good:User {email: "ghost@example.com", price: 1.0});

// the ONLY one that fails: duplicate email
CREATE (:User {email: "ganesh@typedb.com", name: "Impostor"});
```
