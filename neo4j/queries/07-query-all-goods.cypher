// six months ago, someone forgot a label:
CREATE (:Book {price: 8.0, isbn: "978-1593272821"});

// today, revenue report:
MATCH (g:Good) RETURN g;
// the bare :Book is not in the results. No error, no warning —
// it just quietly doesn't count.
