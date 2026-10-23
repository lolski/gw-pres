// EXPECTED TO FAIL: exact scalar duplicate —
// the one error Neo4j Community can give us
CREATE (:User {email: "ganesh@typedb.com", address: "3 Example St"});
