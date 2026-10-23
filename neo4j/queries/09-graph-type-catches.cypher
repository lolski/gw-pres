// Enterprise, graph type active (01): the forgotten-label bug from 07
// is now a write-time error instead of a silent revenue leak.
// EXPECTED TO FAIL on Enterprise (22NB3: Book must have the label Good).
// On Community it still commits silently.
CREATE (:Book {price: 8.0, isbn: "978-1593272821"});
