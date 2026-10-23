// the domain says: a user has ONE email.
CREATE (:User {email: ["ganesh@typedb.com", "ganesh2@typedb.com"],
               address: "1 Example St, London"});
// commits — any property can silently become a list

// and the uniqueness constraint? it compares whole values,
// so a list containing an existing email ALSO commits:
CREATE (:User {email: ["ganesh@typedb.com"],
               address: "2 Example St, London"});
