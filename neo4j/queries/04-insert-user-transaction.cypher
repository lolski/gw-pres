CREATE (:User {email: "ganesh@typedb.com",
               address: "1 Example St, London",
               phone: "+44 20 7946 0000"});

MATCH (u:User {email: "ganesh@typedb.com"}),
      (b:Book {isbn: "978-0135957059"})
CREATE (u)<-[:BUYER]-(:Transaction {amount: 12.99,
        date: date("2026-10-23")})
       -[:CONTAINS]->(b);
