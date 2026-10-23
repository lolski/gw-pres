// What the graph type STILL can't catch — commits on every edition.

// graph types are OPEN: undeclared relationship types are unconstrained.
// You can type BUYER's endpoints, but you cannot say
// "no connection of ANY type between User and Good".
MATCH (u:User {email: "ganesh@typedb.com"}), (b:Book)
CREATE (u)-[:LIKES]->(b);

// no cardinality: "a transaction has at least one good" and
// "exactly one buyer" are not expressible.
MATCH (u:User {email: "ganesh@typedb.com"})
CREATE (:Transaction {amount: 42.0, paymentMethod: "card",
        date: date("2026-10-23")})-[:BUYER]->(u);
